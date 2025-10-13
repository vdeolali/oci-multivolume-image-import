# OCI Provider Credentials (DEV)
oci_tenancy_ocid     = "..."
oci_user_ocid        = "..."
oci_private_key_path = "/Users/vdeolali/.oci/api_key.pem"
oci_fingerprint      = "e3:76:5c:91:6f:xx:xx:xx:ss:ed:75:89:23:14:ff:80:df"
oci_region           = "us-phoenix-1" # Your DEV region

# Environment-specific metadata
environment_name = "dev"

# DEV Specific Resource OCIDs and PARs
compartment_ocid       = "ocid1.compartment.oc1..xxx"
availability_domain_name = "yTes:PHX-AD-1" # Replace with your DEV AD name
vcn_ocid               = "ocid1.vcn.oc1.phx."
subnet_ocid            = "ocid1.subnet.oc1."
ssh_public_key         = "add your key"
#boot_volume_par_url    = "https://objectstorage.ap-mumbai-1.oraclecloud.com/p/e3Z8m1pc-tqFRmM_k4tqX9l4kIpb4o8yHhSJytbaMNeuZZGPAL4X2KVVYXozS4yV/n/bm1c3etnhmwx/b/bucket-001/o/biosUbuntugrublablnofail-1.vmdk"
boot_volume_par_url    = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/xaK2CDPaLET8ROYtT2b1yLyl8qT5hL4WhuPl-QAvzbZyAJcrRMI4Vw0Kx1v1L3Th/n/sanjpill_sandbox/b/DisableSMT/o/csco_biosU-2.qcow2"
#block_volume_par_urls  = [
#  "https://objectstorage.ap-mumbai-1.oraclecloud.com/p/9CtG2TKQff3kjgFjastda-WReSiSrULmUF0oxP_J9sezka9C_UKFiORmkHcGup5T/n/bm1c3etnhmwx/b/bucket-001/o/biosUbuntugrublablnofail-2.vmdk",
#  "https://objectstorage.ap-mumbai-1.oraclecloud.com/p/RTuZ3P9Qsxs2-Eef9QlQETVFkFvZz5gw3fJSN6cH602pv1jfio4LJnQodlL-j6i5/n/bm1c3etnhmwx/b/bucket-001/o/biosUbuntugrublablnofail-3.vmdk"
#  # Add more DEV block volume PAR URLs here, if required. 
#]
block_volume_par_urls = [
  "https://objectstorage.us-phoenix-1.oraclecloud.com/p/KLFKRavOIyn7KdqafOg5GeiquxT_DLjr88scdB7s0zt4izNZbm_KHiTejcUL51Li/n/sanjpill_sandbox/b/DisableSMT/o/csco_biosUbuntuwithoutISO-disk2.vmdk",
  "https://objectstorage.us-phoenix-1.oraclecloud.com/p/MUajZN5AiSG6w2XfJwLpeK6EkmW3TvCqhrVqrguQDa-MfiAQcflefpgqMfpPGCpT/n/sanjpill_sandbox/b/DisableSMT/o/csco_biosUbuntuwithoutISO-disk3.vmdk"
]
instance_display_name_prefix = "dev-catalyst-center" # Prefix for dev instance names
instance_shape         = "VM.Standard.E4.Flex" # Can be a smaller shape for dev
