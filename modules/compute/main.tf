# This file contains the resource definitions for creating an OCI compute instance
# and associated volumes within the 'compute' module.

# NEW: Explicitly declare required_providers for the module itself
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
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

# Keep stable, user-chosen names for every data disk. The legacy list is kept
# temporarily so existing configurations remain usable.
locals {
  legacy_block_volumes = {
    for index, par_url in var.block_volume_par_urls :
    format("data-%02d", index + 1) => {
      par_url      = par_url
      display_name = null
      size_in_gbs  = null
    }
  }

  block_volumes = merge(local.legacy_block_volumes, var.block_volumes)
}

# Create custom images for each block volume from their respective PAR URLs.
resource "oci_core_image" "block_volume_images" {
  for_each       = local.block_volumes
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name}-${each.key}-image"

  image_source_details {
    source_uri  = each.value.par_url
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
  display_name = coalesce(
    try(local.block_volumes[each.key].display_name, null),
    "${var.instance_display_name}-${each.key}-volume",
  )
  size_in_gbs = tostring(coalesce(
    try(local.block_volumes[each.key].size_in_gbs, null),
    ceil(tonumber(each.value.size_in_mbs) / 1024),
  ))
  vpus_per_gb = tostring(var.volume_vpus_per_gb)
  kms_key_id  = var.volume_kms_key_id

  source_details {
    type = "image"
    id   = each.value.id
  }
}

# 3. Start an instance using the boot volume
resource "oci_core_instance" "main_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain_name
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "${var.instance_display_name}-vnic"
    hostname_label   = replace(lower(var.instance_display_name), "/[^a-z0-9-]/", "")
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
  attachment_type = var.data_volume_attachment_type
  instance_id     = oci_core_instance.main_instance.id
  volume_id       = each.value.id
  display_name    = "${var.instance_display_name}-${each.key}-attachment"
  is_read_only    = false
  is_shareable    = false
}
