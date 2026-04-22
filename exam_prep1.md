## How I Prepared for the Terraform Associate Exam with Practice Questions
After weeks of building complex 3-tier architectures and multi-region failover systems, Day 29 was a reality check. I stepped away from the IDE and into the "Exam Simulator" to see if my practical knowledge translated into the specific requirements of the HashiCorp Certified: Terraform Associate exam.
Here is the raw, unedited breakdown of my practice day—the scores, the struggles, and the "aha" moments.

---

### 1. The Raw Scores: A Reality Check
   I took two full-length, 57-question practice exams back-to-back with a 15-minute coffee break in between. Here is how I fared:
   | Metric            | Practice Exam 1 | Practice Exam 2 |
|------------------|----------------|----------------|
| Score            | 74% (42/57)    | 81% (46/57)    |
| Status           | Pass (Barely)  | Pass           |
| Time Taken       | 42 Minutes     | 38 Minutes     |

**Takeaway:** I passed both, but the first exam was a wake-up call. I realized that knowing how to build something doesn't always mean you know the exact CLI flag or the specific order of operations Terraform uses under the hood.

----

### 2. The Wrong-Answer Review: Where I Stumbled
I didn't just look at the correct answers; I analyzed my failures. Most of my errors fell into three "trap" categories:
Topic: **terraform state rm** vs.**terraform destroy**
  - What I answered: I thought **state rm** deleted the resource from AWS.
  - The Reality: **Terraform state rm** only removes the resource from the state file. The resource still exists in AWS; Terraform just "forgets" about it.Why I was wrong: I was thinking too much about "deleting" and not enough about "tracking."
  -
#### Topic: Variable Precedence
  - **What I answered**: I thought environment variables **(TF_VAR_)** overrode **terraform.tfvars.**
  - **The Reality:** It’s actually the opposite. **The terraform.tfvars**file (or **-var** flags) takes precedence over environment variables.
  - **Why I was wrong**: I assumed "system-level" settings were stronger than "file-level" settings.

### Topic: Terraform Cloud Workspaces vs. CLI Workspaces
  - **The Surprise**: CLI workspaces are for managing different state files for the same configuration (like dev vs prod). In Terraform Cloud, a Workspace is a combination of code, variables, and state. They aren't the same thing!

----

### 3. Hands-On Fixes: Closing the Gaps
Instead of just re-reading the docs, I went back to my terminal to "break and fix" the concepts I got wrong.
  - **State Manipulation:** I ran **terraform state list**, then **terraform state rm** on a dummy S3 bucket. I verified that the bucket still existed in the AWS Console, then used **terraform import** to bring it back under management. This made the concept permanent in my brain.
  -**Workspace Drill:** I created three local workspaces (**test**, **staging**, **prod**) and switched between them using **terraform workspace select**. Seeing the separate state files created in my local directory cleared up the confusion instantly.
  - **Precedence Test:** I set an environment variable **TF_VAR_instance_type="t3.large"** and a **terraform.tfvars** file with **instance_type = "t3.micro"**. I ran **terraform plan** to see which one "won." (Spoiler: The .tfvars file won).

----

### 4. Final Domain Accuracy

| Domain              | Accuracy                     |
|---------------------|------------------------------|
| IaC Concepts        | 95%                          |
| Terraform CLI       | 72% (Needs Work)             |
| State Management    | 68% (Targeted Review)        |
| Modules             | 88%                          |
| Terraform Cloud     | 80%                          |

### My Advice for Candidates
If you are preparing for this exam, do not skip the practice tests. My multi-region build from yesterday gave me confidence, but the practice exams gave me precision.The Associate exam isn't just about being a "good coder"; it's about understanding the specific workflow and philosophy of HashiCorp. Spend as much time reviewing your wrong answers as you do taking the test—that is where the real learning happens.
