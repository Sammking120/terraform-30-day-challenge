
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

## Terraform Modules

A module is a reusable package of Terraform code.

Think of it as a blueprint: - Dev = small deployment\
- Production = larger deployment\
- Same design, different scale

------------------------------------------------------------------------

## Project Structure

    modules/
      services/
        webserver-cluster/
          main.tf
          variables.tf
          outputs.tf

    live/
      dev/
      production/

------------------------------------------------------------------------

## Inputs (Variables)

``` hcl
variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}
```

------------------------------------------------------------------------

## Outputs

``` hcl
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}
```

------------------------------------------------------------------------

## Calling the Module

### Dev

``` hcl
module "webserver_cluster" {
  source        = "../../../../modules/services/webserver-cluster"
  cluster_name  = "webservers-dev"
  instance_type = "t3.micro"
  min_size      = 1
  max_size      = 2
}
```

### Production

``` hcl
module "webserver_cluster" {
  source        = "../../../../modules/services/webserver-cluster"
  cluster_name  = "webservers-production"
  instance_type = "t3.micro"
  min_size      = 2
  max_size      = 5
}
```

------------------------------------------------------------------------

## Key Insight

Only inputs change.\
The module stays the same.

------------------------------------------------------------------------

## What Makes a Good Module

-   Clear inputs\
-   Sensible defaults\
-   Minimal complexity\
-   Strong abstraction

------------------------------------------------------------------------

## Final Thoughts

Modules turn Terraform from scripts into systems.

**Write it once. Use it everywhere. Change it in one place.**

------------------------------------------------------------------------

*Author: Sammy King*\
*DevOps \| Cloud \| Terraform*
