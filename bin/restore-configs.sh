#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-archive.tar.gz> [repo-root]"
  exit 1
fi

archive_path="$1"
repo_root="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

if [[ ! -f "$archive_path" ]]; then
  echo "Backup archive not found: $archive_path"
  exit 1
fi

echo "Restoring ignored config files into: $repo_root"
tar -xzf "$archive_path" -C "$repo_root"
echo "Restore complete"