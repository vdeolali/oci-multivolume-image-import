# OCI Provider Credentials (PROD)
oci_tenancy_ocid     = "ocid1.tenancy.oc1..aaaa...your_prod_tenancy_ocid"
oci_user_ocid        = "ocid1.user.oc1..aaaa...your_prod_user_ocid"
oci_private_key_path = "/absolute/path/to/your/prod_oci_api_key.pem" # Ensure absolute path for PROD
oci_fingerprint      = "yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy" # Your PROD API key fingerprint
oci_region           = "us-ashburn-1" # Your PROD region

# Environment-specific metadata
environment_name = "prod"

# PROD Specific Resource OCIDs and PARs
compartment_ocid       = "ocid1.compartment.oc1..aaaa...your_prod_compartment_ocid"
availability_domain_name = "Uocm:PHX-AD-2" # Replace with your PROD AD name (could be different from dev)
vcn_ocid               = "ocid1.vcn.oc1..aaaa...your_prod_vcn_ocid"
subnet_ocid            = "ocid1.subnet.oc1..aaaa...your_prod_subnet_ocid"
ssh_public_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDF/..." # Your PROD SSH public key
boot_volume_par_url    = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/ProdBootPARToken/n/YourNamespace/b/VendorBucket/o/prod-boot-image.qcow2" # PROD boot PAR
block_volume_par_urls  = [
  "https://objectstorage.us-ashburn-1.oraclecloud.com/p/ProdBlockPAR1/n/YourNamespace/b/VendorBucket/o/prod-block-data-1.qcow2",
  "https://objectstorage.us-ashburn-1.oraclecloud.com/p/ProdBlockPAR2/n/YourNamespace/b/VendorBucket/o/prod-block-data-2.qcow2",
  "https://objectstorage.us-ashburn-1.oraclecloud.com/p/ProdBlockPAR3/n/YourNamespace/b/VendorBucket/o/prod-block-data-3.qcow2",
  # Add more PROD block volume PAR URLs here
]
instance_display_name_prefix = "prod-app-server" # Prefix for prod instance names
instance_shape         = "VM.Standard.E4.Flex" # Can be a larger shape for prod
