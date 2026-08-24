#!/usr/bin/env bash
set -euo pipefail

# Publish the XTimers website to the live GitHub Pages repo.
#
# Source of truth : this repository (FlexibleTimers).
# Live deploy     : Samx2015.github.io/XTimers         -> https://xintechllc.com/XTimers/        (canonical)
#                   Samx2015.github.io/FlexibleTimers  -> https://xintechllc.com/FlexibleTimers/ (legacy mirror)
#
# The legacy /FlexibleTimers/ mirror keeps every historical URL working:
# store listings, in-app URL constants of shipped builds, SMS consent records,
# and the Twilio TFV opt-in evidence URL all point there. Marketing pages
# carry canonical tags to /XTimers/; compliance/consent pages stay canonical
# at the legacy path until the Twilio batch (see Docs/XTIMERS_REBRAND.md).
#
# Mirrors the HelperSuite website-publishing idiom: rsync -a --delete from the
# source into the Pages checkout (preserving an existing download/ folder),
# path-scoped commit + push of the Pages repo, then verify the live URLs.
#
# Usage:
#   scripts/publish.sh [--dry-run] [--no-verify]
#
# Environment overrides:
#   XTIMERS_PAGES_DIR          Canonical Pages folder
#                              (default: /Users/sam/GitHub/Samx2015.github.io/XTimers)
#   LEGACY_PAGES_DIR           Legacy-mirror Pages folder (alias: FLEXIBLETIMERS_PAGES_DIR)
#                              (default: /Users/sam/GitHub/Samx2015.github.io/FlexibleTimers)
#   PUBLIC_BASE_URL            Canonical base URL to verify
#                              (default: https://xintechllc.com/XTimers)
#   LEGACY_BASE_URL            Legacy base URL to verify
#                              (default: https://xintechllc.com/FlexibleTimers)
#   XTIMERS_WORKSPACE_ROOT     TimerWorkspace checkout containing the localization release gate
#                              (default: sibling TimerWorkspace repository)
#   XTIMERS_PUBLISH_AGENT_MODEL
#                              Optional agent model recorded in an automated publish commit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST_DIR_NEW="${XTIMERS_PAGES_DIR:-/Users/sam/GitHub/Samx2015.github.io/XTimers}"
DEST_DIR_OLD="${LEGACY_PAGES_DIR:-${FLEXIBLETIMERS_PAGES_DIR:-/Users/sam/GitHub/Samx2015.github.io/FlexibleTimers}}"
PUBLIC_BASE_URL="${PUBLIC_BASE_URL:-https://xintechllc.com/XTimers}"
LEGACY_BASE_URL="${LEGACY_BASE_URL:-https://xintechllc.com/FlexibleTimers}"
XTIMERS_WORKSPACE_ROOT="${XTIMERS_WORKSPACE_ROOT:-$SOURCE_DIR/../TimerWorkspace}"
CALLBACK_CHECK="$SOURCE_DIR/scripts/test-auth-complete.js"
COMPLIANCE_CHECK="$SOURCE_DIR/scripts/check-compliance-pages.sh"
ORIGIN_ROBOTS_HELPER="$SOURCE_DIR/scripts/ensure-origin-robots-sitemap.sh"
RELEASE_VERIFIER="$SOURCE_DIR/scripts/verify-published-localizations.py"

DRY_RUN=0
VERIFY=1

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-verify) VERIFY=0 ;;
    -h|--help)
      sed -n '3,33p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
  shift
done

fail() { printf 'error: %s\n' "$*" >&2; exit 1; }
log()  { printf '\n==> %s\n' "$*"; }

command -v rsync >/dev/null 2>&1 || fail "rsync is required"
command -v git   >/dev/null 2>&1 || fail "git is required"
command -v node  >/dev/null 2>&1 || fail "node is required"
command -v mktemp >/dev/null 2>&1 || fail "mktemp is required"

[[ -f "$CALLBACK_CHECK" ]] || fail "callback test missing: $CALLBACK_CHECK"
[[ -x "$COMPLIANCE_CHECK" ]] || fail "compliance check missing: $COMPLIANCE_CHECK"
[[ -x "$ORIGIN_ROBOTS_HELPER" ]] || fail "robots helper missing: $ORIGIN_ROBOTS_HELPER"
[[ -x "$RELEASE_VERIFIER" ]] || fail "release verifier missing: $RELEASE_VERIFIER"

log "Checking callback routing and click-only handoff"
node "$CALLBACK_CHECK"

# Safety guards: never sync from/to an empty path or a filesystem root.
[[ -n "$SOURCE_DIR" && -n "$DEST_DIR_NEW" && -n "$DEST_DIR_OLD" ]] || fail "empty source or destination path"
[[ "$SOURCE_DIR" != "/" && "$DEST_DIR_NEW" != "/" && "$DEST_DIR_OLD" != "/" ]] || fail "refusing to sync filesystem root"
[[ -d "$SOURCE_DIR" ]] || fail "source missing: $SOURCE_DIR"
[[ -d "$DEST_DIR_OLD" ]] || fail "legacy destination missing: $DEST_DIR_OLD (create the Pages folder first)"
if [[ ! -d "$DEST_DIR_NEW" ]]; then
  [[ "$DRY_RUN" -eq 0 ]] \
    || fail "canonical destination missing in dry-run mode: $DEST_DIR_NEW"
  mkdir -p "$DEST_DIR_NEW"
fi
[[ -f "$SOURCE_DIR/index.html" ]] || fail "source does not look like the website: $SOURCE_DIR"

IO_REPO="$(git -C "$DEST_DIR_OLD" rev-parse --show-toplevel 2>/dev/null)" \
  || fail "destination is not inside a git repo: $DEST_DIR_OLD"
ORIGIN_ROBOTS="$IO_REPO/robots.txt"
[[ -f "$ORIGIN_ROBOTS" ]] || fail "origin robots file missing: $ORIGIN_ROBOTS"

LOCALIZATION_RELEASE_GATE="$XTIMERS_WORKSPACE_ROOT/scripts/check-all-localizations.sh"
[[ -x "$LOCALIZATION_RELEASE_GATE" ]] \
  || fail "localization release gate missing: $LOCALIZATION_RELEASE_GATE"

# rsync: full mirror, minus VCS/junk and this deploy tool (keeps local paths off
# the live site). Preserve an existing download/ folder when the source has none,
# so hosted release assets are never wiped (matches HelperSuite safe_website_rsync).
RSYNC_ARGS=(-a --delete
  --exclude '.git'
  --exclude '.DS_Store'
  --exclude '.gitignore'
  --exclude '.nojekyll'
  --exclude '__pycache__'
  --exclude '*.pyc'
  --exclude 'generated'
  --exclude 'README.md'
  --exclude 'requirements-localization.txt'
  --exclude 'scripts/publish.sh')
[[ -d "$SOURCE_DIR/download" ]] || RSYNC_ARGS+=(--exclude 'download')
SNAPSHOT_RSYNC_ARGS=(-a --delete
  --exclude '.git'
  --exclude '.DS_Store'
  --exclude '__pycache__'
  --exclude '*.pyc')

STAGE_DIR=""
SOURCE_STAGE=""
SOURCE_STAGE_FINGERPRINT=""
cleanup_stage() {
  if [[ -n "$STAGE_DIR" && -d "$STAGE_DIR" ]]; then
    rm -rf -- "$STAGE_DIR"
  fi
}
trap cleanup_stage EXIT

create_release_snapshot() {
  STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/xtimers-publish-stage.XXXXXX")"
  SOURCE_STAGE="$STAGE_DIR/source"
  local canonical_stage="$STAGE_DIR/XTimers"
  local legacy_stage="$STAGE_DIR/FlexibleTimers"
  mkdir -p "$SOURCE_STAGE" "$canonical_stage" "$legacy_stage"
  rsync "${SNAPSHOT_RSYNC_ARGS[@]}" "$SOURCE_DIR"/ "$SOURCE_STAGE"/
  SOURCE_STAGE_FINGERPRINT="$(
    python3 "$RELEASE_VERIFIER" --source-root "$SOURCE_STAGE" --print-tree-digest
  )"

  log "Checking localization release eligibility against immutable snapshot"
  XTIMERS_WEBSITE_ROOT="$SOURCE_STAGE" "$LOCALIZATION_RELEASE_GATE" --release
  log "Checking source compliance against immutable snapshot"
  LOCAL_ROOT="$SOURCE_STAGE" "$SOURCE_STAGE/scripts/check-compliance-pages.sh" --source-only

  rsync "${RSYNC_ARGS[@]}" "$SOURCE_STAGE"/ "$canonical_stage"/
  rsync "${RSYNC_ARGS[@]}" "$SOURCE_STAGE"/ "$legacy_stage"/
  log "Checking staged canonical and legacy mirrors"
  CHECK_LIVE=0 \
    LOCAL_ROOT="$SOURCE_STAGE" \
    CANONICAL_PAGES_ROOT="$canonical_stage" \
    LEGACY_PAGES_ROOT="$legacy_stage" \
    "$SOURCE_STAGE/scripts/check-compliance-pages.sh" --no-live
  python3 "$RELEASE_VERIFIER" --source-root "$SOURCE_STAGE" --verify-local "$canonical_stage"
  python3 "$RELEASE_VERIFIER" --source-root "$SOURCE_STAGE" --verify-local "$legacy_stage"

  local robots_stage="$STAGE_DIR/origin-robots.txt"
  cp -p "$ORIGIN_ROBOTS" "$robots_stage"
  "$SOURCE_STAGE/scripts/ensure-origin-robots-sitemap.sh" "$robots_stage"
  "$SOURCE_STAGE/scripts/ensure-origin-robots-sitemap.sh" --check "$robots_stage"
}

publish_to() {
  local source="$1"
  local dest="$2"
  local rsync_args=("${RSYNC_ARGS[@]}")
  [[ "$DRY_RUN" -eq 1 ]] && rsync_args+=(--dry-run --itemize-changes)
  log "Syncing XTimers website -> $dest"
  rsync "${rsync_args[@]}" "$source"/ "$dest"/
}

assert_snapshot_unchanged() {
  local current
  current="$(python3 "$RELEASE_VERIFIER" --source-root "$SOURCE_STAGE" --print-tree-digest)"
  [[ "$current" == "$SOURCE_STAGE_FINGERPRINT" ]] \
    || fail "immutable release snapshot changed after validation"
}

create_release_snapshot
assert_snapshot_unchanged

publish_to "$SOURCE_STAGE" "$DEST_DIR_NEW"
publish_to "$SOURCE_STAGE" "$DEST_DIR_OLD"

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "Dry run complete; no commit or push performed."
  exit 0
fi

"$SOURCE_STAGE/scripts/ensure-origin-robots-sitemap.sh" "$ORIGIN_ROBOTS"
assert_snapshot_unchanged

log "Checking reconciled deploy trees before commit"
CHECK_LIVE=0 \
  LOCAL_ROOT="$SOURCE_STAGE" \
  CANONICAL_PAGES_ROOT="$DEST_DIR_NEW" \
  LEGACY_PAGES_ROOT="$DEST_DIR_OLD" \
  "$SOURCE_STAGE/scripts/check-compliance-pages.sh" --no-live

# Path-scoped commit so unrelated changes in the Pages repo are left alone.
if [[ -z "$(git -C "$IO_REPO" status --porcelain -- "$DEST_DIR_NEW" "$DEST_DIR_OLD" "$ORIGIN_ROBOTS")" ]]; then
  log "No website changes to publish."
else
  log "Committing and pushing Pages repo"
  git -C "$IO_REPO" add -- "$DEST_DIR_NEW" "$DEST_DIR_OLD" "$ORIGIN_ROBOTS"
  commit_args=(
    -m "[skip ci] Publish XTimers website (canonical + legacy mirror)"
    -m "Deploy the current website source to both public paths after the localization release gate passes."
  )
  if [[ -n "${XTIMERS_PUBLISH_AGENT_MODEL:-}" ]]; then
    machine_name="$(scutil --get ComputerName)"
    commit_args+=(
      -m "Agent-Model: ${XTIMERS_PUBLISH_AGENT_MODEL}"$'\n'"Machine: ${machine_name}"
    )
  fi
  git -C "$IO_REPO" commit -q "${commit_args[@]}"
  git -C "$IO_REPO" push -q
  log "Pushed."
fi

if [[ "$VERIFY" -eq 0 ]]; then
  log "Skipping live verification (--no-verify)."
  exit 0
fi

# Verify the live site picked up the deploy (Pages rebuild can lag a minute).
verify_url_contains() {
  local url="$1" term="$2" tmp
  tmp="$(mktemp)"
  for _ in {1..24}; do
    if curl -fsSL -H 'Cache-Control: no-cache' "${url}?publish-check=$(date +%s)" -o "$tmp"; then
      if grep -Fq "$term" "$tmp"; then rm -f "$tmp"; return 0; fi
    fi
    sleep 5
  done
  rm -f "$tmp"
  fail "live page $url did not contain expected term: $term"
}

log "Verifying live site"
verify_url_contains "$PUBLIC_BASE_URL/" "XTimers"
verify_url_contains "$PUBLIC_BASE_URL/support.html" "mailto:admin@xintechllc.com"
verify_url_contains "$PUBLIC_BASE_URL/auth/complete.html" "xtimers-auth://auth/callback"
verify_url_contains "$PUBLIC_BASE_URL/auth/complete-pro.html" "xtimers-pro-auth://auth/callback"
verify_url_contains "$LEGACY_BASE_URL/" "XTimers"
verify_url_contains "$LEGACY_BASE_URL/sms-opt-in.html" "XTimers by Xintech LLC"
log "Verifying every localized page matches the immutable release snapshot"
python3 "$RELEASE_VERIFIER" \
  --source-root "$SOURCE_STAGE" --verify-live "$PUBLIC_BASE_URL" --poll-seconds 120
python3 "$RELEASE_VERIFIER" \
  --source-root "$SOURCE_STAGE" --verify-live "$LEGACY_BASE_URL" --poll-seconds 120
verify_url_contains "https://xintechllc.com/robots.txt" \
  "Sitemap: https://xintechllc.com/XTimers/sitemap.xml"
log "Checking canonical live compliance and callback semantics"
LIVE_BASE_URL="$PUBLIC_BASE_URL" \
  CANONICAL_PAGES_ROOT="$DEST_DIR_NEW" \
  LEGACY_PAGES_ROOT="$DEST_DIR_OLD" \
  "$SOURCE_STAGE/scripts/check-compliance-pages.sh"
log "Checking legacy live compliance and callback semantics"
LIVE_BASE_URL="$LEGACY_BASE_URL" \
  CANONICAL_PAGES_ROOT="$DEST_DIR_NEW" \
  LEGACY_PAGES_ROOT="$DEST_DIR_OLD" \
  "$SOURCE_STAGE/scripts/check-compliance-pages.sh"
log "XTimers website published: $PUBLIC_BASE_URL/ (legacy mirror: $LEGACY_BASE_URL/)"
