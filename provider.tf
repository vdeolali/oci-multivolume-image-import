# This file configures the OCI provider for the root module.
# Resource Manager supplies its own workload identity. The optional credential
# variables are retained only for customers who run the same configuration
# locally with Terraform.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci" # Explicitly use the Oracle-maintained provider
      version = "~> 8.0"     # Keep current OCI provider compatibility within v8.
    }
  }
}

provider "oci" { # This is the default 'oci' provider
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  private_key_path = var.oci_private_key_path
  fingerprint      = var.oci_fingerprint
  region           = coalesce(var.region, var.oci_region)
}
