# This file contains the resource definitions for creating an OCI compute instance
# and associated volumes within the 'compute' module.

# NEW: Explicitly declare required_providers for the module itself
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# 2. Download PARs (by importing them as OCI images/volumes)

# Import the boot volume image from its PAR URL into a custom OCI image
resource "oci_core_image" "boot_image" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name}-boot-image"

  image_source_details {
    source_uri  = var.boot_volume_par_url
    source_type = "objectStorageUri"
  }

  lifecycle {
    ignore_changes = [] # Removed unconfigurable attributes
  }
}

# Create a non-sensitive map for iterating over block volume PARs
locals {
  block_volume_inputs = {
    for url in var.block_volume_par_urls :
    replace(
      lower(
        split("/", url)[length(split("/", url)) - 1]
      ),
      ".", "-"
    ) => url
  }
}

# Create custom images for each block volume from their respective PAR URLs.
resource "oci_core_image" "block_volume_images" {
  for_each       = local.block_volume_inputs
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name}-${each.key}-image"

  image_source_details {
    source_uri  = each.value
    source_type = "objectStorageUri"
  }

  lifecycle {
    ignore_changes = [] # Removed unconfigurable attributes
  }
}

# Create block volumes from the imported custom images
resource "oci_core_volume" "block_volumes" {
  for_each            = oci_core_image.block_volume_images
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain_name
  display_name        = "${var.instance_display_name}-${each.key}-volume"
  size_in_gbs         = 100

  source_details {
    type = "image"
    id   = each.value.id
  }
}

# 3. Start an instance using the boot volume
resource "oci_core_instance" "main_instance" {
  compartment_id        = var.compartment_ocid
  availability_domain   = var.availability_domain_name
  display_name          = var.instance_display_name
  shape                 = var.instance_shape

  create_vnic_details {
    subnet_id              = var.subnet_ocid
    assign_public_ip       = true
    display_name           = "${var.instance_display_name}-vnic"
    hostname_label         = "${replace(lower(var.instance_display_name), "/[^a-z0-9-]/", "")}"
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_image.boot_image.id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# 4. Mount the other downloaded volumes as block volume attachments of the instance
resource "oci_core_volume_attachment" "block_volume_attachments" {
  for_each        = oci_core_volume.block_volumes
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.main_instance.id
  volume_id       = each.value.id
  display_name    = "${var.instance_display_name}-${each.key}-attachment"
}