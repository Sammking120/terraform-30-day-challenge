How to Handle Sensitive Data Securely in Terraform

On Day 1 of using Terraform, the thrill of spinning up an entire data
center with a single terraform apply is intoxicating. But there is a
hidden danger that catches almost every engineer: Credential Leakage.

If you aren't careful, your database passwords, API keys, and provider
secrets will end up in your GitHub history, your CI/CD logs, or sitting
in plain text on a local disk. This is the guide I wish I had when I
started---a practical roadmap to plugging the "leak paths" in your IaC.

1.  The Three Leak Paths (And How to Plug Them)

To secure your infrastructure, you have to defend against three specific
ways data "bleeds" out of your control.

Path A: The Version Control Leak

The Mistake: Hardcoding a password directly into your .tf files or a
.tfvars file and committing it to Git.

Before (Vulnerable):

Terraform resource "aws_db_instance" "database" { password =
"Password123!" }

After (Secure): Use a variable and keep the actual value in a local
.tfvars file that is listed in your .gitignore, or better yet, fetch it
from a Secret Manager.

Path B: The Console/Log Leak

The Mistake: Terraform prints everything it does to the terminal.

Before (Vulnerable):

Terraform variable "api_key" { type = string }

After (Secure):

Terraform variable "api_key" { type = string sensitive = true }

Path C: The State File Leak

The Mistake: Secrets are stored in plain text in terraform.tfstate.

The Fix: Use a Remote Backend with encryption and strict IAM
permissions.

2.  The Gold Standard: AWS Secrets Manager Integration

Terraform data "aws_secretsmanager_secret" "db_password" { name =
"prod/db/pass" }

data "aws_secretsmanager_secret_version" "current" { secret_id =
data.aws_secretsmanager_secret.db_password.id }

resource "aws_db_instance" "app_db" { identifier = "production-db"
username = "admin" password =
data.aws_secretsmanager_secret_version.current.secret_string }

3.  Redacting Outputs with sensitive = true

Terraform output "db_connection_string" { value =
"mongodb+srv://admin:\${data.aws_secretsmanager_secret_version.current.secret_string}@cluster.aws.com"
sensitive = true }

4.  The State File Security Checklist

\[ \] No Local State

\[ \] Encryption at Rest

\[ \] Encryption in Transit

\[ \] Least Privilege Access

\[ \] S3 Versioning

Summary

Securing Terraform is about minimizing the surface area of your secrets.

1.  Use .gitignore to keep local secrets out of Git.
2.  Use sensitive = true to keep secrets out of logs.
3.  Use Secrets Manager to keep secrets out of your code.
4.  Use Encrypted Remote State to keep secrets off your hard drive.

Follow these four pillars, and you'll sleep much better after your next
production deployment.
