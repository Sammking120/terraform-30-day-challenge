# 🚀*Deploying a Highly Available Web App on AWS Using Terraform* (Terraform Journey)

## 📌 Introduction

This project captures my journey from deploying a **single hardcoded EC2 instance** to building a **configurable, highly available, clustered web server architecture** using Terraform.

The evolution highlights key DevOps principles:

* Infrastructure as Code (IaC)
* DRY (Don’t Repeat Yourself)
* Scalability & High Availability

---

# 🧱 Stage 1: Single Hardcoded Server (Day 3)

Initially, the setup involved:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              echo "Hello World" > /var/www/html/index.html
              EOF
}
```

### ❌ Problems with This Approach

* Hardcoded AMI and instance type
* No scalability
* Single point of failure
* Not reusable across environments

---

# 🔁 Stage 2: Making It Configurable (Using Variables)

## What Are Input Variables?

Input variables allow you to parameterize your Terraform code so you don’t hardcode values.

### Example Variables File

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "server_port" {
  description = "Port for web server"
  type        = number
  default     = 80
}
```

## Why Variables Matter

* Improve reusability
* Enable environment flexibility (dev, staging, prod)
* Support team collaboration
* Enforce DRY principle

---

# 🏗️ Stage 3: Clustered Architecture (ASG + ALB)

## 🔹 Data Sources (Dynamic Infrastructure)

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

### 💡 Explanation

* Fetches existing VPC instead of creating one
* Dynamically retrieves subnets
* Avoids hardcoding IDs

---

## 🔐 Security Groups

```hcl
resource "aws_security_group" "instance_sg" {
  name = "instance-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 💡 Explanation

* Allows HTTP traffic into instances
* Allows all outbound traffic

---

## 🚀 Launch Template

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-template"
  image_id      = "ami-0cebfb1f908092578"
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              echo "Hello from Terraform Cluster" > /var/www/html/index.html
              systemctl start apache2
              EOF
  )
}
```

### 💡 Explanation

* Defines how instances are created
* Ensures consistency across all EC2 instances

---

## 📈 Auto Scaling Group (ASG)

```hcl
resource "aws_autoscaling_group" "web" {
  min_size         = 2
  max_size         = 5
  desired_capacity = 2

  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]
}
```

### 💡 Explanation

* Maintains multiple instances
* Replaces unhealthy instances automatically
* Scales based on demand

---

## ⚖️ Application Load Balancer (ALB)

```hcl
resource "aws_lb" "web" {
  name               = "web-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.instance_sg.id]
}
```

### 💡 Explanation

* Distributes incoming traffic
* Improves availability

---

## 🎯 Target Group

```hcl
resource "aws_lb_target_group" "web" {
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
  }
}
```

### 💡 Explanation

* Routes traffic to instances
* Performs health checks

---

## 🎧 Listener

```hcl
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
```

### 💡 Explanation

* Listens for incoming traffic
* Forwards requests to target group

---

# 🔗 Final Architecture Flow

User → ALB → Listener → Target Group → ASG → EC2 Instances

---

# 🎯 Why This Architecture Matters

## Problems Solved

* Eliminates single point of failure
* Handles traffic spikes
* Improves reliability
* Enables automatic recovery

---

# 🧠 Key Lessons Learned

## 1. Variables = Flexibility

You can change infrastructure behavior without modifying core code.

## 2. Data Sources = Dynamic Infrastructure

Avoid hardcoding IDs and make code reusable.

## 3. ASG = Self-Healing Systems

Automatically replaces failed instances.

## 4. ALB = Scalability

Distributes load efficiently across instances.

---

# 🚀 Conclusion

This journey transformed a simple static deployment into a **production-ready, scalable system**.

I now understand how to:

* Build resilient infrastructure
* Write reusable Terraform code
* Design systems for scale and availability

---
