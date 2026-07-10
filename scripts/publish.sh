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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST_DIR_NEW="${XTIMERS_PAGES_DIR:-/Users/sam/GitHub/Samx2015.github.io/XTimers}"
DEST_DIR_OLD="${LEGACY_PAGES_DIR:-${FLEXIBLETIMERS_PAGES_DIR:-/Users/sam/GitHub/Samx2015.github.io/FlexibleTimers}}"
PUBLIC_BASE_URL="${PUBLIC_BASE_URL:-https://xintechllc.com/XTimers}"
LEGACY_BASE_URL="${LEGACY_BASE_URL:-https://xintechllc.com/FlexibleTimers}"

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

# Safety guards: never sync from/to an empty path or a filesystem root.
[[ -n "$SOURCE_DIR" && -n "$DEST_DIR_NEW" && -n "$DEST_DIR_OLD" ]] || fail "empty source or destination path"
[[ "$SOURCE_DIR" != "/" && "$DEST_DIR_NEW" != "/" && "$DEST_DIR_OLD" != "/" ]] || fail "refusing to sync filesystem root"
[[ -d "$SOURCE_DIR" ]] || fail "source missing: $SOURCE_DIR"
[[ -d "$DEST_DIR_OLD" ]] || fail "legacy destination missing: $DEST_DIR_OLD (create the Pages folder first)"
mkdir -p "$DEST_DIR_NEW"
[[ -f "$SOURCE_DIR/index.html" ]] || fail "source does not look like the website: $SOURCE_DIR"

IO_REPO="$(git -C "$DEST_DIR_OLD" rev-parse --show-toplevel 2>/dev/null)" \
  || fail "destination is not inside a git repo: $DEST_DIR_OLD"

# rsync: full mirror, minus VCS/junk and this deploy tool (keeps local paths off
# the live site). Preserve an existing download/ folder when the source has none,
# so hosted release assets are never wiped (matches HelperSuite safe_website_rsync).
publish_to() {
  local dest="$1"
  local rsync_args=(-a --delete
    --exclude '.git'
    --exclude '.DS_Store'
    --exclude '.gitignore'
    --exclude '.nojekyll'
    --exclude 'README.md'
    --exclude 'scripts/publish.sh')
  [[ -d "$SOURCE_DIR/download" ]] || rsync_args+=(--exclude 'download')
  [[ "$DRY_RUN" -eq 1 ]] && rsync_args+=(--dry-run --itemize-changes)
  log "Syncing XTimers website -> $dest"
  rsync "${rsync_args[@]}" "$SOURCE_DIR"/ "$dest"/
}

publish_to "$DEST_DIR_NEW"
publish_to "$DEST_DIR_OLD"

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "Dry run complete; no commit or push performed."
  exit 0
fi

# Path-scoped commit so unrelated changes in the Pages repo are left alone.
if [[ -z "$(git -C "$IO_REPO" status --porcelain -- "$DEST_DIR_NEW" "$DEST_DIR_OLD")" ]]; then
  log "No website changes to publish."
else
  log "Committing and pushing Pages repo"
  git -C "$IO_REPO" add -- "$DEST_DIR_NEW" "$DEST_DIR_OLD"
  git -C "$IO_REPO" commit -q -m "Publish XTimers website (canonical + legacy mirror)"
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
verify_url_contains "$LEGACY_BASE_URL/" "XTimers"
verify_url_contains "$LEGACY_BASE_URL/sms-opt-in.html" "Flexible Timers"
log "XTimers website published: $PUBLIC_BASE_URL/ (legacy mirror: $LEGACY_BASE_URL/)"
