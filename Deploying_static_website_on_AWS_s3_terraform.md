# Deploying a Static Website on AWS S3 with Terraform: A Beginner's Guide

Today, I’m wrapping up a major milestone in my Cloud journey: deploying a globally distributed, HTTPS-secured static website using **S3** and **CloudFront**, all managed by **Terraform**. This project isn't just about hosting HTML; it’s about applying production-grade DevOps principles to a real-world architecture.

---

## 1. The Project Architecture
While you can host a site directly from S3, that is rarely enough for a professional site. My setup uses a "Gold Standard" approach:
* **S3:** Acts as the origin server where the `index.html` and `error.html` files live.
* **CloudFront:** Acts as the CDN (Content Delivery Network), caching files at edge locations globally to reduce latency and provide an SSL certificate for HTTPS.
* **Terraform:** Orchestrates the entire lifecycle—from creating the bucket to invalidating the cache.



---

## 2. Project Structure & Module Design
I followed a strict directory structure to keep the "blueprint" separate from the "implementation":

```text
day25-static-website/
├── modules/
│   └── s3-static-website/      # Reusable Logic
├── envs/
│   └── dev/                    # Environment-specific Config
├── backend.tf                  # Remote State Config
└── provider.tf                 # AWS Provider
```

### Why use a Module?
Putting everything in one `main.tf` is fine for a weekend project, but it’s a nightmare for a career. I used a **Module** because:
1.  **Reusability:** If I want to launch a "Production" or "Staging" site tomorrow, I just call the same module with different variables.
2.  **Abstraction:** My `envs/dev/main.tf` is only 15 lines long. It hides the 100+ lines of CloudFront complexity, making the code easier to read and maintain.

---

## 3. The DRY Principle in Practice
**DRY (Don't Repeat Yourself)** is the holy grail of IaC. In this project, DRY looks like this:
* **In the Module:** I used `locals` to merge common tags. I don't re-type "Environment = dev" for every resource; Terraform does it for me.
* **In the Environments:** By using a `terraform.tfvars` file, I separate my *data* from my *logic*. The code stays the same; only the bucket names and environment strings change.

---

## 4. Safety First: Remote State
I configured an **S3 Backend with DynamoDB locking**. 
* **Protection:** If my laptop dies, my infrastructure isn't lost. The "truth" of what I deployed is safely stored in a versioned S3 bucket.
* **Collaboration:** The DynamoDB lock prevents two people (or two CI/CD jobs) from running `terraform apply` at the same time, which would corrupt the state.

---

## 5. Deployment & Verification
The deployment was a three-step dance:
1.  `terraform init`: Connected to the remote S3 bucket.
2.  `terraform plan`: Verified that 7 resources would be created (S3, Policies, CloudFront, Objects).
3.  `terraform apply`: Pushed the configuration to AWS.

### The Live Result
After about 10 minutes of CloudFront propagation, my site was live!
**CloudFront URL:** `https://d3v1234example.cloudfront.net`



---

## 6. Closing Thoughts
Building this project taught me that **S3 is the storage, but CloudFront is the delivery.** More importantly, it showed me that Terraform is the glue that makes complex cloud configurations repeatable and safe. 

If you're a beginner, don't just click buttons in the AWS Console. Write the code, version it in Git, and let Terraform do the heavy lifting. Your future self (and your teammates) will thank you.
