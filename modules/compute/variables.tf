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

variable "block_volumes" {
  description = "Data disks to import. Map keys are stable disk names; each value supplies a read PAR URL and optional volume overrides."
  type = map(object({
    par_url      = string
    display_name = optional(string)
    size_in_gbs  = optional(number)
  }))
  default = {}

  validation {
    condition     = alltrue([for volume in values(var.block_volumes) : try(volume.size_in_gbs == null || volume.size_in_gbs > 0, true)])
    error_message = "When set, each block_volumes size_in_gbs value must be greater than zero."
  }
}

variable "block_volume_par_urls" {
  description = "Deprecated compatibility input. Prefer block_volumes, a map with stable names and optional capacity overrides."
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
