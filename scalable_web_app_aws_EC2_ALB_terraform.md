# Building a Scalable Web Application on AWS with EC2, ALB, and Auto Scaling using Terraform

Static websites are great, but the real power of the cloud lies in **dynamic scalability**. Today, I’m taking a deep dive into the "Golden Trio" of AWS architecture: **Elastic Compute Cloud (EC2)**, **Application Load Balancers (ALB)**, and **Auto Scaling Groups (ASG)**—all orchestrated through a modular Terraform workflow.

---

## 1. The Project Structure: Why Modules?

For this project, I moved away from a "monolithic" `main.tf` and split the infrastructure into three distinct modules:

* **`modules/ec2`**: Defines the "blueprint" (Launch Template) and Security Groups.
* **`modules/alb`**: Provisions the "front door" (Load Balancer) and traffic routing logic.
* **`modules/asg`**: Manages the "brain" (Scaling policies and instance lifecycle).

**Why split them?**
In a production environment, different teams often manage different layers. A networking team might handle the ALB, while the app team manages the ASG. Splitting modules prevents "merge conflicts," allows for independent testing, and makes the code reusable across different projects.

---

## 2. Connecting the Dots: The Data Flow

Terraform modules are most powerful when they talk to each other. Here is how the information flows in this project:

1.  **The Blueprint:** The `ec2` module creates an `aws_launch_template`. It outputs the `launch_template_id`.
2.  **The Handover:** In the root `main.tf`, that ID is passed directly into the `asg` module. This tells the Auto Scaling Group *exactly* what kind of server to build.
3.  **Closing the Loop:** The `alb` module creates a `target_group_arn`. This is also passed into the `asg` module. This "plumbing" ensures that every time the ASG spins up a new server, it automatically registers it with the Load Balancer so it can start receiving traffic.



---

## 3. The "Pulse" of the App: Scaling & Health

### What is `health_check_type = "ELB"`?
By default, an ASG only checks if an EC2 instance is "running" (status checks). But what if the server is up, but the **Apache web service has crashed**? 
By setting the health check to **ELB**, the ASG listens to the Load Balancer. If the ALB says, *"I can't get a 200 OK from this instance,"* the ASG marks it as unhealthy, terminates it, and launches a fresh one. This ensures your users never hit a broken page.

### Tracing a Scaling Event (CPU > 70%)
What happens when your app goes viral?
1.  **CloudWatch Alarm:** The `cpu_high` alarm monitors the average CPU of the ASG. Once it hits **70%** for more than 4 minutes, the alarm triggers.
2.  **Scaling Policy:** The alarm notifies the `scale_out` policy.
3.  **Action:** The policy tells the ASG: *"Add 1 instance."*
4.  **New Life:** A new EC2 is launched from the Launch Template, registered with the ALB, and begins sharing the load.

---

## 4. Deployment & Verification

After running `terraform apply`, my terminal provided the ultimate prize—the Load Balancer URL:

```bash
Outputs:
alb_dns_name = "web-challenge-day26-alb-dev-123456789.us-east-1.elb.amazonaws.com"
```

Visiting this URL showed my "Deployed with Terraform" landing page. In the AWS Console, the ASG successfully managed the lifecycle of my instances, showing them as "InService" and "Healthy."



---

## Final Thoughts
Building this dynamic tier is a major milestone. We’ve moved from "deploying a server" to "deploying a system" that breathes and reacts to real-world demand. Terraform makes this complex dance repeatable, versionable, and—most importantly—scalable.

**Next Stop:** CloudWatch Dashboards to visualize this data in real-time! 🚀

#Terraform #AWS #CloudComputing #DevOps #IaC #AutoScaling #CloudArchitect
