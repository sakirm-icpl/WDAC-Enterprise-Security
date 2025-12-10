# Code Review Guidelines

This document outlines the code review process and guidelines for contributing to the WDAC Enterprise Security Toolkit.

## Code Review Process

### Pull Request Workflow

1. **Fork and Branch**: Contributors should fork the repository and create a feature branch for their changes
2. **Submit Pull Request**: Create a pull request (PR) targeting the `main` branch
3. **Automated Checks**: PRs automatically trigger CI checks for syntax, formatting, and basic validation
4. **Manual Review**: Maintainers review the code for quality, security, and adherence to guidelines
5. **Feedback Loop**: Address reviewer feedback and make necessary changes
6. **Approval and Merge**: Once approved, maintainers merge the PR

### Review Criteria

#### Code Quality
- Code follows PowerShell best practices and style guidelines
- Functions and scripts are well-documented with comment-based help
- Error handling is implemented appropriately
- Code is readable and maintainable
- Duplicated code is minimized through reusable functions

#### Security
- No hardcoded credentials or sensitive information
- Proper input validation and sanitization
- Secure handling of file paths and system resources
- Adherence to principle of least privilege
- No use of potentially dangerous PowerShell cmdlets without justification

#### Functionality
- Changes achieve the stated objectives
- No breaking changes to existing APIs or command-line interfaces
- Proper handling of edge cases and error conditions
- Backward compatibility is maintained
- Performance considerations are addressed

#### Documentation
- Code comments explain complex logic
- README files are updated if functionality changes
- Help documentation is provided for new functions
- Examples are provided for new features

## Review Roles

### Contributor Responsibilities
- Ensure code is well-tested before submission
- Provide clear descriptions of changes in PR
- Respond promptly to review feedback
- Follow coding standards and guidelines
- Update documentation as needed

### Reviewer Responsibilities
- Review code within 48 hours of submission
- Provide constructive, actionable feedback
- Focus on code quality, security, and functionality
- Approve only when satisfied with changes
- Be respectful and professional in feedback

### Maintainer Responsibilities
- Final approval on all PRs
- Ensure adherence to project vision and standards
- Coordinate releases and version management
- Handle conflict resolution when needed
- Mentor new contributors

## Review Checklist

### PowerShell Script Review
- [ ] Uses appropriate PowerShell verbs for function names
- [ ] Includes comment-based help for public functions
- [ ] Implements proper error handling with try/catch blocks
- [ ] Uses approved verbs and follows naming conventions
- [ ] Avoids aliases in favor of full cmdlet names
- [ ] Uses appropriate parameter validation
- [ ] Handles pipeline input appropriately
- [ ] Includes appropriate output types
- [ ] Uses Write-Verbose, Write-Warning, and Write-Error appropriately

### XML Policy Review
- [ ] Valid XML syntax
- [ ] Correct WDAC policy structure
- [ ] Appropriate use of Allow/Deny rules
- [ ] Valid signer and file rule references
- [ ] Correct PolicyType specification
- [ ] Proper use of wildcards and paths
- [ ] No conflicting rules

### Documentation Review
- [ ] Clear and accurate descriptions
- [ ] Proper grammar and spelling
- [ ] Consistent formatting and style
- [ ] Updated version numbers and dates
- [ ] Working links and references

## Review Etiquette

### Providing Feedback
- Be specific and actionable in comments
- Explain the "why" behind suggestions
- Link to relevant documentation or style guides
- Use "nitpick" label for minor style issues
- Approve with suggestions using "Approve with comments" when appropriate

### Receiving Feedback
- Respond to all comments within reasonable time
- Ask for clarification when needed
- Make requested changes or provide justification for alternatives
- Thank reviewers for their time and expertise
- Be open to learning and improvement

## Approval Process

### Single Approval
- Minor changes (bug fixes, documentation updates)
- Non-breaking enhancements
- Test improvements

### Dual Approval
- Major feature additions
- Breaking changes
- Security-related modifications
- Architecture changes

### Maintainer Approval
- All PRs require maintainer approval for merge
- Maintainers can merge after sufficient review and approval
- Emergency fixes may be merged by maintainers after review

## Post-Merge Activities

### Release Notes
- Significant changes are documented in release notes
- Contributors are credited for their work
- Breaking changes are clearly identified

### Communication
- Major changes are announced to the community
- Updates are posted to relevant channels
- Feedback is solicited for new features

## Continuous Improvement

### Review Process Evolution
- Regular retrospectives on review process effectiveness
- Updates to guidelines based on team feedback
- Training for new reviewers
- Metrics tracking for review turnaround times

### Quality Metrics
- Code review turnaround time
- Number of issues caught in review vs. post-release
- Contributor satisfaction surveys
- Merge conflict rates

This document is a living guideline and will evolve based on team experiences and feedback.