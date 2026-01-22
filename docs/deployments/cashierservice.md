# Cashier Service Deployment

## Overview

Cashier has two deployment paths:

- **Web MVC**: Hosted in AWS (cloud).
- **API/LegacyService**: On-prem IIS deployments for test and production.

Elastic Beanstalk + Terraform + GitHub Actions apply to the cloud-hosted web MVC tier.

---

## Workflows

### LegacyService (On-Prem IIS)

#### Test

- Workflow: [`.github/workflows/legacyservice-deploy-test.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/legacyservice-deploy-test.yml)
- Build: `windows-latest`
- Deploy runner group: `app-dev-desktops`
- Targets: `EG-WEBAPPS-05`, `EG-WEBAPPS-06` via Web Deploy (`CashierServiceTest`)

#### Production

- Workflow: [`.github/workflows/legacyservice-deploy-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/legacyservice-deploy-prod.yml)
- Build: `windows-latest`
- Deploy runner group: `app-dev-desktops`
- Targets: `EG-WEBAPPS-05`, `EG-WEBAPPS-06` via Web Deploy (`CashierService`)

### Web MVC (AWS Elastic Beanstalk)

- Workflow: [`.github/workflows/aws-ebs-deploy-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/aws-ebs-deploy-prod.yml)
- Uses reusable workflow: [`tcses/src-github-ci-template/.github/workflows/dotnet-4.7-deploy-ebs.yml@main`](https://github.com/tcses/src-github-ci-template/blob/main/.github/workflows/dotnet-4.7-deploy-ebs.yml)

### Terraform (AWS Infrastructure)

- Workflow: [`.github/workflows/terraform-prod.yml`](https://github.com/tcses/src-net-cashierservice/blob/main/.github/workflows/terraform-prod.yml)
- Runs `terraform plan/apply` on `ubuntu-latest` with OIDC
