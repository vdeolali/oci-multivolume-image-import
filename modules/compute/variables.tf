# This file declares input variables for the 'compute' module.

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
  description = "The shape of the OCI instance."
  type        = string
}

variable "instance_display_name" {
  description = "Display name for the OCI instance."
  type        = string
}

variable "ssh_public_key" {
  description = "Your SSH public key for accessing the instance."
  type        = string
  sensitive   = true
}

variable "boot_volume_par_url" {
  description = "The PAR URL for the boot volume image file in the vendor's object storage."
  type        = string
  sensitive   = true
}

variable "block_volume_par_urls" {
  description = "A list of PAR URLs for block volume image/data files in the vendor's object storage."
  type        = list(string)
  default     = []
  # sensitive = true # This attribute is REMOVED per user's request.
}

# block_volume_count is removed from module variables