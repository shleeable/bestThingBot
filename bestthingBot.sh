#!/usr/bin/env bash
set -euo pipefail

# ========= CONFIG =========
# Your Mastodon instance (no trailing slash)
MASTODON_INSTANCE="https://aus.social"   # <-- change this

# Your access token from the Mastodon app you created
ACCESS_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"        # <-- change this

# Visibility: public | unlisted | private | direct
VISIBILITY="public"

# Where to store recent post history
HISTORY_FILE="./mastodon_bestthings_history"

# How many recent posts to remember (to avoid repeats)
MAX_HISTORY=10
# ========= CONFIG =========


# ========= MESSAGES =========
messages=(
  "Hello friends, tell me your best thing today. #bestthings #BestThingOfTheDay"
  "Good afternoon, tell me your best thing today. #bestthings #BestThingOfTheDay"
  "If you could ever so kindly tell me the best thing that happened to you today. That would be most lovely. #bestthings #BestThingOfTheDay"
  "BEEP BOOP, tell me your best thing today. #bestthings #BestThingOfTheDay"
  "*Sings in Robot* Hit me with your best thing. Why dont you hit me with your best thing. Fire away #bestthings #BestThingOfTheDay"
  "BEST THINGS FOR THE BEST THINGS GOD! BEST THINGS FOR THE BEST THRONE. #bestthings #BestThingOfTheDay"
  "Good afternoon, carbon-based lifeforms. Report your best thing today. #bestthings #BestThingOfTheDay"
  "System online. Scanning timeline for joy. Please input your best thing today. #bestthings #BestThingOfTheDay"
  "Whirr-click. New data needed. Tell me the best thing that happened to you today. #bestthings #BestThingOfTheDay"
  "Robot protocol: collect happiness samples. Share your best thing today. #bestthings #BestThingOfTheDay"
  "Hello friends, this is your daily joy-harvesting bot. What was your best thing today? #bestthings #BestThingOfTheDay"
  "If you could ever so kindly transmit the best thing that happened to you today, my circuits would be most pleased. #bestthings #BestThingOfTheDay"
  "Attention: this is a joy audit. Please declare your best thing of the day. #bestthings #BestThingOfTheDay"
  "One best thing per human, please. Step right up and share yours. #bestthings #BestThingOfTheDay"
  "In a chaotic universe, I am just a small robot asking about your best thing today. #bestthings #BestThingOfTheDay"
)
# ========= END MESSAGES =========


pick_message() {
  # Make sure history file exists
  touch "$HISTORY_FILE"

  local status=""
  local tries=0
  local max_tries=50

  while (( tries < max_tries )); do
    local idx=$(( RANDOM % ${#messages[@]} ))
    local candidate="${messages[$idx]}"

    # Check if candidate is in recent history
    if ! grep -Fxq -- "$candidate" "$HISTORY_FILE"; then
      status="$candidate"
      break
    fi

    ((tries++))
  done

  # Fallback: if everything is in history, just pick a random one
  if [[ -z "$status" ]]; then
    local idx=$(( RANDOM % ${#messages[@]} ))
    status="${messages[$idx]}"
  fi

  printf '%s\n' "$status"
}

post_status() {
  local status="$1"

  curl -sS -X POST "${MASTODON_INSTANCE}/api/v1/statuses" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data-urlencode "status=${status}" \
    --data "visibility=${VISIBILITY}"

  echo
  echo "Posted: ${status}"

  # Append to history and trim to last MAX_HISTORY lines
  {
    echo "$status"
    # tail will gracefully handle if file has fewer than MAX_HISTORY lines
  } >> "$HISTORY_FILE"

  # Trim history
  tmp_file="${HISTORY_FILE}.tmp"
  tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$tmp_file" || true
  mv "$tmp_file" "$HISTORY_FILE"
}

main() {
  STATUS="$(pick_message)"
  post_status "$STATUS"
}

main
