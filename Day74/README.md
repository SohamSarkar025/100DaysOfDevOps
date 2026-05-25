![Progress](https://img.shields.io/badge/Progress-74%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-Zero_to_Hero-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/Language-HCL-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Multi_Region-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Multi_Provider-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

# Day 74 - Terraform Zero to Hero: Providers, Variables, tfvars, Conditionals & Built-in Functions

## Overview

On Day 74, I continued the **Terraform Zero to Hero** series — diving deep into **Terraform Providers** (Registry, multi-provider, multi-region), **Variables** (input, output, `var.*`), **`.tfvars` files** (environment separation), **Conditional Expressions** (ternary operator for environment-based routing), and **Built-in Functions** (`concat`, `element`, `length`, `map`, `lookup`, `join`). All concepts were studied through code examples in VS Code and the official Terraform/GitHub documentation.

**Core insight: Real-world Terraform is never just one provider or hardcoded values — variables, tfvars, conditionals, and functions make infrastructure code reusable, secure, and environment-aware.**

---

## Project File Structure

```
Day74/
└── assets/
    ├── providers.tf                  # Single AWS provider
    ├── multi-providor.tf             # AWS + Azure multi-provider
    ├── multi-regions.tf              # Multi-region with aliases
    ├── variable.tf                   # Variable + output basics
    ├── variables-implementation.tf   # EC2 using variables + output
    └── conditional-expressions.tf    # Ternary operator by environment
```

---

## Part 1 — Terraform Providers

### What Is a Provider?

A **provider** is a plugin that lets Terraform communicate with a specific cloud or service API. Every resource in Terraform belongs to a provider.

```
Terraform HCL code
        │
        ▼
    Provider  ← translates HCL → cloud API calls
        │
        ▼
  Cloud / Service (AWS, Azure, GCP, Kubernetes...)
```

Providers are published on the **Terraform Registry** at `registry.terraform.io`. There are four tiers:

| Tier                | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| **Official**        | Owned and maintained by HashiCorp                               |
| **Partner**         | Owned by a technology company with direct HashiCorp partnership |
| **Partner Premier** | Third-party companies that write and maintain premier providers |
| **Community**       | Published and maintained by individual contributors             |

**Featured providers on the Registry:**

| Provider                    | Maintained by | Tier     |
| --------------------------- | ------------- | -------- |
| AWS                         | HashiCorp     | Official |
| Azure                       | HashiCorp     | Official |
| Google Cloud Platform       | HashiCorp     | Official |
| Kubernetes                  | HashiCorp     | Official |
| Alibaba Cloud               | aliyun        | Partner  |
| Oracle Cloud Infrastructure | oracle        | Partner  |

![Terraform Registry — Browse Providers, Featured Providers AWS/Azure/GCP/Kubernetes/Alibaba/Oracle, Official/Partner/Partner Premier/Community tiers](<assets/Screenshot (474).png>)

---

### Single Provider — `providers.tf`

The basic provider configuration declares the required provider and its version:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.46.0"
    }
  }
}

provider "aws" {
  # Configuration options
}
```

**Breaking it down:**

| Block                      | Purpose                                            |
| -------------------------- | -------------------------------------------------- |
| `terraform {}`             | Meta-configuration block for Terraform itself      |
| `required_providers`       | Lock which providers and versions are needed       |
| `source = "hashicorp/aws"` | Registry path: `<namespace>/<provider-name>`       |
| `version = "6.46.0"`       | Exact version to use (pinning prevents surprises)  |
| `provider "aws" {}`        | Configure the provider (region, credentials, etc.) |

![providers.tf — terraform block, required_providers hashicorp/aws v6.46.0, provider aws configuration options](<assets/Screenshot (475).png>)

---

### Multi-Provider — `multi-providor.tf`

Terraform can manage resources across **multiple cloud providers simultaneously** in the same project:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  subscription_id = "your-azure-subscription-id"
  client_id       = "your-azure-client-id"
  client_secret   = "your-azure-client-secret"
  tenant_id       = "your-azure-tenant-id"
}
```

**Use case:** A company running workloads on both AWS and Azure — Terraform manages both from a single codebase with a single `terraform apply`.

| Provider  | Auth method                                    |
| --------- | ---------------------------------------------- |
| `aws`     | AWS CLI profile, env vars, or IAM role         |
| `azurerm` | Service Principal (subscription/client/tenant) |

> ⚠️ **Security:** Never hardcode `client_secret` in `.tf` files. Use environment variables or a secrets manager, and add `.tfvars` to `.gitignore`.

![multi-providor.tf — provider aws us-east-1 + provider azurerm with subscription_id/client_id/client_secret/tenant_id](<assets/Screenshot (476).png>)

---

### Multi-Region — `multi-regions.tf`

Using **provider aliases**, you can deploy resources to multiple AWS regions from one configuration:

```hcl
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider      = "aws.us-east-1"
}

resource "aws_instance" "example2" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider      = "aws.us-west-2"
}
```

**How aliases work:**

```
provider "aws" alias="us-east-1"  ──► EC2 in us-east-1
provider "aws" alias="us-west-2"  ──► EC2 in us-west-2

Each resource picks its provider via:
  provider = "aws.<alias>"
```

**Use case:** Active-active multi-region deployments, disaster recovery setups, geographic distribution of workloads.

![multi-regions.tf — two provider aws blocks with alias us-east-1/us-west-2, two aws_instance resources each with provider = aws.us-east-1/us-west-2](<assets/Screenshot (477).png>)

---

## Part 2 — Variables & Outputs

### Variable Basics — `variable.tf`

Terraform **input variables** make configurations reusable — instead of hardcoding values, you parameterize them:

```hcl
variable "example_var" {
  description = "An example input variable"
  type        = string
  default     = "default_value"
}

resource "example_resource" "example" {
  name = var.example_var
  # other resource configurations
}

output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}

output "root_output" {
  value = module.example_module.example_output
}
```

**Variable block anatomy:**

| Argument      | Purpose                                              |
| ------------- | ---------------------------------------------------- |
| `description` | Human-readable explanation of the variable           |
| `type`        | Data type: `string`, `number`, `bool`, `list`, `map` |
| `default`     | Default value if none is provided at runtime         |

**Output block anatomy:**

| Argument      | Purpose                                               |
| ------------- | ----------------------------------------------------- |
| `description` | Human-readable explanation of the output              |
| `value`       | The value to expose — references a resource attribute |

**Referencing variables:**

- Input variable: `var.<variable_name>`
- Resource attribute: `resource.<type>.<name>.<attribute>`
- Module output: `module.<module_name>.<output_name>`

![variable.tf — variable example_var string default_value, resource using var.example_var, output example_output resource id, output root_output module output](<assets/Screenshot (478).png>)

---

### Variables in Practice — `variables-implementation.tf`

A complete, real-world example using variables for EC2 provisioning:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Define an input variable for the EC2 instance AMI ID
variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

# Configure the AWS provider using the input variables
provider "aws" {
  region = "us-east-1"
}

# Create an EC2 instance using the input variables
resource "aws_instance" "example_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

# Define an output variable to expose the public IP address of the EC2 instance
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example_instance.public_ip
}
```

**What this achieves:**

```
variables-implementation.tf
         │
         ├── var.instance_type  → "t2.micro" (default)
         ├── var.ami_id         → supplied at runtime (no default)
         │
         ▼
aws_instance.example_instance
  ami           = var.ami_id
  instance_type = var.instance_type
         │
         ▼
output: public_ip ← aws_instance.example_instance.public_ip
```

Variables without a `default` **must** be provided — via CLI (`-var`), `.tfvars` file, or environment variable. `ami_id` has no default because AMIs are region-specific.

![variables-implementation.tf — variable instance_type t2.micro, variable ami_id string, provider aws us-east-1, aws_instance using var.ami_id/var.instance_type, output public_ip](<assets/Screenshot (479).png>)

---

## Part 3 — Terraform `.tfvars` Files

### What Is `.tfvars`?

`.tfvars` files let you **separate configuration values from code** — the `.tf` files define the structure (what variables exist), while `.tfvars` files supply the actual values.

```
variables.tf          ← defines: variable "ami_id" { type = string }
dev.tfvars            ← supplies: ami_id = "ami-dev-123"
prod.tfvars           ← supplies: ami_id = "ami-prod-456"
```

### Four Purposes of `.tfvars`

**1. Separation of Configuration from Code**

Use the same `.tf` code with different value sets. Instead of hardcoding values into `.tf` files, keep configuration in `.tfvars` files — easier to maintain across environments.

**2. Sensitive Information**

`.tfvars` files are a common place to store API keys, access credentials, or secrets — kept outside version control by adding them to `.gitignore`. This prevents accidental secret exposure.

**3. Reusability**

Reuse the same Terraform modules with different `.tfvars` files for different projects or environments without modifying the core infrastructure code.

**4. Collaboration**

Each team member can have their own `.tfvars` file with environment-specific values — avoiding conflicts in the shared codebase.

### How to Use `.tfvars`

```
Step 1: Define variables in variables.tf
Step 2: Create environment-specific .tfvars files
Step 3: Apply with the -var-file flag
```

```bash
# Apply with dev values
terraform apply -var-file=dev.tfvars

# Apply with prod values
terraform apply -var-file=prod.tfvars
```

**Typical `.tfvars` file content:**

```hcl
# dev.tfvars
ami_id        = "ami-091138d0f0d41ff90"
instance_type = "t2.micro"
environment   = "development"

# prod.tfvars
ami_id        = "ami-0abcdef1234567890"
instance_type = "t3.large"
environment   = "production"
```

> ⚠️ **Never commit `.tfvars` files containing secrets to Git.** Add `*.tfvars` to `.gitignore` and use a secrets manager (AWS Secrets Manager, HashiCorp Vault) for sensitive values.

![Terraform tfvars GitHub doc — purpose: Separation of Config, Sensitive Information, Reusability, Collaboration](<assets/Screenshot (480).png>)

![Terraform tfvars Summary — define variables in variables.tf, create .tfvars files, terraform apply -var-file=dev.tfvars](<assets/Screenshot (481).png>)

---

## Part 4 — Conditional Expressions

### Ternary Operator in HCL

Terraform supports **conditional expressions** (ternary operator) — routing configuration based on variable values:

```hcl
condition ? true_value : false_value
```

### Real Example — `conditional-expressions.tf`

```hcl
variable "environment" {
  description = "Environment type"
  type        = string
  default     = "development"
}

variable "production_subnet_cidr" {
  description = "CIDR block for production subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "development_subnet_cidr" {
  description = "CIDR block for development subnet"
  type        = string
  default     = "10.0.2.0/24"
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = var.environment == "production" ? [var.production_subnet_cidr] : [var.development_subnet_cidr]
  }
}
```

**How the conditional works:**

```
var.environment == "production"?
        │
        ├── YES → cidr_blocks = ["10.0.1.0/24"]  (production subnet)
        └── NO  → cidr_blocks = ["10.0.2.0/24"]  (development subnet)
```

**Real-world use cases for conditionals:**

| Scenario                       | Example                                                    |
| ------------------------------ | ---------------------------------------------------------- |
| Environment-based CIDR routing | Prod vs Dev subnet CIDRs (as above)                        |
| Instance size by environment   | `var.env == "prod" ? "t3.large" : "t2.micro"`              |
| Enable/disable features        | `var.enable_monitoring ? 1 : 0` for CloudWatch alarm count |
| Multi-AZ toggle                | `var.env == "prod" ? true : false` for RDS multi-AZ        |

![conditional-expressions.tf — variable environment (default: development), production_subnet_cidr 10.0.1.0/24, development_subnet_cidr 10.0.2.0/24, aws_security_group ternary cidr_blocks](<assets/Screenshot (482).png>)

---

## Part 5 — Built-in Functions

Terraform provides **built-in functions** to manipulate and transform data within HCL configuration files. These functions are called within expressions and help avoid repetition.

### `concat(list1, list2, ...)` — Combine Lists

Combines multiple lists into a single list.

```hcl
variable "list1" {
  type    = list
  default = ["a", "b"]
}

variable "list2" {
  type    = list
  default = ["c", "d"]
}

output "combined_list" {
  value = concat(var.list1, var.list2)
  # Returns ["a", "b", "c", "d"]
}
```

![Built-in Functions GitHub doc — concat(list1, list2) example combining two lists](<assets/Screenshot (483).png>)

---

### `element(list, index)` — Get Item by Index

Returns the element at the specified index in a list.

```hcl
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "selected_element" {
  value = element(var.my_list, 1)
  # Returns "banana"
}
```

### `length(list)` — Count Elements

Returns the number of elements in a list (or characters in a string, keys in a map).

```hcl
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "list_length" {
  value = length(var.my_list)
  # Returns 3
}
```

![Built-in Functions — element(list, index) returns banana at index 1, length(list) returns 3, map(key, value) example](<assets/Screenshot (484).png>)

---

### `map(key, value)` — Create a Map

Creates a map from a list of keys and a list of values.

```hcl
variable "keys" {
  type    = list
  default = ["name", "age"]
}

variable "values" {
  type    = list
  default = ["Alice", 30]
}

output "my_map" {
  value = map(var.keys, var.values)
  # Returns {"name" = "Alice", "age" = 30}
}
```

### `lookup(map, key)` — Retrieve from Map

Retrieves the value associated with a specific key in a map.

```hcl
variable "my_map" {
  type    = map(string)
  default = {"name" = "Alice", "age" = "30"}
}

output "value" {
  value = lookup(var.my_map, "name")
  # Returns "Alice"
}
```

![Built-in Functions — map(key, value) creates map, lookup(map, key) retrieves Alice from my_map](<assets/Screenshot (485).png>)

---

### `join(separator, list)` — List to String

Joins the elements of a list into a single string using the specified separator.

```hcl
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "joined_string" {
  value = join(", ", var.my_list)
  # Returns "apple, banana, cherry"
}
```

![Built-in Functions — lookup(map, key) returning Alice, join(separator, list) returning apple banana cherry string](<assets/Screenshot (486).png>)

---

## Built-in Functions — Quick Reference

| Function  | Signature                     | Returns              | Example output              |
| --------- | ----------------------------- | -------------------- | --------------------------- |
| `concat`  | `concat(list1, list2, ...)`   | Combined list        | `["a","b","c","d"]`         |
| `element` | `element(list, index)`        | Single item at index | `"banana"` (index 1)        |
| `length`  | `length(list)`                | Number of elements   | `3`                         |
| `map`     | `map(keys_list, values_list)` | Map object           | `{"name"="Alice","age"=30}` |
| `lookup`  | `lookup(map, key)`            | Value for key        | `"Alice"`                   |
| `join`    | `join(separator, list)`       | String               | `"apple, banana, cherry"`   |

---

## Key Concepts — Summary

### Provider Hierarchy

```
registry.terraform.io
        │
        ├── Official   (HashiCorp) → AWS, Azure, GCP, Kubernetes
        ├── Partner    (tech co.)  → Alibaba, Oracle
        ├── Partner Premier        → Third-party vetted
        └── Community             → Open-source contributors
```

### Variable Flow

```
variables.tf          ← defines variable blocks
        +
dev.tfvars            ← supplies values for dev
prod.tfvars           ← supplies values for prod
        │
        ▼
terraform apply -var-file=dev.tfvars
        │
        ▼
var.ami_id, var.instance_type → used in resource blocks
        │
        ▼
output blocks → expose values after apply
```

### Conditional Expression Pattern

```
attribute = condition ? value_if_true : value_if_false

# Environment-based routing:
cidr_blocks = var.environment == "production"
              ? [var.production_subnet_cidr]
              : [var.development_subnet_cidr]
```

### Multi-Region Pattern

```hcl
# Define aliased providers
provider "aws" { alias = "east"; region = "us-east-1" }
provider "aws" { alias = "west"; region = "us-west-2" }

# Pin resource to specific region
resource "aws_instance" "east" { provider = "aws.east" ... }
resource "aws_instance" "west" { provider = "aws.west" ... }
```

---

## Key Takeaways

| Concept                     | Summary                                                                         |
| --------------------------- | ------------------------------------------------------------------------------- |
| **Providers**               | Plugin layer translating HCL → cloud API calls; sourced from Terraform Registry |
| **Multi-provider**          | AWS + Azure in one config — Terraform manages both simultaneously               |
| **Provider aliases**        | Deploy same provider to multiple regions using `alias` + `provider = "aws.X"`   |
| **Input variables**         | Parameterize config with `variable {}` blocks, reference with `var.<name>`      |
| **Output variables**        | Expose resource attributes after apply with `output {}` blocks                  |
| **`.tfvars` files**         | Separate values from code — one codebase, many environments                     |
| **Sensitive data**          | Store secrets in `.tfvars`, add to `.gitignore`, never hardcode in `.tf`        |
| **Conditional expressions** | Ternary `condition ? true : false` for environment-aware configurations         |
| **Built-in functions**      | `concat`, `element`, `length`, `map`, `lookup`, `join` for data manipulation    |

---

## Resources

- [Terraform Registry — Browse Providers](https://registry.terraform.io/browse/providers)
- [hashicorp/aws Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform Output Values](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Terraform Variable Definitions (.tfvars)](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- [Terraform Conditional Expressions](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [Terraform Built-in Functions](https://developer.hashicorp.com/terraform/language/functions)
- [terraform-zero-to-hero GitHub](https://github.com/iam-veeramalla/terraform-zero-to-hero)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
