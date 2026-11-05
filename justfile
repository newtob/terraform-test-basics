tf := "terraform -chdir=terraform"

# List available recipes
default:
    @just --list

# Initialise Terraform without backend
tf-init:
    {{ tf }} init -backend=false -input=false -no-color > /dev/null

# Validate Terraform configuration
[group('infra')]
tf-validate: tf-init
    {{ tf }} validate -no-color

# Lint with tflint
[group('infra')]
tf-lint:
    tflint --chdir=terraform --config="$PWD/.tflint.hcl" --no-color

# Validate and lint
[group('infra')]
tf-check: tf-validate tf-lint

# Run terraform test suite
[group('infra')]
tf-test: tf-init
    {{ tf }} test -no-color

# Format Terraform files
[group('infra')]
tf-fix:
    {{ tf }} fmt -recursive -no-color

# Auto-fix all formatting
[group('root')]
fix: tf-fix

# Run all checks and tests
[group('root')]
ci: tf-check tf-test
