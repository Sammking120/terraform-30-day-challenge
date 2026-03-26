# Managing High Traffic Applications with AWS Elastic Load Balancer and Terraform

Modern applications must handle unpredictable traffic while maintaining
performance and uptime. This is where **Application Load Balancers
(ALB)** and **Auto Scaling Groups (ASG)** come in---especially when
managed using **Terraform**.

## 🏗️ Architecture Overview

-   Application Load Balancer distributes traffic\
-   Target Group ensures only healthy instances receive traffic\
-   Auto Scaling Group dynamically scales instances\
-   Terraform manages infrastructure as code

## ⚙️ ALB Setup

``` hcl
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
}
```

## 🔄 Auto Scaling Integration

``` hcl
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 5
  min_size         = 1
}
```

## 🧠 Terraform State

Terraform uses a state file to track infrastructure and prevent
duplication.

## 🔐 Best Practices

-   Never commit state files\
-   Use remote backends (S3)\
-   Enable state locking (DynamoDB)

## 📊 Terraform Blocks

  Block      Purpose
  ---------- -----------------
  provider   Configure cloud
  resource   Define infra
  variable   Input values
  output     Expose values

## 🚀 Final Thoughts

This is a production-ready architecture used in real-world cloud
systems.
