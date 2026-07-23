# Deploy a multi-volume OVA with OCI Resource Manager

This is an OCI Resource Manager (RM) stack, in the same deployment model used
by OpenShift on OCI. Terraform is the stack definition; RM is the
customer-facing service that presents the form, stores state, runs the plan
and apply jobs, and records their logs.

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/vdeolali/oci-multivolume-image-import/archive/refs/heads/main.zip)

## Customer deployment

1. Obtain the vendor OVA. An OVA is a TAR archive containing an OVF manifest
   and VMDK files. This deployment uses `disk1` as the boot disk and imports
   every remaining VMDK as an OCI block volume.
2. On a Mac or Linux workstation with the OCI CLI, `tar`, `shasum`, and `jq`,
   run the preparation helper once. It validates the OVA manifest, uploads the
   VMDKs to your Object Storage bucket, creates short-lived read-only PARs,
   and writes a pre-populated Resource Manager launch URL.

   ```bash
   ./scripts/prepare_ova.sh \
     --ova /path/to/multiVolumeUbuntu.ova \
     --output ./prepared-ova \
     --upload \
     --bucket customer-imports \
     --compartment-id ocid1.compartment.oc1..example \
     --profile DEFAULT
   ```

3. Open `prepared-ova/deploy-to-oci-url.txt` in a browser. It opens **Create
   Stack** with the boot and data-disk PAR variables already filled in.
4. Select the target compartment, network, availability domain, compute shape,
   and SSH public key. Review the disk PARs, then leave **Run apply** selected
   and click **Create**. Resource Manager runs Terraform in OCI; the customer
   does not install or run Terraform locally.
5. Follow the RM job logs until the image imports, instance launch, and volume
   attachments complete.

For a versioned offline handoff, build the same minimal RM package and upload
it on the **Create Stack** page, exactly as the OpenShift installation flow
uploads its Terraform stack ZIP:

```bash
./scripts/build_rm_package.sh --output ./catalyst-center-multivolume-stack.zip
```

`schema.yaml` supplies the guided RM form and OCI pickers for compartment,
VCN, subnet, availability domain, shape, SSH key, and KMS key. The repository
contains no customer credentials or generated PAR URLs.

## What the stack creates

1. A custom image from the boot VMDK PAR.
2. A custom image and a block volume for each data VMDK PAR.
3. One compute instance from the boot image.
4. Attachments for the imported data volumes.

## Important prerequisites and limits

- The customer needs IAM permission for Resource Manager stacks/jobs plus
  Compute Images, Compute Instances, Block Volumes, and Object Storage in the
  selected compartment.
- The guest must boot successfully when the data disks are temporarily absent.
  Use stable filesystem labels or UUIDs in `/etc/fstab` and add `nofail` where
  appropriate.
- The helper infers the boot disk from a filename containing `disk1`. Verify
  the displayed disk choice if the vendor uses another convention.
- PARs are credentials. They expire after seven days by default; keep the
  generated files private and recreate the stack inputs if they expire.
- The uploaded VMDKs and intermediate custom images are retained after a
  successful apply. Keep them for recovery or remove them through normal OCI
  lifecycle controls after validation.

## Local Terraform is optional

The same configuration can still be run with local Terraform for development,
but this is not the customer path. Supply OCI API credentials and use an
environment tfvars file only for that workflow. Resource Manager uses its own
workload identity; do not enter private keys or API credentials in the RM
variables page.
