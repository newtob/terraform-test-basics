# terraform-test-basics

A small repo for trying out native [`terraform test`](https://developer.hashicorp.com/terraform/language/tests).

It defines one S3 bucket using the public module
[`terraform-aws-modules/s3-bucket/aws`](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest)
and tests it with a **mocked AWS provider**. The code is **never deployed**: no AWS account, credentials or
network access to AWS are needed, and nothing is created.

## What gets built

`terraform/main.tf` declares:

- the S3 bucket (module `~> 5.3`) with AES256 server-side encryption, versioning and default tags
- an `aws_s3_bucket_public_access_block` that blocks all public access

The public access block lives in the root module (the module's own is turned off with
`attach_public_policy = false`) because `terraform test` can only read root-module resources and a
module's outputs, not resources inside a module.

## Tests

`terraform/tests/s3_bucket.tftest.hcl` (all `command = plan`, using `mock_provider "aws"`):

| Run | Checks |
| --- | --- |
| `s3_bucket_is_not_public` | all four public-access-block settings are `true` |
| `no_bucket_policy_attached` | no bucket policy is attached (it could grant public access) |
| `versioning_and_tags` | versioning is `Enabled` and the default `ManagedBy` tag is set |
| `rejects_invalid_bucket_name` | an invalid `bucket_name` fails variable validation |

## Prerequisites

- Terraform >= 1.7 (needed for `mock_provider`). `.terraform-version` pins `1.17.1`; [`tenv`](https://github.com/tofuutils/tenv) picks it up automatically
- [`just`](https://just.systems), [`tflint`](https://github.com/terraform-linters/tflint), [`prek`](https://github.com/j178/prek)
- `betterleaks` or `gitleaks` (the secret-scan hook fails if neither is installed)

## Running the tests

```sh
just ci            # fmt check, validate, tflint, then all tests
just infra-test    # tests only
```

Without `just`:

```sh
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform test
terraform -chdir=terraform test -filter=tests/s3_bucket.tftest.hcl -verbose
```

The first run can take about a minute while the large AWS provider plugin is started for the first time.

To see the main test fail, set `block_public_acls = false` in `terraform/main.tf` and run `just infra-test`.

## Other commands

| Command | Purpose |
| --- | --- |
| `just` | list all recipes |
| `just infra-check` | fmt check, validate and tflint (no changes made) |
| `just fix` | run `terraform fmt` |
| `prek install` | install the git pre-commit hook |
| `prek run -a -q` | run every hook against all files |

Hooks (`prek.toml`): whitespace/EOF/YAML/large-file/merge-conflict checks, secret scan, `terraform fmt -check`,
`terraform validate` and `tflint`. `terraform test` runs in `just ci`, not in the commit hook.

## Layout

```
terraform/            root module (main, variables, outputs, locals, providers, versions)
terraform/tests/      terraform test files
scripts/hooks/        secret-scan scripts used by prek
justfile              command surface
prek.toml             pre-commit hooks
.tflint.hcl           tflint config
```

## Running against real AWS (optional)

Remove `mock_provider` and switch a run to `command = apply` to create real resources in a sandbox account
(`terraform test` destroys them afterwards). That is outside the scope of this repo.
