# This file declares all input variables for the root module.

# OCI Provider Credentials (used by provider.tf)
variable "oci_tenancy_ocid" {
  description = "Local Terraform only: OCI tenancy OCID. Leave unset for Resource Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "oci_user_ocid" {
  description = "Local Terraform only: OCI user OCID. Leave unset for Resource Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "oci_private_key_path" {
  description = "Local Terraform only: path to the OCI API private key. Leave unset for Resource Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "oci_fingerprint" {
  description = "Local Terraform only: OCI API key fingerprint. Leave unset for Resource Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "oci_region" {
  description = "Deprecated local Terraform region input. Prefer region."
  type        = string
  default     = null
}

variable "region" {
  description = "OCI region where Resource Manager runs the stack."
  type        = string
  default     = null
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

variable "block_volumes" {
  description = "Data disks to import. Map keys are stable disk names; values contain a read PAR URL and optional overrides."
  type = map(object({
    par_url      = string
    display_name = optional(string)
    size_in_gbs  = optional(number)
  }))
  default = {}
}

variable "block_volume_par_urls" {
  description = "Deprecated compatibility input. Prefer block_volumes."
  type        = list(string)
  default     = []
}

variable "data_volume_attachment_type" {
  description = "OCI attachment type for imported data volumes."
  type        = string
  default     = "paravirtualized"

  validation {
    condition     = contains(["paravirtualized", "iscsi"], var.data_volume_attachment_type)
    error_message = "data_volume_attachment_type must be paravirtualized or iscsi."
  }
}

variable "volume_vpus_per_gb" {
  description = "VPUs per GB for imported data volumes."
  type        = number
  default     = 10

  validation {
    condition     = var.volume_vpus_per_gb > 0
    error_message = "volume_vpus_per_gb must be greater than zero."
  }
}

variable "volume_kms_key_id" {
  description = "Optional KMS key OCID used to encrypt imported data volumes."
  type        = string
  default     = null
}
