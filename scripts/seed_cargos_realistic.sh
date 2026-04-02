#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-https://cargo-back.darjs.workers.dev}"
TOKEN="${BEARER_TOKEN:-${1:-}}"

if [[ -z "$TOKEN" ]]; then
  echo "Error: missing bearer token."
  echo "Usage: BEARER_TOKEN=<token> ./scripts/seed_cargos_realistic.sh [token]"
  exit 1
fi

payloads=(
  '{"trackingNumber":"LP009845612CN","description":"Apple AirPods Pro 2 with MagSafe case"}'
  '{"trackingNumber":"YT7845123901234","description":"Uniqlo ultra light down jacket (men, navy)"}'
  '{"trackingNumber":"SF1309845621","description":"Kindle Paperwhite 16GB, black"}'
  '{"trackingNumber":"JNTMGL30294815","description":"Logitech MX Master 3S mouse"}'
  '{"trackingNumber":"ZTO8874512390","description":"Mechanical keyboard keycap set, PBT"}'
  '{"trackingNumber":"UBX4490138752","description":"Xiaomi smart home sensor bundle"}'
  '{"trackingNumber":"EMSCN739105248","description":"Dyson Supersonic hair dryer attachments"}'
  '{"trackingNumber":"CAINIAO590412773","description":"iPad Air 11-inch ESR folio case"}'
)

created=0
failed=0

echo "Seeding ${#payloads[@]} realistic cargo item(s) into $BASE_URL/api/cargos ..."

for i in "${!payloads[@]}"; do
  index=$((i + 1))
  payload="${payloads[$i]}"
  response_file=$(mktemp)

  status_code=$(curl -sS -o "$response_file" -w "%{http_code}" \
    -X POST "$BASE_URL/api/cargos" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload")

  tracking=$(python3 - <<'PY' "$payload"
import json
import sys
print(json.loads(sys.argv[1]).get("trackingNumber", ""))
PY
)

  if [[ "$status_code" == "200" ]]; then
    created=$((created + 1))
    id=$(python3 - <<'PY' "$response_file"
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
print((data.get("data") or {}).get("id", ""))
PY
)
    echo "[$index/${#payloads[@]}] Created tracking=$tracking id=${id:-unknown}"
  else
    failed=$((failed + 1))
    body=$(python3 - <<'PY' "$response_file"
import json
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(data.get("message", data))
except Exception:
    with open(path, "r", encoding="utf-8") as f:
        print(f.read())
PY
)
    echo "[$index/${#payloads[@]}] Failed tracking=$tracking status=$status_code error=$body"
  fi

  rm -f "$response_file"
done

echo "Done. Created=$created Failed=$failed"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
