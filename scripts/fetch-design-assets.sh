#!/usr/bin/env bash
# Download Stitch-hosted images locally before the URLs expire.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/frontend/public/img"
mkdir -p "$OUT"

grep -rhoE 'https://lh3\.googleusercontent\.com/[^"'\'')]+' "$ROOT/design" \
  | sort -u > /tmp/cc-assets.txt

total=$(wc -l < /tmp/cc-assets.txt)
echo "Found $total unique image URLs."
i=0; ok=0; fail=0
while read -r url; do
  i=$((i+1)); printf -v name "asset-%02d.jpg" "$i"
  if curl -fsSL --max-time 30 "$url" -o "$OUT/$name"; then
    echo "  OK   $name  ($(du -h "$OUT/$name" | cut -f1))"; ok=$((ok+1))
  else
    echo "  FAIL $url"; rm -f "$OUT/$name"; fail=$((fail+1))
  fi
done < /tmp/cc-assets.txt

echo
echo "Downloaded $ok of $total. Failed: $fail."
echo "Saved to $OUT — rename them meaningfully next."
