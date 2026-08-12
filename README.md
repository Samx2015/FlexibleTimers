# Flexible Timers

Public static pages for Flexible Timers support, SMS terms, privacy, and
messaging compliance evidence.

## Source of truth and publishing

This repository is the editable **source** of the site. The live site is served
by GitHub Pages from `Samx2015/Samx2015.github.io` (folder `FlexibleTimers/`),
not from this repo directly. Edit here, then publish:

```sh
scripts/publish.sh            # rsync source -> Pages repo, commit/push, verify live
scripts/publish.sh --dry-run  # preview the file changes without writing
```

`publish.sh` mirrors the source into the Pages checkout (preserving any
`download/` folder), makes a path-scoped commit in the Pages repo, and verifies
the live URLs. The Pages folder defaults to
`/Users/sam/GitHub/Samx2015.github.io/FlexibleTimers` (override with
`FLEXIBLETIMERS_PAGES_DIR`).

Published pages:

- https://xintechllc.com/FlexibleTimers/
- https://xintechllc.com/FlexibleTimers/support.html
- https://xintechllc.com/FlexibleTimers/terms.html
- https://xintechllc.com/FlexibleTimers/sms-opt-in.html
- https://xintechllc.com/FlexibleTimers/sms-terms.html
- https://xintechllc.com/FlexibleTimers/privacy.html
- https://xintechllc.com/FlexibleTimers/compliance.html
- https://xintechllc.com/XTimers/auth/complete.html (standard-app OAuth return)
- https://xintechllc.com/XTimers/auth/complete-pro.html (Pro OAuth return)

The OAuth completion pages deliberately load no analytics or third-party
resources. They accept only a Supabase OAuth response and one of the two
hard-coded XTimers callback schemes, remove the one-time response from browser
history, and then return control to the matching app. Verify their routing with:

```sh
node scripts/test-auth-complete.js
```

Run this after publishing changes to verify the public Twilio evidence pages,
support URL, exact keyword responses, verified owner-only reminder SMS scope,
no-marketing claims, and sitemap entries:

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
