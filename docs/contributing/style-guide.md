# Style Guide

This style guide outlines the coding and documentation standards for the WDAC Policy Toolkit project. Following these guidelines helps maintain consistency and quality across the project.

## Code Style

### PowerShell Coding Standards

#### Naming Conventions

- Use PascalCase for function names: `Get-WDACStatus`
- Use camelCase for variables: `$policyPath`
- Use UPPERCASE for constants: `MAX_RETRY_ATTEMPTS`
- Use descriptive names that clearly indicate purpose

#### Function Structure

```powershell
function Get-WDACStatus {
    <#
    .SYNOPSIS
    Gets the current WDAC policy status
    
    .DESCRIPTION
    Retrieves information about the currently deployed WDAC policy including
    enforcement status, policy location, and recent events.
    
    .PARAMETER ComputerName
    The name of the computer to check. Defaults to localhost.
    
    .EXAMPLE
    Get-WDACStatus
    
    Returns the WDAC status for the local computer.
    
    .EXAMPLE
    Get-WDACStatus -ComputerName "SERVER01"
    
    Returns the WDAC status for SERVER01.
    
    .OUTPUTS
    PSCustomObject containing status information
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    # Implementation here
}
```

#### Error Handling

- Use try/catch blocks for error handling
- Provide meaningful error messages
- Use Write-Error for terminating errors
- Use Write-Warning for non-terminating issues
- Log errors appropriately

#### Comments

- Use comment-based help for all public functions
- Add inline comments for complex logic
- Keep comments up to date with code changes
- Remove commented-out code before committing

### XML Policy Standards

#### Formatting

- Use 2-space indentation
- Place each attribute on a new line for complex elements
- Maintain consistent spacing and alignment

#### Element Ordering

Follow this order for policy elements:
1. VersionEx
2. PlatformID or BasePolicyID
3. Rules
4. EKUs
5. FileRules
6. Signers
7. SigningScenarios
8. UpdatePolicySigners
9. CiSigners
10. HvciOptions
11. Settings

#### Naming Conventions

- Use ID prefixes for rule identification: `ID_ALLOW_`, `ID_DENY_`, `ID_SIGNER_`
- Use descriptive FriendlyName attributes
- Maintain consistent naming patterns

## Documentation Style

### Markdown Formatting

#### Headers

Use proper header hierarchy:
```markdown
# Main Title (H1)
## Section Title (H2)
### Subsection Title (H3)
#### Sub-subsection Title (H4)
```

#### Lists

Use hyphens for unordered lists:
```markdown
- First item
- Second item
- Third item
```

Use numbered lists for sequential steps:
```markdown
1. First step
2. Second step
3. Third step
```

#### Code Blocks

Specify the language for syntax highlighting:
```markdown
```powershell
Get-WDACStatus
```
```

#### Links

Use descriptive link text:
```markdown
[Policy Creation Guide](../using/base-policy.md)
```

### Writing Style

#### Voice and Tone

- Use clear, concise language
- Write in active voice when possible
- Maintain a professional but approachable tone
- Avoid jargon unless explaining it

#### Grammar and Mechanics

- Use American English spelling and grammar
- Use serial commas (Oxford commas)
- Use present tense for instructions
- Use second person ("you") when addressing the reader

#### Content Structure

- Begin with a brief overview of the topic
- Use short paragraphs (2-4 sentences)
- Include examples where appropriate
- End with next steps or related topics

## Commit Message Guidelines

### Format

Follow the conventional commit format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Scope

Optional scope specifies the place of the commit change:
- `cli`: Command-line interface tools
- `gui`: Graphical user interface (future)
- `docs`: Documentation
- `policy`: Policy templates and samples
- `tests`: Test files

### Subject

- Use imperative mood ("Add feature" not "Added feature")
- Don't capitalize first letter
- No period at the end
- Keep under 50 characters

### Body

- Wrap at 72 characters
- Explain what and why, not how
- Use bullet points if needed

### Footer

- Reference issues closed by the commit
- Mention breaking changes

### Examples

```
feat(cli): add policy validation tool

Add new CLI tool for validating WDAC policy XML files for syntax and structure correctness.

Closes #123
```

```
fix(docs): correct installation steps

Update installation documentation to reflect correct PowerShell execution policy requirements.

Fixes #456
```

## File Organization

### Directory Structure

Follow the established directory structure:
```
├── docs/
│   ├── getting-started/
│   ├── using/
│   └── contributing/
├── tools/
│   ├── cli/
│   └── templates/
├── samples/
└── tests/
```

### File Naming

- Use lowercase with hyphens to separate words
- Use descriptive names that indicate content
- Match documentation filenames to their topics
- Use `.ps1` extension for PowerShell scripts
- Use `.md` extension for Markdown files
- Use `.xml` extension for policy files

## Versioning

Follow Semantic Versioning (SemVer):
- MAJOR version for incompatible changes
- MINOR version for backward-compatible features
- PATCH version for backward-compatible bug fixes

Format: `MAJOR.MINOR.PATCH` (e.g., 1.2.3)

## Testing

### PowerShell Script Tests

- Include unit tests for new functions
- Test both success and error conditions
- Use descriptive test names
- Mock external dependencies when possible

### Policy Tests

- Validate XML structure
- Test policy rules with sample applications
- Verify policy merging works correctly
- Check policy deployment scenarios

## Accessibility

### Documentation Accessibility

- Use alt text for images
- Ensure sufficient color contrast
- Use heading hierarchy properly
- Write clear link text

### Code Accessibility

- Use descriptive variable names
- Include helpful error messages
- Provide multiple ways to accomplish tasks when possible
- Document accessibility features

By following these guidelines, you help maintain the quality and consistency of the WDAC Policy Toolkit project.