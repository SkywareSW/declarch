#!/usr/bin/env bash
set -euo pipefail
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
if [ "${1:-}" = "uninstall" ]; then
  rm -f /usr/local/bin/declarch; rm -rf /usr/share/doc/declarch
  echo "Removed (your /etc/declarch config was kept)."; exit 0
fi
python3 -c 'import tomllib' 2>/dev/null || { echo "Python 3.11+ required"; exit 1; }
here="$(cd "$(dirname "$0")" && pwd)"
install -Dm755 "$here/declarch" /usr/local/bin/declarch
install -d /etc/declarch /usr/share/doc/declarch
cp -r "$here/example" /usr/share/doc/declarch/
install -Dm644 "$here/DOCS.md" /usr/share/doc/declarch/DOCS.md
[ -e /etc/declarch/configuration.arch ] || declarch init
echo "Installed. Edit /etc/declarch/configuration.arch, then: declarch plan && sudo declarch apply"
