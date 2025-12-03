# Active Directory Domain - Test Scenarios

## 📋 Overview

This document contains detailed test scenarios for deploying WDAC policies in Active Directory domain environments using Group Policy.

**Target Systems:**
- Windows 10/11 Pro/Enterprise (Domain-joined)
- Windows Server 2019/2022 (Domain Controllers and Member Servers)
- Active Directory Domain Services
- Group Policy Management

## 🎯 Test Objectives

1. Validate GPO-based policy deployment
2. Test policy replication across domain
3. Verify department-specific policies
4. Test exception policy deployment
5. Validate centralized monitoring

## ⚙️ Test Environment Setup

### Prerequisites
```powershell
# Verify domain membership
(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

# Check domain name
(Get-WmiObject -Class Win32_ComputerSystem).Domain

# Verify Group Policy service
Get-Service -Name gpsvc

# Check SYSVOL replication
Get-DfsrBacklog -GroupName "Domain System Volume" -FolderName "SYSVOL Share"
```

### Required Infrastructure
- Active Directory Domain (functional level 2016+)
- Group Policy Management Console (GPMC)
- File share for policy distribution
- Event log collection (optional but recommended)

## 🧪 Test Scenarios

### TS-AD-001: GPO Creation and Linking

**Objective:** Create and link WDAC policy GPO

**Prerequisites:**
- Domain Admin or GPO management rights
- GPMC installed
- Policy files ready

**Test Steps:**
```powershell
# Step 1: Create new GPO
New-GPO -Name "WDAC-Base-Policy" -Comment "WDAC Base Policy for Enterprise"

# Step 2: Link to OU
New-GPLink -Name "WDAC-Base-Policy" -Target "OU=Workstations,DC=contoso,DC=com"

# Step 3: Configure GPO settings
# Open GPMC: gpmc.msc
# Navigate to: Computer Configuration > Policies > Windows Settings > Security Settings > Application Control Policies
# Import policy XML

# Step 4: Force GPO update on test client
gpupdate /force

# Step 5: Verify GPO applied
gpresult /r /scope:computer

# Step 6: Check policy status
Get-CIPolicy
```

**Expected Results:**
- ✅ GPO created successfully
- ✅ GPO linked to correct OU
- ✅ Policy settings configured
- ✅ GPO applies to test client
- ✅ Policy active on client

**Pass Criteria:**
- GPO creation and linking successful
- Policy applies and loads correctly

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-002: Policy Replication Test

**Objective:** Verify policy replicates across all domain controllers

**Prerequisites:**
- TS-AD-001 completed
- Multiple domain controllers

**Test Steps:**
```powershell
# Step 1: Get all domain controllers
$DCs = Get-ADDomainController -Filter *

# Step 2: Check SYSVOL replication status
foreach ($DC in $DCs) {
    Write-Host "Checking $($DC.HostName)..."
    Get-DfsrBacklog -GroupName "Domain System Volume" -FolderName "SYSVOL Share" -SourceComputerName $DC.HostName
}

# Step 3: Verify GPO on each DC
foreach ($DC in $DCs) {
    Write-Host "Checking GPO on $($DC.HostName)..."
    Get-GPO -Name "WDAC-Base-Policy" -Server $DC.HostName
}

# Step 4: Test policy application from different DCs
# Force client to authenticate to different DCs and verify policy applies
```

**Expected Results:**
- ✅ SYSVOL replication healthy
- ✅ GPO present on all DCs
- ✅ Policy applies regardless of DC
- ✅ No replication errors

**Pass Criteria:**
- Policy replicates to all DCs
- Clients receive policy from any DC

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-003: Department-Specific Policy Deployment

**Objective:** Deploy different policies to different departments

**Prerequisites:**
- TS-AD-001 completed
- OUs created for departments (Finance, HR, IT)

**Test Steps:**
```powershell
# Step 1: Create department-specific GPOs
New-GPO -Name "WDAC-Finance-Supplemental" -Comment "Finance Department Supplemental Policy"
New-GPO -Name "WDAC-HR-Supplemental" -Comment "HR Department Supplemental Policy"
New-GPO -Name "WDAC-IT-Supplemental" -Comment "IT Department Supplemental Policy"

# Step 2: Link to respective OUs
New-GPLink -Name "WDAC-Finance-Supplemental" -Target "OU=Finance,OU=Departments,DC=contoso,DC=com"
New-GPLink -Name "WDAC-HR-Supplemental" -Target "OU=HR,OU=Departments,DC=contoso,DC=com"
New-GPLink -Name "WDAC-IT-Supplemental" -Target "OU=IT,OU=Departments,DC=contoso,DC=com"

# Step 3: Configure each GPO with department-specific policies

# Step 4: Test on client in each OU
# Move test computer to Finance OU
Move-ADObject -Identity "CN=TestPC,OU=Workstations,DC=contoso,DC=com" -TargetPath "OU=Finance,OU=Departments,DC=contoso,DC=com"

# Force GPO update
gpupdate /force

# Verify correct policy applied
Get-CIPolicy

# Repeat for HR and IT OUs
```

**Expected Results:**
- ✅ Department GPOs created
- ✅ GPOs linked to correct OUs
- ✅ Clients receive department-specific policies
- ✅ Policies layer correctly (Base + Supplemental)

**Pass Criteria:**
- Each department receives correct policy
- No policy conflicts

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-004: Security Group Filtering

**Objective:** Apply policies based on security group membership

**Prerequisites:**
- TS-AD-001 completed
- Security groups created

**Test Steps:**
```powershell
# Step 1: Create security groups
New-ADGroup -Name "WDAC-Pilot-Users" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "WDAC-Excluded-Users" -GroupScope Global -GroupCategory Security

# Step 2: Configure GPO security filtering
# Remove "Authenticated Users"
Set-GPPermission -Name "WDAC-Base-Policy" -TargetName "Authenticated Users" -TargetType Group -PermissionLevel None

# Add pilot group
Set-GPPermission -Name "WDAC-Base-Policy" -TargetName "WDAC-Pilot-Users" -TargetType Group -PermissionLevel GpoApply

# Step 3: Add test users to pilot group
Add-ADGroupMember -Identity "WDAC-Pilot-Users" -Members "testuser1","testuser2"

# Step 4: Test policy application
# Login as testuser1 (in pilot group) - should get policy
# Login as testuser3 (not in pilot group) - should not get policy

# Step 5: Verify with gpresult
gpresult /r /scope:computer
```

**Expected Results:**
- ✅ Security groups created
- ✅ GPO filtering configured
- ✅ Pilot users receive policy
- ✅ Non-pilot users don't receive policy

**Pass Criteria:**
- Security filtering works correctly
- Policy applies only to intended users

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-005: WMI Filtering

**Objective:** Apply policies based on system criteria

**Prerequisites:**
- TS-AD-001 completed

**Test Steps:**
```powershell
# Step 1: Create WMI filter for Windows 10 only
# In GPMC, create WMI filter:
# Name: Windows 10 Only
# Query: SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.%"

# Step 2: Link WMI filter to GPO
# In GPMC, edit GPO properties and select WMI filter

# Step 3: Test on Windows 10 client
gpupdate /force
gpresult /r /scope:computer
# Should show policy applied

# Step 4: Test on Windows 11 client
gpupdate /force
gpresult /r /scope:computer
# Should show policy NOT applied

# Step 5: Create additional WMI filters as needed
# Example: Laptops only, Desktops only, Specific hardware, etc.
```

**Expected Results:**
- ✅ WMI filter created
- ✅ Filter linked to GPO
- ✅ Policy applies only to matching systems
- ✅ Non-matching systems don't receive policy

**Pass Criteria:**
- WMI filtering works correctly
- Policy targets correct systems

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-006: Exception Policy Deployment

**Objective:** Deploy exception policies for specific scenarios

**Prerequisites:**
- TS-AD-001 completed
- Exception policy created

**Test Steps:**
```powershell
# Step 1: Create exception GPO
New-GPO -Name "WDAC-Emergency-Access" -Comment "Emergency access exception policy"

# Step 2: Link to specific OU or use security filtering
New-GPLink -Name "WDAC-Emergency-Access" -Target "OU=IT-Admins,DC=contoso,DC=com"

# Step 3: Set GPO precedence (should process after base policy)
# In GPMC, adjust link order

# Step 4: Configure exception policy
# Import exception policy XML

# Step 5: Test exception
# Login as IT admin
# Verify base policy + exception policy both active
Get-CIPolicy

# Test that exception allows previously blocked application
```

**Expected Results:**
- ✅ Exception GPO created
- ✅ GPO linked correctly
- ✅ Exception policy layers with base policy
- ✅ Previously blocked apps now allowed

**Pass Criteria:**
- Exception policy works correctly
- No conflicts with base policy

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-007: Centralized Event Log Collection

**Objective:** Configure centralized logging for WDAC events

**Prerequisites:**
- TS-AD-001 completed
- Event log collector server configured

**Test Steps:**
```powershell
# Step 1: Configure event forwarding on clients via GPO
# Create GPO: WDAC-Event-Forwarding
# Configure: Computer Configuration > Policies > Administrative Templates > Windows Components > Event Forwarding

# Step 2: Configure subscription on collector server
wecutil cs /c:subscription.xml

# Step 3: Verify events forwarding
# On collector server:
Get-WinEvent -LogName "ForwardedEvents" -MaxEvents 10

# Step 4: Create custom view for WDAC events
# Event Viewer > Create Custom View
# Filter for Event IDs: 3076, 3077, 3099

# Step 5: Test event collection
# Generate test event on client
# Verify appears on collector server
```

**Expected Results:**
- ✅ Event forwarding configured
- ✅ Subscription active
- ✅ Events forwarding to collector
- ✅ Custom views created

**Pass Criteria:**
- Centralized logging functional
- Events collected from all clients

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-008: GPO Refresh and Update

**Objective:** Test policy updates via GPO

**Prerequisites:**
- TS-AD-001 completed
- Policy deployed

**Test Steps:**
```powershell
# Step 1: Modify existing policy
# Update policy XML with new rules

# Step 2: Update GPO with new policy
# In GPMC, import updated policy XML

# Step 3: Increment GPO version
# Happens automatically when GPO is modified

# Step 4: Force GPO refresh on clients
Invoke-GPUpdate -Computer "TestPC" -Force

# Step 5: Verify updated policy applied
Get-CIPolicy
# Check version number

# Step 6: Monitor event logs for policy update
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 10 |
    Where-Object {$_.Id -eq 3099}
```

**Expected Results:**
- ✅ Policy updated in GPO
- ✅ Clients receive updated policy
- ✅ Policy version incremented
- ✅ No disruption to users

**Pass Criteria:**
- Policy updates successfully
- All clients receive update

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-009: Roaming Profile Compatibility

**Objective:** Verify WDAC works with roaming profiles

**Prerequisites:**
- TS-AD-001 completed
- Roaming profiles configured

**Test Steps:**
```powershell
# Step 1: Configure test user with roaming profile
Set-ADUser -Identity testuser1 -ProfilePath "\\fileserver\profiles\testuser1"

# Step 2: Login as testuser1 on Computer A
# Verify policy applies
Get-CIPolicy

# Test applications work

# Step 3: Logout and login on Computer B
# Verify policy applies
Get-CIPolicy

# Test applications work
# Verify profile roamed correctly

# Step 4: Check for any policy-related issues in profile
# Review event logs
# Check for access denied errors
```

**Expected Results:**
- ✅ Policy applies with roaming profiles
- ✅ Profile roams correctly
- ✅ No access denied errors
- ✅ Applications work on both computers

**Pass Criteria:**
- Roaming profiles compatible with WDAC
- No user experience issues

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-AD-010: Mass Deployment

**Objective:** Deploy policy to large number of systems

**Prerequisites:**
- All previous tests passed
- Pilot deployment successful

**Test Steps:**
```powershell
# Step 1: Plan phased rollout
# Phase 1: 10% of systems
# Phase 2: 25% of systems
# Phase 3: 50% of systems
# Phase 4: 100% of systems

# Step 2: Create OUs for each phase
New-ADOrganizationalUnit -Name "WDAC-Phase1" -Path "OU=Workstations,DC=contoso,DC=com"
New-ADOrganizationalUnit -Name "WDAC-Phase2" -Path "OU=Workstations,DC=contoso,DC=com"
# etc.

# Step 3: Move computers to Phase 1 OU
# Select 10% of computers
$phase1Computers = Get-ADComputer -Filter * -SearchBase "OU=Workstations,DC=contoso,DC=com" | 
    Select-Object -First 50
foreach ($computer in $phase1Computers) {
    Move-ADObject -Identity $computer.DistinguishedName -TargetPath "OU=WDAC-Phase1,OU=Workstations,DC=contoso,DC=com"
}

# Step 4: Link GPO to Phase 1 OU
New-GPLink -Name "WDAC-Base-Policy" -Target "OU=WDAC-Phase1,OU=Workstations,DC=contoso,DC=com"

# Step 5: Monitor Phase 1 for 1 week
# Check event logs
# Review support tickets
# Collect user feedback

# Step 6: Proceed to Phase 2 if successful
# Repeat for remaining phases
```

**Expected Results:**
- ✅ Phased rollout plan executed
- ✅ Each phase successful
- ✅ Minimal support tickets
- ✅ No production issues

**Pass Criteria:**
- Successful deployment to all systems
- <1% incident rate

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

## 📊 Test Summary Template

**Test Date:** _______________  
**Tester Name:** _______________  
**Domain:** _______________  
**Number of DCs:** _______________  
**Number of Clients:** _______________

**Test Results:**

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| TS-AD-001 | GPO Creation | [ ] Pass [ ] Fail | |
| TS-AD-002 | Policy Replication | [ ] Pass [ ] Fail | |
| TS-AD-003 | Department Policies | [ ] Pass [ ] Fail | |
| TS-AD-004 | Security Filtering | [ ] Pass [ ] Fail | |
| TS-AD-005 | WMI Filtering | [ ] Pass [ ] Fail | |
| TS-AD-006 | Exception Policy | [ ] Pass [ ] Fail | |
| TS-AD-007 | Centralized Logging | [ ] Pass [ ] Fail | |
| TS-AD-008 | GPO Update | [ ] Pass [ ] Fail | |
| TS-AD-009 | Roaming Profiles | [ ] Pass [ ] Fail | |
| TS-AD-010 | Mass Deployment | [ ] Pass [ ] Fail | |

**Overall Result:** [ ] Pass [ ] Fail

**Issues Found:** _______________

**Recommendations:** _______________

**Sign-off:** _______________

---

**Document Version:** 2.0  
**Last Updated:** 2025-12-03  
**Next Review:** Before each deployment phase
