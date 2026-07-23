# This file defines the output values exposed by the root module.

output "instance_public_ip" {
  description = "The public IP address of the created instance."
  value       = module.compute.instance_public_ip
}

output "instance_id" {
  description = "The OCID of the created instance."
  value       = module.compute.instance_id
}

output "boot_image_id" {
  description = "The OCID of the imported boot image."
  value       = module.compute.boot_image_id
}

output "block_volume_ids" {
  description = "A map of display names to OCIDs for the created block volumes."
  value       = module.compute.block_volume_ids
}

output "block_volume_image_ids" {
  description = "A map of image keys to OCIDs for the created block volume images."
  value       = module.compute.block_volume_image_ids
}

output "block_volume_attachment_ids" {
  description = "A map of data-volume keys to attachment OCIDs."
  value       = module.compute.block_volume_attachment_ids
}
