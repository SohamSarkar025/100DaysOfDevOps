![Progress](https://img.shields.io/badge/Progress-58%25-brightgreen?style=for-the-badge&logo=amazonaws)
![AWS CLI](https://img.shields.io/badge/AWS-CLI_v2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash_Scripting-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

# Day 58: AWS CLI Deep Dive — Concepts, Installation & Shell Script Automation

Welcome to Day 58 of my **#100DaysOfDevOps** journey! After spending Day 57 working with the AWS Management Console to host a static website on S3, today I went a level deeper — moving from **point-and-click to command-line**. Day 58 covers the AWS CLI from first principles: what it is, how it communicates with AWS, how to install and configure it, and finally how to write a production-grade **Bash automation script** that launches an EC2 instance, waits for it to be ready, and generates a billing report — all from the terminal.

---

## 📌 Project Overview

| Detail              | Value                                                              |
| :------------------ | :----------------------------------------------------------------- |
| **Topic**           | AWS CLI v2 — Concepts, Installation & Bash Automation              |
| **Script Name**     | `launch-ec2-instance.sh`                                           |
| **Author**          | Soham Sarkar                                                       |
| **Script Purpose**  | Everyday DevOps Lab Automator (Clean & Readable)                   |
| **Region**          | us-east-1                                                          |
| **Instance Type**   | t2.micro                                                           |
| **AMI**             | Ubuntu 22.04 LTS (dynamically fetched)                             |
| **Key Name**        | linux-for-devops-key                                               |
| **Script Sections** | Configuration → Launch → Smart-Wait → Termination → Billing Report |

---

## 📚 Section 1: Understanding the AWS CLI

### What is the AWS CLI?

The **AWS Command Line Interface (CLI)** is a unified tool that allows you to control and automate AWS services directly from your terminal using text commands — instead of clicking through the AWS Management Console.

Under the hood, every `aws` command you type is a **Python application** that translates your command into an **AWS API call** (an HTTP POST request), authenticates it using your credentials, sends it to AWS, and prints the JSON response in a human-readable format.

---

### How AWS Accepts Requests — 3 Ways

![AWS CLI vs IaC Tools Conceptual Overview](<assets/Screenshot%20(132).png>)

There are multiple ways to interact with AWS. The whiteboard above maps them clearly:

**1. AWS CLI** → Command-based → type `aws s3 ls` → sends API call → gets response

- Best for: quick tasks, scripts, automation, debugging

**2. Infrastructure as Code (IaC) Tools** — all ultimately call the AWS API:

- **Terraform** ✅ — most popular IaC tool, declarative HCL syntax
- **CloudFormation (CFT)** ✅ — AWS-native IaC, JSON/YAML templates
- **CDK (Cloud Development Kit)** — write infrastructure in TypeScript/Python/Java

**3. AWS Management Console (UI)** → browser clicks → calls same API internally

> **Key Insight:** Whether you click the console, run `aws ec2 run-instances`, or write a Terraform resource — they all end up calling the same AWS REST API. The CLI and IaC tools are just different levels of abstraction on top of that API.

---

### How the AWS API Works

![AWS API Communication Flow](<assets/Screenshot%20(133).png>)

When you create an S3 bucket via the CLI, here is what actually happens under the hood:

```
User types: aws s3api create-bucket --bucket my-bucket --region us-east-1
                    │
                    ▼
        AWS CLI (Python Application)
        translates command into HTTP:
                    │
                    ▼
        POST https://api.aws.com/s3/create
        Body: { "name": "my-bucket", "versioning": false, ... }
                    │
                    ▼
        AWS API validates credentials + processes request
                    │
                    ▼
        ✅ Returns JSON response → CLI prints it
```

The CLI is simply a Python utility that: reads your command → loads your credentials → constructs the correct API request → sends it → parses and displays the JSON response.

---

### CLI Architecture — How It All Connects

![CLI Architecture and Abstraction Layers](<assets/Screenshot%20(134).png>)

The full picture of how AWS CLI fits into the ecosystem:

- **AWS** exposes everything through its **API**
- **CLI** is installed as a Python application — it calls `aws` subcommands (`aws s3`, `aws ec2`, `aws ls`)
- **IaC tools** (Terraform, CFT, CDK) also call the same API but provide **abstraction** — you declare desired state, they figure out the API calls
- **Quick use case**: `aws s3 ls` → lists all your S3 buckets → equivalent to opening S3 console and reading the bucket list

![CLI to AWS Flow — User, Commands, IaC, API](<assets/Screenshot%20(135).png>)

The complete flow:

- **User** types `aws` commands → CLI sends to AWS API
- **CLI reference docs** map every command to its API equivalent
- IaC tools (Terraform, CFT, CDK) use the same API pathway but with state management and templating on top

---

### CLI Quick Use Cases

![CLI Quick Use Cases — aws s3 ls example](<assets/Screenshot%20(136).png>)

The CLI shines for quick operational tasks:

| Command                       | What it does                          |
| :---------------------------- | :------------------------------------ |
| `aws s3 ls`                   | List all S3 buckets                   |
| `aws ec2 describe-instances`  | List all EC2 instances                |
| `aws ec2 run-instances ...`   | Launch a new EC2 instance             |
| `aws ec2 terminate-instances` | Terminate instances                   |
| `aws ce get-cost-and-usage`   | Pull billing/cost data                |
| `aws configure`               | Set up credentials and default region |

---

## 🛠️ Section 2: Installing the AWS CLI

### Official Documentation

![AWS CLI Install Docs — Windows MSI Installer](<assets/Screenshot%20(142).png>)

The AWS CLI v2 is installed differently per OS. For **Windows**:

**Requirements:**

- 64-bit Microsoft-supported Windows version
- Admin rights to install software

**Installation steps:**

1. Download the MSI installer from the official AWS docs:
   ```
   https://awscli.amazonaws.com/AWSCLIV2.msi
   ```
2. Run the installer, or use `msiexec` from Command Prompt:
   ```
   C:\> msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
   ```
3. Verify installation:
   ```bash
   aws --version
   # aws-cli/2.x.x Python/3.x.x Windows/...
   ```

For **Linux/Ubuntu**:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

For **macOS**:

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

---

## 🔑 Section 3: Configuring the AWS CLI

### Step 1 — Create Access Keys in IAM

![IAM Security Credentials — Access Keys](<assets/Screenshot%20(141).png>)

Before running `aws configure`, you need an **Access Key ID** and **Secret Access Key**. Navigate to:

**IAM → Security credentials → Access keys → Create access key**

The console shows:

- **MFA**: Virtual MFA device assigned (`arn:aws:iam::248189914762:mfa/Authapp`) — best practice
- **Access keys (2)**: Both active, last used 4 days ago in `us-east-1`
  - `AKIATTSKFR2FBV56326R` — Active, last used 4 days ago
  - `AKIATTSKFR2FIKVPM6UU` — Active, last used 47 days ago

> ⚠️ **Security Best Practice:** You can have a maximum of 2 access keys per IAM user. Always rotate keys regularly, never commit them to code, and delete keys that are no longer in use. Use IAM roles instead of access keys wherever possible (e.g., on EC2 instances).

---

### Step 2 — Run `aws configure`

![aws configure Command Being Run](<assets/Screenshot%20(140).png>)

Once you have your credentials, configure the CLI:

```bash
aws configure
```

The CLI prompts for 4 values:

```
AWS Access Key ID [****************PZWF]: <your-access-key-id>
AWS Secret Access Key [****************BnKv]: <your-secret-access-key>
Default region name [us-east-1]: us-east-1
Default output format [json]: json
```

This stores your credentials in `~/.aws/credentials` and your config in `~/.aws/config`. These files are read automatically by every subsequent `aws` command.

> **Never share your Secret Access Key.** Once you close the key creation dialog in the AWS Console, you cannot view the secret key again — store it securely immediately.

---

## 🚀 Section 4: Shell Script — EC2 Lab Automator

With the CLI configured, the real power comes from **Bash scripting** — combining multiple CLI commands into a fully automated workflow. Today I wrote `launch-ec2-instance.sh`, a clean, production-grade script that automates the complete DevOps lab lifecycle.

### Script Overview

The script has **5 sections**:

1. **Configuration** — define all variables in one place
2. **Launch** — dynamically find the latest Ubuntu AMI and launch EC2
3. **Smart-Wait** — poll until the instance has a public IP
4. **Termination** — clean up all resources with one keystroke
5. **Billing Report** — pull and format AWS cost data for the session

---

### Section 1 & 2 — Configuration & AMI Discovery

![Script Part 1 — Config, Security Group, AMI Fetch](<assets/Screenshot%20(138).png>)

```bash
#!/bin/bash
########################################################
# Author: Soham Sarkar
# Purpose: Everyday DevOps Lab Automator (Clean & Readable)
########################################################

set -e

# --- 1. CONFIGURATION ---
REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
KEY_NAME="linux-for-devops-key"
SUBNET_ID="subnet-0d98cba5e69bd6e68"

echo "🔍 Fetching Security Group..."
SEC_GROUP=$(aws ec2 describe-security-groups \
  --region $REGION \
  --filters "Name=group-name,Values=default" \
  --query "SecurityGroups[0].GroupId" \
  --output text)

echo "🔍 Finding Latest Ubuntu 22.04 AMI..."
AMI_ID=$(aws ec2 describe-images \
  --region $REGION \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd*/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
```

**What's happening here:**

- `set -e` — exit immediately if any command fails (safety net)
- All config variables are defined at the top — easy to change for different labs
- **Security Group** is fetched dynamically using `describe-security-groups` instead of hardcoding the SG ID
- **AMI ID** is fetched dynamically using `describe-images` with owner `099720109477` (Canonical/Ubuntu's AWS account) — this always gets the **latest** Ubuntu 22.04 image, so the script never becomes stale

---

### Section 2 — EC2 Launch with Auto-Naming

![Script Part 2 — Launch, Smart-Wait for IP, SSH Command](<assets/Screenshot%20(139).png>)

```bash
# --- 2. LAUNCH ---
INSTANCE_NAME="DevOps-Lab-$(date +%Y%m%d-%H%M)"  # e.g. DevOps-Lab-20260328-1945

echo "🚀 Launching Instance '$INSTANCE_NAME' in $REGION..."
INSTANCE_ID=$(aws ec2 run-instances \
  --region $REGION \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SEC_GROUP \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true}}]' \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "✅ Instance $INSTANCE_ID ($INSTANCE_NAME) is live."

# --- 3. SMART-WAIT FOR IP ---
PUBLIC_IP="None"
echo "⏳ Waiting for Public IP assignment..."
while [ "$PUBLIC_IP" == "None" ] || [ -z "$PUBLIC_IP" ]; do
  sleep 5
  PUBLIC_IP=$(aws ec2 describe-instances \
    --region $REGION \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
  echo "   ...still waiting..."
done

echo "------------------------------------------------"
echo "🌐 SUCCESS! Connect to your lab here:"
echo "ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo "------------------------------------------------"
```

**Key design decisions:**

- `INSTANCE_NAME` uses `date +%Y%m%d-%H%M` to generate a **unique name** for every run (e.g., `DevOps-Lab-20260504-1754`) — no naming conflicts
- `--associate-public-ip-address` ensures the instance gets a public IP automatically
- `--block-device-mappings` with `DeleteOnTermination:true` ensures the EBS volume is automatically cleaned up when the instance terminates — no orphaned volumes
- `--tag-specifications` tags the instance with the generated name — visible in the console
- The **smart-wait loop** polls every 5 seconds until the public IP is assigned — avoids trying to SSH into an instance that isn't ready yet

---

### Section 3 — Termination & Billing Report

![Script Part 3 — Termination and Billing Report](<assets/Screenshot%20(140).png>)

```bash
# --- 4. TERMINATION ---
read -p "🔴 Press [Enter] to TERMINATE resources..."

echo "🧹 Cleaning up $REGION..."
# Redirecting JSON to /dev/null for a clean terminal
aws ec2 terminate-instances \
  --region $REGION \
  --instance-ids $INSTANCE_ID \
  --output text > /dev/null

echo "⏳ Waiting for termination to complete..."
aws ec2 wait instance-terminated \
  --region $REGION \
  --instance-ids $INSTANCE_ID
echo "✅ All resources deleted successfully."

# --- 5. HUMAN-READABLE BILLING REPORT ---
echo "------------------------------------------------"
echo "💰 --- AWS BILLING REPORT ---"
echo "------------------------------------------------"

START_DATE=$(date +%Y-%m-01)
END_DATE=$(date +%Y-%m-%d)

RAW_COST=$(aws ce get-cost-and-usage \
  --region us-east-1 \
  --time-period Start=$START_DATE,End=$END_DATE \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --query 'ResultsByTime[0].Total.UnblendedCost.Amount' \
  --output text)

# Rounding to 2 decimal places
FORMATTED_COST=$(printf "%.2f" $RAW_COST)

echo "📅 Period: $START_DATE to $END_DATE"
echo "💵 Total Accrued: \$$FORMATTED_COST USD"
# Standard INR conversion for quick reference
echo "🇮🇳 Approx in INR: ₹$(awk "BEGIN {print $FORMATTED_COST * 83.00}")"
echo "------------------------------------------------"
echo "🎓 Lab Session Complete! Ready for the next task."
```

**What makes this script production-grade:**

- `read -p` — interactive pause before termination prevents accidental deletion
- `--output text > /dev/null` — suppresses noisy JSON output from the terminate command for a clean terminal experience
- `aws ec2 wait instance-terminated` — the script **blocks and waits** until AWS confirms the instance is fully terminated before proceeding — no partial cleanup
- **Billing report** uses `aws ce get-cost-and-usage` (AWS Cost Explorer API) to pull the month-to-date spend
- `printf "%.2f"` rounds the raw float to 2 decimal places
- INR conversion using `awk` for a quick rupee estimate alongside the USD amount

---

## 🏗️ Architecture: What the Script Automates

```
Developer runs: bash launch-ec2-instance.sh
        │
        ▼
[1] CONFIGURATION
    ├── Region: us-east-1
    ├── Instance: t2.micro
    └── Key: linux-for-devops-key
        │
        ▼
[2] DYNAMIC DISCOVERY (AWS CLI API calls)
    ├── describe-security-groups → SEC_GROUP
    └── describe-images (Ubuntu 22.04) → AMI_ID
        │
        ▼
[3] LAUNCH (aws ec2 run-instances)
    ├── Auto-named: DevOps-Lab-YYYYMMDD-HHMM
    ├── Public IP: auto-assigned
    ├── EBS: auto-delete on termination
    └── INSTANCE_ID captured
        │
        ▼
[4] SMART-WAIT LOOP
    └── Poll every 5s until PUBLIC_IP assigned
        │
        ▼
[5] OUTPUT
    └── ssh -i linux-for-devops-key.pem ubuntu@<PUBLIC_IP>
        │
        ▼ (user presses Enter)
[6] TERMINATION
    ├── terminate-instances
    └── wait instance-terminated (blocks until done)
        │
        ▼
[7] BILLING REPORT
    ├── aws ce get-cost-and-usage (MTD)
    ├── Format: $X.XX USD
    └── Convert: ₹XXX INR
```

---

## 📚 Key Takeaways from Day 58

**About the AWS CLI:**

- The CLI is a Python application — every command becomes an HTTP API call to AWS.
- The Console, CLI, Terraform, CFT, and CDK all call the same AWS API — they are different interfaces to the same backend.
- `aws configure` stores credentials in `~/.aws/credentials` — never hardcode credentials in scripts.
- Always use `--query` to extract specific fields from JSON output — avoid piping through `jq` when the CLI can do it natively.

**About Bash Automation:**

- `set -e` is a safety net — always include it in production scripts to prevent cascading failures.
- Fetch dynamic values (AMI IDs, Security Group IDs) at runtime instead of hardcoding — scripts stay valid across regions and over time.
- Use `aws ec2 wait` commands for synchronous behavior — they block until the expected state is reached, eliminating brittle `sleep` timers.
- Use `--output text > /dev/null` to suppress unwanted JSON output for cleaner terminal UX.
- Tag all resources with meaningful names using `--tag-specifications` — makes cost attribution and cleanup much easier.

**About IAM & Security:**

- Access keys should be rotated regularly and deleted when not in use.
- Maximum of 2 access keys per IAM user — keep one active, one for rotation.
- Use IAM roles (not access keys) for EC2 instances and Lambda functions — avoid storing credentials on compute resources.
- Enable MFA on all IAM users with console access.

---
