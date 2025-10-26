# Terraform Native Tests

This directory contains native Terraform tests (`.tftest.hcl` files) for the terraform-azurerm-log-analytics-workspace module.

## Overview

These tests use Terraform's built-in testing framework (available in Terraform >= 1.6.0) to validate module functionality without requiring external test harnesses.

## Test Files

### basic.tftest.hcl
Tests core Log Analytics Workspace functionality:
- Basic workspace creation with required variables
- Output generation validation
- Data collection rule creation
- Azure Monitor Private Link Scope integration
- Alert rule creation

**Test Cases**:
- `test_basic_workspace` - Verifies workspace is created with correct configuration
- `test_outputs_generated` - Validates all outputs are generated
- `test_data_collection_rule` - Tests DCR creation
- `test_alerts_created` - Verifies alert rules are configured

### validation.tftest.hcl
Tests input validation rules:
- Invalid action group ID formats
- Invalid resource group configurations
- Valid configurations for all inputs
- Edge cases and boundary conditions

**Test Cases**:
- `test_valid_configuration` - Tests with valid inputs
- `test_required_variables` - Validates required variable enforcement
- `test_expiration_days_validation` - Tests expiration days constraints

## Running Tests

### Prerequisites

- Terraform >= 1.6.0 (required for native testing)
- No additional dependencies needed

### Run All Tests

```bash
# Using Terraform directly
terraform test

# Using Makefile
make test-terraform
```

### Run Specific Test File

```bash
terraform test -filter=tests/basic.tftest.hcl
terraform test -filter=tests/validation.tftest.hcl
```

### Run Specific Test Case

```bash
terraform test -filter=test_basic_workspace
terraform test -filter=test_valid_configuration
```

### Verbose Output

```bash
terraform test -verbose
```

## Test Structure

Each test file follows this structure:

```hcl
# Test run block
run "test_name" {
  command = plan  # or apply

  # Input variables
  variables {
    action_group_id = "/subscriptions/.../actionGroups/test"
    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }
    # ... other variables
  }

  # Assertions
  assert {
    condition     = output.some_output != null
    error_message = "Error message if assertion fails"
  }

  # Expected failures (for negative tests)
  expect_failures = [
    var.some_variable,
  ]
}
```

## Test Coverage

Current test coverage:

| Feature | Coverage |
|---------|----------|
| Basic workspace creation | ✅ Comprehensive |
| Input validation | ✅ Comprehensive |
| Outputs | ✅ Comprehensive |
| Data collection rules | ✅ Comprehensive |
| Alert rules | ✅ Comprehensive |
| Private link integration | ✅ Comprehensive |

## Continuous Integration

These tests run automatically in CI/CD:

- On pull requests to `main` and `develop`
- On pushes to `main` and `develop`
- When `*.tf` or `tests/**` files change

See `.github/workflows/test.yml` for CI configuration.

## Writing New Tests

To add new tests:

1. Create a new `.tftest.hcl` file or add to an existing one
2. Follow the naming convention: `test_<feature>_<scenario>`
3. Include clear error messages in assertions
4. Test both positive and negative cases
5. Run tests locally before committing

Example:

```hcl
run "test_new_feature" {
  command = plan

  variables {
    action_group_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Insights/actionGroups/test"
    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }
    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }
    name = {
      contact     = "test@example.com"
      environment = "sbx"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }
  }

  assert {
    condition     = # your condition
    error_message = "Clear description of what went wrong"
  }
}
```

## Comparing to Go Tests

This module has both Terraform native tests (this directory) and Go-based Terratest tests (in the `test/` directory):

| Aspect | Terraform Tests | Go Tests |
|--------|----------------|----------|
| **Location** | `tests/*.tftest.hcl` | `test/*.go` |
| **Framework** | Terraform native | Terratest |
| **Speed** | Fast (plan only) | Slower (may apply) |
| **Requirements** | Terraform >= 1.6.0 | Go >= 1.18 |
| **Best for** | Unit testing, validation | Integration testing |
| **CI/CD** | Yes | Yes |

Both test suites are maintained and run in CI/CD.

## Troubleshooting

### Test Failures

If tests fail:

1. Run with verbose output: `terraform test -verbose`
2. Check the specific assertion that failed
3. Validate your changes didn't break existing functionality
4. Ensure you're using Terraform >= 1.6.0

### Terraform Version

Check your Terraform version:

```bash
terraform version
```

If you're using an older version, upgrade:

```bash
# Using tfenv
tfenv install latest
tfenv use latest

# Or download from terraform.io
```

### Debugging Tests

Add temporary output blocks to debug:

```hcl
run "test_debug" {
  command = plan

  variables {
    # ...
  }

  # This will print during test execution
  assert {
    condition     = true
    error_message = "Debug: ${output.some_value}"
  }
}
```

## Best Practices

1. **Keep tests focused** - Each test should validate one specific behavior
2. **Use descriptive names** - Test names should clearly indicate what they test
3. **Clear error messages** - Help developers understand failures quickly
4. **Test edge cases** - Don't just test the happy path
5. **Maintain tests** - Update tests when functionality changes
6. **Run before commit** - Always run tests before pushing changes

## Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Writing Terraform Tests](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)

---

For questions or issues with tests, please open an issue in the repository.
