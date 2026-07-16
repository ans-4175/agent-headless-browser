# Third-party notices

## gstack

This package vendors a pinned source archive from [gstack](https://github.com/garrytan/gstack), commit `9fd03fae9e74f5daa7a138366aca8f86c7367c5c`. gstack is MIT licensed; its original `LICENSE` is retained inside `vendor/gstack-browse-source.tar.gz` and must remain present in source and derivative distributions.

## Playwright

The installer downloads Playwright as a runtime dependency. Playwright is licensed under Apache License 2.0. Release artifacts must retain its distributed notices and license material from the installed package.

## Chromium

The installer downloads a matching Chromium build through Playwright. Chromium has a BSD-style primary license plus third-party notices. Do not strip Chromium `LICENSE`, `ABOUT`, or `ThirdPartyNotices` files from runtime artifacts.

## Bun

Bun is downloaded only as a temporary build tool and is not included in the installed runtime. Follow Bun's upstream licensing and redistribution terms when changing that behavior.
