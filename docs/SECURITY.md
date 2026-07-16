# Security

- The wrapper exposes an allowlisted browser command surface only.
- Profiles and daemon state are owner-only and separate from personal browser profiles.
- Cookie import, arbitrary JavaScript, custom headers, uploads, CDP, tunnels, and headed mode are blocked.
- Page content is untrusted; user instructions are the only authority.
- Chromium sandboxing is required by default. `--allow-no-sandbox` creates an explicit local approval marker and must be used only when the host cannot provide user namespaces. It materially weakens browser isolation.
- Never publish generated runtime artifacts containing host-specific files, profiles, logs, cookies, or browser state.
