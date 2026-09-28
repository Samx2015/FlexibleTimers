# Flexible Timers

Public static pages for XTimers support, terms, privacy, privacy choices,
browser-extension privacy, SMS terms, and messaging compliance evidence.

## Source of truth and publishing

This repository is the editable **source** of the site. GitHub Pages serves two
generated mirrors from `Samx2015/Samx2015.github.io`: the canonical `XTimers/`
tree and the compatibility `FlexibleTimers/` tree. Neither generated tree is
an edit target. Edit here, then publish both mirrors together:

```sh
scripts/publish.sh            # rsync source -> Pages repo, commit/push, verify live
scripts/publish.sh --dry-run  # preview the file changes without writing
```

`publish.sh` first validates a temporary, non-publishing rendering of both
mirrors, then mirrors the source into the Pages checkout (preserving any
`download/` folder), makes one path-scoped commit in the Pages repo, and
verifies both live trees. The folders default to
`/Users/sam/GitHub/Samx2015.github.io/XTimers` and
`/Users/sam/GitHub/Samx2015.github.io/FlexibleTimers` (override with
`XTIMERS_PAGES_DIR` and `LEGACY_PAGES_DIR`).

Published pages:

- https://xintechllc.com/XTimers/ (canonical tree, including support, terms,
  privacy, compliance, and localized routes)
- https://xintechllc.com/FlexibleTimers/ (compatibility mirror of the same
  source; historical SMS and store URLs remain valid)
- https://xintechllc.com/XTimers/auth/complete.html (standard-app OAuth return)
- https://xintechllc.com/XTimers/auth/complete-pro.html (Pro OAuth return)

Xin Account uses the existing policy set rather than a separate portal. The
canonical app-configured links are:

- https://xintechllc.com/FlexibleTimers/privacy.html
- https://xintechllc.com/FlexibleTimers/terms.html
- https://xintechllc.com/XTimers/support.html

The OAuth completion pages deliberately load no analytics or third-party
resources. They accept only the current identity-provider response fields and
one of the two hard-coded XTimers callback schemes, remove the one-time response
from browser history, and then return control to the matching consumer app.
Their public presentation names Xin Account while the callback format remains
compatible with the retained provider integration during migration. Verify
their routing with:

```sh
node scripts/test-auth-complete.js
```

Run this after publishing changes to verify both deploy trees, the reconciled
privacy and click-driven callback semantics, public messaging evidence pages,
support URL, consent-before-verification and verified owner-reminder SMS scope,
truthful keyword instructions, no-marketing claims, and sitemap entries.
Use `--source-only` while authoring; `publish.sh --dry-run` performs the
source/deploy semantic checks against one immutable temporary snapshot without
changing either Pages tree:

```sh
scripts/check-compliance-pages.sh
scripts/check-compliance-pages.sh --source-only
```

## Localization authoring

The generated website inventory and translation packages under `generated/`
come from the canonical manifest in the sibling `TimerWorkspace` repository.
Website translation drafts are deliberately separate from publication: they
must pass the local checks and the cross-repository qualified-review ledger
before any localized pages are eligible to deploy.
`scripts/publish.sh` enforces that cross-repository release gate before any
rsync, commit, or push operation.

```sh
python3 -m pip install -r requirements-localization.txt
python3 scripts/prepare-localized-page-drafts.py --extract
python3 scripts/prepare-localized-page-drafts.py --import-existing
python3 scripts/prepare-localized-page-drafts.py --prune-obsolete-translations
python3 scripts/prepare-localized-page-drafts.py \
  --import-alarm-terms-from ../FlexibleTimersSwiftUI/Sources/FlexibleTimersSwiftUI/Resources
python3 scripts/prepare-localized-page-drafts.py --apply-reviewed-corrections
python3 scripts/prepare-localized-page-drafts.py --generate
python3 scripts/generate-localization-navigation.py
scripts/check-localizations.sh \
  --alarm-term-source ../FlexibleTimersSwiftUI/Sources/FlexibleTimersSwiftUI/Resources \
  --alarm-term-source ../FlexibleTimersiOS/Sources/FlexibleTimersiOS/Resources
```

The `--import-existing` command is a one-time migration aid: it recovers the
five historically localized pages against the English revisions they were
authored from. Generation now produces eight pages per non-English locale,
including Terms, Privacy Choices, and the Activity Extension Privacy Policy.
`compliance.html` is intentionally English-only carrier/compliance evidence;
it has one legacy-path canonical URL, is included once in the sitemap, and must
not have locale variants.
The alarm-term import copies only the central alarm UI glossary (`Rings On`,
`This Device`, and scheduling states) from the completed app catalogs. The
hash-bound reviewed correction artifacts are then replayed so independently
reviewed full legal values and alarm-label corrections supersede machine-draft
copy deterministically. The localization checker requires every policy
reference to use those same localized terms and verifies each app's supported
glossary-key intersection, avoiding a second website-specific name for an app
control. Supplying a missing or invalid app resource root is a hard failure;
the workspace release gate must pass both roots shown above.
The shared draft tool fills only current-source gaps. None of these commands
publishes or modifies the GitHub Pages repository.

## Current landing-page design

`index.html` and `flexible-timers.html` share the approved landing-page layout.
All 44 non-English routes are generated from that same structure and use the
shared styles, script, feature icons and native captures in `assets/marketing/`.
Captions, image descriptions and navigation accessibility labels are translated;
the pixels of the native application screenshots are retained.

The September 28 landing-page translation delta is recorded in
`generated/LandingTranslations20260928/`. Each packet contains 380 directly
GPT-authored strings and its source checksum and semantic-review record. The
importer retains the 219 existing, previously reviewed support/policy values
and rejects incomplete, mismatched or invalid packets. These packets remain
bound to the historical source snapshot; do not reimport them over later deltas.
Regenerate the current catalog-backed pages with:

```sh
python3 scripts/prepare-localized-page-drafts.py --generate
python3 scripts/generate-localization-navigation.py
python3 scripts/generate-website-value-provenance.py
```

The subsequent glossary alignment in
`generated/WebsiteAlarmLabelReview20260928.json` records 28 scoped corrections
across Arabic, Czech, German, French, Hungarian and Turkish. The labels match
the current Mac and iOS app catalogs; the record includes the directly
GPT-reviewed old/new values, associated headings and policy references. These
corrections are already included in the full translation authorities.

These commands do not grant release approval. Publication still uses the full
workspace release gate and its source-bound review evidence. Historical review
ledgers remain immutable; the historical landing-page review is recorded under
`TimerWorkspace/Docs/Localization/ReleaseReviews/Website20260928/`.
Later deltas require their own source-bound review bundle, selected for the
release gate with `XTIMERS_WEBSITE_RELEASE_REVIEW`.
Design studies and screenshot-capture tooling stay outside the published source.
The obsolete `preview-3-5.html` study is removed.

The marketing delta in `generated/MarketingTranslations20260928/` adds 13
directly authored and semantically reviewed strings per locale. It retains 594
unchanged reviewed values and retires five obsolete values, producing 607 current
values per locale. The packets and full authorities distinguish the new review
from retained evidence; they do not claim a native-speaker review.

Availability is a September 28, 2026 snapshot: Mac 3.4 is public, while the
feature imagery previews Mac 3.5 and the unreleased iPhone/iPad app. The header
retains a visible Mac download action on compact screens. The approved hero
artwork and removal of its separate action buttons remain unchanged.

Mac download links use the exact Apple-generated `website_mac` campaign URL.
The existing Umami `App Store Click` event now includes placement, platform and
locale; mobile-preview exploration has its own event. Clicks are not installs.
Guides and the press kit are explicitly English resources linked from every
homepage; their five canonical URLs are included in the sitemap.

`scripts/generate-marketing-renditions.py` uses Pillow with WebP support to
create lossless display renditions and the shared English social card. It
preserves every original PNG and zoom target. The source hashes, dimensions,
output hashes and aggregate transfer comparison are recorded in
`generated/MarketingMedia20260928.json`; browser selection depends on viewport
and pixel density. The shared card labels the Mac 3.5 preview and current Mac
3.4 availability. Localized metadata identifies the card's English artwork.
