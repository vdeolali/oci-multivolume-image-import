# This file defines the root module configuration.
# It calls the 'compute' module to deploy the OCI instance and volumes.

module "compute" {
  source = "./modules/compute" # Path to your compute module

  # REMOVED: No 'providers' block needed here if the child module correctly requests the default 'oci' provider

  compartment_ocid         = var.compartment_ocid
  availability_domain_name = var.availability_domain_name
  vcn_ocid                 = var.vcn_ocid
  subnet_ocid              = var.subnet_ocid
  instance_shape           = var.instance_shape
  instance_display_name    = "${var.instance_display_name_prefix}-${var.environment_name}"
  ssh_public_key           = var.ssh_public_key
  boot_volume_par_url      = var.boot_volume_par_url
  block_volume_par_urls    = var.block_volume_par_urls
}