#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://xintechllc.com}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

failures=0

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 2
  fi
}

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "PASS $description"
  else
    echo "FAIL $description" >&2
    failures=$((failures + 1))
  fi
}

fetch() {
  local path="$1"
  local output="$TMP_DIR/${path//\\//_}"
  if [[ "$path" == "/" ]]; then
    output="$TMP_DIR/index"
  fi
  curl -fsSL "$BASE_URL$path" -o "$output"
  printf '%s' "$output"
}

page_has() {
  local path="$1"
  local pattern="$2"
  local file
  file="$(fetch "$path")"
  rg -q "$pattern" "$file"
}

url_ok() {
  local path="$1"
  curl -fsSIL "$BASE_URL$path" >/dev/null
}

require_command curl
require_command rg

echo "Checking Flexible Timers public compliance pages"
echo "Base URL: $BASE_URL"
echo

check "Homepage is reachable" url_ok "/"
check "Support page is reachable" url_ok "/support.html"
check "Terms page is reachable" url_ok "/terms.html"
check "Privacy page is reachable" url_ok "/privacy.html"
check "SMS Terms page is reachable" url_ok "/sms-terms.html"
check "SMS opt-in evidence page is reachable" url_ok "/sms-opt-in.html"
check "Compliance page is reachable" url_ok "/compliance.html"
check "SMS consent screenshot evidence is reachable" url_ok "/assets/sms-consent.png"
check "Robots file is reachable" url_ok "/robots.txt"
check "Sitemap is reachable" url_ok "/sitemap.xml"

check "SMS Terms documents one-time verification use" \
  page_has "/sms-terms.html" "verification codes"
check "SMS Terms documents STOP keyword" \
  page_has "/sms-terms.html" "Reply STOP to opt out"
check "SMS Terms documents HELP keyword" \
  page_has "/sms-terms.html" "Reply HELP for help"
check "SMS Terms says no marketing texts" \
  page_has "/sms-terms.html" "does not send marketing text messages"
check "Privacy says SMS opt-in data is not sold" \
  page_has "/privacy.html" "does not sell SMS opt-in data"
check "Opt-in page includes consent wording" \
  page_has "/sms-opt-in.html" "I agree to receive one-time SMS verification codes"
check "Opt-in page includes sample production message" \
  page_has "/sms-opt-in.html" "Flexible Timers verification code"
check "Compliance page links opt-in evidence" \
  page_has "/compliance.html" "SMS opt-in evidence page"
check "Support page includes contact path" \
  page_has "/support.html" "github.com/Samx2015/FlexibleTimers/issues"
check "Sitemap includes Terms and opt-in pages" \
  page_has "/sitemap.xml" "terms.html|sms-opt-in.html"

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "$failures check(s) failed." >&2
  exit 1
fi

echo
echo "All public compliance page checks passed."
