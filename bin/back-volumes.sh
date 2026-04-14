#!/usr/bin/env bash
set -euo pipefail

backup_root="${1:-$HOME/back-volumes}"
timestamp="$(date +%Y%m%d-%H%M%S)"
workdir="$(mktemp -d)"
bundle_dir="$workdir/docker-volumes-$timestamp"
archive_path="$backup_root/docker-volumes-$timestamp.tar.gz"

cleanup() {
	rm -rf "$workdir"
}
trap cleanup EXIT

mkdir -p "$backup_root" "$bundle_dir/volumes"

mapfile -t volumes < <(docker volume ls -q)
if [[ ${#volumes[@]} -eq 0 ]]; then
	echo "No Docker volumes found."
	exit 0
fi

printf '%s\n' "${volumes[@]}" > "$bundle_dir/volumes.txt"

echo "Backing up ${#volumes[@]} volume(s)..."
for volume in "${volumes[@]}"; do
	echo "- $volume"
	docker run --rm \
		-v "$volume":/source:ro \
		-v "$bundle_dir/volumes":/backup \
		alpine sh -c "cd /source && tar czf /backup/$volume.tar.gz ."
done

tar -C "$bundle_dir" -czf "$archive_path" .
echo "Backup complete: $archive_path"
