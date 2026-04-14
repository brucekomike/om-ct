#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-archive.tar.gz>"
  exit 1
fi

archive_path="$1"
if [[ ! -f "$archive_path" ]]; then
  echo "Backup archive not found: $archive_path"
  exit 1
fi

workdir="$(mktemp -d)"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

tar -xzf "$archive_path" -C "$workdir"

if [[ ! -f "$workdir/volumes.txt" ]]; then
  echo "Invalid backup archive: missing volumes.txt"
  exit 1
fi

mapfile -t volumes < "$workdir/volumes.txt"
if [[ ${#volumes[@]} -eq 0 ]]; then
  echo "No volumes listed in backup archive."
  exit 0
fi

echo "Restoring ${#volumes[@]} volume(s)..."
for volume in "${volumes[@]}"; do
  volume_archive="$workdir/volumes/$volume.tar.gz"
  if [[ ! -f "$volume_archive" ]]; then
    echo "Skipping $volume: archive not found"
    continue
  fi

  echo "- $volume"
  docker volume create "$volume" >/dev/null
  docker run --rm \
    -e VOLUME_NAME="$volume" \
    -v "$volume":/target \
    -v "$workdir/volumes":/backup \
    alpine sh -c 'set -e; find /target -mindepth 1 -exec rm -rf {} +; tar xzf "/backup/${VOLUME_NAME}.tar.gz" -C /target'
done

echo "Restore complete from: $archive_path"
