# This file defines the output values exposed by the 'compute' module.

output "instance_public_ip" {
  description = "The public IP address of the created instance."
  value       = oci_core_instance.main_instance.public_ip
}

output "instance_id" {
  description = "The OCID of the created instance."
  value       = oci_core_instance.main_instance.id
}

output "boot_image_id" {
  description = "The OCID of the imported boot image."
  value       = oci_core_image.boot_image.id
}

output "block_volume_ids" {
  description = "A map of image keys to OCIDs for the created block volumes."
  value       = { for k, v in oci_core_volume.block_volumes : k => v.id }
}

output "block_volume_image_ids" {
  description = "A map of image keys to OCIDs for the created block volume images."
  value       = { for k, v in oci_core_image.block_volume_images : k => v.id }
}

output "block_volume_attachment_ids" {
  description = "A map of data-volume keys to attachment OCIDs."
  value       = { for k, v in oci_core_volume_attachment.block_volume_attachments : k => v.id }
}
