#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-https://cargo-back.darjs.workers.dev}"
TOKEN="${BEARER_TOKEN:-${1:-}}"
COUNT="${COUNT:-5}"
PREFIX="${TRACKING_PREFIX:-SEED}"

if [[ -z "$TOKEN" ]]; then
  echo "Error: missing bearer token."
  echo "Usage: BEARER_TOKEN=<token> ./scripts/seed_cargos.sh [token]"
  exit 1
fi

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [[ "$COUNT" -lt 1 ]]; then
  echo "Error: COUNT must be a positive integer."
  exit 1
fi

created=0
failed=0

echo "Seeding $COUNT cargo item(s) into $BASE_URL/api/cargos ..."

for i in $(seq 1 "$COUNT"); do
  tracking_number="${PREFIX}-$(date +%s)-${i}"
  payload=$(printf '{"trackingNumber":"%s","description":"Seeded cargo %s"}' "$tracking_number" "$i")

  response_file=$(mktemp)
  status_code=$(curl -sS -o "$response_file" -w "%{http_code}" \
    -X POST "$BASE_URL/api/cargos" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload")

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
    echo "[$i/$COUNT] Created tracking=$tracking_number id=${id:-unknown}"
  else
    failed=$((failed + 1))
    body=$(cat "$response_file")
    echo "[$i/$COUNT] Failed tracking=$tracking_number status=$status_code body=$body"
  fi

  rm -f "$response_file"
done

echo "Done. Created=$created Failed=$failed"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
