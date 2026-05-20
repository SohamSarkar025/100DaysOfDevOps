![Progress](https://img.shields.io/badge/Progress-69%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![ALB](https://img.shields.io/badge/AWS-ALB-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/AWS-S3-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

# Day 69 - Terraform + AWS: Infrastructure as Code with VPC, EC2, ALB & S3

## Overview

On Day 69, I provisioned a **complete AWS infrastructure stack** using **Terraform** — the industry-standard Infrastructure as Code (IaC) tool. The project (`Day69/`) defines a custom VPC with two public subnets across different Availability Zones, two EC2 web servers, a security group, an S3 bucket, and an **Application Load Balancer (ALB)** that distributes HTTP traffic across both instances. Everything was created with a single `terraform apply` command.

**Result: 16 AWS resources created via Terraform — ALB routing traffic to 2 EC2 instances confirmed live in browser ✅**

---

## Concept Notes

### Terraform — Infrastructure as Code

Terraform is an open-source IaC tool by HashiCorp. It lets you define cloud infrastructure in **declarative `.tf` files** and provision it reproducibly across any environment.

```
.tf files (HCL)
     │
     ├── terraform init     → Download provider plugins (hashicorp/aws)
     ├── terraform validate → Syntax + config validation
     ├── terraform plan     → Dry run — show what will be created/destroyed
     └── terraform apply    → Provision resources on AWS
```

### Core Workflow

| Command              | Purpose                                                   |
| -------------------- | --------------------------------------------------------- |
| `terraform init`     | Initialize working directory, download provider plugins   |
| `terraform validate` | Check configuration syntax and internal consistency       |
| `terraform plan`     | Preview changes before applying                           |
| `terraform apply`    | Create/update/destroy resources to match config           |
| `terraform destroy`  | Tear down all managed resources (16 destroyed at Day end) |

### Project File Structure

```
Day69/
├── providers.tf       # AWS provider config (hashicorp/aws v6.45.0, us-east-1)
├── main.tf            # All resource definitions (VPC, subnets, EC2, ALB, etc.)
├── variables.tf       # Input variable declarations
├── userdata.sh        # Bootstrap script for webserver1
├── userdata1.sh       # Bootstrap script for webserver2
└── assets/            # Screenshots
```

---

## Architecture

```
                        Internet
                           │
                    Internet Gateway (igw)
                           │
                    Route Table (RT)
                    ┌──────┴──────┐
                    │             │
              Subnet sub1       Subnet sub2
              (us-east-1a)     (us-east-1b)
                    │             │
             webserver1        webserver2
             (t2.micro)        (t2.micro)
             userdata.sh      userdata1.sh
                    │             │
                    └──────┬──────┘
                     Target Group (myTG)
                     HTTP:80 | 2 Healthy
                           │
               Application Load Balancer (myalb)
               Internet-facing | HTTP Listener
                           │
                    ALB DNS (public)
              myalb-1623016366.us-east-1.elb.amazonaws.com

                    S3 Bucket: sohamsarkarofficial000-day70
                    Security Group: webSg (port 80 open)
                    VPC: myvpc (10.0.0.0/16)
```

---

## Steps Performed

### Step 1 — Write `providers.tf`

Set up the Terraform block with the AWS provider plugin and target region.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.45.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
```

---

### Step 2 — `terraform init`

Initialize the working directory and download the AWS provider plugin.

```bash
PS C:\Users\sruti\OneDrive\Desktop\100DaysOfDevOps\Day69> terraform init
Initializing the backend...
Initializing provider plugins...

Terraform has been successfully initialized!
```

After init, the `.terraform/` directory and `.terraform.lock.hcl` file appear in the project.

![terraform init - Terraform has been successfully initialized, .terraform folder created](<assets/Screenshot%20(407).png>)

---

### Step 3 — Write `main.tf`

Define all AWS resources in `main.tf`. The configuration provisions the full networking stack, compute, storage, and load balancing layer.

![main.tf lines 32-40 - route_table_association rta1 and rta2](<assets/Screenshot%20(416).png>)

![main.tf lines 73-95 - S3 bucket, webserver1, webserver2, alb comment](<assets/Screenshot%20(417).png>)

---

### Step 4 — `terraform validate`

Validate the configuration syntax before applying.

```bash
PS C:\Users\sruti\OneDrive\Desktop\100DaysOfDevOps\Day69> terraform validate
Success! The configuration is valid.
```

![terraform validate - Success! The configuration is valid.](<assets/Screenshot%20(408).png>)

---

### Step 5 — `terraform apply -auto-approve`

Apply the configuration. Terraform created **16 resources** in sequence.

```
Plan: 16 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + loadbalancerdns = (known after apply)

aws_vpc.myvpc: Creating...
aws_s3_bucket.s3: Creating...
aws_vpc.myvpc: Creation complete after 4s [id=vpc-0a125cf5ed1664efe]
aws_internet_gateway.igw: Creating...
aws_subnet.sub1: Creating...
aws_subnet.sub2: Creating...
aws_lb_target_group.tg: Creating...
aws_security_group.webSg: Creating...
aws_internet_gateway.igw: Creation complete after 2s [id=igw-087982c9b2a1b527c]
aws_route_table.RT: Creating...
...
Destroy complete! Resources: 16 destroyed.   ← (cleanup at end of day)
```

![terraform apply -auto-approve - 16 to add, VPC creating, IGW complete, subnet creating](<assets/Screenshot%20(409).png>)

---

### Step 6 — Verify EC2 Instances

Navigate to **EC2 → Instances** — both `webserver1` and `webserver2` show **Running** with 2/2 status checks passed.

| Instance ID         | State   | Type     | AZ         |
| ------------------- | ------- | -------- | ---------- |
| i-08951384b440c896a | Running | t2.micro | us-east-1b |
| i-0528200a76f9c2ae5 | Running | t2.micro | us-east-1a |

![EC2 Instances 2 - Running, t2.micro, 2/2 checks passed, us-east-1b and us-east-1a](<assets/Screenshot%20(410).png>)

---

### Step 7 — Verify ALB (`myalb`)

Navigate to **EC2 → Load Balancers → myalb**.

| Property           | Value                                                                |
| ------------------ | -------------------------------------------------------------------- |
| Load balancer type | Application                                                          |
| Status             | ✅ Active                                                            |
| Scheme             | Internet-facing                                                      |
| VPC                | vpc-0a125cf5ed1664efe                                                |
| Availability Zones | us-east-1b (use1-az6), us-east-1a (use1-az4)                         |
| DNS name           | myalb-1623016366.us-east-1.elb.amazonaws.com (A Record)              |
| ARN                | arn:aws:elasticloadbalancing:us-east-1:248189914762:loadbalancer/... |
| Date created       | May 20, 2026, 20:56 (UTC+05:30)                                      |
| Listeners          | 1 (HTTP:80)                                                          |

![myalb - Application, Active, Internet-facing, DNS name, ARN, Listeners 1](<assets/Screenshot%20(411).png>)

---

### Step 8 — Verify Target Group (`myTG`)

Navigate to **EC2 → Target Groups → myTG**.

| Property         | Value                 |
| ---------------- | --------------------- |
| Target type      | Instance              |
| Protocol : Port  | HTTP : 80             |
| Protocol version | HTTP1                 |
| VPC              | vpc-0a125cf5ed1664efe |
| Load balancer    | myalb                 |
| Total targets    | **2**                 |
| Healthy          | ✅ **2**              |
| Unhealthy        | 0                     |

Both EC2 instances registered and **healthy** — ALB will distribute traffic between them.

![myTG - 2 total targets, 2 Healthy, 0 Unhealthy, HTTP:80, HTTP1, myalb](<assets/Screenshot%20(412).png>)

---

### Step 9 — Verify VPC

Navigate to **VPC → Your VPCs → vpc-0091b50974986c016**.

| Property       | Value                 |
| -------------- | --------------------- |
| VPC ID         | vpc-0091b50974986c016 |
| State          | ✅ Available          |
| IPv4 CIDR      | 10.0.0.0/16           |
| Tenancy        | default               |
| DNS resolution | Enabled               |
| DNS hostnames  | Disabled              |
| Default VPC    | No                    |
| Subnets        | 2                     |
| Route tables   | 2                     |

Resource map shows VPC → Subnets (2: us-east-1a) → Route tables (2).

![VPC vpc-0091b50974986c016 - Available, 10.0.0.0/16, Resource map with subnets and route tables](<assets/Screenshot%20(413).png>)

---

### Step 10 — Test ALB Load Balancing in Browser

Accessed the ALB DNS name in browser:

```
http://myalb-1884436196.us-east-1.elb.amazonaws.com
```

On **first request** → routed to `webserver1`:

```
Terraform Project Server 1
Instance ID: i-0585a90e0651febed
Welcome to Abhishek Veeramalla's Channel
```

On **refresh** → ALB round-robins to `webserver2`:

```
Terraform Project Server 1
Instance ID: i-05fed1337ae97ef8a
Welcome to CloudChamp's Channel
```

Each instance serves its own `userdata.sh` / `userdata1.sh` content — confirming the ALB is distributing traffic across both targets.

![Browser - Terraform Project Server 1, Instance ID i-0585a90e0651febed, Abhishek Veeramalla's Channel](<assets/Screenshot%20(414).png>)

![Browser refresh - Terraform Project Server 1, Instance ID i-05fed1337ae97ef8a, CloudChamp's Channel](<assets/Screenshot%20(415).png>)

---

### Step 11 — `terraform destroy`

All 16 resources torn down at end of day to avoid ongoing charges.

```bash
PS C:\Users\sruti\OneDrive\Desktop\100DaysOfDevOps\Day69> terraform apply -auto-approve
...
Destroy complete! Resources: 16 destroyed.
```

![terraform destroy - Destroy complete, Resources 16 destroyed, terminal in VS Code](<assets/Screenshot%20(418).png>)

---

## End-to-End Architecture Summary

```
Day69/
├── providers.tf      # hashicorp/aws v6.45.0, region = us-east-1
├── main.tf           # 16 resources: VPC, IGW, RT, sub1+sub2, RTAs,
│                     # webSg, S3, webserver1, webserver2, ALB, TG, listener
├── variables.tf      # Input variables
├── userdata.sh       # Webserver1 bootstrap (HTML page w/ Instance ID)
└── userdata1.sh      # Webserver2 bootstrap (HTML page w/ Instance ID)

terraform apply ──► 16 AWS resources created in us-east-1
                    │
                    ├── VPC (10.0.0.0/16) + IGW + Route Table
                    ├── sub1 (us-east-1a) + sub2 (us-east-1b)
                    ├── webSg (port 80 open)
                    ├── S3: sohamsarkarofficial000-day70
                    ├── webserver1 (t2.micro, sub1) ─┐
                    ├── webserver2 (t2.micro, sub2) ─┤
                    ├── Target Group myTG (2 Healthy) ┘
                    └── ALB myalb (Active, Internet-facing)
                              │
                    http://myalb-*.us-east-1.elb.amazonaws.com
                    → Round-robin between webserver1 & webserver2 ✅
```

---

## Terraform Resources Created (16 total)

| Resource                      | Name / Value                         |
| ----------------------------- | ------------------------------------ |
| `aws_vpc`                     | myvpc — 10.0.0.0/16                  |
| `aws_internet_gateway`        | igw                                  |
| `aws_route_table`             | RT                                   |
| `aws_route_table_association` | rta1 (sub1), rta2 (sub2)             |
| `aws_subnet` ×2               | sub1 (us-east-1a), sub2 (us-east-1b) |
| `aws_security_group`          | webSg — port 80 open                 |
| `aws_s3_bucket`               | sohamsarkarofficial000-day70         |
| `aws_instance` ×2             | webserver1 (sub1), webserver2 (sub2) |
| `aws_lb_target_group`         | myTG — HTTP:80, Instance type        |
| `aws_lb`                      | myalb — Application, Internet-facing |
| `aws_lb_listener`             | HTTP:80 → forward to myTG            |

---

## Key Concepts Covered

### Terraform State

Terraform tracks all created resources in `terraform.tfstate` — a JSON file mapping config to real AWS resource IDs. After `apply`, this file contains IDs like `vpc-0a125cf5ed1664efe`, `igw-087982c9b2a1b527c`, etc. `terraform destroy` uses state to know what to delete.

### `user_data_base64` vs `user_data`

```hcl
user_data_base64 = base64encode(file("userdata.sh"))
```

EC2 `user_data` must be base64-encoded when passed via Terraform's `aws_instance`. The `base64encode()` function + `file()` reads the shell script from disk and encodes it inline — no manual encoding needed.

### ALB → Target Group → EC2 Flow

```
Client HTTP request
      │
Application Load Balancer (myalb)
      │  Listener: HTTP:80
      │  Default rule: forward to myTG
      ▼
Target Group (myTG)
      │  Health check: HTTP GET /
      │  2 healthy targets registered
      ├──► webserver1 (i-xxx, sub1, us-east-1a)
      └──► webserver2 (i-yyy, sub2, us-east-1b)
```

### Multi-AZ Deployment

Both subnets (`sub1`, `sub2`) are in different Availability Zones (`us-east-1a`, `us-east-1b`). The ALB spans both AZs — if one AZ goes down, traffic continues flowing to the healthy AZ. This is the foundation of **high availability** on AWS.

---

## AWS Services Used

| Service                | Purpose                                                    |
| ---------------------- | ---------------------------------------------------------- |
| Amazon VPC             | Custom network — myvpc (10.0.0.0/16) with 2 public subnets |
| Amazon EC2             | Two t2.micro web servers (webserver1, webserver2)          |
| Elastic Load Balancing | myalb — distributes HTTP traffic across both instances     |
| Amazon S3              | sohamsarkarofficial000-day70 — storage bucket              |
| AWS IAM                | Profile: default (AWS CLI credentials)                     |
| Terraform              | IaC tool — hashicorp/aws provider v6.45.0                  |

---

## Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [aws_instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [aws_lb Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
- [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)
- [Terraform CLI Commands](https://developer.hashicorp.com/terraform/cli/commands)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
