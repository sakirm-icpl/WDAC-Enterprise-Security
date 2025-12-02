# WDAC Compliance Mapping

This document maps Windows Defender Application Control (WDAC) capabilities to various compliance frameworks and standards, helping organizations understand how WDAC supports their compliance requirements.

## NIST Cybersecurity Framework

### Identify (ID)

**ID.AM-1**: Resource inventory and ownership
- WDAC helps identify which applications are authorized to run on systems
- Provides visibility into application usage across the enterprise

**ID.RA-1**: Asset vulnerability identification
- WDAC reduces attack surface by preventing unauthorized code execution
- Blocks known malicious file types and locations

### Protect (PR)

**PR.AC-3**: Access enforcement through hardware and software mechanisms
- WDAC enforces application execution policies at the kernel level
- Prevents unauthorized applications from running regardless of user permissions

**PR.AC-6**: Least functionality principle
- WDAC implements least functionality by allowing only explicitly permitted applications
- Blocks unnecessary or potentially harmful software

**PR.DS-7**: Protection of information at rest and in transit
- WDAC prevents execution of data exfiltration tools
- Blocks unauthorized encryption or steganography tools

**PR.IP-1**: Baseline configuration management
- WDAC policies define and enforce baseline application configurations
- Ensures only approved software versions execute

### Detect (DE)

**DE.CM-1**: Network events detection
- WDAC logs application execution attempts for monitoring
- Provides audit trail for security analysis

**DE.CM-7**: Malicious code detection
- WDAC prevents execution of known malicious code patterns
- Blocks living-off-the-land techniques

### Respond (RS)

**RS.MI-3**: Vulnerability mitigation strategies
- WDAC mitigates vulnerabilities in unauthorized applications
- Reduces impact of zero-day exploits

### Recover (RC)

**RC.CO-3**: Recovery planning improvements
- WDAC helps maintain clean system states
- Reduces need for system recovery due to malware infections

## CIS Controls

### Control 2: Inventory and Control of Software Assets

**2.1**: Maintain inventory of authorized software
- WDAC policies explicitly define authorized software
- Provides real-time enforcement of software inventory

**2.2**: Ensure software is supported by vendor
- WDAC can restrict execution to vendor-supported applications
- Blocks execution of end-of-life software

**2.6**: Allowlist authorized software
- WDAC implements comprehensive application allowlisting
- Prevents execution of unauthorized software

### Control 3: Data Protection

**3.9**: Limit access to sensitive data
- WDAC prevents unauthorized data access tools from executing
- Blocks file sharing applications that bypass security controls

### Control 8: Malware Defenses

**8.1**: Malware defenses
- WDAC provides prevention-based malware defense
- Blocks execution of known malware families

**8.5**: Detect/prevent advanced persistent threats
- WDAC prevents APTs from executing malicious payloads
- Blocks lateral movement through unauthorized tools

### Control 11: Secure Configuration

**11.2**: Establish configuration standards
- WDAC enforces configuration standards through policy
- Ensures consistent security posture across systems

### Control 12: Boundary Defense

**12.6**: Physically secure network infrastructure
- WDAC prevents execution of unauthorized remote access tools
- Blocks USB-based malware execution

## ISO 27001

### A.9 - Access Control

**A.9.2**: User access management
- WDAC enforces application-level access controls
- Prevents privilege escalation through unauthorized applications

**A.9.4**: System and application access control
- WDAC provides system-level application access control
- Implements principle of least privilege for applications

### A.12 - Information Security Aspects of Business Continuity

**A.12.6**: Information backup
- WDAC prevents backup encryption by ransomware
- Blocks unauthorized backup manipulation tools

### A.13 - Communications Security

**A.13.1**: Network controls
- WDAC prevents unauthorized network communication tools
- Blocks peer-to-peer file sharing applications

## PCI DSS

### Requirement 1: Install and maintain a firewall configuration

**1.1**: Establish firewall and router configurations
- WDAC complements network firewalls with endpoint controls
- Prevents execution of unauthorized communication tools

### Requirement 2: Do not use vendor-supplied defaults

**2.2**: Develop configuration standards
- WDAC policies enforce secure application configurations
- Prevents use of default or insecure applications

### Requirement 5: Use anti-virus software

**5.1**: Deploy anti-virus software
- WDAC provides prevention-based protection
- Blocks malware before traditional AV detection

### Requirement 10: Track and monitor all access

**10.2**: Audit trails for system components
- WDAC generates detailed audit logs
- Provides visibility into application execution attempts

## HIPAA

### Administrative Safeguards

**164.308(a)(1)(i)**: Security management process
- WDAC supports risk analysis and management
- Reduces security risks through application control

**164.308(a)(5)(ii)(B)**: Protection from malicious software
- WDAC prevents execution of malicious software
- Provides proactive protection against malware

### Physical Safeguards

**164.310(d)(1)**: Workstation use
- WDAC enforces workstation security policies
- Prevents installation of unauthorized applications

### Technical Safeguards

**164.312(a)(1)**: Access control
- WDAC implements technical access controls
- Prevents unauthorized application execution

**164.312(b)**: Audit controls
- WDAC provides detailed audit logging
- Enables monitoring of application execution

## SOX (Sarbanes-Oxley)

### Section 404: Management Assessment of Internal Controls

- WDAC helps establish and maintain internal controls
- Provides technical enforcement of security policies
- Supports management's assessment of control effectiveness

### Section 302: Corporate Responsibility for Financial Reports

- WDAC helps ensure system integrity for financial applications
- Prevents unauthorized modifications to financial systems
- Supports accuracy and reliability of financial reporting

## GDPR

### Article 25: Data Protection by Design and by Default

- WDAC implements privacy by design through application control
- Prevents execution of unauthorized data processing tools
- Supports data protection by default principles

### Article 32: Security of Processing

- WDAC provides security measures for personal data processing
- Prevents unauthorized access to personal data
- Implements technical and organizational measures

## CMMC (Cybersecurity Maturity Model Certification)

### Level 1 - Basic Cyber Hygiene

**AC.1.001**: Limit information system access
- WDAC limits system access through application control
- Prevents execution of unauthorized software

### Level 2 - Intermediate Cyber Hygiene

**AC.2.015**: Control and monitor remote access
- WDAC prevents unauthorized remote access tools
- Blocks execution of unapproved remote desktop applications

### Level 3 - Good Cyber Hygiene

**AC.3.019**: Establish and maintain list of authorized software
- WDAC maintains and enforces authorized software lists
- Provides real-time application allowlisting

## NERC CIP (Critical Infrastructure Protection)

### CIP-007-3: Systems Security Management

**R1**: Manage security risks from ports, services, and protocols
- WDAC prevents execution of unauthorized network services
- Blocks unauthorized communication protocols

### CIP-010-0: Personnel Roles and Responsibilities

**R1**: Identify and document personnel with access
- WDAC prevents unauthorized personnel from executing privileged tools
- Enforces role-based application access

## Best Practices for Compliance

### 1. Policy Documentation

- Maintain detailed documentation of WDAC policies
- Record business justification for all allow rules
- Document policy change history and approvals

### 2. Audit and Monitoring

- Regularly review WDAC audit logs
- Monitor for unauthorized application execution attempts
- Generate compliance reports from audit data

### 3. Policy Review and Updates

- Regularly review policies for compliance effectiveness
- Update policies to reflect changing compliance requirements
- Maintain evidence of policy reviews and updates

### 4. Training and Awareness

- Train staff on WDAC compliance requirements
- Ensure personnel understand compliance implications
- Provide guidance on handling compliance-related issues

## Compliance Reporting

### Audit Log Analysis

WDAC generates detailed audit logs that can be used for compliance reporting:

```powershell
# Example: Generate compliance report from audit logs
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
    Id = 3076, 3077, 3089
    StartTime = (Get-Date).AddDays(-30)
} | Export-Csv -Path "Compliance_Report.csv" -NoTypeInformation
```

### Policy Inventory Reports

Regular policy inventory reports help demonstrate compliance:

```powershell
# Example: Export policy rules for compliance review
[xml]$Policy = Get-Content "policies\MergedPolicy.xml"
$Policy.Policy.FileRules.ChildNodes | 
    Select-Object FriendlyName, FilePath, Hash |
    Export-Csv -Path "Policy_Inventory.csv" -NoTypeInformation
```

## Compliance Validation Checklist

### Regulatory Compliance
- [ ] NIST Cybersecurity Framework alignment documented
- [ ] CIS Controls implementation verified
- [ ] ISO 27001 requirements addressed
- [ ] PCI DSS requirements implemented
- [ ] HIPAA security rule compliance ensured
- [ ] SOX requirements supported

### Audit Preparation
- [ ] Policy documentation complete and current
- [ ] Audit logs retained per regulatory requirements
- [ ] Compliance reports generated and reviewed
- [ ] Staff trained on compliance requirements
- [ ] Incident response procedures updated

### Ongoing Compliance
- [ ] Regular policy reviews conducted
- [ ] Compliance metrics monitored and reported
- [ ] Policy updates aligned with regulatory changes
- [ ] Staff training updated as needed

By implementing WDAC and following this compliance mapping, organizations can strengthen their security posture while meeting regulatory requirements across multiple frameworks and standards.