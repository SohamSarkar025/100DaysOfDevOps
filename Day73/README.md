![Progress](https://img.shields.io/badge/Progress-73%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![HCL](https://img.shields.io/badge/Language-HCL-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Tools-AWS_CLI-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)

# Day 73 - Terraform Zero to Hero: First EC2 Instance with Infrastructure as Code

## Overview

On Day 73, I started the **Terraform Zero to Hero** series — learning Infrastructure as Code (IaC) from first principles, understanding **why Terraform exists**, how it differs from cloud-native IaC tools (CloudFormation, Azure Resource Manager, Heat), and provisioning a **real EC2 instance on AWS** using `main.tf`, `terraform init`, `terraform plan`, `terraform apply`, and `terraform destroy`. The complete lifecycle — from concept to running instance to teardown — was completed in one session.

**Result: EC2 instance `i-0ba46884c5dcf7418` provisioned and destroyed via Terraform ✅**

---

## Concept Notes

### How DevOps Engineers Interact with AWS

There are three ways to interact with AWS resources:

```
DevOps Engineer
      │
      ├── 1. AWS Console (UI)
      │        └── Click through GUI — S3, EC2, VPC
      │            Fast for 1–2 resources (e.g., S3 bucket in 2 mins)
      │            NOT scalable for 100 resources
      │
      ├── 2. Programmatic (CLI / API)
      │        ├── AWS CLI  → shell commands
      │        └── AWS API  → REST calls from any language
      │            Better than UI, but still manual
      │
      └── 3. Programming / IaC
               └── Write code that defines infrastructure
                   Python, HCL, JSON, YAML
                   Repeatable, version-controlled, automated
```

**The problem with the Console:** Creating 1 S3 bucket via UI takes 2 minutes. Creating 100 takes 200 minutes — manually, error-prone, not reproducible.

**IaC solves this:** Define your infrastructure in code once → run it → 100 resources created consistently in minutes.

### Infrastructure as Code (IaC)

IaC means defining your cloud resources (VPC, EC2, S3, etc.) in **declarative code files** instead of clicking through a UI. The code is the single source of truth for your infrastructure.

```
Infrastructure as Code (IaC)
         │
         ├── Template formats: JSON / YAML
         │
         ├── Cloud-native IaC tools:
         │       ├── AWS       → CloudFormation (CFT) — Template JSON/YAML
         │       ├── Azure     → Resource Manager (ARM)
         │       └── OpenStack → Heat Template
         │
         └── Universal IaC tool:
                 └── Terraform (HCL) ← works with ALL clouds
```

**Cloud-native IaC tools are provider-locked:**

| Cloud     | Native IaC Tool        | Works with other clouds? |
| --------- | ---------------------- | ------------------------ |
| AWS       | CloudFormation (CFT)   | ❌ AWS only              |
| Azure     | Resource Manager (ARM) | ❌ Azure only            |
| OpenStack | Heat Template          | ❌ OpenStack only        |
| GCP       | Deployment Manager     | ❌ GCP only              |
| **Any**   | **Terraform**          | ✅ Universal             |

![IaC concept whiteboard — DevOps→AWS Console/Programmatic/Programming paths, S3 2mins/100 resources problem, VPC+EC2 config, IaC template JSON/YAML, Providers→AWS→CFT](<assets/Screenshot (459).png>)

---

### Why Terraform? — Universal Approach

Terraform is the **universal IaC tool** — one tool, one language (HCL), works across all major cloud providers.

```
Why Terraform?
      │
      ▼
  Universal approach — write once, apply anywhere
      │
      ├── ① AWS        ✅
      ├── ② Azure      ✅
      ├── ③ OpenStack  ✅  (community supported)
      └── ④ GCP        ✅
```

**How Terraform achieves universality — Providers:**

```
Terraform (HCL code)
         │
         ▼
    Providers  ← plugin layer between Terraform and cloud APIs
         │
         ├── hashicorp/aws   → calls AWS API
         ├── hashicorp/azure → calls Azure API
         └── hashicorp/gcp   → calls GCP API
```

Terraform uses **HCL (HashiCorp Configuration Language)** — a human-readable language to describe infrastructure. Under the hood, Terraform translates HCL into the respective cloud's **API calls** (AWS API, Azure API).

**Terraform is also called "API as Code"** — it wraps cloud provider APIs in declarative HCL syntax.

**Cross-plane** is an alternative Kubernetes-native IaC tool — Terraform remains the industry standard for multi-cloud IaC.

**Community advantage:** Terraform has a massive open-source community — thousands of pre-built modules, providers, and examples available on the Terraform Registry.

![Why Terraform whiteboard — Universal approach AWS/Azure/OpenStack/GCP, IaC tools comparison (CFT/ARM/Heat), Providers, HCL language, Cross-plane, API as Code, AWS API + Azure API](<assets/Screenshot (460).png>)

---

## Project Setup

### Prerequisites Verified

```bash
# AWS CLI version check
PS C:\Users\sruti\OneDrive\Desktop\100DaysOfDevOps\Day73> aws --version
aws-cli/2.34.9 Python/3.13.11 Windows/11 exe/AMD64

# Terraform version check
PS C:\Users\sruti\OneDrive\Desktop\100DaysOfDevOps\Day73> terraform --version
Terraform v1.14.8
on windows_amd64

Your version of Terraform is out of date!
The latest version is 1.15.4.
```

| Tool      | Version | Platform         |
| --------- | ------- | ---------------- |
| AWS CLI   | 2.34.9  | Windows/11 AMD64 |
| Python    | 3.13.11 | (bundled)        |
| Terraform | v1.14.8 | windows_amd64    |

![aws --version and terraform --version — aws-cli/2.34.9, Terraform v1.14.8 on windows_amd64](<assets/Screenshot (462).png>)

---

### Target AMI — Ubuntu 26.04 LTS

Before writing Terraform code, the target AMI was identified from the EC2 Launch Instance console.

| Setting          | Value                         |
| ---------------- | ----------------------------- |
| AMI              | Ubuntu Server 26.04 LTS (HVM) |
| AMI ID           | `ami-091138d0f0d41ff90`       |
| Architecture     | 64-bit (x86)                  |
| Publish Date     | 2026-04-21                    |
| Username         | ubuntu                        |
| Virtualization   | hvm                           |
| Root device type | ebs                           |
| Provider         | Canonical (Verified)          |

![EC2 Launch Instance — Ubuntu 26.04 LTS, ami-091138d0f0d41ff90, t3.micro, Summary panel](<assets/Screenshot (461).png>)

---

### Default VPC and Subnet

The instance will be launched into the **default VPC** with the existing default subnet.

| Property            | Value                    |
| ------------------- | ------------------------ |
| Subnet ID           | subnet-0d98cba5e69bd6e68 |
| State               | ✅ Available             |
| VPC                 | vpc-0307c54aed3ccdb41    |
| IPv4 CIDR           | 172.31.1.0/24            |
| Available IPs       | 251                      |
| Availability Zone   | use1-az5 (us-east-1f)    |
| Block Public Access | Off                      |

![VPC Subnets — subnet-0d98cba5e69bd6e68, Available, vpc-0307c54aed3ccdb41, 172.31.1.0/24, us-east-1f](<assets/Screenshot (463).png>)

---

## Project File Structure

```
Day73/
├── main.tf                    # Terraform resource definition
├── .terraform/                # Provider plugins (created by terraform init)
├── .terraform.lock.hcl        # Provider version lock file
├── terraform.tfstate          # Current state (JSON)
├── terraform.tfstate.backup   # Previous state backup (created after destroy)
└── assets/                    # Screenshots
```

---

## Terraform Configuration — `main.tf`

The `main.tf` file defines the AWS provider and the EC2 instance resource:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-091138d0f0d41ff90"   # Ubuntu 26.04 LTS
  instance_type = "t2.micro"
}
```

**Breaking down the HCL:**

| Block                     | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| `terraform {}`            | Terraform settings — required provider versions |
| `required_providers`      | Declare which providers are needed              |
| `provider "aws" {}`       | Configure the AWS provider (region)             |
| `resource "aws_instance"` | Define an EC2 instance resource                 |
| `"example"`               | Local resource name (used to reference in code) |
| `ami`                     | AMI ID for Ubuntu 26.04 LTS                     |
| `instance_type`           | EC2 instance type (t2.micro = free tier)        |

---

## Steps Performed

### Step 1 — `terraform init`

Initialize the working directory — Terraform downloads the AWS provider plugin.

```bash
PS ...\Day73> terraform init
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v6.46.0...
- Installed hashicorp/aws v6.46.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

**What `terraform init` does:**

- Downloads the `hashicorp/aws` provider plugin (v6.46.0)
- Creates `.terraform/` directory with the provider binary
- Creates `.terraform.lock.hcl` to lock the provider version
- Makes all `terraform` commands available for this workspace

After init, the explorer shows: `.terraform/`, `.terraform.lock.hcl`, `main.tf`

---

### Step 2 — `terraform plan`

Preview what Terraform will create — a **dry run** with no changes to AWS.

```bash
PS ...\Day73> terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                          = "ami-091138d0f0d41ff90"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + cpu_options                  = (known after apply)
      + ebs_block_device             = (known after apply)
      + enclave_options              = (known after apply)
      + ephemeral_block_device       = (known after apply)
      + instance_market_options      = (known after apply)
      + maintenance_options          = (known after apply)
      + metadata_options             = (known after apply)
      + network_interface            = (known after apply)
      + primary_network_interface    = (known after apply)
      + private_dns_name_options     = (known after apply)
      + root_block_device            = (known after apply)
      + secondary_network_interface  = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Reading the plan output:**

| Symbol | Meaning                    |
| ------ | -------------------------- |
| `+`    | Resource will be created   |
| `~`    | Resource will be updated   |
| `-`    | Resource will be destroyed |

**`(known after apply)`** — these values are assigned by AWS at creation time and cannot be known beforehand (ARN, IP addresses, network interfaces, etc.).

![terraform init — hashicorp/aws v6.46.0 installed, lock file created, initialized! + terraform plan beginning showing aws_instance.example creation](<assets/Screenshot (464).png>)

![terraform plan — full plan output, all attributes known after apply, Plan: 1 to add 0 to change 0 to destroy](<assets/Screenshot (465).png>)

---

### Step 3 — `terraform apply`

Apply the plan — Terraform prompts for confirmation before making changes.

```bash
PS ...\Day73> terraform apply

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

![terraform apply — Plan 1 to add, Do you want to perform these actions, Enter a value: yes prompt](<assets/Screenshot (466).png>)

```bash
aws_instance.example: Creating...
aws_instance.example: Still creating... [00m10s elapsed]
aws_instance.example: Creation complete after 17s [id=i-0ba46884c5dcf7418]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**EC2 instance created in 17 seconds!**

| Property    | Value                           |
| ----------- | ------------------------------- |
| Instance ID | `i-0ba46884c5dcf7418`           |
| Result      | ✅ Apply complete               |
| Resources   | 1 added, 0 changed, 0 destroyed |

After `apply`, the explorer now shows `terraform.tfstate` — the state file was created.

![terraform apply — Enter value yes, aws_instance.example Creating → Still creating 10s → Creation complete after 17s id=i-0ba46884c5dcf7418, Apply complete Resources 1 added](<assets/Screenshot (467).png>)

---

### Step 4 — Inspect `terraform.tfstate`

After apply, Terraform records everything about the created resource in `terraform.tfstate`:

```json
{
  "version": 4,
  "terraform_version": "1.14.8",
  "serial": 1,
  "lineage": "43e9a308-e93b-8a02-c164-5baebe8d8985",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "ami": "ami-091138d0f0d41ff90",
            "arn": "arn:aws:ec2:us-east-1:248189914762:instance/i-0ba46884c5dcf7418",
            "associate_public_ip_address": false,
            "availability_zone": "us-east-1f",
            ...
          }
        }
      ]
    }
  ]
}
```

**Key state file fields:**

| Field               | Value / Purpose                           |
| ------------------- | ----------------------------------------- |
| `version`           | State file schema version (4)             |
| `terraform_version` | Terraform version that created this state |
| `serial`            | Increments each time state changes        |
| `lineage`           | Unique ID for this state file chain       |
| `type`              | `aws_instance` — the resource type        |
| `ami`               | `ami-091138d0f0d41ff90` — the AMI used    |
| `arn`               | Full AWS ARN of the created instance      |
| `availability_zone` | `us-east-1f` — where it was placed        |

**Why `terraform.tfstate` matters:** Terraform uses this file to know what it manages. Without it, Terraform can't track or destroy the resource. **Never delete it manually.**

![terraform.tfstate — JSON file, version 4, aws_instance example, ami, arn, availability_zone us-east-1f, all resource attributes recorded](<assets/Screenshot (468).png>)

---

### Step 5 — Verify EC2 in AWS Console

Navigate to **EC2 → Instances** — the instance `i-0ba46884c5dcf7418` is **Running**.

| Property          | Value                     |
| ----------------- | ------------------------- |
| Instance ID       | `i-0ba46884c5dcf7418`     |
| Instance state    | ✅ Running                |
| Instance type     | t2.micro                  |
| Availability Zone | us-east-1f                |
| Private IPv4      | 172.31.1.137              |
| Public IPv4       | — (not assigned)          |
| Status check      | Initializing → 2/2 passed |

The instance is in the default subnet (`172.31.1.0/24`, `us-east-1f`) — exactly as expected from the subnet identified in setup.

![EC2 Instances — i-0ba46884c5dcf7418 Running, t2.micro, us-east-1f, private IP 172.31.1.137, Initializing status](<assets/Screenshot (469).png>)

---

### Step 6 — `terraform destroy`

Tear down the infrastructure — Terraform shows exactly what will be deleted.

```bash
PS ...\Day73> terraform destroy

aws_instance.example: Refreshing state... [id=i-0ba46884c5dcf7418]

Terraform will perform the following actions:

  # aws_instance.example will be destroyed
  - resource "aws_instance" "example" {
      - ami                                  = "ami-091138d0f0d41ff90" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:248189914762:instance/i-0ba46884c5dcf7418" -> null
      - associate_public_ip_address          = false -> null
      - availability_zone                    = "us-east-1f" -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - id                                   = "i-0ba46884c5dcf7418" -> null
      - instance_type                        = "t2.micro" -> null
      - key_name                             = "linux-for-devops-key" -> null
      - monitoring                           = false -> null
      - private_dns                          = "ip-172-31-1-137.ec2.internal" -> null
      - private_ip                           = "172.31.1.137" -> null
      ...
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

![terraform destroy — aws_instance.example will be destroyed, all attributes → null shown in red, Plan 0 to add 0 to change 1 to destroy](<assets/Screenshot (470).png>)

```bash
aws_instance.example: Destroying... [id=i-0ba46884c5dcf7418]
aws_instance.example: Still destroying... [id=i-0ba46884c5dcf7418, 00m10s elapsed]
aws_instance.example: Still destroying... [id=i-0ba46884c5dcf7418, 00m20s elapsed]
aws_instance.example: Still destroying... [id=i-0ba46884c5dcf7418, 00m30s elapsed]
aws_instance.example: Still destroying... [id=i-0ba46884c5dcf7418, 00m40s elapsed]
aws_instance.example: Destruction complete after 42s

Destroy complete! Resources: 1 destroyed.
```

EC2 termination takes ~42 seconds. After destroy, `terraform.tfstate.backup` is created — a snapshot of the previous state before destruction.

Explorer after destroy: `main.tf`, `terraform.tfstate`, **`terraform.tfstate.backup`** ← new

![terraform destroy — Destroying id=i-0ba46884c5dcf7418, Still destroying 10s/20s/30s/40s, Destruction complete after 42s, Destroy complete Resources 1 destroyed, tfstate.backup created](<assets/Screenshot (472).png>)

---

### Step 7 — Verify Deletion in AWS Console

Navigate to **EC2 → Instances** — filtered by `running` state shows **No matching instances found**.

The instance `i-0ba46884c5dcf7418` is gone from AWS — Terraform's destroy worked correctly.

![EC2 Instances — No matching instances found after terraform destroy, instance i-0ba46884c5dcf7418 gone](<assets/Screenshot (471).png>)

---

## Terraform Lifecycle — Full Picture

```
main.tf (HCL code)
      │
      ▼
terraform init
  └── Downloads hashicorp/aws v6.46.0
  └── Creates .terraform/ + .terraform.lock.hcl
      │
      ▼
terraform plan
  └── Dry run — shows what WILL happen
  └── No changes to AWS
  └── "Plan: 1 to add, 0 to change, 0 to destroy"
      │
      ▼
terraform apply
  └── Prompts "Enter a value: yes"
  └── Creates EC2: i-0ba46884c5dcf7418 (17s)
  └── Writes terraform.tfstate
      │
      ▼
AWS EC2 Console
  └── i-0ba46884c5dcf7418 Running ✅
  └── t2.micro, us-east-1f, 172.31.1.137
      │
      ▼
terraform destroy
  └── Prompts "Enter a value: yes"
  └── Terminates EC2 (42s)
  └── Writes terraform.tfstate.backup
      │
      ▼
AWS EC2 Console
  └── No matching instances found ✅
```

---

## Key Files Explained

### `main.tf`

The **only file you write**. Defines providers and resources in HCL. Everything else is generated.

### `.terraform.lock.hcl`

**Provider version lock file.** Records the exact version of each provider used (`hashicorp/aws v6.46.0`). Commit this to version control so all team members use identical provider versions.

### `terraform.tfstate`

**The state file.** JSON file mapping your HCL resources to real AWS resources. Terraform uses this to know what it manages, what needs updating, and what to destroy. Critical — never delete manually, store remotely in S3 for teams.

### `terraform.tfstate.backup`

**Previous state snapshot.** Created automatically before each state change. Allows recovery if the current state is accidentally corrupted.

---

## Key Concepts Covered

### IaC vs Console vs CLI

| Method       | Scalable | Reproducible | Version-controlled | Speed            |
| ------------ | -------- | ------------ | ------------------ | ---------------- |
| Console (UI) | ❌       | ❌           | ❌                 | 2 min / resource |
| AWS CLI      | Partial  | Partial      | ✅ (scripts)       | Fast             |
| Terraform    | ✅       | ✅           | ✅                 | Fast + reliable  |

### `terraform plan` vs `terraform apply`

| Command           | Changes AWS? | Purpose                  |
| ----------------- | ------------ | ------------------------ |
| `terraform plan`  | ❌ No        | Preview — dry run only   |
| `terraform apply` | ✅ Yes       | Executes the plan on AWS |

Always run `plan` before `apply` in production environments.

### Why HCL over JSON/YAML?

| Format | Readability | Comments | Terraform native |
| ------ | ----------- | -------- | ---------------- |
| JSON   | Low         | ❌ No    | ✅ Supported     |
| YAML   | Medium      | ✅ Yes   | ✅ Supported     |
| HCL    | High        | ✅ Yes   | ✅ Native        |

HCL is purpose-built for infrastructure — it's more concise than JSON and more powerful than YAML for complex infrastructure logic.

---

## AWS Services Used

| Service    | Purpose                                           |
| ---------- | ------------------------------------------------- |
| Amazon EC2 | Target compute — `i-0ba46884c5dcf7418` (t2.micro) |
| Amazon VPC | Default VPC + subnet (172.31.1.0/24, us-east-1f)  |
| AWS IAM    | Profile: default (Terraform uses CLI credentials) |
| Terraform  | IaC engine — `hashicorp/aws` provider v6.46.0     |

---

## Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [aws_instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
- [HCL Language Reference](https://developer.hashicorp.com/terraform/language)
- [Terraform Registry](https://registry.terraform.io/)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
