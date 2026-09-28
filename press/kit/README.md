# XTimers press kit

Prepared September 28, 2026 for coverage of XTimers by Xintech LLC.

## Start here

- `descriptions.md`: ready-to-use product descriptions, availability and credit.
- `facts.json`: dated public-release facts and official source links.
- `asset-manifest.json`: exact source provenance, dimensions and SHA-256 hashes.
- `captions.csv`: captions and image credit for every packaged image.
- `brand/`: the existing 1024 × 1024 XTimers app icon.
- `screenshots/mac-3.5-preview/`: ten approved English marketing compositions, 2880 × 1800 PNG.
- `native/mac-3.5-preview/`: six unchanged native PNG captures for flexible editorial layouts.
- `video/`: genuine 40-second silent walkthrough, poster, English WebVTT, descriptive transcript and sanitized public provenance.
- `checksums.sha256`: checksums of all kit files except the checksum file itself.

## Version context

**The current public Mac release is 3.4.0. Every app screenshot in this kit shows the unreleased Mac 3.5.0 candidate (build 151).** Keep that preview label when using an image. The images contain simulated local tasks and session history, not customer data. The ten composed images combine separate genuine app captures; the native files retain the original pixels and framing.

The current US Mac App Store download is free and requires macOS 13 or later. This does not establish that every optional connected service is free. The iPhone and iPad apps are in preparation and have not been publicly released. No Mac 3.5 or mobile release date is announced here.

The video contains native recordings from Mac 3.5 candidate **builds 151 and 152**: task start and menu bar from 151, reports from 152. The pre-existing 30-hour sample report week is separate from the short Planning run. Captions are baked into the silent video; a selectable WebVTT track and descriptive transcript are also provided.

Credit: Xintech LLC. Contact: admin@xintechllc.com.

Official press page: https://xintechllc.com/XTimers/press/

## Package maintenance

The repository version of this directory is the editable package. After an approved asset or fact update, run `python3 press/rebuild-package.py` from the FlexibleTimers repository. It verifies media hashes, refreshes `checksums.sha256`, and creates the downloadable ZIP from this directory only. Replacing candidate screenshots with a public release requires revising the facts and labels first.
