# Contributing to WDAC Enterprise Security Toolkit

Thank you for your interest in contributing to the WDAC Enterprise Security Toolkit! We welcome contributions from the community to help improve and expand this toolkit for Windows Defender Application Control.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Development Process](#development-process)
5. [Style Guides](#style-guides)
6. [Community](#community)

## Code of Conduct

This project adheres to the Contributor Covenant [code of conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
- PowerShell 5.1 or later (PowerShell 7.x compatible)
- Windows SDK (for policy development and testing)
- Visual Studio Code or another code editor with PowerShell extension

### Setting Up Your Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/WDAC-Enterprise-Security.git
   ```
3. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Make your changes
5. Commit your changes with a descriptive commit message
6. Push to your fork
7. Create a pull request

## How to Contribute

### Reporting Bugs

Before submitting a bug report, please check if the issue has already been reported. If not, create a new issue with:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots or logs if applicable
- Your environment details (OS version, PowerShell version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:

- A clear and descriptive title
- Detailed explanation of the proposed enhancement
- Use cases and benefits
- Potential implementation approach (if known)

### Code Contributions

1. **Choose an Issue**: Look for issues labeled "good first issue" or "help wanted"
2. **Comment on the Issue**: Let others know you're working on it
3. **Fork and Branch**: Create a feature branch in your fork
4. **Develop**: Write clean, well-documented code
5. **Test**: Ensure your changes work as expected
6. **Commit**: Write clear, concise commit messages
7. **Push**: Push your changes to your fork
8. **Pull Request**: Submit a PR with a clear description

### Documentation Improvements

Documentation is crucial for this project. You can contribute by:

- Improving existing documentation
- Adding new guides and tutorials
- Fixing typos and grammatical errors
- Translating documentation to other languages

## Development Process

### Branch Naming Convention

- `feature/feature-name` for new features
- `bugfix/issue-description` for bug fixes
- `docs/documentation-topic` for documentation changes
- `release/version-number` for release preparations

### Commit Message Guidelines

Follow the conventional commit format:

```
type(scope): brief description

Detailed explanation of the changes (optional)

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Pull Request Process

1. Ensure your code follows the [style guides](#style-guides)
2. Update documentation as needed
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request with a clear title and description
6. Link to any relevant issues
7. Request review from maintainers

### Code Review Process

All submissions require review. We use GitHub pull requests for this process. Consult [code review guidelines](code-review-guidelines.md) for more information.

## Style Guides

### PowerShell Style Guide

- Follow [Microsoft's PowerShell Best Practices](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/write-readable-code)
- Use approved verbs for function names
- Include comment-based help for all public functions
- Use proper parameter validation
- Handle errors gracefully with try/catch blocks
- Avoid aliases in favor of full cmdlet names
- Use consistent indentation (4 spaces)

### XML Policy Style Guide

- Follow WDAC policy structure guidelines
- Use meaningful IDs and friendly names
- Organize rules logically
- Comment complex rule sets
- Validate policies with the ConfigCI module

### Documentation Style Guide

- Use clear, concise language
- Follow Microsoft's style guide for technical documentation
- Use proper heading hierarchy
- Include code examples where appropriate
- Use consistent terminology

## Community

### Communication Channels

- GitHub Issues: For bug reports and feature requests
- GitHub Discussions: For general discussion and questions
- Email: Contact maintainers directly for sensitive issues

### Recognition

Contributors are recognized in:

- Release notes
- Contributor list
- Annual contributor spotlight

### Getting Help

If you need help with your contribution:

1. Check the documentation
2. Search existing issues
3. Ask in GitHub Discussions
4. Contact maintainers directly

## Additional Resources

- [WDAC Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)

Thank you for contributing to the WDAC Enterprise Security Toolkit!