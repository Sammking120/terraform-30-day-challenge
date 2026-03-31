# Advanced Terraform Module Usage: Versioning, Gotchas, and Reuse Across Environments

Scaling infrastructure with Terraform eventually leads every engineer to a crossroads: you either build a monolith that is impossible to test, or you embrace Modules. However, as you move from local modules to shared, versioned repositories, the *gotchas* become more expensive.

In this post, we’ll dive into the common pitfalls of module development, how to master the versioning workflow, and why environment pinning is your best friend in production.

---

## 1. The Three Module "Gotchas"

Even experienced developers stumble on these three Chapter 4 staples. If you don't handle these, your modules will be brittle and hard to manage.

### Gotcha A: The Embedded Provider

Modules should be *plug-and-play*. When you hardcode a provider inside a module, you lock that module to a specific region or account, making it impossible to reuse across different environments.

**The Broken Way:** Hardcoding the provider forces the caller to use your specific configuration.

```hcl
# ❌ BROKEN: Hardcoded provider inside modules/s3/main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "company-global-assets"
}
```

**The Correct Way:** Pass provider configurations implicitly or explicitly from the root.

```hcl
# ✅ CORRECTED: Remove the provider block; let the caller define it.
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
```

---

### Gotcha B: Relative Path Failures

When your module needs to read a file (like a script or a policy JSON), using `./` refers to the root directory where you run Terraform, not the folder where the module lives.

```hcl
# ❌ BROKEN: This looks for setup.sh in your root project folder
resource "aws_instance" "web" {
  user_data = file("./setup.sh")
}
```

**The Correct Way:** Use `path.module` to anchor the path to the module folder.

```hcl
# ✅ CORRECTED: Use path.module
resource "aws_instance" "web" {
  user_data = file("${path.module}/setup.sh")
}
```

---

### Gotcha C: The "Double-Edged" Count

Using `count` on a module that contains multiple resources can lead to unexpected *destroy and recreate* cycles if the list order changes.

```hcl
# ❌ BROKEN (Risky)
module "users" {
  source = "./modules/user"
  count  = length(var.user_names)
  name   = var.user_names[count.index]
}
```

**The Correct Way:** Use `for_each` for stable, key-based resource management.

```hcl
# ✅ CORRECTED
module "users" {
  source   = "./modules/user"
  for_each = toset(var.user_names)
  name     = each.value
}
```

---

## 2. The Versioning Workflow: From Tagging to Pinning

Versioning is what separates a "copy-paste" workflow from a professional Infrastructure as Code (IaC) strategy. By versioning, you ensure that a change to a module doesn't instantly break every environment you own.

### Step 1: The Git Tag

Once your module is ready, you lock its state using a Git tag.

```bash
git tag -a v1.0.1 -m "Added encryption to S3 bucket"
git push origin v1.0.1
```

### Step 2: Source URL Syntax

How you call the module depends on where it lives. Here is a practical breakdown of the source URL syntax:

| Source Type        | Syntax Example |
|------------------|---------------|
| Local Path        | `source = "../modules/vpc"` |
| GitHub (HTTPS)    | `source = "github.com/org/repo?ref=v1.0.1"` |
| GitHub (SSH)      | `source = "git@github.com:org/repo.git?ref=v1.0.1"` |
| Terraform Registry| `source = "terraform-aws-modules/vpc/aws"` + `version = "5.0.0"` |

---

## 3. Multi-Environment Deployment Pattern

The goal of versioning is to enable **Promotional Deployments**. You want to test `v2.0.0` in Development while keeping `v1.9.0` running safely in Production.

### The "Pinning" Strategy

In a professional setup, your folder structure likely looks like this:

```
environments/
  ├── dev/main.tf
  └── prod/main.tf
```

### Dev Environment (The Testing Ground)

Here, we point to the latest release to test new features.

```hcl
module "network" {
  source   = "github.com/acme/infra-modules?ref=v2.0.0" # Newest version
  vpc_cidr = "10.0.0.0/16"
}
```

### Production Environment (The Fortress)

We keep Production pinned to a known, stable version. We only update this after `v2.0.0` has survived a week in Dev without issues.

```hcl
module "network" {
  source   = "github.com/acme/infra-modules?ref=v1.9.0" # Stable version
  vpc_cidr = "10.1.0.0/16"
}
```

---

## Why This Matters for Teams

If two engineers run `terraform apply` at the same time and you are not version pinning (e.g., just pointing to the `main` branch), one engineer might accidentally pull in a "work in progress" commit that another teammate just pushed.

Pinning ensures that what you see in your plan is exactly what gets applied.

---

## Final Thoughts

Mastering advanced modules isn't just about writing HCL; it’s about managing the lifecycle of your code. By avoiding provider gotchas, using `path.module`, and strictly pinning versions across environments, you build a resilient platform that can grow without the constant fear of accidental destruction.

