# Managing Terraform State: Best Practices for DevOps

Infrastructure as Code (IaC) is powerful---but only if your state
management is solid. In Terraform, **state is the single source of
truth** for your infrastructure. Mismanaging it is one of the fastest
ways to break production systems.

------------------------------------------------------------------------

## What is Terraform State?

Terraform state is a JSON file (`terraform.tfstate`) that tracks: - All
resources Terraform manages - Their real-world IDs (e.g., AWS resource
ARNs) - Dependency relationships - Metadata needed for updates and
deletions

Think of it as Terraform's **memory layer**.

------------------------------------------------------------------------

## Why Local State Fails at Scale

By default, Terraform stores state locally:

``` bash
terraform.tfstate
```

### Key Problems

**1. No Collaboration** - Multiple engineers overwrite the same file -
No locking → race conditions

**2. No Security** - State files may contain sensitive data - Stored
unencrypted on local machines

**3. No Reliability** - If your laptop crashes → state is gone - No
versioning or rollback

**4. No Concurrency Control** - Two engineers running `terraform apply`
= corruption risk

------------------------------------------------------------------------

## The Solution: Remote State (S3 + DynamoDB)

-   **S3 bucket** → stores Terraform state\
-   **DynamoDB table** → handles state locking

------------------------------------------------------------------------

## Backend Configuration

``` hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-226"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
```

### Argument Breakdown

-   **bucket**: S3 bucket storing state\
-   **key**: Path to state file\
-   **region**: AWS region\
-   **dynamodb_table**: Enables locking\
-   **encrypt**: Enables encryption

------------------------------------------------------------------------

## AWS Provider

``` hcl
provider "aws" {
  region = "eu-central-1"
}
```

------------------------------------------------------------------------

## S3 Bucket

``` hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-226"

  lifecycle {
    prevent_destroy = true
  }
}
```

------------------------------------------------------------------------

## Versioning

``` hcl
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

------------------------------------------------------------------------

## Encryption

``` hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

------------------------------------------------------------------------

## Block Public Access

``` hcl
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}
```

------------------------------------------------------------------------

## DynamoDB Lock Table

``` hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

------------------------------------------------------------------------

## Outputs

``` hcl
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 Bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
```

------------------------------------------------------------------------

## Best Practices

### Always:

-   Use remote state\
-   Enable locking\
-   Enable versioning\
-   Encrypt state\
-   Block public access

### Avoid:

-   Local state in teams\
-   Manual sharing\
-   No locking

------------------------------------------------------------------------

## Final Thoughts

Terraform state management is foundational to reliable infrastructure.\
Done correctly, it enables safe collaboration, scalability, and
production readiness.

------------------------------------------------------------------------

*Author: Sammy King*\
*DevOps \| Cloud \| Terraform*
