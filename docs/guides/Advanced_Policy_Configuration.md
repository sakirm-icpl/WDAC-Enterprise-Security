# Advanced WDAC Policy Configuration

This guide covers advanced configuration options and techniques for Windows Defender Application Control policies.

## Policy Rule Options

WDAC policies support numerous rule options that control policy behavior. Here are the most important ones:

### Core Policy Options

- `Enabled:Unsigned System Integrity Policy` - Allows unsigned policies (for testing only)
- `Enabled:Audit Mode` - Enables audit mode for logging without blocking
- `Enabled:Enforce Mode` - Enables enforce mode for active blocking
- `Enabled:Advanced Boot Options Menu` - Controls access to boot options
- `Required:Enforce Store Applications` - Requires Windows Store applications to be allowed
- `Enabled:UMCI` - Enables User Mode Code Integrity
- `Enabled:Inherit Default Policy` - Inherits default Windows policy rules

### Script Enforcement Options

- `Enabled:Script Enforcement` - Controls script execution
- `Disabled:Script Enforcement` - Disables script enforcement
- `Enabled:Managed Installer` - Allows managed installers to run scripts

### Advanced Options

- `Enabled:Update Policy No Reboot` - Allows policy updates without reboot
- `Enabled:Revoked Expired Certificates` - Handles expired certificates
- `Required:EV Signers` - Requires Extended Validation certificates

## Rule Types in Depth

### Publisher Rules

Publisher rules are the most maintainable rule type as they automatically cover updates to applications with the same publisher:

```xml
<Allow ID="ID_ALLOW_MS_PUBLISHER" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
  <Signer Id="ID_SIGNER_MS">
    <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
    <CertPublisher Value="Microsoft Corporation" />
  </Signer>
</Allow>
```

### File Hash Rules

Hash rules provide the most restrictive control but require updating when files change:

```xml
<Allow ID="ID_ALLOW_SPECIFIC_FILE" FriendlyName="Specific Application" Hash="9F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F" />
```

### FilePath Rules

FilePath rules allow applications based on their location:

```xml
<Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
```

### FileAttributes Rules

FileAttributes rules combine multiple file attributes:

```xml
<FileAttrib ID="ID_FILEATTRIB_CUSTOM" FriendlyName="Custom Application" FileName="customapp.exe" MinimumFileVersion="1.0.0.0" />
```

## Supplemental Policy Techniques

Supplemental policies can extend base policies in several ways:

### Extension Policies

Extension policies add new rules to an existing base policy:

```xml
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <BasePolicyID>{BASE_POLICY_GUID}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <!-- Additional rules here -->
  </FileRules>
</Policy>
```

### Exception Policies

Exception policies can selectively allow applications that would otherwise be blocked:

```xml
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <BasePolicyID>{BASE_POLICY_GUID}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <Allow ID="ID_EXCEPTION_RULE" FriendlyName="Exception for Legacy App" FileName="legacyapp.exe" FilePath="%PROGRAMFILES%\LegacyApp\*" />
  </FileRules>
</Policy>
```

## Multi-Policy Architecture

For complex environments, consider a multi-policy architecture:

### Policy Hierarchy

1. **Base Policy**: Core rules allowing Microsoft and trusted vendor applications
2. **Deny Policy**: Rules blocking untrusted locations and applications
3. **Department Policies**: Department-specific supplemental policies
4. **Exception Policies**: Temporary exception policies for special cases

### Policy Merging Best Practices

- Merge policies in a logical order (base first, then supplements)
- Test merged policies thoroughly before deployment
- Document policy merge sequences
- Maintain separate backup copies of individual policies

## Automation and Scripting

### PowerShell Policy Management

Use PowerShell cmdlets for advanced policy management:

```powershell
# Create a policy from audit logs
New-CIPolicy -Audit -Path "C:\temp\newpolicy.xml" -Level FilePublisher

# Merge multiple policies
Merge-CIPolicy -PolicyPaths "policy1.xml", "policy2.xml" -OutputFilePath "merged.xml"

# Convert XML to binary
ConvertFrom-CIPolicy -XmlFilePath "policy.xml" -BinaryFilePath "policy.p7b"
```

### Custom Rule Creation

Automate rule creation for common scenarios:

```powershell
# Create hash rules for a directory
$Files = Get-ChildItem "C:\Apps\Custom" -Recurse -Include *.exe, *.dll
$Rules = @()
foreach ($File in $Files) {
    $Hash = Get-FileHash $File.FullName -Algorithm SHA256
    $Rule = "<Allow ID=`"ID_$($File.BaseName)`" FriendlyName=`"$($File.Name)`" Hash=`"$($Hash.Hash)`" />"
    $Rules += $Rule
}
```

## Performance Optimization

### Policy Size Management

Large policies can impact system performance. Optimize by:

1. Removing unused rules regularly
2. Using publisher rules instead of hash rules when possible
3. Consolidating similar rules
4. Removing redundant FilePath rules

### Rule Ordering

Place frequently matched rules earlier in the policy for better performance:

```xml
<FileRules>
  <!-- Frequently used rules first -->
  <Allow ID="ID_COMMON_APPS" ... />
  
  <!-- Less frequently used rules later -->
  <Allow ID="ID_RARE_APPS" ... />
</FileRules>
```

## Security Considerations

### Policy Signing

For production environments, sign policies to prevent tampering:

```powershell
# Set policy to require signing
<Rule>
  <Option>Enabled:Signed System Integrity Policy</Option>
</Rule>
```

### Secure Deployment

- Deploy policies through secure channels (Group Policy, Intune)
- Protect policy files with appropriate permissions
- Regularly audit policy deployments
- Monitor for unauthorized policy changes

## Troubleshooting Advanced Issues

### Policy Conflict Resolution

When policies conflict, the most restrictive rule typically wins. Use these techniques to diagnose conflicts:

1. Enable verbose Code Integrity logging
2. Use Process Monitor to trace file access attempts
3. Review merged policy logic carefully
4. Test policies in isolation

### Debugging Tools

```powershell
# Enable verbose CI logging
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Debug" /v "Verbose" /t REG_DWORD /d 1 /f

# Check policy load status
Get-CimInstance -ClassName Win32_CodeIntegrityPolicy -Namespace root\Microsoft\Windows\CodeIntegrity
```

## Best Practices Summary

1. **Start Simple**: Begin with basic policies and gradually add complexity
2. **Test Extensively**: Always test in audit mode before enforcing
3. **Document Everything**: Maintain detailed documentation of all policies
4. **Monitor Continuously**: Regularly review audit logs and policy effectiveness
5. **Plan for Updates**: Design policies with easy maintenance in mind
6. **Secure Policies**: Use signed policies and secure deployment methods
7. **Optimize Performance**: Keep policies lean and well-organized

## Additional Resources

- Microsoft Documentation: [Windows Defender Application Control](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)
- [WDAC Policy Wizard](https://web.archive.org/web/20210101000000*/https://github.com/MicrosoftDocs/WDAC-Toolkit)
- Community Resources: [WDAC Community](https://github.com/topics/wdac)