# This file declares all input variables for the root module.

# OCI Provider Credentials (used by provider.tf)
variable "oci_tenancy_ocid" {
  description = "The OCID of your OCI tenancy."
  type        = string
  sensitive   = true
}

variable "oci_user_ocid" {
  description = "The OCID of the OCI user to authenticate with."
  type        = string
  sensitive   = true
}

variable "oci_private_key_path" {
  description = "The path to the OCI API private key file."
  type        = string
  sensitive   = true
}

variable "oci_fingerprint" {
  description = "The fingerprint of the OCI API private key."
  type        = string
  sensitive   = true
}

variable "oci_region" {
  description = "The OCI region to deploy resources in (e.g., 'us-ashburn-1')."
  type        = string
}

# Environment-specific variable to help differentiate resources
variable "environment_name" {
  description = "The name of the current environment (e.g., 'dev', 'prod')."
  type        = string
}

# Common variables that will be passed to the compute module
variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "availability_domain_name" {
  description = "The name of the availability domain for the instance and volumes."
  type        = string
}

variable "vcn_ocid" {
  description = "The OCID of the VCN for the instance."
  type        = string
}

variable "subnet_ocid" {
  description = "The OCID of the subnet for the instance."
  type        = string
}

variable "instance_shape" {
  description = "The shape of the OCI instance (e.g., 'VM.Standard.E3.Flex')."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_display_name_prefix" {
  description = "Prefix for the display name of the OCI instance. Environment suffix will be added."
  type        = string
  default     = "par-instance"
}

variable "ssh_public_key" {
  description = "Your SSH public key for accessing the instance (e.g., 'ssh-rsa AAAAB3NzaC...')."
  type        = string
  sensitive   = true
}

variable "boot_volume_par_url" {
  description = "The PAR URL for the boot volume image file in the vendor's object storage."
  type        = string
  #sensitive   = true
}

variable "block_volume_par_urls" {
  description = "A list of PAR URLs for block volume image/data files in the vendor's object storage (4-10 PARs)."
  type        = list(string)
  default     = []
  # sensitive = true # This attribute is REMOVED per user's request.
}