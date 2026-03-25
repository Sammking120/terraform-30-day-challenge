variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = "terraform-day-4-asg"
}
variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 5
}

variable "security_group_name" {
  description = "Name of the instance security group"
  type        = string
  default     = "terraform-day-04-instance-sg"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "terraform-day-4-alb"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-central-1"
}

variable "server_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "terraform-day-4-server"
}