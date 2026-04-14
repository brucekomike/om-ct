#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
backup_root="${1:-$HOME/back-configs}"
timestamp="$(date +%Y%m%d-%H%M%S)"
archive_path="$backup_root/conf-configs-$timestamp.tar.gz"
manifest_path="$backup_root/conf-configs-$timestamp.files.txt"

mkdir -p "$backup_root"

mapfile -d '' -t ignored_files < <(
	cd "$repo_root" && git ls-files -oi -z --exclude-standard -- conf
)

if [[ ${#ignored_files[@]} -eq 0 ]]; then
	echo "No ignored files found under conf/."
	exit 0
fi

printf '%s\n' "${ignored_files[@]}" > "$manifest_path"

echo "Backing up ${#ignored_files[@]} ignored file(s) from conf/..."
(cd "$repo_root" && tar -czf "$archive_path" "${ignored_files[@]}")

echo "Backup complete: $archive_path"
echo "Manifest: $manifest_path"
