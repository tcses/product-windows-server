# CampusNexus Core API Services

Core API requirements and known install issues.

---

## WCF HTTP Activation Required

Symptoms:
- Web client errors referencing WCF web services

Fix:
- Enable **Windows Communication Foundation HTTP Activation** in IIS features.

---

## Microsoft.Build.Tasks 2.0 Error

Symptoms:
- Build task failures in legacy .NET components

Fix:
- Install .NET 3.5 components.
- On Server 2019, this may require mounting a Windows ISO to install.
