![Progress](https://img.shields.io/badge/Progress-62%25-brightgreen?style=for-the-badge&logo=amazonaws)
![CodeDeploy](https://img.shields.io/badge/AWS-CodeDeploy-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM_Roles-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![GitHub](https://img.shields.io/badge/Source-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![Ubuntu](https://img.shields.io/badge/OS-Ubuntu_22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Continuous_Deployment-4EAA25?style=for-the-badge&logo=githubactions&logoColor=white)

# Day 62 - AWS CodeDeploy: Full CD Pipeline — Agent, IAM, Deployment Group & Successful Deployment

## Overview

On Day 62, I completed the full **AWS CodeDeploy** setup — the CD (Continuous Deployment) half of the CI/CD pipeline built on Day 61. This covered installing the CodeDeploy agent on EC2, creating two dedicated IAM roles, configuring the Deployment Group with EC2 tag filters, connecting CodeDeploy to GitHub as the revision source, and triggering a **successful deployment** to the EC2 instance.

**Final result: Deployment `d-AC4KNMMDJ` — ✅ Succeeded (1/1 instances, 100%)**

The full pipeline now looks like:

```
GitHub (SohamSarkar025/aws-cicd)
        │
        │  Revision (commit: 098a863d...)
        ▼
AWS CodeDeploy (CD)
        │  Deployment Group: sample-python-app
        │  Config: CodeDeployDefault.AllAtOnce
        ▼
EC2 Instance (Ubuntu 22.04, t2.micro)
        └── CodeDeploy Agent (active, running)
                │
                ▼
        appspec.yml lifecycle hooks executed ✅
```

---

## Architecture: Two IAM Roles Required

CodeDeploy requires **two separate IAM roles** — a common source of confusion:

| Role                  | Trusted Entity             | Purpose                                                                                                   |
| --------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| `ec2-codedeploy-role` | `codedeploy.amazonaws.com` | Allows the CodeDeploy **service** to manage deployments and interact with EC2                             |
| `MyEC2CodeDeployRole` | `ec2.amazonaws.com`        | Attached to the **EC2 instance profile** — allows the on-instance agent to pull artifacts and report back |

---

## Steps Performed

### Step 1 — Install the CodeDeploy Agent on EC2

SSH into the instance and install prerequisites:

```bash
sudo apt update
sudo apt install ruby-full -y
sudo apt install wget        # Already newest version (1.25.0-2ubuntu4)
```

Download the agent installer from the regional S3 bucket:

```bash
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
```

Run the installer:

```bash
chmod +x install
sudo ./install auto
```

The installer automatically detected the region via EC2 metadata, downloaded `codedeploy-agent_1.8.1-26_all.deb`, installed via `gdebi`, and registered the systemd service.

Verify the agent is running:

```bash
systemctl status codedeploy-agent
```

**Result: ✅ active (running) since Sun 2026-05-10 08:19:48 UTC**

```
● codedeploy-agent.service - LSB: AWS CodeDeploy Host Agent
   Active: active (running) since Sun 2026-05-10 08:19:48 UTC; 47s ago
   Tasks: 2 (limit: 1123)
  Memory: 60.5M
```

Two processes confirm correct operation:

- `codedeploy-agent: master 2350`
- `codedeploy-agent: InstanceAgent::Plugins::CodeDeployPlugin::CommandPoller of master 2350`

![Agent running - systemctl status](<assets/Screenshot%20(333).png>)

---

### Step 2 — Create the CodeDeploy Service Role (`ec2-codedeploy-role`)

Navigate to **IAM → Roles → Create Role**.

- **Trusted Entity:** AWS Service → **CodeDeploy** (EC2/On-premises use case)
- **Role Name:** `ec2-codedeploy-role`

AWS auto-generates the trust policy with `codedeploy.amazonaws.com` as the principal. Then add `AmazonEC2FullAccess` to the role.

![CodeDeploy use case selection](<assets/Screenshot%20(334).png>)

![Role name and trust policy](<assets/Screenshot%20(335).png>)

![Attach AmazonEC2FullAccess](<assets/Screenshot%20(345).png>)

---

### Step 3 — Create the EC2 Instance Profile Role (`MyEC2CodeDeployRole`)

Navigate to **IAM → Roles → Create Role**.

- **Trusted Entity:** AWS Service → **EC2**
- **Policy:** `AWSCodeDeployFullAccess`
- **Role Name:** `MyEC2CodeDeployRole`

![EC2 use case selection](<assets/Screenshot%20(336).png>)

![AWSCodeDeployFullAccess selected](<assets/Screenshot%20(337).png>)

![Role name review](<assets/Screenshot%20(338).png>)

---

### Step 4 — Attach `MyEC2CodeDeployRole` to the EC2 Instance

Navigate to **EC2 → Instances → Actions → Security → Modify IAM Role**.

Select `MyEC2CodeDeployRole` (instance profile ARN: `arn:aws:iam::248189914762:instance-profile/MyEC2CodeDeployRole`) and click **Update IAM role**.

> ✅ **Successfully attached MyEC2CodeDeployRole to instance i-0e20849f7600ca806**

![IAM role dropdown](<assets/Screenshot%20(339).png>)

![Role attached confirmation](<assets/Screenshot%20(341).png>)

---

### Step 5 — Tag the EC2 Instance for CodeDeploy Discovery

Navigate to **EC2 → Instances → Actions → Instance Settings → Manage Tags**.

Add tag:

| Key    | Value                      |
| ------ | -------------------------- |
| `Name` | `DevOps-Lab-20260510-1345` |

This tag is what CodeDeploy uses to find the target instance when the Deployment Group runs.

![Manage tags - set Name tag](<assets/Screenshot%20(346).png>)

---

### Step 6 — Create the Deployment Group

Navigate to **CodeDeploy → Applications → sample-python-flask-app → Create deployment group**.

| Setting                  | Value                                                |
| ------------------------ | ---------------------------------------------------- |
| Deployment Group Name    | `sample-python-app`                                  |
| Service Role ARN         | `arn:aws:iam::248189914762:role/ec2-codedeploy-role` |
| Deployment Type          | In-place                                             |
| Deployment Configuration | `CodeDeployDefault.AllAtOnce`                        |
| Load Balancer            | Disabled                                             |

**Environment configuration — EC2 tag filter:**

| Key    | Value                      |
| ------ | -------------------------- |
| `Name` | `DevOps-Lab-20260510-1345` |

CodeDeploy immediately confirmed: **1 unique matched instance** ✅

![Environment config with tag filter - 1 instance matched](<assets/Screenshot%20(347).png>)

![Deployment settings - AllAtOnce, no load balancer](<assets/Screenshot%20(348).png>)

**Deployment Group created successfully:**

| Field                    | Value                                              |
| ------------------------ | -------------------------------------------------- |
| Deployment group name    | `sample-python-app`                                |
| Application name         | `sample-python-flask-app`                          |
| Compute platform         | EC2/on-premises                                    |
| Deployment type          | In place                                           |
| Service role ARN         | `arn:aws:iam::248189914762:role/ec2-codeploy-role` |
| Deployment configuration | `CodeDeployDefault.AllAtOnce`                      |
| Rollback enabled         | False                                              |
| EC2 tag filter           | `Name = DevOps-Lab-20260510-1345`                  |

![Deployment group created successfully](<assets/Screenshot%20(349).png>)

---

### Step 7 — Create a Deployment (GitHub as Revision Source)

Navigate to **CodeDeploy → Applications → sample-python-flask-app → Create deployment**.

**Revision type:** My application is stored in **GitHub**

![Create deployment - GitHub selected](<assets/Screenshot%20(350).png>)

**Connect to GitHub via OAuth:**

Click **Connect to GitHub**. The GitHub OAuth popup appeared requesting access to `SohamSarkar025` account (public and private repos). Authorized `aws-codesuite`.

![GitHub OAuth authorization](<assets/Screenshot%20(351).png>)

![Processing OAuth request - Confirm](<assets/Screenshot%20(352).png>)

After confirmation:

> ✅ **Application sample-python-flask-app successfully bound to soham GitHub token**

**Repository and revision details:**

| Field             | Value                                      |
| ----------------- | ------------------------------------------ |
| GitHub token name | `soham`                                    |
| Repository name   | `SohamSarkar025/aws-cicd`                  |
| Commit ID         | `098a863d9b979e308f9af376a3110df55edf1b5c` |

![GitHub connected - repo and commit ID filled](<assets/Screenshot%20(353).png>)

**Additional deployment behavior settings** were left at defaults (no `ApplicationStop` failure override, no content overwrite option selected).

![Additional deployment behavior settings](<assets/Screenshot%20(357).png>)

Before clicking Create, restarted the CodeDeploy agent and installed Docker on the instance:

```bash
sudo service codedeploy-agent restart
sudo apt install docker.io -y
```

![Agent restart and Docker install](<assets/Screenshot%20(356).png>)

Click **Create deployment**.

---

### Step 8 — Deployment In Progress → Succeeded ✅

The deployment `d-AC4KNMMDJ` was triggered.

**In progress (0%):**

![Deployment in progress - 0%](<assets/Screenshot%20(358).png>)

**Deployment succeeded (100%):**

| Field                    | Value                         |
| ------------------------ | ----------------------------- |
| Deployment ID            | `d-AC4KNMMDJ`                 |
| Status                   | ✅ Succeeded                  |
| Deployment configuration | `CodeDeployDefault.AllAtOnce` |
| Deployment group         | `sample-python-app`           |
| Instances updated        | 1 of 1                        |
| Initiated by             | User action                   |

![Deployment succeeded - 1/1 instances, 100%](<assets/Screenshot%20(359).png>)

---

## IAM Roles — Trust Relationship Diagram

```
┌──────────────────────────────────────┐
│     AWS CodeDeploy Service           │
│  (console / API / pipeline trigger)  │
└──────────────┬───────────────────────┘
               │ assumes
               ▼
  ┌────────────────────────┐
  │   ec2-codedeploy-role  │  ← Principal: codedeploy.amazonaws.com
  │  AmazonEC2FullAccess   │  ← Used by: CodeDeploy control plane
  └────────────┬───────────┘
               │ manages deployments on
               ▼
  ┌──────────────────────────────────┐
  │  EC2 Instance (t2.micro)         │
  │  Tag: Name=DevOps-Lab-20260510   │
  │                                  │
  │  Instance Profile ─────────────► │  MyEC2CodeDeployRole
  │                                  │  ← Principal: ec2.amazonaws.com
  │  CodeDeploy Agent (running)      │  ← AWSCodeDeployFullAccess
  │  ↓ polls CodeDeploy API          │  ← Used by: agent on instance
  │  ↓ downloads revision from GitHub│
  │  ↓ executes appspec.yml hooks    │
  └──────────────────────────────────┘
```

---

## Key Concepts Covered

### Deployment Group Tag Filtering

CodeDeploy uses EC2 tags to dynamically discover deployment targets. When tag `Name = DevOps-Lab-20260510-1345` was entered, the console immediately confirmed **1 unique matched instance** — validating the tag before the group was even saved. This makes scaling out trivial: add more instances with the same tag and they're automatically included in future deployments.

### `CodeDeployDefault.AllAtOnce`

Deploys to all instances in the group simultaneously. For a single instance this is straightforward, but in a multi-instance fleet this means zero rolling — all instances go offline for the update at the same time. Other configurations include `HalfAtATime` and `OneAtATime` for safer rolling updates.

### GitHub as Revision Source

CodeDeploy can pull revisions directly from GitHub (instead of S3) using OAuth. The connection is established once per AWS account per region — the token alias (`soham`) is reused for future deployments. CodeDeploy identifies the exact revision by **Commit ID**, ensuring reproducible deployments.

### In-Place Deployment Lifecycle

When the deployment ran on the instance, the agent executed hooks in this order:

```
ApplicationStop          ← Stop the old running app (if any)
DownloadBundle           ← Pull revision from GitHub
BeforeInstall            ← Pre-install scripts
Install                  ← Copy files per appspec.yml
AfterInstall             ← Post-install scripts
ApplicationStart         ← Start the new app
ValidateService          ← Health check
```

### Why Docker Was Installed Before Deployment

The `appspec.yml` in the `aws-cicd` repository includes lifecycle scripts that run Docker commands to start the Flask container. Without Docker installed on the EC2 instance, the `ApplicationStart` hook would fail. Installing `docker.io` beforehand ensures the instance is ready to execute the deployment scripts.

---

## Deployment Summary

| Property         | Value                                      |
| ---------------- | ------------------------------------------ |
| Deployment ID    | `d-AC4KNMMDJ`                              |
| Application      | `sample-python-flask-app`                  |
| Deployment Group | `sample-python-app`                        |
| Revision Source  | GitHub — `SohamSarkar025/aws-cicd`         |
| Commit           | `098a863d9b979e308f9af376a3110df55edf1b5c` |
| Configuration    | `CodeDeployDefault.AllAtOnce`              |
| Target Instance  | 1 EC2 (Ubuntu 22.04, t2.micro)             |
| Final Status     | ✅ **Succeeded**                           |

---

## AWS Services Used

| Service                    | Purpose                                                |
| -------------------------- | ------------------------------------------------------ |
| AWS CodeDeploy             | Deployment orchestration and lifecycle management      |
| AWS EC2                    | Target deployment environment (t2.micro, Ubuntu 22.04) |
| AWS IAM                    | Two service roles with distinct trust policies         |
| GitHub (OAuth)             | Application revision source                            |
| CodeDeploy Agent v1.8.1-26 | On-instance daemon that executes deployments           |
| Docker                     | Container runtime for the Flask application            |

---

## Resources

- [AWS CodeDeploy Agent Installation — Ubuntu](https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html)
- [Create a Service Role for CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-service-role.html)
- [AppSpec File Reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)
- [Deployment Configurations](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
- [aws-cicd Repository](https://github.com/SohamSarkar025/aws-cicd)
