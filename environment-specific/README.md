# Environment-Specific WDAC Policies and Scripts

This directory contains environment-specific Windows Defender Application Control (WDAC) policies and scripts tailored for different deployment scenarios including Active Directory, non-AD, and hybrid environments.

## Directory Structure

```
environment-specific/
├── active-directory/
│   ├── policies/
│   │   ├── enterprise-base-policy.xml
│   │   ├── department-supplemental-policies/
│   │   │   ├── finance-policy.xml
│   │   │   ├── hr-policy.xml
│   │   │   └── it-policy.xml
│   │   └── exception-policies/
│   │       └── emergency-access-policy.xml
│   ├── scripts/
│   │   ├── deploy-ad-policy.ps1
│   │   ├── update-ad-policy.ps1
│   │   └── monitor-ad-systems.ps1
│   └── documentation/
│       └── ad-deployment-guide.md
├── non-ad/
│   ├── policies/
│   │   ├── non-ad-base-policy.xml
│   │   ├── department-supplemental-policies/
│   │   │   ├── finance-policy.xml
│   │   │   ├── hr-policy.xml
│   │   │   └── it-policy.xml
│   │   └── exception-policies/
│   │       └── emergency-access-policy.xml
│   ├── scripts/
│   │   ├── deploy-non-ad-policy.ps1
│   │   ├── update-non-ad-policy.ps1
│   │   └── monitor-non-ad-systems.ps1
│   └── documentation/
│       └── non-ad-environment-guide.md
├── hybrid/
│   ├── policies/
│   │   └── (Placeholder for hybrid policies)
│   ├── scripts/
│   │   └── (Placeholder for hybrid scripts)
│   └── documentation/
│       └── hybrid-environment-guide.md
└── shared/
    ├── scripts/
    │   └── wdac-utils.ps1
    ├── templates/
    │   ├── base-policy-template.xml
    │   ├── supplemental-policy-template.xml
    │   └── exception-policy-template.xml
    └── utilities/
        ├── policy-validator.ps1
        ├── compliance-reporter.ps1
        └── audit-log-analyzer.ps1
```