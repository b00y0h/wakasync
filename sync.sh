#!/usr/bin/env bash
set -euo pipefail

# Fetch WakaTime data for the last 7 days and archive as JSON.
# Required env vars: WAKATIME_API_KEY, WAKATIME_API_URL

if [[ -z "${WAKATIME_API_KEY:-}" ]]; then
  echo "Error: WAKATIME_API_KEY is not set" >&2
  exit 1
fi

if [[ -z "${WAKATIME_API_URL:-}" ]]; then
  echo "Error: WAKATIME_API_URL is not set" >&2
  exit 1
fi

API_URL="${WAKATIME_API_URL%/}"
AUTH=$(printf '%s' "$WAKATIME_API_KEY" | base64)

fetch() {
  local endpoint="$1"
  local outfile="$2"

  local http_code
  http_code=$(curl -s -w '%{http_code}' -o "$outfile.tmp" \
    -H "Authorization: Basic $AUTH" \
    "${API_URL}${endpoint}")

  if [[ "$http_code" -ne 200 ]]; then
    echo "  FAILED (HTTP $http_code): $endpoint" >&2
    rm -f "$outfile.tmp"
    return 1
  fi

  python3 -m json.tool "$outfile.tmp" > "$outfile"
  rm -f "$outfile.tmp"
  echo "  Saved $outfile"
}

TODAY=$(date -u +%Y-%m-%d)

for i in $(seq 0 6); do
  if date --version >/dev/null 2>&1; then
    # GNU date
    DAY=$(date -u -d "$TODAY - $i days" +%Y-%m-%d)
  else
    # macOS date
    DAY=$(date -u -j -v-"${i}d" -f "%Y-%m-%d" "$TODAY" +%Y-%m-%d)
  fi

  YEAR=$(echo "$DAY" | cut -d- -f1)
  MONTH=$(echo "$DAY" | cut -d- -f2)
  DD=$(echo "$DAY" | cut -d- -f3)
  DIR="data/${YEAR}/${MONTH}/${DD}"

  if [[ -f "$DIR/summary.json" && -f "$DIR/durations.json" ]]; then
    echo "Skipping $DAY (already exists)"
    continue
  fi

  echo "Fetching $DAY ..."
  mkdir -p "$DIR"

  fetch "/users/current/summaries?start=${DAY}&end=${DAY}" "$DIR/summary.json" || true
  fetch "/users/current/durations?date=${DAY}" "$DIR/durations.json" || true
done

# Fetch stats (last 7 days) once, stored under today's date
TYEAR=$(echo "$TODAY" | cut -d- -f1)
TMONTH=$(echo "$TODAY" | cut -d- -f2)
TDD=$(echo "$TODAY" | cut -d- -f3)
STATS_DIR="data/${TYEAR}/${TMONTH}/${TDD}"
mkdir -p "$STATS_DIR"

echo "Fetching stats/last_7_days ..."
fetch "/users/current/stats/last_7_days" "$STATS_DIR/stats.json" || true

echo "Done."
