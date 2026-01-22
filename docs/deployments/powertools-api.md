# AIM Powertools API Deployment

## Overview

Powertools API deployments use GitHub Actions to build releases and deploy to on-prem IIS servers via shared deploy folders.

---

## Workflows

### Test

- Workflow: [`.github/workflows/deploy-test-servers.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/deploy-test-servers.yml)
- Build: `ubuntu-latest`
- Deploy runner group: `App-Dev-Desktops`
- Targets: `CH-WEBAPPS-01`, `CH-WEBAPPS-02` via `SharedDeployFolder`

### Production

- Workflow: [`.github/workflows/deploy-release-iis-prod.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/deploy-release-iis-prod.yml)
- Deploy runner group: `Windows-Build-Deploy`
- Targets: `EG-WEBAPPS-01..04` via `SharedDeployFolder`

### Release

- Workflow: [`.github/workflows/release-dotnet-api.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/release-dotnet-api.yml)
- Creates tagged release artifacts
