# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.10] - 2025-01-14

### Changed
- Updated random provider version to ~> 3.6 in examples
- Minor dependency updates

### Changed
- **COMPLIANCE**: Extended log retention to 365 days (from 90 days) for PCI-DSS 10.7 and SOC 2 compliance
- Standardized module structure to match reference standards
- Improved documentation with auto-generated sections

### Added
- Comprehensive .gitignore with extensive patterns for security, IDE, and build artifacts
- Enhanced Makefile with full development automation targets
- CONTRIBUTING.md with complete development workflow and guidelines
- CHANGELOG.md for tracking version history
- GitHub Actions CI/CD workflows for automated testing and releases
- Native Terraform tests in tests/ directory
- tests/README.md documenting test approach and usage
- Enhanced documentation generation with terraform-docs

## [0.0.1] - Previous Release

### Added
- Initial module implementation for Azure Log Analytics Workspace
- Support for Log Analytics solutions deployment
- VM Insights data collection rule configuration
- Azure Monitor Private Link Scope integration
- Automated alerting for operational issues and ingestion limits
- Diagnostic settings integration
- Integration with terraform-namer module for naming conventions
- Go-based tests using Terratest
- Basic examples (default, diff-rg)

### Features
- Log Analytics Workspace with configurable SKU and retention
- Internet ingestion and query enabled by default
- Pre-configured alerts for:
  - Operational issues (APOT)
  - Ingestion rate limit (APIT)
  - Daily cap reached (APCT)
- Data collection rules for VM Insights
- Support for multiple Log Analytics solutions

### Supported
- Terraform >= 1.3
- Azure Provider >= 3.41
- Integration with Azure Monitor Private Link Scope
- Action Group integration for alerts

---

## Version History Notes

### Versioning Scheme

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

### Release Process

Releases are automated via GitHub Actions:
1. Create a tag matching the pattern `v*.*.*` (e.g., `v0.1.0`)
2. Push the tag to GitHub
3. GitHub Actions automatically creates a release with notes

### Upgrade Guidance

When upgrading between versions, check the relevant sections above for:
- **Breaking Changes**: May require updates to your configuration
- **Deprecated Features**: Plan to migrate away from these
- **New Features**: Optional enhancements you may want to adopt

---

## Template for Future Releases

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features and capabilities

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security-related changes
```

---

[Unreleased]: https://github.com/infoex/terraform-azurerm-log-analytics-workspace/compare/0.0.1...HEAD
[0.0.1]: https://github.com/infoex/terraform-azurerm-log-analytics-workspace/releases/tag/0.0.1
