# Authenticated QA design

## Goal

Support QA flows that must be performed after signing in, without weakening the browser's core isolation boundary or exposing session credentials to agent tooling.

## Chosen approach

The browser continues to use its existing owner-only, isolated persistent Chromium profile at `~/.agent-headless-browser/chromium-profile`. A site may set its own normal session cookies during an explicitly approved interactive login. Chromium persists those cookies in this dedicated profile, so later QA runs can use the authenticated state. This is already how the installed runtime launches Chromium; no cookie or storage command needs to be exposed.

Authentication is restricted to a dedicated QA/test account. It requires explicit human approval that names the target site, account purpose, and intended QA outcome before any credential entry or login action. The agent must not use a personal or production account, import cookies, read/export cookies or storage, use a personal browser profile, upload files, handle payments, or change account/security settings. Each later state-changing QA action remains subject to its own explicit approval.

## Policy and documentation changes

The command wrapper stays unchanged: `fill`, `type`, `click`, `select`, and `press` are already allowlisted; cookie/storage/import commands remain blocked. Update the README, installation/security documentation, and every adapter skill to make the distinction clear: normal website-set login sessions are supported only after explicit approval, while programmatic cookie/storage access remains prohibited. Also correct the audit interpretation: `hasCookies` reports cookie imports, not all cookies in the browser context.

## Verification

Verify the install checksum and that Chromium sandboxing remains required. Confirm the persistent profile exists with owner-only permissions. Do not perform a real login in the repository verification; an authenticated smoke test requires a user-approved target and dedicated QA account. Stop the daemon after testing.
