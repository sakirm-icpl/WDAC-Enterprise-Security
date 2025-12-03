# WDAC Policy Overview

## Policy Types

### 1. Base Policies
Foundation policies that define core rules for system-wide protection.

**Core Policy Files:**
- `BasePolicy.xml` - Generic base policy template
- `environment-specific/non-ad/policies/non-ad-base-policy.xml` - Non-AD optimized
- `environment-specific/active-directory/policies/enterprise-base-policy.xml` - AD optimized

### 2. Supplemental Policies
Department-specific policies that extend base policies with additional allowances.

**Location:**
- `environment-specific/*/policies/department-supplemental-policies/`

**Examples:**
- Finance department policies
- HR department policies
- IT department policies

### 3. Deny Policies
Explicitly block untrusted locations and applications.

**Core Files:**
- `DenyPolicy.xml` - Generic deny policy
- `TrustedApp.xml` - Explicitly trusted applications

### 4. Exception Policies
Temporary allowances for special circumstances.

**Location:**
- `environment-specific/*/policies/exception-policies/`

## Policy Structure

All policies follow the WDAC XML schema with these key elements:

```xml
<SiPolicy xmlns="urn:schemas-microsoft-com:sipolicy">
  <VersionEx>10.0.0.0</VersionEx>
  <PlatformID>{GUID}</PlatformID>
  <Rules>
    <!-- Policy rules -->
  </Rules>
  <SigningScenarios>
    <!-- Signing scenarios -->
  </SigningScenarios>
</SiPolicy>
```

## Policy Rules

### Common Rule Options
- `Enabled:Unsigned System Integrity Policy` - Allow unsigned policies
- `Enabled:Audit Mode` - Log violations without blocking
- `Enabled:Enforce Mode` - Block unauthorized applications
- `Enabled:UMCI` - User Mode Code Integrity

## Best Practices

1. **Always start with Audit Mode** for testing
2. **Use Base + Supplemental policy combinations** for flexibility
3. **Regular policy reviews** to remove obsolete rules
4. **Backup existing policies** before updates
5. **Document all customizations** for compliance

## Policy Templates

Ready-to-use templates are available in `examples/templates/`:
- `BasePolicy_Template.xml` - Starting point for base policies
- `DenyPolicy_Template.xml` - Template for deny policies
- `TrustedAppPolicy_Template.xml` - Template for trusted application policies