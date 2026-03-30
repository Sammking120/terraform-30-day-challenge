---
categories:
- Terraform
- DevOps
- IaC
date: 2026-03-30
layout: post
tags:
- terraform
- modules
- devops
- infrastructure-as-code
- aws
title: Building Reusable Infrastructure with Terraform Modules
---

# Building Reusable Infrastructure with Terraform Modules

As your Terraform configurations grow, one thing becomes obvious very
quickly:

> Copy-pasting infrastructure code does not scale.

This is where **Terraform modules** come in.

------------------------------------------------------------------------

## What is a Terraform Module?

A module is a **container for multiple Terraform resources** that are
used together.

-   Root module → where you run `terraform apply`\
-   Child modules → reusable components

------------------------------------------------------------------------

## Module Directory Structure

    modules/
      vpc/
        main.tf
        variables.tf
        outputs.tf
        README.md
      ec2/
        main.tf
        variables.tf
        outputs.tf

    live/
      dev/
        main.tf
      prod/
        main.tf

------------------------------------------------------------------------

## Example Module: EC2

### main.tf

``` hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}
```

### variables.tf

``` hcl
variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "name" {
  type = string
}
```

### outputs.tf

``` hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

------------------------------------------------------------------------

## Calling the Module

``` hcl
module "web_server" {
  source = "../../modules/ec2"

  ami           = "ami-123456"
  instance_type = "t2.micro"
  name          = "dev-web-server"
}
```

------------------------------------------------------------------------

## Good vs Bad Modules

### Good Module

-   Clear inputs\
-   Sensible defaults\
-   Simple design\
-   Reusable

### Bad Module

-   Too many variables\
-   Hardcoded logic\
-   Environment-specific logic\
-   Poor naming

------------------------------------------------------------------------

## Best Practices

### Naming

-   Use clear names (`instance_type`, `vpc_id`)

### Keep Modules Small

-   One responsibility per module

### Split When Needed

-   Large modules → smaller focused ones

### Avoid Hardcoding

-   Always use variables

### Write README

Include: - Description\
- Inputs\
- Outputs\
- Usage example

------------------------------------------------------------------------

## Final Thoughts

Terraform modules help you move from writing infrastructure to designing
systems.

Good modules improve: - Reusability\
- Consistency\
- Collaboration

Bad modules create technical debt.

------------------------------------------------------------------------

*Author: Sammy King*\
*DevOps \| Cloud \| Terraform*
