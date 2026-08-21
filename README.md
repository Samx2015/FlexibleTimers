# Flexible Timers

Public static pages for Flexible Timers support, SMS terms, privacy, and
messaging compliance evidence.

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
support URL, exact keyword responses, verified owner-only reminder SMS scope,
no-marketing claims, and sitemap entries. `publish.sh --dry-run` performs the
same source/deploy semantic checks against temporary mirrors without changing
either Pages tree:

```sh
scripts/check-compliance-pages.sh
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
python3 scripts/prepare-localized-page-drafts.py --generate
python3 scripts/generate-localization-navigation.py
scripts/check-localizations.sh
```

The `--import-existing` command is a one-time migration aid: it recovers
checked-in translations against the historical English page revisions they
were authored from, preserving them while the shared draft tool fills only
current-source gaps. None of these commands publishes or modifies the GitHub
Pages repository.
