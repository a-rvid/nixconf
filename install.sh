#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <disk-device-name>"
  echo "Example: $0 sda"
  echo "Example: $0 nvme0n1"
  echo ""
  echo "Available disk devices:"
  lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E "disk"
  exit 1
fi

DISK_DEV="$1"

# If the user specified a full path like /dev/sda, extract the name
if [[ "$DISK_DEV" == /dev/* ]]; then
  DISK_DEV="${DISK_DEV#/dev/}"
fi

# Full device path
DEV_PATH="/dev/$DISK_DEV"

if [ ! -b "$DEV_PATH" ]; then
  echo "Error: Device $DEV_PATH does not exist or is not a block device."
  exit 1
fi

echo "Available disks status:"
lsblk "$DEV_PATH"
echo ""
echo "WARNING: This will completely ERASE and partition $DEV_PATH!"
echo "Are you sure you want to continue? (y/N)"
read -r CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "Installation aborted."
  exit 1
fi

# Get the absolute path of the configuration directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run disko-install using path: to bypass Git ownership checks under sudo
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake "path:${SCRIPT_DIR}#main" \
  --disk main "$DEV_PATH" \
  --write-efi-boot-entries
