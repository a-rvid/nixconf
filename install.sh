#!/usr/bin/env bash
set -euo pipefail

# Check if target disk is provided
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

echo "=========================================================="
echo "Step 1/3: Formatting the disk using Disko..."
echo "=========================================================="
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest' -- \
  --mode format \
  --flake "path:${SCRIPT_DIR}#hostMain" \
  --disk main "$DEV_PATH"

echo "=========================================================="
echo "Step 2/3: Mounting the partitions..."
echo "=========================================================="
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest' -- \
  --mode mount \
  --flake "path:${SCRIPT_DIR}#hostMain" \
  --disk main "$DEV_PATH"

# Create a temporary directory on the mounted target disk to prevent Nix from
# using the live ISO's memory-backed tmpfs for build operations.
sudo mkdir -p /mnt/tmp
export TMPDIR=/mnt/tmp

echo "=========================================================="
echo "Step 3/3: Installing NixOS (building directly to target disk store to save RAM)..."
echo "=========================================================="
sudo nixos-install \
  --flake "path:${SCRIPT_DIR}#main" \
  --no-root-passwd

echo "=========================================================="
echo "Installation complete! You can now reboot into your new system."
echo "=========================================================="
