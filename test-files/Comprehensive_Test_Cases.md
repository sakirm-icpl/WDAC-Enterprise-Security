# Comprehensive WDAC Test Cases for Different Environments

This document provides comprehensive test cases for validating WDAC implementations across various environments including Active Directory, non-AD, hybrid, and cloud environments.

## Test Environment Setup

### Prerequisites for All Environments
- Windows 10/11 Enterprise or Education (version 1903 or later)
- PowerShell 5.1 or later
- Administrative privileges
- Test applications representing different categories

### Test Environment Configuration
1. Create dedicated test systems or VMs for each environment type
2. Ensure systems are fully updated
3. Install representative applications for testing:
   - Microsoft-signed applications (Office, Edge, etc.)
   - Third-party applications with valid certificates
   - Applications without certificates
   - Scripts (PowerShell, batch files)
   - Legacy applications

## Test Cases by Environment

## 1. Active Directory Environment Test Cases

### TC-AD-001: Group Policy Deployment Validation
**Objective**: Verify WDAC policy deployment through Group Policy
**Preconditions**: 
- Active Directory domain with at least one domain controller
- Test client systems joined to the domain
- Group Policy management permissions

**Test Steps**:
1. Create WDAC policy XML file
2. Convert to binary format
3. Create GPO and link to test OU
4. Configure Device Guard settings in GPO
5. Force Group Policy update on test clients
6. Verify policy deployment on clients
7. Restart test clients
8. Validate policy enforcement

**Expected Results**:
- Policy file copied to client systems
- Policy applied after restart
- Allowed applications execute successfully
- Blocked applications are prevented from executing

**Pass Criteria**:
- GPO applies without errors
- Policy file exists at `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`
- Device Guard status shows policy loaded
- Audit logs show appropriate allow/block events

### TC-AD-002: Policy Update Through Group Policy
**Objective**: Verify policy updates propagate through Group Policy
**Preconditions**: 
- Existing WDAC policy deployed via GPO
- Test applications installed on client systems

**Test Steps**:
1. Modify existing WDAC policy to block additional applications
2. Update policy file in SYSVOL or designated share
3. Force Group Policy update on test clients
4. Verify policy update on clients
5. Test newly blocked applications
6. Validate audit logs

**Expected Results**:
- Policy updates propagate to all clients
- New blocking rules take effect
- Audit logs reflect updated policy

**Pass Criteria**:
- All clients receive updated policy within 90 minutes
- New blocking rules enforced
- No policy corruption or errors

### TC-AD-003: Selective Policy Application
**Objective**: Verify selective policy application based on OU structure
**Preconditions**: 
- Multiple OUs with different security requirements
- Test systems in different OUs
- Different WDAC policies for each OU

**Test Steps**:
1. Create different WDAC policies for different OUs
2. Link appropriate GPOs to each OU
3. Force Group Policy update on all test systems
4. Verify policy application per OU
5. Test applications on systems in different OUs
6. Validate audit logs

**Expected Results**:
- Systems in different OUs receive appropriate policies
- Policy enforcement matches OU requirements
- No policy conflicts between OUs

**Pass Criteria**:
- Correct policy applied to each OU
- Systems enforce appropriate rules
- No Group Policy errors

## 2. Non-AD Environment Test Cases

### TC-NONAD-001: Manual Policy Deployment
**Objective**: Verify manual WDAC policy deployment on standalone systems
**Preconditions**: 
- Standalone Windows systems
- Administrative access to systems
- WDAC policy files prepared

**Test Steps**:
1. Copy WDAC policy binary to test systems
2. Place policy file in `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`
3. Restart test systems
4. Verify policy loading
5. Test allowed and blocked applications
6. Validate audit logs

**Expected Results**:
- Policy file successfully copied
- Policy loads after restart
- Applications behave according to policy rules
- Audit logs generated appropriately

**Pass Criteria**:
- Policy file placement succeeds
- System restarts successfully
- Policy enforcement works as expected
- No system instability

### TC-NONAD-002: Script-Based Deployment
**Objective**: Verify script-based WDAC policy deployment
**Preconditions**: 
- PowerShell remoting enabled on target systems
- Deployment script prepared
- Network connectivity between management and target systems

**Test Steps**:
1. Execute deployment script targeting test systems
2. Monitor script execution
3. Verify policy deployment on target systems
4. Restart target systems
5. Validate policy enforcement
6. Check audit logs

**Expected Results**:
- Script executes without errors
- Policy deployed to all target systems
- Systems restart and load policies
- Policy enforcement functions correctly

**Pass Criteria**:
- Script completes successfully
- All target systems receive policy
- No deployment errors
- Policy enforcement verified

### TC-NONAD-003: Intune Cloud Deployment
**Objective**: Verify WDAC policy deployment through Microsoft Intune
**Preconditions**: 
- Azure AD-joined test devices
- Intune tenant with appropriate licenses
- WDAC policy files prepared

**Test Steps**:
1. Create WDAC configuration profile in Intune
2. Upload policy file to profile
3. Assign profile to test devices
4. Monitor deployment status in Intune
5. Verify policy on test devices
6. Test policy enforcement
7. Validate audit logs

**Expected Results**:
- Profile created and assigned successfully
- Policy deploys to test devices
- Devices enforce policy rules
- Audit logs generated

**Pass Criteria**:
- Intune shows successful deployment
- Devices receive and apply policy
- Policy enforcement works as expected
- No deployment errors

## 3. Hybrid Environment Test Cases

### TC-HYBRID-001: Co-Management Policy Consistency
**Objective**: Verify policy consistency in co-managed environments
**Preconditions**: 
- Hybrid Azure AD-joined devices
- Configuration Manager and Intune co-management enabled
- WDAC policies configured in both tools

**Test Steps**:
1. Configure WDAC policy in Configuration Manager
2. Configure WDAC policy in Intune
3. Define policy precedence
4. Deploy policies to test devices
5. Verify policy application
6. Test policy enforcement
7. Validate audit logs

**Expected Results**:
- Correct policy takes precedence
- No policy conflicts
- Consistent enforcement across devices
- Audit logs reflect applied policy

**Pass Criteria**:
- Policy precedence works as configured
- No deployment conflicts
- Consistent enforcement behavior
- Audit logs accurate

### TC-HYBRID-002: Cross-Environment Policy Updates
**Objective**: Verify policy updates work across different management tools
**Preconditions**: 
- Co-managed test devices
- Existing WDAC policies from both tools
- Updated policy files prepared

**Test Steps**:
1. Update policy in Configuration Manager
2. Update policy in Intune
3. Monitor deployment from both tools
4. Verify policy updates on test devices
5. Test updated policy enforcement
6. Validate audit logs

**Expected Results**:
- Updates deploy from both tools
- Devices receive correct policy versions
- Updated enforcement rules apply
- Audit logs reflect changes

**Pass Criteria**:
- Both tools successfully deploy updates
- No policy conflicts during updates
- Updated policies enforced correctly
- Audit logs accurate

## 4. Policy Rule Type Test Cases

### TC-RULES-001: Publisher Rule Validation
**Objective**: Verify publisher rules correctly allow signed applications
**Preconditions**: 
- WDAC policy with publisher rules
- Signed applications for testing
- Unsigned applications for negative testing

**Test Steps**:
1. Deploy policy with publisher rules
2. Test signed applications from allowed publishers
3. Test signed applications from non-allowed publishers
4. Test unsigned applications
5. Review audit logs

**Expected Results**:
- Applications from allowed publishers execute
- Applications from non-allowed publishers blocked
- Unsigned applications blocked
- Audit logs show appropriate events

**Pass Criteria**:
- Correct applications allowed/blocked
- Publisher verification works
- Audit logs accurate
- No false positives/negatives

### TC-RULES-002: Path Rule Validation
**Objective**: Verify path rules correctly control application execution
**Preconditions**: 
- WDAC policy with path rules
- Applications in allowed and blocked paths
- Test applications prepared

**Test Steps**:
1. Deploy policy with path rules
2. Test applications in allowed paths
3. Test applications in blocked paths
4. Move applications between paths
5. Test execution in new locations
6. Review audit logs

**Expected Results**:
- Applications in allowed paths execute
- Applications in blocked paths blocked
- Path changes affect execution
- Audit logs show path-based events

**Pass Criteria**:
- Path-based control works correctly
- Applications respect path rules
- Audit logs accurate
- No path traversal bypasses

### TC-RULES-003: Hash Rule Validation
**Objective**: Verify hash rules provide precise application control
**Preconditions**: 
- WDAC policy with hash rules
- Specific application binaries for testing
- Modified versions of same applications

**Test Steps**:
1. Deploy policy with hash rules
2. Test exact binary matches
3. Test modified versions of same applications
4. Test different applications
5. Review audit logs

**Expected Results**:
- Exact binary matches execute
- Modified versions blocked
- Different applications blocked
- Audit logs show hash-based events

**Pass Criteria**:
- Hash verification works correctly
- Only exact matches allowed
- Audit logs accurate
- No hash collisions

## 5. Deployment Mode Test Cases

### TC-MODE-001: Audit Mode Validation
**Objective**: Verify audit mode logs without blocking applications
**Preconditions**: 
- WDAC policy configured for audit mode
- Test applications representing various scenarios

**Test Steps**:
1. Deploy policy in audit mode
2. Test various applications
3. Monitor audit logs
4. Verify no applications blocked
5. Analyze audit log content

**Expected Results**:
- All applications execute
- Audit logs generated for all executions
- No enforcement actions taken
- Logs contain detailed information

**Pass Criteria**:
- No applications blocked
- Comprehensive audit logging
- Logs contain actionable information
- System performance not significantly impacted

### TC-MODE-002: Enforce Mode Validation
**Objective**: Verify enforce mode blocks unauthorized applications
**Preconditions**: 
- WDAC policy configured for enforce mode
- Test applications representing allowed and blocked scenarios

**Test Steps**:
1. Deploy policy in enforce mode
2. Test allowed applications
3. Test blocked applications
4. Verify blocking behavior
5. Review audit logs
6. Test policy exceptions

**Expected Results**:
- Allowed applications execute
- Blocked applications fail to execute
- Audit logs show enforcement events
- Exceptions work correctly

**Pass Criteria**:
- Correct applications allowed/blocked
- Enforcement works reliably
- Audit logs accurate
- No system instability

## 6. Performance and Scalability Test Cases

### TC-PERF-001: Policy Load Performance
**Objective**: Verify policy loading performance meets requirements
**Preconditions**: 
- Large WDAC policy files prepared
- Test systems with varying hardware configurations

**Test Steps**:
1. Deploy increasingly large policy files
2. Measure boot times with policies
3. Monitor system resource usage
4. Test policy update performance
5. Validate policy functionality

**Expected Results**:
- Boot times within acceptable limits
- Resource usage reasonable
- Policy updates complete timely
- Functionality maintained

**Pass Criteria**:
- Boot time increase < 10%
- Memory usage < 100MB for large policies
- Policy updates < 5 minutes
- No functionality degradation

### TC-PERF-002: Concurrent Deployment Scalability
**Objective**: Verify concurrent policy deployment to multiple systems
**Preconditions**: 
- Multiple test systems available
- Network infrastructure capable of concurrent transfers
- Deployment scripts prepared

**Test Steps**:
1. Initiate concurrent policy deployments to 10 systems
2. Monitor deployment progress
3. Measure deployment completion times
4. Verify policy integrity on all systems
5. Test policy enforcement

**Expected Results**:
- All deployments complete successfully
- Reasonable completion times
- Policy integrity maintained
- No deployment failures

**Pass Criteria**:
- 100% deployment success rate
- Completion time < 15 minutes for 10 systems
- Policy integrity verified
- No network saturation

## 7. Security Test Cases

### TC-SEC-001: Policy Tampering Detection
**Objective**: Verify detection of unauthorized policy modifications
**Preconditions**: 
- Signed WDAC policies deployed
- Systems configured to require signed policies

**Test Steps**:
1. Attempt to modify policy file directly
2. Attempt to replace policy with unsigned version
3. Monitor system responses
4. Check audit logs
5. Verify policy integrity

**Expected Results**:
- Unauthorized modifications rejected
- System maintains original policy
- Audit logs show tampering attempts
- Policy continues to function

**Pass Criteria**:
- Modifications rejected
- Original policy preserved
- Tampering detected in logs
- No policy bypass

### TC-SEC-002: Bypass Attempt Detection
**Objective**: Verify detection of common bypass techniques
**Preconditions**: 
- WDAC policy deployed in enforce mode
- Common bypass techniques identified

**Test Steps**:
1. Attempt file renaming bypass
2. Attempt path traversal bypass
3. Attempt symbolic link bypass
4. Attempt registry manipulation
5. Monitor system responses
6. Check audit logs

**Expected Results**:
- Bypass attempts blocked
- System maintains policy enforcement
- Audit logs show bypass attempts
- No unauthorized execution

**Pass Criteria**:
- All bypass attempts blocked
- Policy enforcement maintained
- Attempts logged appropriately
- No successful bypasses

## 8. Recovery and Rollback Test Cases

### TC-RECOVERY-001: Policy Rollback Validation
**Objective**: Verify policy rollback procedures work correctly
**Preconditions**: 
- Active WDAC policy deployed
- Rollback procedures documented
- Backup policies available

**Test Steps**:
1. Execute policy rollback procedure
2. Verify policy removal
3. Test application execution
4. Validate system stability
5. Document rollback results

**Expected Results**:
- Policy successfully removed
- Applications execute normally
- System stable after rollback
- No residual policy effects

**Pass Criteria**:
- Rollback completes successfully
- Policy completely removed
- System functions normally
- No adverse effects

### TC-RECOVERY-002: Emergency Boot Validation
**Objective**: Verify system boot capability during policy issues
**Preconditions**: 
- Problematic WDAC policy prepared
- Test systems available
- Emergency boot procedures documented

**Test Steps**:
1. Deploy problematic policy
2. Attempt normal system boot
3. Use emergency boot procedures
4. Verify system accessibility
5. Remove problematic policy
6. Test normal boot

**Expected Results**:
- Emergency boot procedures work
- System accessible in emergency mode
- Problematic policy removable
- Normal boot restored

**Pass Criteria**:
- Emergency boot successful
- System accessible
- Policy removable
- Normal operation restored

## Test Data Requirements

### Application Categories for Testing
1. **Microsoft-signed applications**: Office, Edge, Notepad++, etc.
2. **Third-party signed applications**: Adobe Reader, Chrome, etc.
3. **Unsigned applications**: Custom-developed tools, legacy software
4. **Scripts**: PowerShell, batch, VBScript files
5. **Malicious samples**: EICAR test files, benign malware simulators

### Test Environment Variants
1. **Hardware configurations**: Different CPU architectures, memory sizes
2. **Windows versions**: Windows 10, Windows 11, various builds
3. **Network conditions**: High latency, low bandwidth, disconnected
4. **System states**: Clean installs, heavily used systems, domain-joined

## Test Execution Guidelines

### Test Scheduling
- **Daily**: Critical functionality tests
- **Weekly**: Comprehensive policy validation
- **Monthly**: Performance and scalability tests
- **As needed**: Security and recovery tests

### Test Documentation
- Record test execution details
- Capture audit log samples
- Document any anomalies
- Maintain test result history

### Test Automation
- Automate repetitive test cases
- Use PowerShell for test orchestration
- Implement continuous validation
- Generate automated test reports

## Reporting and Metrics

### Key Performance Indicators
1. **Policy Deployment Success Rate**: Percentage of successful deployments
2. **False Positive Rate**: Legitimate applications incorrectly blocked
3. **False Negative Rate**: Malicious applications incorrectly allowed
4. **Policy Load Time**: Time to load policy during boot
5. **System Performance Impact**: CPU/memory usage increase

### Test Result Analysis
- Trend analysis of deployment success rates
- Identification of common failure patterns
- Performance benchmarking
- Security effectiveness measurement

These comprehensive test cases ensure WDAC implementations are thoroughly validated across different environments and scenarios, providing confidence in production deployments.