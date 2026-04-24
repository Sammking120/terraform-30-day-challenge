# Fine-tuning My Terraform Exam Prep with Practice Exams

The jump from building infrastructure to answering 57 rapid-fire questions is steeper than I expected. For Day 29 of my Terraform journey, I hung up my architect hat and put on my student cap. I realized that while I can build a multi-region failover system, I still occasionally stumble on the specific nuances of CLI flags and state internals.

Here is the raw data and the strategy I used to turn my weaknesses into strengths.

---

### 1. The Four-Exam Score Trend

I tracked my performance across four full-length simulations. The goal was to see a steady upward trajectory—or identify if I was hitting a plateau.

| Exam | Score | % | Time | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Exam 1** (Day 28) | 42/57 | 74% | 42m | Pass (Barely). Struggled with variable precedence. |
| **Exam 2** (Day 28) | 46/57 | 81% | 38m | Better. Felt more comfortable with module syntax. |
| **Exam 3** (Today) | 49/57 | **86%** | 35m | Stronger. State management is finally clicking. |
| **Exam 4** (Today) | 52/57 | **91%** | 31m | Peak performance. CLI nuances are second nature. |

**Trend Analysis:** My scores improved as I moved from 003-style questions to the newer **Associate 004** objectives. The warm-up effect was real, but the most significant jumps came from the "State Surgery" labs I did between exams.

---

### 2. Domain Accuracy Breakdown (Combined)

This table reflects my average accuracy across all 228 questions attempted.

| Domain | Accuracy | Status |
| :--- | :--- | :--- |
| **IaC Concepts** | 98% | Mastered |
| **Terraform Fundamentals** | 88% | Solid |
| **Core Workflow** | 92% | Mastered |
| **Modules** | 85% | Solid |
| **State Management** | **69%** | ⚠️ **Priority Area** |
| **HCP Terraform** | 82% | Solid |
| **Terraform 0.14+ (004 Prep)** | 78% | Needs Review |

---

### 3. Deep Dive: Persistent Wrong Answers

I noticed a pattern: I wasn't missing "big" concepts; I was missing "details." Here are the five persistent traps I fell into:

1.  **Command Side-Effects:** I consistently confused `terraform state rm` with `terraform destroy`. 
    * *Correction:* `rm` only removes the record from state; the resource remains untouched in the cloud.
2.  **Explicit vs. Implicit Dependencies:** I was overusing `depends_on`. 
    * *Correction:* Terraform is smart. Only use `depends_on` when there is a hidden dependency the code can't see (like a null_resource trigger).
3.  **Variable Precedence:** I kept thinking environment variables were the highest priority. 
    * *Correction:* No. Command-line `-var` flags and `.tfvars` files override environment variables.
4.  **Backend Constraints:** I tried to use variables in my backend configuration block. 
    * *Correction:* Backends are initialized before variables are loaded. They must be hardcoded or passed via a `.backend.hcl` file.
5.  **TFC Workspaces:** I confused CLI workspaces (for state isolation) with HCP Terraform Workspaces (which include variables and code).

---

### 4. Hands-On Revision: The "Reset" Lab

To fix my **State Management** score, I spent an hour doing a "Break-Fix" lab. I intentionally deleted resources from my state file, then used `terraform import` to bring them back.

**The Drill:**
```bash
# 1. Force-remove a resource from state
terraform state rm aws_instance.web_server

# 2. Witness the drift
terraform plan # Result: Terraform wants to create a NEW instance.

# 3. Import it back to restore the link
terraform import aws_instance.web_server i-0abcd1234efgh5678

# 4. Confirm state is healthy
terraform plan # Result: No changes. Infrastructure matches state.
```

---

### Final Thoughts for Day 30

I am now consistently scoring above 85% on practice exams. My focus for the final 24 hours isn't on "learning more," but on **retaining the nuances**. I'll be reviewing the new 004 objectives—specifically **lifecycle rules** and **custom validation conditions**—one last time.

If you're studying for the exam, don't just read the docs. Take the test, fail the questions, and then go build the "wrong" answer in your terminal. That's where the certification is actually earned.

**#30DayTerraformChallenge #TerraformAssociate #DevOps #IaC #NairobiTech #AWS #CloudEngineer**

[Preparing for the Terraform Associate 004 Exam](https://www.youtube.com/watch?v=Sa_StyU6Xzo)

Since the Terraform Associate 003 exam was recently replaced by the 004 version, this video is essential for understanding the new focus areas like lifecycle rules and custom validation that you'll encounter on exam day.


http://googleusercontent.com/youtube_content/3
