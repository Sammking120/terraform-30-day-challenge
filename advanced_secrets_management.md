# Advanced Secrets Management Guide (Terraform, Multi-Cloud)

This is a **practical, production-grade reference** for securing secrets
across Terraform workflows. The focus is not theory---it's eliminating
real-world leak vectors and enforcing least-privilege, auditable access
patterns.

------------------------------------------------------------------------

## 1. The Three Leak Paths (and How to Close Them)

### Path A: Version Control Leak (Git)

**Failure Mode** - Hardcoded secrets in `.tf` or `.tfvars` - Accidental
commits of local config files - Secrets lingering forever in Git history

**Mitigations** - Never store secrets in Terraform code - Use
`.gitignore` aggressively - Use secret managers as the source of truth

``` hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

------------------------------------------------------------------------

### Path B: Console / CI Logs Leak

``` hcl
variable "api_key" {
  type      = string
  sensitive = true
}
```

------------------------------------------------------------------------

### Path C: State File Leak

-   Never use local state
-   Always use encrypted remote backends

------------------------------------------------------------------------

## 2. AWS Secrets Manager Integration

``` hcl
data "aws_secretsmanager_secret" "db_password" {
  name = "prod/db/password"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "db" {
  username = "admin"
  password = data.aws_secretsmanager_secret_version.current.secret_string
}
```

------------------------------------------------------------------------

## 3. HashiCorp Vault Integration

``` hcl
provider "vault" {
  address = "https://vault.example.com"
}

data "vault_kv_secret_v2" "db" {
  mount = "secret"
  name  = "prod/db"
}

resource "aws_db_instance" "db" {
  password = data.vault_kv_secret_v2.db.data["password"]
}
```

------------------------------------------------------------------------

## 4. Environment Variables

``` bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

------------------------------------------------------------------------

## 5. State Backend Example

``` hcl
terraform {
  backend "s3" {
    bucket  = "my-terraform-state"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```

------------------------------------------------------------------------

## 6. .gitignore Template

``` gitignore
*.tfstate
*.tfvars
.terraform/
.env
```

------------------------------------------------------------------------

## 7. IAM Policy Example

``` json
{
  "Effect": "Allow",
  "Action": ["s3:GetObject","s3:PutObject"],
  "Resource": "arn:aws:s3:::my-terraform-state/*"
}
```

------------------------------------------------------------------------

## Summary

-   Keep secrets out of code
-   Use secret managers
-   Use encrypted remote state
-   Enforce least privilege
