# WDAC Architecture Overview

This diagram shows the high-level architecture of Windows Defender Application Control (WDAC).

```mermaid
graph TB
    A[WDAC Policy] --> B[Code Integrity Engine]
    B --> C{Application Request}
    C --> D[Check Against Policy Rules]
    D --> E{Is Application Allowed?}
    E -->|Yes| F[Allow Execution]
    E -->|No| G[Block Execution]
    G --> H[Log Event]
    
    A --> I[Policy Deployment]
    I --> J[Group Policy]
    I --> K[Intune]
    I --> L[Manual Deployment]
    
    B --> M[Event Logging]
    M --> N[Event Viewer]
    M --> O[SIEM Integration]
    
    subgraph "Policy Components"
        A
        P[Allow Rules]
        Q[Deny Rules]
        R[File Rules]
        S[Signer Rules]
        A --> P
        A --> Q
        A --> R
        A --> S
    end
    
    subgraph "Deployment Methods"
        I
        J
        K
        L
    end
    
    subgraph "WDAC Policy Toolkit Components"
        T[CLI Tools]
        U[GUI Wizard]
        V[Policy Templates]
        W[Validation Tools]
        X[Testing Framework]
        Y[Sample Policies]
        Z[Documentation]
        
        T --> A
        U --> A
        V --> A
        W --> A
        X --> A
        Y --> A
        Z --> A
    end
```

## Core Architecture Components

### 1. Policy Engine
The WDAC policy engine operates at the kernel level to enforce application execution policies. It evaluates each application execution request against the defined policy rules.

### 2. Policy Structure
WDAC policies are XML-based files that define what applications are allowed or denied. Policies contain:
- **Allow Rules**: Define what applications can run
- **Deny Rules**: Explicitly block specific applications
- **File Rules**: Path-based restrictions
- **Signer Rules**: Publisher certificate-based rules

### 3. Deployment Mechanisms
Policies can be deployed through multiple mechanisms:
- **Group Policy**: For Active Directory environments
- **Microsoft Intune**: For cloud-managed devices
- **Manual Deployment**: For standalone systems or testing

### 4. Monitoring and Logging
All WDAC decisions are logged for monitoring and compliance:
- **Event Viewer**: Local system event logs
- **SIEM Integration**: Centralized security information management
- **Audit Mode**: Non-blocking monitoring for policy testing

## WDAC Policy Toolkit Architecture

The WDAC Policy Toolkit enhances the core WDAC architecture with additional components:

### Command-Line Interface Tools
Powerful CLI tools for policy management:
- Policy generation from templates
- AppLocker to WDAC conversion
- Policy validation and simulation
- Deployment and rollback operations

### Graphical User Interface
Work-in-progress GUI wizard for simplified policy creation:
- Visual policy builder
- Template selection interface
- Rule configuration wizards
- Policy preview and validation

### Policy Management Components
- **Templates**: Pre-defined policy templates for common scenarios
- **Samples**: Real-world policy examples for reference
- **Validation Tools**: Syntax checking and policy simulation
- **Testing Framework**: Comprehensive test suites for validation

### Documentation and Guidance
Complete documentation suite including:
- Getting started guides
- Implementation tutorials
- Best practices recommendations
- Troubleshooting guidance