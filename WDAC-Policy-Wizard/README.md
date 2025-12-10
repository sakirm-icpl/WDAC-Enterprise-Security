# WDAC Policy Wizard

The WDAC Policy Wizard is a graphical user interface application designed to simplify the creation, editing, and management of Windows Defender Application Control (WDAC) policies.

## Project Overview

This application will provide a user-friendly interface for IT professionals to:

- Create new WDAC policies using templates
- Edit existing policies visually
- Merge multiple policies
- Validate policy syntax and structure
- Deploy policies to systems
- Monitor policy effectiveness

## Technology Stack

### Primary Technologies

- **Language**: C# (.NET 6/7)
- **Framework**: Windows Presentation Foundation (WPF)
- **UI Design**: Modern Fluent Design with dark/light theme support
- **Packaging**: MSIX for easy deployment and updates

### Dependencies

- Windows 10 version 1903 or later
- .NET 6 Desktop Runtime
- PowerShell 5.1 or later
- ConfigCI PowerShell module

## Core Features

### 1. Policy Creation Wizard

- Template selection (Base, Supplemental, Deny policies)
- Guided workflow for policy configuration
- Visual rule builder for file paths, hashes, and signers
- Policy preview before generation

### 2. Policy Editor

- Visual representation of policy structure
- Tree view of rules and signers
- Property editors for policy elements
- Syntax highlighting for XML editing

### 3. Policy Management

- Policy library with import/export capabilities
- Version history and comparison
- Policy merging functionality
- Batch operations for multiple policies

### 4. Validation and Testing

- Real-time policy validation
- Syntax checking and error reporting
- Policy simulation mode
- Audit mode testing integration

### 5. Deployment Tools

- Deployment target selection
- Group Policy integration
- Intune deployment support
- Deployment status monitoring

## Application Architecture

### MVVM Pattern

The application will follow the Model-View-ViewModel (MVVM) pattern for clean separation of concerns:

- **Models**: Represent policy data structures and business logic
- **Views**: XAML-based user interface components
- **ViewModels**: Bind views to models and handle UI logic

### Core Modules

1. **Policy Engine**: Handles policy creation, editing, and validation
2. **Deployment Manager**: Manages policy deployment to targets
3. **Validation Service**: Provides real-time policy validation
4. **Template Manager**: Manages policy templates and samples
5. **Settings Service**: Handles application configuration

## UI Design

### Main Window Layout

- Ribbon-style toolbar for primary actions
- Navigation pane for switching between features
- Main content area for policy work
- Status bar with progress and notifications

### Color Scheme

- Dark theme as default with light theme option
- Accent colors for highlighting important elements
- Consistent iconography throughout the application

## Development Roadmap

### Phase 1: Core Infrastructure (Weeks 1-4)

- Project setup and basic architecture
- Policy engine implementation
- Basic UI framework
- Template management

### Phase 2: Policy Creation (Weeks 5-8)

- Policy creation wizard
- Visual rule builder
- Template selection interface
- Policy preview functionality

### Phase 3: Policy Management (Weeks 9-12)

- Policy editor
- Policy library
- Import/export features
- Version management

### Phase 4: Validation and Testing (Weeks 13-16)

- Real-time validation
- Syntax checking
- Policy simulation
- Audit mode integration

### Phase 5: Deployment (Weeks 17-20)

- Deployment manager
- Target selection
- Deployment monitoring
- Status reporting

### Phase 6: Polish and Release (Weeks 21-24)

- UI refinement
- Performance optimization
- Documentation
- Packaging and distribution

## Contributing

We welcome contributions to the WDAC Policy Wizard! Please see our [contributing guidelines](../docs/contributing/contributing.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE-CODE](../LICENSE-CODE) file for details.