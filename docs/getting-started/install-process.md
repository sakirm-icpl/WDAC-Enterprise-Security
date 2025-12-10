# Installing the WDAC Policy Toolkit

This guide provides step-by-step instructions for installing and setting up the WDAC Policy Toolkit on your system.

## System Requirements

Before installing the WDAC Policy Toolkit, ensure your system meets the following requirements:

- Windows 10 version 1903 or later, or Windows 11
- Windows Server 2019 or later
- PowerShell 5.1 or later (PowerShell 7.x compatible)
- Administrator privileges for policy deployment
- .NET Framework 4.8 or later (for GUI components)

## Installation Process

### For Command-Line Tools Only

1. Clone or download this repository to your local system:
   ```powershell
   git clone https://github.com/your-org/WDAC-Enterprise-Security.git
   ```

2. Navigate to the tools directory:
   ```powershell
   cd WDAC-Enterprise-Security\tools
   ```

3. All PowerShell scripts are ready to use directly without additional installation.

### For GUI Policy Wizard (Coming Soon)

The GUI Policy Wizard will be available as an MSIX package that can be installed on Windows 10/11 systems. Watch this space for updates.

## Verifying Installation

To verify that the toolkit is properly installed:

1. Open PowerShell as Administrator
2. Navigate to the tools directory
3. Run the prerequisites check:
   ```powershell
   .\prerequisites-check.ps1
   ```

If all checks pass, your system is ready to use the WDAC Policy Toolkit.

## Updating the Toolkit

To update the toolkit to the latest version:

1. Navigate to your cloned repository directory
2. Pull the latest changes:
   ```powershell
   git pull origin main
   ```

3. Run the prerequisites check again to ensure compatibility:
   ```powershell
   .\tools\prerequisites-check.ps1
   ```

## Troubleshooting Installation Issues

### Common Issues and Solutions

1. **PowerShell Execution Policy Errors**
   - Solution: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` in an elevated PowerShell prompt

2. **Missing ConfigCI Module**
   - Solution: Ensure you're running Windows 10 version 1903 or later, or Windows Server 2019 or later

3. **Insufficient Permissions**
   - Solution: Run PowerShell as Administrator for all policy-related operations

For additional help, refer to the [FAQ](../guides/FAQ.md) or [open an issue](../../CONTRIBUTING.md#reporting-issues) on our GitHub repository.