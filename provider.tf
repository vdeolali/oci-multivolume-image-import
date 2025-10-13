# This file configures the OCI provider for the root module.
# OCI credentials are read from variables declared in variables.tf.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci" # Explicitly use the Oracle-maintained provider
      version = "~> 5.0"     # Specify a compatible version range, e.g., "5.47.0"
    }
  }
}

provider "oci" { # This is the default 'oci' provider
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  private_key_path = var.oci_private_key_path
  fingerprint      = var.oci_fingerprint
  region           = var.oci_region
}