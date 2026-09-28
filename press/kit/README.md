# XTimers 3.5.0 press kit

Prepared September 28, 2026 for coverage of XTimers by Xintech LLC.

## Start here

- `descriptions.md`: ready-to-use product descriptions, platform details and credit.
- `facts.json`: product facts and official source links.
- `asset-manifest.json`: exact source provenance, dimensions and SHA-256 hashes.
- `captions.csv`: captions and image credit for every packaged image.
- `brand/`: the existing 1024 × 1024 XTimers app icon.
- `screenshots/mac-3.5.0/`: ten English feature compositions, 2880 × 1800 PNG.
- `native/mac-3.5.0/`: six unchanged native PNG captures for flexible editorial layouts.
- `video/`: genuine 40-second silent walkthrough, poster, English WebVTT, descriptive transcript and public provenance.
- `checksums.sha256`: checksums of all kit files except the checksum file itself.

## Product and media

XTimers 3.5.0 brings timers, countdowns, world clocks and reports into one Mac workspace. The Mac app requires macOS 13 or later. The US Mac App Store download price is free; connected services have separate eligibility and terms.

The screenshots show XTimers 3.5.0, capture build 151, with sample local tasks and session history. The ten composed images combine separate genuine app captures; the native files retain their original pixels and framing.

The video contains native recordings from builds 151 and 152: task start and menu bar from 151, reports from 152. The existing 30-hour sample report week is separate from the short Planning run. Captions are baked into the silent video; a selectable WebVTT track and descriptive transcript are also provided. Capture dates, build identities and source hashes remain in the provenance files.

Credit: Xintech LLC. Contact: admin@xintechllc.com.

Official press page: https://xintechllc.com/XTimers/press/

## Package maintenance

The repository version of this directory is the editable package. After an approved asset or fact update, run `python3 press/rebuild-package.py` from the FlexibleTimers repository. It verifies media hashes, refreshes `checksums.sha256`, and creates the downloadable ZIP from this directory only.
