# Deployment Configuration

This section documents how application deployments are currently executed for Windows-hosted services and related AWS workloads.

---

## Current Deployment Patterns

### GitHub Actions + Local Runners (Windows)

Deployments are orchestrated via GitHub Actions and executed on local, self-hosted Windows runners for:

- Academic Portal (test and production)
- AIM Powertools API (test and production)
- Cashier legacy service (test and production)

Runners push artifacts to the target IIS hosts (EG-* today, PRD-* planned) using environment-specific configurations.

---

### Cashiering Site (Windows, AWS)

- **Web MVC**: Hosted in AWS (cloud).
- **API Service**: On-prem IIS deployments for test and production.

Elastic Beanstalk + Terraform + GitHub Actions apply to the cloud-hosted web MVC tier.

---

## Workflow Inventory (Repo Paths + Runners)

### Academic Portal (`src-net-academic-portal`)

- **Prod**: [`.github/workflows/prod-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/prod-deploy.yml)  
  Uses reusable workflow [`tcses/src-github-ci-template/.github/workflows/deploy-release-IIS.yml@main`](https://github.com/tcses/src-github-ci-template/blob/main/.github/workflows/deploy-release-IIS.yml) with MSDeploy targets.  
  Targets: `EG-WEBAPPS-01..04` via Web Deploy endpoints.
- **Test**: [`.github/workflows/test-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/test-deploy.yml)  
  Build runs on `windows-latest`; deploy runs on runner group `Windows-Build-Deploy-DevTest`.
- **Dev**: [`.github/workflows/dev-deploy.yml`](https://github.com/tcses/src-net-academic-portal/blob/main/.github/workflows/dev-deploy.yml)  
  Build runs on `windows-latest`; deploy runs on runner group `Windows-Build-Deploy-DevTest` (targets `CH-WEBAPPS-01`).

### AIM Powertools API (`src-nodejs-tcses-powertools`)

- **Test**: [`.github/workflows/deploy-test-servers.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/deploy-test-servers.yml)  
  Build runs on `ubuntu-latest`; deploy runs on runner group `App-Dev-Desktops`  
  Targets: `CH-WEBAPPS-01`, `CH-WEBAPPS-02` via `SharedDeployFolder`.
- **Prod**: [`.github/workflows/deploy-release-iis-prod.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/deploy-release-iis-prod.yml)  
  Deploy runs on runner group `Windows-Build-Deploy` to `EG-WEBAPPS-01..04` via `SharedDeployFolder`.
- **Release**: [`.github/workflows/release-dotnet-api.yml`](https://github.com/tcses/src-nodejs-tcses-powertools/blob/main/.github/workflows/release-dotnet-api.yml)  
  Builds and publishes release artifacts (tagged).

### Cashier LegacyService (`src-net-cashierservice`)

- **Test**: [`.github/workflows/legacyservice-deploy-test.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/legacyservice-deploy-test.yml)  
  Build runs on `windows-latest`; deploy runs on runner group `app-dev-desktops`  
  Targets: `EG-WEBAPPS-05`, `EG-WEBAPPS-06` via Web Deploy (`CashierServiceTest`).
- **Prod**: [`.github/workflows/legacyservice-deploy-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/legacyservice-deploy-prod.yml)  
  Build runs on `windows-latest`; deploy runs on runner group `app-dev-desktops`  
  Targets: `EG-WEBAPPS-05`, `EG-WEBAPPS-06` via Web Deploy (`CashierService`).

### Cashier Site (AWS Elastic Beanstalk + Terraform) (`src-net-cashierservice`)

- **EBS Deploy**: [`.github/workflows/aws-ebs-deploy-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/aws-ebs-deploy-prod.yml)  
  Uses reusable workflow [`tcses/src-github-ci-template/.github/workflows/dotnet-4.7-deploy-ebs.yml@main`](https://github.com/tcses/src-github-ci-template/blob/main/.github/workflows/dotnet-4.7-deploy-ebs.yml).
- **Terraform**: [`.github/workflows/terraform-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/terraform-prod.yml)  
  Runs `terraform plan/apply` on `ubuntu-latest` with OIDC.

---

## Notes

- This repo documents deployment behavior only. Changes are executed in automation repos or manually, then recorded here.
- Update this section when deployment tools, runners, or environments change.
