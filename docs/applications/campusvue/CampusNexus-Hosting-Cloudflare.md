# CampusNexus Hosting: Cloudflare + IIS

Digest of hosting/WAF/DNS notes for CampusNexus.

---

## Hosting Stack

- CampusNexus Web Client runs on on-prem IIS servers.
- Cloudflare provides CDN + WAF.
- Traffic is load balanced to IIS origin pools.

---

## IIS Logging: True Client IP

Add these custom IIS log fields:

- `CF-Connecting-IP`
- `True-Client-IP`
- `X-Forwarded-For`
- `CF-RAY`
- `CF-IPCountry`

---

## Firewall / Edge Allowlist

- Only allow inbound 443 from Cloudflare IP ranges.
- If legacy proxy/tunnel IPs are still in use, include them in the allowlist.

---

## Cloudflare Page Rules

Rocket Loader can break Staff STS Content Security Policy:

- Symptom: CSP blocks `rocket-loader.min.js`
- Fix: Disable Rocket Loader for Staff STS hostnames

---

## Cloudflare Firewall Rules

- Use geo-fencing as needed (example: US-only).

---

## Railgun Deprecation

- Railgun is deprecated.
- Current proxy/tunneling uses Cloudflared (documented elsewhere).
