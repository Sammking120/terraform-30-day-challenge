# How Conditionals Make Terraform Infrastructure Dynamic and Efficient

In the early days of Infrastructure as Code (IaC), "scaling" often meant
"copy-pasting." If you needed a staging environment and a production
environment, you likely ended up with two nearly identical folders of
code. This redundancy is the enemy of efficiency.

Terraform conditionals are the solution. By moving away from static
declarations toward logic-driven configurations, you can build a single
codebase that adapts to your needs. Here is how to master the patterns
that make your infrastructure truly dynamic.

------------------------------------------------------------------------

## 1. The Ternary Expression: Beyond Static Strings

**The Problem:** Hard-coding values like instance sizes or naming
conventions makes your modules brittle.

**The Solution:** The ternary operator allows you to swap values
dynamically.

### Before (Static)

``` hcl
resource "aws_instance" "server" {
  instance_type = "t3.micro"
}
```

### After (Dynamic)

``` hcl
resource "aws_instance" "server" {
  instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"
}
```

------------------------------------------------------------------------

## 2. The `count` Pattern: Conditional Resource Creation

``` hcl
resource "aws_instance" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  ami           = "ami-xyz"
  instance_type = "t3.micro"
}
```

------------------------------------------------------------------------

## 3. Safe Referencing

``` hcl
output "bastion_ip" {
  value = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : "none"
}
```

------------------------------------------------------------------------

## 4. Input Validation

``` hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'"
  }
}
```

------------------------------------------------------------------------

## 5. Environment-Aware Module Pattern

``` hcl
locals {
  env_settings = {
    dev = {
      size  = "t3.micro"
      count = 1
    }
    prod = {
      size  = "m5.large"
      count = 3
    }
  }

  cfg = local.env_settings[var.environment]
}

resource "aws_instance" "cluster" {
  count         = local.cfg.count
  instance_type = local.cfg.size
}
```

------------------------------------------------------------------------

## Conclusion

Conditionals transform Terraform into a powerful orchestration engine
for dynamic infrastructure.
