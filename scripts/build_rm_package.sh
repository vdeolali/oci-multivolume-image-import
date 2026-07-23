#!/usr/bin/env bash
# Build the minimal, customer-safe ZIP accepted by OCI Resource Manager.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: build_rm_package.sh [--output FILE]

Builds a Resource Manager configuration ZIP containing only the Terraform
configuration, schema, module, and customer instructions. It deliberately
excludes local credentials, generated PAR files, Terraform state, and the OVA.
EOF
}

output="${PWD}/catalyst-center-multivolume-stack.zip"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) output="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v zip >/dev/null || { echo "zip is required." >&2; exit 2; }

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

mkdir -p "$stage/modules/compute"
cp "$project_root"/{main.tf,outputs.tf,provider.tf,variables.tf,schema.yaml,README.md} "$stage"
cp "$project_root/modules/compute"/*.tf "$stage/modules/compute"

mkdir -p "$(dirname "$output")"
(cd "$stage" && zip -qr "$output" .)

echo "Created Resource Manager package: $output"
