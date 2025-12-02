# WDAC Policy Rule Types Comparison Matrix

This document compares the different WDAC policy rule types to help you choose the most appropriate approach for your environment.

## Rule Type Comparison

| Rule Type | Security Level | Maintenance Effort | Performance Impact | Flexibility | Best Use Cases |
|-----------|----------------|-------------------|-------------------|-------------|----------------|
| Publisher Rules | High | Low | Low | High | Enterprise environments with signed applications |
| File Path Rules | Medium | Medium | Medium | Medium | Controlled environments with organized file structures |
| File Hash Rules | Very High | Very High | Medium-High | Low | Highly secure environments, unsigned applications |
| File Attributes Rules | Medium-High | Low-Medium | Low | High | Applications with consistent metadata |

## Detailed Analysis

### Publisher Rules

**Pros:**
- Automatically covers application updates from the same publisher
- Low maintenance as new versions are automatically allowed
- Good performance with minimal policy size impact
- Works well with enterprise software vendors

**Cons:**
- Requires applications to be digitally signed
- Less granular control over specific application versions
- May allow unintended applications from the same publisher

**Example:**
```xml
<Allow ID="ID_ALLOW_MS_PUBLISHER" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
  <Signer Id="ID_SIGNER_MS">
    <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
    <CertPublisher Value="Microsoft Corporation" />
  </Signer>
</Allow>
```

### File Path Rules

**Pros:**
- Simple to understand and implement
- Good for organized file structures
- Moderate maintenance requirements
- Can be combined with other rule types

**Cons:**
- Vulnerable to path traversal attacks
- Applications can be bypassed by moving them to allowed paths
- Requires disciplined file organization

**Example:**
```xml
<Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
```

### File Hash Rules

**Pros:**
- Highest security level - only specific files can execute
- Immune to file renaming or moving
- Works with unsigned applications
- Precise control over allowed executables

**Cons:**
- High maintenance when applications are updated
- Larger policy files
- Must create new rules for each application version
- Performance impact with many hash rules

**Example:**
```xml
<Allow ID="ID_ALLOW_SPECIFIC_FILE" FriendlyName="Specific Application" Hash="9F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F" />
```

### File Attributes Rules

**Pros:**
- Flexible combination of file properties
- Good balance of security and maintainability
- Can specify minimum file versions
- Works with both signed and unsigned files

**Cons:**
- Less precise than hash rules
- May allow unintended files with matching attributes
- Requires understanding of file metadata

**Example:**
```xml
<FileAttrib ID="ID_FILEATTRIB_CUSTOM" FriendlyName="Custom Application" FileName="customapp.exe" MinimumFileVersion="1.0.0.0" />
```

## Policy Approach Comparison

| Approach | Security Level | Implementation Complexity | Maintenance Effort | Deployment Risk | Best For |
|----------|----------------|--------------------------|-------------------|----------------|----------|
| Permissive | Low | Low | Low | Low | Initial testing, less security-conscious environments |
| Moderate | Medium | Medium | Medium | Medium | Standard enterprise deployments |
| Restrictive | High | High | High | High | Highly secure environments, compliance requirements |

### Permissive Approach

**Characteristics:**
- Allow broad categories (all Microsoft apps, all Program Files)
- Minimal deny rules
- Focus on blocking clearly malicious locations

**When to Use:**
- Initial WDAC implementation
- Environments with many legacy applications
- Organizations new to application control

### Moderate Approach

**Characteristics:**
- Publisher rules for trusted vendors
- Path rules for organized applications
- Targeted deny rules for high-risk locations
- Supplemental policies for exceptions

**When to Use:**
- Standard enterprise environments
- Organizations with established software approval processes
- Balanced security and usability requirements

### Restrictive Approach

**Characteristics:**
- Primarily hash-based rules
- Comprehensive deny policies
- Minimal allowed locations
- Extensive exception management

**When to Use:**
- High-security environments (finance, healthcare, government)
- Compliance requirements (SOX, HIPAA, PCI-DSS)
- Zero-trust security models

## Performance Comparison

| Aspect | Publisher Rules | Path Rules | Hash Rules | Attributes Rules |
|--------|----------------|------------|------------|------------------|
| Policy Size | Small | Small | Large (many hashes) | Small-Medium |
| Processing Speed | Fast | Medium | Slow (with many hashes) | Fast |
| Memory Usage | Low | Low | Medium-High | Low |
| Policy Load Time | Fast | Fast | Slow (with many hashes) | Fast |

## Maintenance Comparison

| Task | Publisher Rules | Path Rules | Hash Rules | Attributes Rules |
|------|----------------|------------|------------|------------------|
| Adding New Apps | Automatic (same publisher) | Manual path setup | Manual hash creation | Manual attribute definition |
| Application Updates | Automatic | May require updates | Manual for each version | Manual if version restrictions apply |
| Policy Updates | Infrequent | Occasional | Frequent | Occasional |
| Complexity | Low | Medium | High | Medium |

## Recommendations by Environment

### Small Business
- **Primary**: Publisher rules for major software vendors
- **Secondary**: Path rules for trusted directories
- **Deny**: Downloads and temporary folders

### Enterprise
- **Primary**: Publisher rules for enterprise software
- **Secondary**: Path rules for internal applications
- **Tertiary**: Hash rules for critical unsigned applications
- **Deny**: User directories, removable media

### Highly Secure/Government
- **Primary**: Hash rules for all executables
- **Secondary**: Publisher rules where signing is available
- **Deny**: Comprehensive blocking of non-essential locations
- **Supplemental**: Department-specific policies

## Hybrid Approach (Recommended)

For most environments, a hybrid approach works best:

1. **Base Policy**: Publisher rules for Microsoft and major vendors
2. **Supplemental Policy 1**: Path rules for internal applications
3. **Supplemental Policy 2**: Hash rules for critical unsigned applications
4. **Deny Policy**: Block high-risk locations (Downloads, Temp, etc.)

This approach provides:
- Good security posture
- Manageable maintenance overhead
- Reasonable performance
- Flexibility for different application types

## Best Practices Summary

1. **Start Simple**: Begin with publisher rules and gradually add complexity
2. **Test Extensively**: Always use audit mode before enforce mode
3. **Monitor Continuously**: Regularly review audit logs
4. **Document Everything**: Keep detailed records of policy decisions
5. **Plan for Updates**: Design policies with maintenance in mind
6. **Use Supplemental Policies**: Extend base policies rather than modifying them
7. **Balance Security and Usability**: Choose the right approach for your environment

By understanding these comparisons, you can make informed decisions about which rule types and approaches will work best for your specific WDAC implementation.