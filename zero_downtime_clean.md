## Mastering Zero-Downtime Deployments with Terraform

You've built your infrastructure, your app is running, and your CI/CD
pipeline is green. Now comes the moment of truth: The Production
Deployment. If you are using Terraform's default settings, you might be
in for a rude awakening. By default, Terraform is a "destroyer." It
clears the old to make room for the new. In a production environment,
that means one thing: Downtime.

Here is how to move from "fingers crossed" deployments to seamless,
zero-downtime updates.

## The Silent Killer: Default "Destroy-then-Create"

By default, if you change a property that requires a resource to be
replaced (like an AMI ID or User Data), Terraform follows this sequence:

-   Terminate the existing instance/resource.
-   Wait for the cloud provider to confirm deletion.
-   Provision the new resource.
-   Wait for the new resource to boot and pass health checks.

This creates a "Gap of Silence." For several minutes, your Load Balancer
has nowhere to send traffic, and your users see 502 Bad Gateway errors.

## The Fix: create_before_destroy

The lifecycle block is your best friend in production. By setting
`create_before_destroy = true`, you flip the script. Terraform will
ensure the new resource is up and running before it touches the old one.

``` hcl
resource "aws_launch_configuration" "app" {
  image_id      = var.new_ami_id
  instance_type = "t3.medium"

  lifecycle {
    create_before_destroy = true
  }
}
```

## The "Name Collision" Problem

There's a catch. AWS (and most providers) won't let you have two
resources with the exact same name. If your Launch Configuration is
named `web-server-v1`, Terraform can't create the new one because the
name is already taken.

## The Solution: Use name_prefix

This tells Terraform to take your base name and append a unique random
string to it, allowing the old and new versions to coexist during the
handover.

``` hcl
resource "aws_launch_configuration" "app" {
  name_prefix = "web-app-lc-"
}
```

## The Blue/Green Strategy

While `create_before_destroy` is great for simple resource swaps,
Blue/Green is the gold standard for complex deployments.

In this pattern, you maintain two identical "target groups" (Blue and
Green). One is live; the other is idle. You deploy your new code to the
idle environment, test it, and then flip a single switch at the Load
Balancer level to route traffic.

``` hcl
resource "aws_lb_listener_rule" "production" {
  action {
    type             = "forward"
    target_group_arn = var.traffic_target == "blue" ? aws_tg.blue.arn : aws_tg.green.arn
  }
}
```

## Seeing is Believing: The Transition

``` bash
$ while true; do curl -s http://myapp.com/version; sleep 1; done

# Output:
{"version": "v1.0.4", "status": "healthy"}
{"version": "v1.0.4", "status": "healthy"}
{"version": "v1.0.4", "status": "healthy"}
{"version": "v2.0.0", "status": "healthy"}
{"version": "v2.0.0", "status": "healthy"}
{"version": "v2.0.0", "status": "healthy"}
```

Notice what's missing? No connection refused. No timeouts. Just a clean
handover.

## Summary for Your First Deploy

-   Always use `lifecycle { create_before_destroy = true }`
-   Never use hardcoded names; use `name_prefix`
-   Use validation for variables
-   Consider Blue/Green deployments

Deploying to production doesn't have to be stressful. With these
patterns, you can ship confidently.
