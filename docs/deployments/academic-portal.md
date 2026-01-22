# Academic Portal Deployment

## Overview

Academic Portal deployments are run via GitHub Actions and target on-prem IIS servers using MSDeploy.

---

## Workflows

### Production

- Workflow: [`.github/workflows/prod-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/prod-deploy.yml)
- Uses reusable workflow: [`tcses/src-github-ci-template/.github/workflows/deploy-release-IIS.yml@main`](https://github.com/tcses/src-github-ci-template/blob/main/.github/workflows/deploy-release-IIS.yml)
- Targets: `EG-WEBAPPS-01..04` via Web Deploy endpoints

### Test

- Workflow: [`.github/workflows/test-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/test-deploy.yml)
- Build: `windows-latest`
- Deploy runner group: `Windows-Build-Deploy-DevTest`

### Dev

- Workflow: [`.github/workflows/dev-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/dev-deploy.yml)
- Build: `windows-latest`
- Deploy runner group: `Windows-Build-Deploy-DevTest`
- Targets: `CH-WEBAPPS-01`
