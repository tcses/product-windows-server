# CampusNexus Staff STS Notes

Operational notes for Staff STS install/runtime based on legacy KB.

---

## Runtime Configuration

- Use IIS UI or edit `web.config` directly for appSettings.

---

## Known Errors

### Relying Parties Misconfigured

Symptoms:
- Staff STS errors about relying parties

Fix:
- Update relying parties in `web.config` or via IIS config UI.

### API Endpoint Misconfigured

Symptoms:
- Staff STS errors pointing to API server endpoint

Fix:
- Ensure the API endpoint in `web.config` points to the correct API server.

### Clock Skew Error

Symptoms:
- "Specified Argument was out of the range of valid values. Parameter name: validFrom"

Fix:
- Sync server time with domain controller.
- Ensure Windows Time Service is running and set to automatic.

---

## Certificate Rotation

- Update thumbprints in **Staff STS** and **Web Client** `web.config`.
- Update IIS bindings for the new cert.
- Grant private key access to `IIS_IUSRS`.
- Recycle the Staff STS app pool after rotation.

---

## Logging

- Set `nlog.config` to `trace`.
- Create `/log/` in Staff STS web root and grant write permissions to `IIS_IUSRS`.

---

## Legacy Portal Compatibility

- Only run a single Staff STS instance so Installation Manager updates are consistent.
- Legacy portal settings are stored in Staff STS `web.config`.
