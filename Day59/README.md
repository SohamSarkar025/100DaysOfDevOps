![Progress](https://img.shields.io/badge/Progress-59%25-brightgreen?style=for-the-badge&logo=amazonaws)
![CloudFormation](https://img.shields.io/badge/AWS-CloudFormation-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Infrastructure_as_Code-4EAA25?style=for-the-badge&logo=terraform&logoColor=white)

# Day 59: AWS CloudFormation — Infrastructure as Code Deep Dive

Welcome to Day 59 of my **#100DaysOfDevOps** journey! After mastering the AWS CLI and Bash scripting on Day 58, today I took the next major step in cloud automation — **Infrastructure as Code (IaC)** using **AWS CloudFormation (CFT)**. Instead of clicking through the console or writing individual CLI commands, CloudFormation lets you define your entire AWS infrastructure in a single YAML or JSON template file, and AWS provisions everything automatically, repeatably, and safely.

---

## 📌 Project Overview

| Detail                | Value                                            |
| :-------------------- | :----------------------------------------------- |
| **Topic**             | AWS CloudFormation — IaC Concepts & Hands-On Lab |
| **Template File**     | `template.yaml`                                  |
| **Stack Name**        | `demo-s3-creation`                               |
| **Resource Created**  | `soham-devops-lab-bucket` (AWS::S3::Bucket)      |
| **Region**            | US East (N. Virginia) — us-east-1                |
| **Stack Status**      | ✅ CREATE_COMPLETE                               |
| **Template Format**   | YAML                                             |
| **Deployment Method** | CloudFormation Console (Upload template file)    |

---

## 📚 Section 1: Understanding Infrastructure as Code

### What is IaC and Why Does It Matter?

Before diving into CloudFormation specifically, it's important to understand the problem it solves. Without IaC, every environment (dev, staging, production) is configured manually — a process that is slow, inconsistent, and impossible to audit or version-control. IaC solves this by treating **infrastructure the same way you treat application code**.

---

### The AWS Automation Ecosystem

![CFT, IaC, and AWS CLI Ecosystem Overview](<assets/Screenshot%20(143).png>)

There are several ways to automate AWS infrastructure. The diagram above maps the full landscape:

- **AWS CLI** — command-line tool that sends direct API calls; great for quick tasks and scripts
- **CloudFormation (CFT)** ✅ — AWS-native IaC; you write a template → CFT provisions the infrastructure
- **Terraform** ✅ — most popular multi-cloud IaC tool (HashiCorp HCL syntax)
- **CDK** — AWS Cloud Development Kit; write infrastructure in TypeScript, Python, or Java

All of these are forms of **IaC (Infrastructure as Code)** — meaning code defines and manages your infrastructure, not manual clicks or one-off commands.

---

### How CloudFormation Works — The Full Flow

![CFT Flow — User → Template → AWS via API Calls](<assets/Screenshot%20(144).png>)

The end-to-end CloudFormation flow:

```
User writes template (YAML or JSON)
         │
         ▼
  CFT acts as the "middleman" (IaC engine)
         │
         │  AWS API Calls
         ▼
    AWS Cloud provisions resources
```

Key characteristics of the template:

- **Declarative** — you describe _what you want_ ("I need an S3 bucket"), not _how to create it_ step by step
- **Versioned** — templates are files that live in Git, enabling code review, history, rollback, and collaboration
- **YAML or JSON** — both formats are supported; YAML is preferred for readability

> **Key Insight:** You are not telling CloudFormation _how_ to create a VPC — you are telling it _what_ you want. CFT figures out the correct API calls and order of operations automatically.

---

### CFT as the IaC Middleman

![CFT as IaC Middleman — Terraform and Crossplane as Alternatives](<assets/Screenshot%20(146).png>)

CloudFormation sits between your template file and the AWS API:

- **User** writes a YAML/JSON template
- **CFT** reads the template and translates it into the correct sequence of AWS API calls
- **AWS** provisions the resources

Other tools like **Terraform** and **Crossplane** serve the same "middleman" role — they are IaC engines that sit between your declarative config and the underlying cloud API. The difference is that CFT is AWS-native (free, deeply integrated, no state file needed), while Terraform is multi-cloud and community-driven.

---

### Why IaC? — Declarative, Versioned, Reviewable

![IaC Benefits — Declarative, Versioned, Code Review, Git](<assets/Screenshot%20(147).png>)

The whiteboard above captures the core value proposition of IaC:

**"What you see is what you have"** — the template is the single source of truth for your infrastructure. If the template says you have a VPC, a Route Table, a Load Balancer, and an EC2 instance — that is exactly what exists in AWS.

**Key benefits:**

- **Declarative** — describe desired state; CFT handles the implementation
- **Versioned** — store templates in Git; every change is tracked, reviewable, and reversible
- **Code Review** — infrastructure changes go through pull requests, just like application code
- **Template reuse** — the same template deploys identical environments in 10 days or 5 days — no configuration drift between them
- **Everything as code** — VPC + Route Table + Load Balancer + EC2 — all in one file, version-controlled in S3 or Git

---

### CFT's Superpower — Drift Detection

![CFT Drift Detection — Periodically Check Template vs Reality](<assets/Screenshot%20(148).png>)

One of CloudFormation's most powerful features beyond provisioning is **Drift Detection**:

- **Drift** occurs when someone manually modifies a resource (via the console or CLI) after it was created by CFT — causing the actual state to diverge from the template definition
- CloudFormation can **periodically scan** all managed resources and compare their actual configuration against what the template specifies
- If EC2 or S3 configurations have been manually changed, CFT flags those resources as **"drifted"**
- You can enable/disable drift detection per stack and view drift reports in the console

This is a critical feature for compliance — it ensures no one can silently modify production infrastructure without it being detected.

---

### How Stacks Work — YAML → CFT → Stacks

![YAML Template → AWS CFT → Stacks → Create/Import](<assets/Screenshot%20(149).png>)

In CloudFormation, the unit of deployment is called a **Stack**:

- You write a **YAML (or JSON) template** describing your resources
- You submit that template to **AWS CFT** (via CLI or the Console)
- CFT creates a **Stack** — a logical grouping of all the resources defined in that template
- Within a Stack, you can: **Create** new resources, **Update** existing ones, or **Import** pre-existing AWS resources into CFT management

A stack is the "envelope" that holds all your resources together — delete the stack, and CloudFormation deletes all the resources inside it (unless you configure retain policies).

---

## 📋 Section 2: CFT Template Structure

### Template Sections — What Goes Where

![CFT Template Sections — Visual Overview](<assets/Screenshot%20(150).png>)

A CloudFormation template is organized into well-defined sections. The diagram shows the full list — **Resources is the only mandatory section**; all others are optional.

---

### Official AWS Documentation

![AWS CloudFormation Official Docs](<assets/Screenshot%20(151).png>)

CloudFormation is a service that helps you model and set up AWS resources so you can spend less time managing those resources and more time focusing on your applications. You create a template that describes all the AWS resources you want, and CloudFormation takes care of provisioning and configuring them — you never need to individually create resources or figure out what depends on what.

---

### Full YAML Template Structure — Part 1

![CFT YAML Template Structure — Top Sections](<assets/Screenshot%20(153).png>)

The complete YAML template structure with all available sections:

```yaml
---
AWSTemplateFormatVersion: version date # e.g. "2010-09-09" (only valid value)

Description: String # Human-readable description of the template

Metadata: template metadata # Additional info about the template

Parameters: set of parameters # Input values at stack creation time

Rules: set of rules # Validate parameter combinations

Mappings: set of mappings # Key-value lookup tables (e.g. AMI per region)

Conditions: set of conditions # Conditionally create resources
```

---

### Full YAML Template Structure — Part 2

![CFT YAML Template Structure — Resources and Outputs](<assets/Screenshot%20(154).png>)

```yaml
Transform: set of transforms # SAM/macros (for serverless apps)

Resources: # ✅ MANDATORY — define all AWS resources here
  set of resources # e.g. AWS::EC2::Instance, AWS::S3::Bucket

Outputs:
  set of outputs # Values to export after stack creation
  # e.g. bucket name, instance IP
```

> **Most Important Section:** `Resources` is the only required section. Every other section is optional but adds powerful capabilities — `Parameters` for dynamic inputs, `Outputs` for cross-stack references, `Conditions` for environment-specific resources.

---

### A Real Template Example — EC2 Instance in YAML

![CFT YAML Template Example — EC2 Instance with EBS](<assets/Screenshot%20(152).png>)

```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: A sample CloudFormation template with YAML comments.
# Resources section
Resources:
  MyEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      # Linux AMI
      ImageId: ami-1234567890abcdef0
      InstanceType: t2.micro
      KeyName: MyKey
      BlockDeviceMappings:
        - DeviceName: /dev/sdm
          Ebs:
            VolumeType: io1
            Iops: 200
            DeleteOnTermination: false
            VolumeSize: 20
```

This template creates a single EC2 instance. Notice:

- `Type` specifies the AWS resource type using the `AWS::Service::ResourceType` notation
- `Properties` contains the resource-specific configuration
- Comments are supported in YAML (not in JSON)
- The `Logical ID` (`MyEC2Instance`) is the name CFT uses internally to track this resource

---

## 🛠️ Section 3: Hands-On Lab — Creating an S3 Bucket with CloudFormation

### The Template File

For today's lab I wrote a simple YAML template to create an S3 bucket. The template was saved as `template.yaml` in the `Day59` project folder:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: Day 59 - Create an S3 bucket using CloudFormation

Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: soham-devops-lab-bucket
```

This minimal template demonstrates the core pattern — `AWSTemplateFormatVersion`, `Description`, and the `Resources` section with a single `AWS::S3::Bucket` resource.

---

### Step 1: Navigate to CloudFormation — Empty Stacks

![CloudFormation Console — No Stacks Yet](<assets/Screenshot%20(160).png>)

Navigate to **CloudFormation → Stacks** in the AWS Management Console. The console shows **Stacks (0)** — no stacks exist yet. The available actions are Create stack, Update stack, Stack actions, and Delete stack. Click **"Create stack"** to begin.

---

### Step 2: Upload the Template File

![Create Stack — Choose Existing Template, Upload File](<assets/Screenshot%20(161).png>)

The **Create stack** wizard has 4 steps. In **Step 1: Create stack**:

- **Prerequisite — Prepare template**: Choose an existing template
- **Template source**: Upload a template file ✅ (selected)
  - Alternative options: Amazon S3 URL, or Sync from Git
- Click **"Choose file"** to select the local `template.yaml`

> You can also use the **Infrastructure Composer** (visual drag-and-drop builder) to create templates — but writing YAML directly gives you full control and is the production-standard approach.

---

### Step 3: Select the Template from Local Filesystem

![File Picker — Desktop/100DaysOfDevOps/Day59/template.yaml](<assets/Screenshot%20(162).png>)

The Windows file picker opens to the project directory:
**`Desktop > 100DaysOfDevOps > Day59`**

The folder contains:

- `assets/` — folder with screenshots
- `README` — Markdown source file (0 KB, still being written)
- `template` — **YAML Source File** (1 KB) ← selected

Select `template` (the YAML file) and click **Open** to upload it to CloudFormation.

---

### Step 4: Specify Stack Details

![Step 2 — Stack Name: demo-s3-creation, No Parameters](<assets/Screenshot%20(163).png>)

In **Step 2: Specify stack details**:

- **Stack name**: `demo-s3-creation`
  - Must contain only letters, numbers, and hyphens; max 128 characters
  - Character count: 16/128
- **Parameters**: No parameters to display — this template has no `Parameters` section, so all values are hardcoded in the template

Click **Next** to continue.

---

### Step 5: Configure Stack Options

![Step 3 — Stack Options: Policy, Rollback, Notifications, Creation Options](<assets/Screenshot%20(164).png>)

**Step 3: Configure stack options** provides advanced settings (all optional for this lab):

- **Stack policy** — define which resources are protected from unintentional updates during stack updates
- **Rollback configuration** — specify CloudWatch alarms to monitor during stack create/update; if a threshold is breached, CFT automatically rolls back
- **Notification options** — specify an SNS topic for stack event notifications
- **Stack creation options** — configure timeout and termination protection

![Step 3 — Stack Creation Options: Termination Protection Deactivated, Submit](<assets/Screenshot%20(165).png>)

Stack creation options for this lab:

- **Timeout**: None (no time limit)
- **Termination protection**: Deactivated (for lab purposes; enable in production to prevent accidental stack deletion)
- **Quick-create link**: Available to share this stack configuration with a URL
- Click **Submit** to create the stack

---

### Step 6: Stack Created — CREATE_COMPLETE

![Stack demo-s3-creation — Status: CREATE_COMPLETE](<assets/Screenshot%20(166).png>)

After clicking Submit, CloudFormation provisions the resources defined in the template. The **Stack info** tab shows:

| Field            | Value                                                                                                       |
| :--------------- | :---------------------------------------------------------------------------------------------------------- |
| **Stack name**   | `demo-s3-creation`                                                                                          |
| **Stack ID**     | `arn:aws:cloudformation:us-east-1:248189914762:stack/demo-s3-creation/14a8df20-4849-11f1-bd3f-0affff5240c5` |
| **Status**       | ✅ `CREATE_COMPLETE`                                                                                        |
| **Created time** | 2026-05-05, 11:40:14 UTC+0530                                                                               |
| **Drift status** | `NOT_CHECKED`                                                                                               |

The stack was created successfully with zero manual configuration of the S3 bucket — CloudFormation handled everything from the template definition.

---

### Step 7: Resources Tab — S3 Bucket Created

![Stack Resources Tab — S3Bucket CREATE_COMPLETE](<assets/Screenshot%20(167).png>)

Navigate to the **Resources** tab of the stack. It shows all resources managed by this stack:

| Logical ID | Physical ID               | Type              | Status               |
| :--------- | :------------------------ | :---------------- | :------------------- |
| `S3Bucket` | `soham-devops-lab-bucket` | `AWS::S3::Bucket` | ✅ `CREATE_COMPLETE` |

The **Logical ID** (`S3Bucket`) is the name defined in the template. The **Physical ID** (`soham-devops-lab-bucket`) is the actual name of the bucket created in AWS. CloudFormation maps between them automatically.

---

### Step 8: Final Verification — S3 Console

![S3 Console — 2 Buckets: CFT Staging + soham-devops-lab-bucket](<assets/Screenshot%20(168).png>)

Navigate to **Amazon S3** to verify the bucket was created. The S3 console now shows **2 buckets**:

| Bucket Name                           | Region                | Created               |
| :------------------------------------ | :-------------------- | :-------------------- |
| `cf-templates-67dembpq5z7m-us-east-1` | US East (N. Virginia) | May 5, 2026, 11:39:20 |
| `soham-devops-lab-bucket`             | US East (N. Virginia) | May 5, 2026, 11:40:20 |

**Two buckets were created — here's why:**

- `soham-devops-lab-bucket` — the bucket explicitly defined in our template (the goal)
- `cf-templates-67dembpq5z7m-us-east-1` — automatically created by CloudFormation to stage the uploaded template file; CFT always stores uploaded templates in S3 internally

The `soham-devops-lab-bucket` was created at 11:40:20 — exactly 1 minute after the template was uploaded (11:39:20), matching the stack creation timeline perfectly.

---

## 📐 Architecture Summary

```
Developer (You)
      │
      │  Writes template.yaml
      ▼
┌─────────────────────────────────┐
│  template.yaml                  │
│  ─────────────────────────      │
│  AWSTemplateFormatVersion: ...  │
│  Description: Day 59 lab        │
│  Resources:                     │
│    S3Bucket:                    │
│      Type: AWS::S3::Bucket      │
│      Properties:                │
│        BucketName: soham-...    │
└─────────────────────────────────┘
      │
      │  Upload via Console / CLI
      ▼
┌─────────────────────────────────┐
│  AWS CloudFormation             │
│  Stack: demo-s3-creation        │
│  Status: CREATE_COMPLETE ✅     │
│  Drift:  NOT_CHECKED            │
└─────────────────────────────────┘
      │
      │  AWS API Calls (internally)
      ▼
┌─────────────────────────────────┐
│  Amazon S3                      │
│  Bucket: soham-devops-lab-bucket│
│  Type:   AWS::S3::Bucket        │
│  Status: CREATE_COMPLETE ✅     │
└─────────────────────────────────┘
```

---

## 📚 Key Takeaways from Day 59

**About Infrastructure as Code:**

- IaC is not just automation — it is treating infrastructure as software: versioned, reviewed, tested, and deployed through a pipeline.
- The declarative model ("what you want") is fundamentally more powerful than the imperative model ("how to do it") for infrastructure management.
- Templates stored in Git give you full audit history of every infrastructure change — essential for compliance.

**About CloudFormation:**

- CFT is AWS-native IaC — free, deeply integrated, no state file management required (unlike Terraform).
- The `Resources` section is the only mandatory section; everything else is optional but powerful.
- Stacks are the unit of deployment — all resources in a template are managed together as a group.
- Deleting a stack deletes all its resources — making cleanup trivial and preventing resource orphaning.
- Drift Detection is CFT's safety net — it catches unauthorized manual changes to managed resources.

**About Template Design:**

- Always use YAML over JSON for human-written templates — comments and readability make a big difference.
- Use `Parameters` to make templates reusable across environments — one template, multiple stacks.
- Use `Outputs` to export values (bucket names, IPs, ARNs) for cross-stack references.
- Use `Conditions` to create environment-specific resources (e.g., only create a CloudWatch alarm in production).
- Enable **Termination Protection** on production stacks to prevent accidental deletion.

**CFT vs CLI/Bash:**

- Day 58 (Bash + CLI): great for one-time tasks, quick automation, and operational scripts
- Day 59 (CFT): great for repeatable, version-controlled, self-documenting infrastructure — the production standard

---

**Challenge**: 100 Days of DevOps
**Milestone**: Day 59 - AWS CloudFormation IaC Deep Dive — Concepts, Template Structure & S3 Stack Lab
