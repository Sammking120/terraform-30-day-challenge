# Mastering Loops and Conditionals in Terraform: The Definitive Guide

Writing Terraform code often starts with simple resource blocks. But as
your infrastructure scales, you quickly realize that copy-pasting the
same resource three times is a recipe for a maintenance nightmare.

To write truly DRY (Don't Repeat Yourself) infrastructure, you need to
master Terraform's four logic engines: `count`, `for_each`, `for`
expressions, and ternary conditionals.

Here is everything you need to know to move from beginner to pro.

------------------------------------------------------------------------

## 1. The `count` Meta-Argument

The `count` parameter is the "OG" way to iterate in Terraform. It tells
Terraform to create X number of a specific resource.

### Real-World Code

``` hcl
variable "user_names" {
  type    = list(string)
  default = ["Neo", "Trinity", "Morpheus"]
}

resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}
```

### The Secret Sauce

`count.index` is an integer that represents the current iteration (0, 1,
2...). We use it here to look up a name from our list.

### ⚠️ The "Count Index" Breaking Point

Here is the problem: `count` identifies resources by their position in
the list.

Imagine you want to remove `"Trinity"` (index 1).

Your list becomes:

``` hcl
["Neo", "Morpheus"]
```

Terraform sees that at index 1, the name is now `"Morpheus"` instead of
`"Trinity"`.

### The Disaster

Terraform will: - Rename (or delete and recreate) `"Trinity"` to
`"Morpheus"` - Delete the resource at index 2 because the list is
shorter

If these were databases or stateful servers, you just caused a massive
outage by deleting the wrong resource.

------------------------------------------------------------------------

## 2. The `for_each` Meta-Argument

`for_each` was introduced to solve the "index shift" problem. Instead of
identifying resources by a number, it identifies them by a unique string
key.

### Real-World Code

``` hcl
resource "aws_iam_user" "better_example" {
  for_each = toset(["Neo", "Trinity", "Morpheus"])
  name     = each.value
}
```

### Why It Fixes `count`

If you remove `"Trinity"` from this set:

Terraform checks its state and sees that:

``` hcl
aws_iam_user.better_example["Trinity"]
```

is gone --- so it deletes only that resource.

The resource for `"Morpheus"` remains untouched because its key
(`"Morpheus"`) hasn't changed.

### Pro Tip

You can also use `for_each` with a map to handle more complex
configurations, such as assigning different tags per environment.

------------------------------------------------------------------------

## 3. The `for` Expression

While `count` and `for_each` create resources, the `for` expression is
used to transform data. Think of it like a list comprehension in Python.

### Real-World Code

``` hcl
variable "hero_roles" {
  type = map(string)
  default = {
    Neo      = "The One"
    Trinity  = "Pilot"
    Morpheus = "Captain"
  }
}

output "hero_announcement" {
  value = [for name, role in var.hero_roles : "${name} is the ${role}"]
}
```

### The Result

``` hcl
[
  "Neo is the The One",
  "Trinity is the Pilot",
  "Morpheus is the Captain"
]
```

This is incredibly useful for: - Filtering lists - Formatting outputs -
Passing structured data between modules

------------------------------------------------------------------------

## 4. Ternary Conditionals

Terraform doesn't have traditional `if/else` blocks. Instead, it uses
the ternary syntax:

``` hcl
CONDITION ? TRUE_VAL : FALSE_VAL
```

### Real-World Code

Common use cases include environment-based sizing and optional resource
creation.

``` hcl
variable "is_production" {
  type = bool
}

# 1. Conditional Sizing
resource "aws_instance" "web" {
  instance_type = var.is_production ? "m5.large" : "t3.micro"
}

# 2. Conditional Creation (The "Zero or One" Pattern)
resource "aws_autoscaling_policy" "high_cpu" {
  count = var.is_production ? 1 : 0
  # This policy only exists in Prod!
}
```

------------------------------------------------------------------------

## The Verdict: Which One Do I Use?

  -----------------------------------------------------------------------
  Tool                             Best Use Case
  -------------------------------- --------------------------------------
  `count`                          Creating a fixed number of identical
                                   resources, or a simple 0/1 toggle

  `for_each`                       Creating multiple resources with
                                   unique identities (preferred over
                                   `count` for lists)

  `for`                            Transforming lists or maps into new
                                   formats

  Ternary                          Switching between two values based on
                                   a boolean condition
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Summary

If you take one thing away:

> **Stop using `count` for lists of names. Use `for_each` to avoid
> destructive index-shift issues.**

This small shift prevents a dangerous "delete-everything" domino effect
when your infrastructure evolves.

------------------------------------------------------------------------

🚀 Master these patterns, and your Terraform code will go from "working"
to production-grade and scalable.
