#!/usr/bin/env bash
# Extract a multi-disk OVA, verify its manifest, upload its VMDKs, and produce
# Terraform inputs containing short-lived Object Storage read PARs.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  prepare_ova.sh --ova FILE --output DIRECTORY
                 [--upload --bucket NAME --compartment-id OCID]
                 [--profile OCI_PROFILE] [--region OCI_REGION]
                 [--expires-at RFC3339_TIMESTAMP] [--rm-zip-url URL]

Without --upload, the script extracts and validates the OVA only.
With --upload, it uploads the boot VMDK and every data VMDK to Object Storage,
creates read-only PARs, and writes customer.auto.tfvars to the output directory.
It also writes Resource Manager variable JSON and a Deploy-to-OCI launch URL.

The boot disk is inferred from a filename containing "disk1". If that convention
does not apply, inspect the extracted VMDKs and rename them before using --upload.
EOF
}

ova=""
output_dir=""
upload=false
bucket=""
compartment_id=""
profile="DEFAULT"
region=""
expires_at=""
rm_zip_url="https://github.com/vdeolali/oci-multivolume-image-import/archive/refs/heads/main.zip"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ova) ova="$2"; shift 2 ;;
    --output) output_dir="$2"; shift 2 ;;
    --upload) upload=true; shift ;;
    --bucket) bucket="$2"; shift 2 ;;
    --compartment-id) compartment_id="$2"; shift 2 ;;
    --profile) profile="$2"; shift 2 ;;
    --region) region="$2"; shift 2 ;;
    --expires-at) expires_at="$2"; shift 2 ;;
    --rm-zip-url) rm_zip_url="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "$ova" ]] || { echo "OVA file not found: $ova" >&2; exit 2; }
[[ -n "$output_dir" ]] || { usage >&2; exit 2; }

if $upload; then
  [[ -n "$bucket" && -n "$compartment_id" ]] || {
    echo "--bucket and --compartment-id are required with --upload." >&2
    exit 2
  }
  command -v oci >/dev/null || { echo "OCI CLI is required for --upload." >&2; exit 2; }
  command -v jq >/dev/null || { echo "jq is required for --upload." >&2; exit 2; }
fi

mkdir -p "$output_dir"
extract_dir="$output_dir/extracted"
mkdir -p "$extract_dir"

echo "Validating archive: $ova"
tar -tf "$ova" >/dev/null
echo "Extracting OVA to: $extract_dir"
tar -xf "$ova" -C "$extract_dir"

manifest=$(find "$extract_dir" -type f -name '*.mf' -print -quit)
if [[ -n "$manifest" ]]; then
  echo "Verifying SHA-256 entries in $(basename "$manifest")"
  while IFS= read -r entry; do
    [[ "$entry" =~ ^SHA256\((.*)\)=\ ([0-9a-fA-F]{64})$ ]] || continue
    member="${BASH_REMATCH[1]}"
    expected="${BASH_REMATCH[2],,}"
    member_path="$extract_dir/$member"
    [[ -f "$member_path" ]] || { echo "Manifest member is missing: $member" >&2; exit 1; }
    actual=$(shasum -a 256 "$member_path" | awk '{print $1}')
    [[ "$actual" == "$expected" ]] || { echo "Checksum failed: $member" >&2; exit 1; }
  done < "$manifest"
fi

mapfile -t vmdks < <(find "$extract_dir" -type f -iname '*.vmdk' -print | sort)
(( ${#vmdks[@]} >= 1 )) || { echo "No VMDKs found in OVA." >&2; exit 1; }

boot_vmdk=""
for vmdk in "${vmdks[@]}"; do
  if [[ "$(basename "$vmdk")" =~ [Dd]isk1 ]]; then
    boot_vmdk="$vmdk"
    break
  fi
done
boot_vmdk="${boot_vmdk:-${vmdks[0]}}"

echo "Boot VMDK: $(basename "$boot_vmdk")"
echo "Data VMDKs:"
for vmdk in "${vmdks[@]}"; do
  [[ "$vmdk" == "$boot_vmdk" ]] || echo "  $(basename "$vmdk")"
done

if ! $upload; then
  echo "Extraction is complete. Re-run with --upload to create Object Storage PARs."
  exit 0
fi

if [[ -z "$region" ]]; then
  region=$(oci configure get region --profile "$profile")
fi

if [[ -z "$expires_at" ]]; then
  if date -u -d '+7 days' '+%Y-%m-%dT%H:%M:%SZ' >/dev/null 2>&1; then
    expires_at=$(date -u -d '+7 days' '+%Y-%m-%dT%H:%M:%SZ')
  else
    expires_at=$(date -u -v+7d '+%Y-%m-%dT%H:%M:%SZ')
  fi
fi

namespace=$(oci os ns get --profile "$profile" --query data --raw-output)
bucket_compartment=$(oci os bucket get \
  --profile "$profile" \
  --namespace "$namespace" \
  --name "$bucket" \
  --query 'data."compartment-id"' \
  --raw-output)
[[ "$bucket_compartment" == "$compartment_id" ]] || {
  echo "Bucket $bucket is not in the supplied compartment." >&2
  exit 1
}
prefix="ova-import/$(basename "${ova%.*}")-$(date -u '+%Y%m%dT%H%M%SZ')"
tfvars="$output_dir/customer.auto.tfvars"
rm_variables="$output_dir/resource-manager-variables.json"
rm_launch_url="$output_dir/deploy-to-oci-url.txt"
umask 077

create_par() {
  local object_name="$1"
  local par_name="codex-$(basename "$object_name")"
  local access_uri
  access_uri=$(oci os preauth-request create \
    --profile "$profile" \
    --bucket-name "$bucket" \
    --namespace "$namespace" \
    --access-type ObjectRead \
    --name "$par_name" \
    --object-name "$object_name" \
    --time-expires "$expires_at" \
    --query 'data."access-uri"' \
    --raw-output)
  printf 'https://objectstorage.%s.oraclecloud.com%s' "$region" "$access_uri"
}

upload_disk() {
  local source_file="$1"
  local object_name="$prefix/$(basename "$source_file")"
  echo "Uploading $(basename "$source_file")" >&2
  oci os object put \
    --profile "$profile" \
    --bucket-name "$bucket" \
    --namespace "$namespace" \
    --name "$object_name" \
    --file "$source_file" \
    --force >/dev/null
  create_par "$object_name"
}

hcl_escape() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

boot_par=$(upload_disk "$boot_vmdk")
block_volumes_json='{}'
{
  echo "# Generated by prepare_ova.sh. Contains temporary PARs; do not commit."
  printf 'boot_volume_par_url = "%s"\n\n' "$(printf '%s' "$boot_par" | hcl_escape)"
  echo "block_volumes = {"
  index=1
  for vmdk in "${vmdks[@]}"; do
    [[ "$vmdk" == "$boot_vmdk" ]] && continue
    data_par=$(upload_disk "$vmdk")
    printf '  data-%02d = { par_url = "%s" }\n' "$index" "$(printf '%s' "$data_par" | hcl_escape)"
    block_volumes_json=$(jq \
      --arg key "$(printf 'data-%02d' "$index")" \
      --arg par_url "$data_par" \
      '. + {($key): {par_url: $par_url}}' <<<"$block_volumes_json")
    ((index++))
  done
  echo "}"
} > "$tfvars"

jq -n \
  --arg boot_volume_par_url "$boot_par" \
  --argjson block_volumes "$block_volumes_json" \
  '{boot_volume_par_url: $boot_volume_par_url, block_volumes: $block_volumes}' > "$rm_variables"

encoded_rm_variables=$(jq -c . "$rm_variables" | jq -sRr @uri)
printf '%s?region=home&zipUrl=%s&zipUrlVariables=%s\n' \
  'https://cloud.oracle.com/resourcemanager/stacks/create' \
  "$rm_zip_url" \
  "$encoded_rm_variables" > "$rm_launch_url"

echo "Wrote Terraform inputs to: $tfvars"
echo "Wrote Resource Manager variables to: $rm_variables"
echo "Open this file to launch the pre-populated Resource Manager stack: $rm_launch_url"
echo "PARs expire at: $expires_at"
