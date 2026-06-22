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

Run this after publishing changes to verify the public Twilio evidence pages,
support URL, exact keyword responses, verified owner-only reminder SMS scope,
no-marketing claims, and sitemap entries:

```sh
scripts/check-compliance-pages.sh
```
