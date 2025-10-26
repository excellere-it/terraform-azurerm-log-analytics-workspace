# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automating testing, security scanning, and releases of the terraform-azurerm-log-analytics-workspace module.

## Workflows

### test.yml

**Purpose**: Automated testing and validation of Terraform code

**Triggers**:
- Push to `main` or `develop` branches (when `**.tf`, `test/**`, or workflow files change)
- Pull requests to `main` or `develop` branches (when `**.tf`, `test/**`, or workflow files change)
- Manual workflow dispatch

**Jobs**:

1. **terraform-format**: Checks Terraform code formatting
   - Runs `terraform fmt -check -recursive`
   - Fails if code is not properly formatted

2. **terraform-validate**: Validates Terraform configuration
   - Initializes Terraform with `terraform init -backend=false`
   - Runs `terraform validate`

3. **security-scan**: Security analysis with Checkov
   - Scans Terraform code for security issues
   - Soft fail mode (warnings don't fail the build)
   - Uploads SARIF results as artifacts

4. **lint**: Code quality linting with TFLint
   - Initializes TFLint
   - Runs linting checks

5. **test-examples**: Tests all example configurations
   - Matrix strategy testing multiple examples (default, diff-rg)
   - For each example:
     - Initializes Terraform
     - Validates configuration
     - Creates a plan
     - Uploads plan as artifact

6. **test-summary**: Aggregates test results
   - Creates summary in GitHub Actions
   - Fails if required tests fail

7. **comment-pr**: Comments on pull requests
   - Posts test results summary to PR
   - Shows status icons for each check

**Permissions**:
- `contents: read`
- `pull-requests: write`

**Required Secrets**: None (public repository)

### release-module.yml

**Purpose**: Automated module releases

**Triggers**:
- Push of tags matching pattern `v*.*.*` (e.g., `v0.1.0`, `v1.0.0`)

**Jobs**:

1. **release**: Creates GitHub release
   - Checks out code
   - Creates release using softprops/action-gh-release
   - Auto-generates release notes from commits

**Usage**:
```bash
# Create and push a tag to trigger release
git tag v0.1.0
git push origin v0.1.0
```

## Common Issues and Troubleshooting

### Format Check Failures

**Problem**: `terraform-format` job fails

**Solution**:
```bash
# Format all Terraform files locally
make fmt

# Or
terraform fmt -recursive

# Commit the changes
git add .
git commit -m "fix: Format Terraform files"
git push
```

### Validation Failures

**Problem**: `terraform-validate` job fails

**Solution**:
```bash
# Validate locally
make validate

# Or
terraform init -backend=false
terraform validate

# Fix any errors reported
```

### Example Test Failures

**Problem**: `test-examples` job fails

**Solution**:
```bash
# Test specific example locally
cd examples/default
terraform init
terraform validate
terraform plan

# Fix any errors in the example
```

### Security Scan Issues

**Problem**: Checkov reports security concerns

**Solution**:
- Review the security findings in the workflow artifacts
- Address legitimate security issues
- For false positives, add inline skip comments:
  ```hcl
  resource "azurerm_log_analytics_workspace" "workspace" {
    #checkov:skip=CKV_AZURE_123:Reason for skipping
    # ... resource configuration
  }
  ```

### Lint Failures

**Problem**: TFLint reports issues

**Solution**:
```bash
# Run locally
make lint

# Or
tflint --init
tflint

# Fix reported issues
```

## Workflow Maintenance

### Updating Terraform Version

To update the Terraform version used in workflows:

1. Edit `test.yml`
2. Update `terraform_version` in all `hashicorp/setup-terraform@v3` steps
3. Test locally with the new version before committing

### Adding New Examples

When adding a new example:

1. Create the example directory under `examples/`
2. Update `test.yml` workflow:
   ```yaml
   strategy:
     matrix:
       example:
         - default
         - diff-rg
         - your-new-example  # Add here
   ```

### Modifying Test Jobs

When adding or modifying test jobs:

1. Update the job definition in `test.yml`
2. Update `needs` dependencies in `test-summary` and `comment-pr` jobs
3. Test the workflow on a feature branch before merging

## Running Workflows Locally

While GitHub Actions workflows are designed to run in GitHub's infrastructure, you can test some aspects locally:

### Using Act

[Act](https://github.com/nektos/act) allows running GitHub Actions locally:

```bash
# Install act
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run a specific workflow
act -W .github/workflows/test.yml

# Run a specific job
act -j terraform-format
```

**Note**: Some jobs may not work perfectly with act due to dependencies on GitHub-specific features.

### Manual Testing

Test individual components:

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform init -backend=false
terraform validate

# Examples
cd examples/default && terraform init && terraform validate && terraform plan

# Security scan (requires tfsec)
make security-scan

# Linting (requires tflint)
make lint
```

## Best Practices

1. **Always test locally first**: Run `make fmt`, `make validate`, and `make test` before pushing

2. **Watch workflow runs**: Monitor workflow execution after pushing to catch issues early

3. **Fix format issues immediately**: Format check failures are quick to fix

4. **Address security findings**: Don't ignore security scan results

5. **Keep workflows updated**: Regularly update action versions and Terraform versions

6. **Document workflow changes**: Update this README when modifying workflows

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Checkov GitHub Action](https://github.com/bridgecrewio/checkov-action)
- [TFLint GitHub Action](https://github.com/terraform-linters/setup-tflint)

---

For questions or issues with workflows, please open an issue in the repository.
