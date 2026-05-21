![Progress](https://img.shields.io/badge/Progress-70%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Config](https://img.shields.io/badge/AWS-Config-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)

# Day 70 - AWS Config + Lambda: Custom Compliance Rule for EC2 Monitoring

## Overview

On Day 70, I built a **custom AWS Config compliance rule** powered by an **AWS Lambda function** written in Python. The rule (`test-demo-ec2`) automatically evaluates whether EC2 instances have **Detailed CloudWatch Monitoring enabled** — and flags them as **Noncompliant** if they don't. AWS Config detected a real EC2 instance (`i-0650d00fe3c6c47d0`) with monitoring disabled and correctly reported it as `Noncompliant`.

**Result: Custom Config rule triggered → EC2 instance flagged as Noncompliant for missing Detailed CloudWatch Monitoring ✅**

---

## Concept Notes

### AWS Config — What It Does

AWS Config is a **continuous configuration monitoring and compliance service**. It records the state of your AWS resources over time and evaluates them against **rules** (compliance checks). When a resource drifts from its desired state, Config flags it.

```
AWS Resource Changes
        │
        ▼
AWS Config Recorder ──► Records configuration snapshots
        │
        ▼
Config Rule (test-demo-ec2)
        │
        ▼
Lambda Function invoked ──► Evaluates compliance logic
        │
        ├── COMPLIANT      → Resource meets the rule
        ├── NON_COMPLIANT  → Resource violates the rule
        └── NOT_APPLICABLE → Resource type doesn't apply
```

### Lambda as a Config Rule Evaluator

A **Custom Lambda Config rule** lets you write any compliance logic in code. AWS Config invokes your Lambda with a JSON payload containing the resource's current configuration. Your Lambda returns a compliance verdict back to Config.

```
Config detects change
      │
      ▼
Invokes Lambda (test-config-lamda-function)
      │  event['invokingEvent'] → JSON with configurationItem
      │
      ▼
Lambda extracts:
  - resourceType  → AWS::EC2::Instance
  - resourceId    → instance ID
  - configuration → monitoring.state
      │
      ▼
Returns: COMPLIANT / NON_COMPLIANT / NOT_APPLICABLE
```

### Evaluation Modes

| Mode          | When it runs                                  |
| ------------- | --------------------------------------------- |
| **Detective** | After a resource has been provisioned/changed |
| **Proactive** | Before a resource is provisioned              |

Day 70 uses **Detective** mode — evaluating resources that already exist.

### Trigger Types

| Trigger                        | Description                                                     |
| ------------------------------ | --------------------------------------------------------------- |
| **When configuration changes** | Fires when any tracked resource is created, updated, or deleted |
| **Periodic**                   | Fires on a fixed schedule you define                            |

---

## Architecture

```
         EC2 Instance (test-instance)
         i-0650d00fe3c6c47d0
         Detailed Monitoring: DISABLED ❌
                  │
                  │ Config detects state
                  ▼
         AWS Config Recorder
         (Specific: AWS EC2 Instance, Continuous)
         S3 Delivery: config-bucket-248189914762
                  │
                  │ Triggers rule evaluation
                  ▼
         Config Rule: test-demo-ec2
         Type: Custom Lambda | Mode: DETECTIVE
         Trigger: When configuration changes
                  │
                  │ Invokes
                  ▼
         Lambda: test-config-lamda-function
         Runtime: Python 3.14 | Timeout: 10s
         Role: test-config-lamda-function-role-dexlusqd
           - AmazonEC2FullAccess
           - AWS_ConfigRole
           - AWSCloudTrail_FullAccess
           - AWSLambdaBasicExecutionRole
           - CloudWatchFullAccess
                  │
                  │ Returns verdict
                  ▼
         Config Result: ⚠️ NONCOMPLIANT
         Annotation: "Detailed CloudWatch Monitoring not enabled"
```

---

## Project File Structure

```
Day70/
├── lambda_function.py   # Compliance evaluation logic (Python)
├── README.md            # This file
└── assets/              # Screenshots
```

---

## Steps Performed

### Step 1 — Navigate to AWS Lambda Console

Navigate to **AWS Lambda** — the landing page shows Lambda's core value: run code without managing servers. Supported runtimes include .NET, Java, Node.js, Python, Ruby, and Custom runtime.

![AWS Lambda landing page - Run code without managing servers, Create a function button, Node.js example](<assets/Screenshot (419).png>)

---

### Step 2 — Create Lambda Function (`test-config-lamda-function`)

Navigate to **Lambda → Functions → Create function**.

**Configuration:**

| Setting       | Value                               |
| ------------- | ----------------------------------- |
| Creation mode | Author from scratch                 |
| Function name | `test-config-lamda-function`        |
| Runtime       | **Python 3.14**                     |
| Permissions   | Create new execution role (default) |

**Creation modes available:**

| Option                     | Description                                          |
| -------------------------- | ---------------------------------------------------- |
| **Author from scratch** ✅ | Start with a Hello World example                     |
| Use a blueprint            | Sample code and config presets for common use cases  |
| Container image            | Select a container image to deploy for your function |

![Create function - test-config-lamda-function, Python 3.14, Author from scratch selected](<assets/Screenshot (420).png>)

---

### Step 3 — Function Created + Execution Role

Lambda created the function and auto-generated an **IAM execution role** (`test-config-lamda-function-role-dexlusqd`).

> ✅ **Successfully created the function "test-config-lamda-function"**. You can now change its code and configuration. To invoke your function with a test event, choose "Test".

The **Permissions** tab shows the execution role and its resource summary — by default it only has **CloudWatch Logs** access (3 actions, 2 resources).

![test-config-lamda-function created - Configuration Permissions tab, execution role, CloudWatch Logs resource summary](<assets/Screenshot (421).png>)

---

### Step 4 — Attach IAM Policies to the Execution Role

Navigate to **IAM → Roles → test-config-lamda-function-role-dexlusqd** and attach the required policies.

> ✅ **Policies have been successfully attached to role.**

**Policies attached (5 total):**

| Policy Name                                | Type             | Purpose                              |
| ------------------------------------------ | ---------------- | ------------------------------------ |
| `AmazonEC2FullAccess`                      | AWS managed      | Describe EC2 instance configurations |
| `AWS_ConfigRole`                           | AWS managed      | Put evaluation results to Config     |
| `AWSCloudTrail_FullAccess`                 | AWS managed      | CloudTrail access for audit          |
| `AWSLambdaBasicExecutionRole-507fe103-...` | Customer managed | Lambda basic execution + CW logs     |
| `CloudWatchFullAccess`                     | AWS managed      | CloudWatch metrics and logs access   |

![IAM role policies - AmazonEC2FullAccess, AWS_ConfigRole, AWSCloudTrail_FullAccess, AWSLambdaBasicExecutionRole, CloudWatchFullAccess attached](<assets/Screenshot (422).png>)

---

### Step 5 — Write the Lambda Function Code

Navigate to **Lambda → test-config-lamda-function → Code** tab. The initial code is replaced with the compliance evaluation logic.

**Initial code (Undeployed state visible in editor):**

![Lambda Code tab - lambda_function.py, import boto3/json, lambda_handler, ec2_client, compliance_status COMPLIANT, Undeployed status](<assets/Screenshot (423).png>)

**Final refined version** (`lambda_function.py` in VS Code — the deployed logic):

![VS Code lambda_function.py - full version with guardrail checks, DEBUG prints, monitoring_state evaluation, compliance logic](<assets/Screenshot (435).png>)

---

### Step 6 — Configure Lambda Timeout

Navigate to **Lambda → test-config-lamda-function → Configuration → Edit basic settings**.

The default timeout (3 seconds) was increased to **10 seconds** to allow enough time for AWS API calls (EC2 describe, Config put-evaluations).

| Setting           | Value                                      |
| ----------------- | ------------------------------------------ |
| Timeout           | **0 min 10 sec**                           |
| Ephemeral storage | 512 MB                                     |
| SnapStart         | None                                       |
| Execution role    | `test-config-lamda-function-role-dexlusqd` |

![Lambda Edit basic settings - Timeout 10 sec, Ephemeral storage 512MB, execution role dexlusqd](<assets/Screenshot (434).png>)

---

### Step 7 — Set Up AWS Config (Step 1: Settings)

Navigate to **AWS Config → Set up AWS Config → Step 1: Settings**.

**Recording strategy — first attempt (All resource types):**

| Setting             | Value                                          |
| ------------------- | ---------------------------------------------- |
| Recording strategy  | All resource types with customizable overrides |
| Recording frequency | **Continuous recording**                       |
| Override            | AWS EC2 Instance → Exclude from recording      |

The first attempt used "All resource types" with an EC2 exclusion override — but this was revised.

![AWS Config Setup Step 1 - All resource types selected, Continuous recording, Override settings section](<assets/Screenshot (424).png>)

![AWS Config - Override settings, AWS EC2 Instance Exclude from recording, Data governance, S3 bucket config-bucket-248189914762](<assets/Screenshot (425).png>)

**Final recording strategy — Specific resource types:**

Switched to **Specific resource types** to record only `AWS EC2 Instance` at Continuous frequency — cleaner and cost-effective for this demo.

| Setting            | Value                       |
| ------------------ | --------------------------- |
| Recording strategy | **Specific resource types** |
| Resource type      | AWS EC2 Instance            |
| Frequency          | Continuous                  |

![AWS Config - Specific resource types selected, AWS EC2 Instance Continuous frequency](<assets/Screenshot (426).png>)

**Delivery channel:**

| Setting                 | Value                                    |
| ----------------------- | ---------------------------------------- |
| IAM role for AWS Config | Create AWS Config service-linked role    |
| S3 Bucket               | Create a bucket                          |
| S3 Bucket name          | `config-bucket-248189914762`             |
| Log path                | `/AWSLogs/248189914762/Config/us-east-1` |
| Amazon SNS topic        | Not configured                           |

![AWS Config delivery channel - S3 bucket config-bucket-248189914762, service-linked role, no SNS](<assets/Screenshot (427).png>)

---

### Step 8 — Add Custom Config Rule

Navigate to **AWS Config → Rules** — no rules exist yet.

![AWS Config Rules page - No rules found, Add rule button](<assets/Screenshot (428).png>)

Click **Add rule → Specify rule type**.

**Rule type options:**

| Option                           | Description                                                   |
| -------------------------------- | ------------------------------------------------------------- |
| Add AWS managed rule             | Predefined managed rules (e.g. ec2-instance-managed-by-ssm)   |
| **Create custom Lambda rule** ✅ | Use a Lambda function with custom code to evaluate compliance |
| Create custom rule using Guard   | Use Guard Custom policy for evaluation                        |

**Create custom Lambda rule** was selected — this links the Config rule to the Lambda function written in Step 5.

![Add rule - Specify rule type, Create custom Lambda rule selected](<assets/Screenshot (429).png>)

---

### Step 9 — Configure the Rule (`test-demo-ec2`)

Navigate to **Step 2: Configure rule**.

**Rule details:**

| Setting                 | Value                                                                       |
| ----------------------- | --------------------------------------------------------------------------- |
| Name                    | `test-demo-ec2`                                                             |
| AWS Lambda function ARN | `arn:aws:lambda:us-east-1:248189914762:function:test-config-lamda-function` |

![Configure rule - name test-demo-ec2, Lambda ARN arn:aws:lambda:us-east-1:248189914762:function:test-config-lamda-function](<assets/Screenshot (430).png>)

**Evaluation mode and trigger:**

| Setting                  | Value                                               |
| ------------------------ | --------------------------------------------------- |
| Proactive evaluation     | Off                                                 |
| **Detective evaluation** | ✅ On — evaluates resources already provisioned     |
| Trigger type             | **When configuration changes**                      |
| Scope of changes         | **All changes** — any resource create/change/delete |

![Evaluation mode - Detective ON, When configuration changes trigger, All changes scope](<assets/Screenshot (431).png>)

---

### Step 10 — Create Test EC2 Instance

A test EC2 instance (`test-instance`) was launched to be evaluated by the Config rule.

- **Instance ID:** `i-0650d00fe3c6c47d0`
- **Detailed monitoring:** Disabled (default)

The **Detailed monitoring** dialog was opened to confirm the current state — monitoring was **not enabled**, meaning the instance would be flagged as **Noncompliant**.

> ℹ️ After you enable detailed monitoring, the Amazon EC2 console displays monitoring graphs with a 1-minute period for the instance. **Additional charges apply.**

The checkbox was left **unchecked** intentionally to trigger the noncompliant result.

![EC2 instance i-0650d00fe3c6c47d0 (test-instance) - Detailed monitoring dialog, Enable checkbox unchecked](<assets/Screenshot (432).png>)

---

### Step 11 — Config Rule Evaluates → NONCOMPLIANT ✅

Navigate to **AWS Config → Rules → test-demo-ec2**.

**Rule details:**

| Property                             | Value                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------- |
| Config rule ARN                      | `arn:aws:config:us-east-1:248189914762:config-rule/config-rule-pfsfej` |
| Enabled evaluation mode              | **DETECTIVE**                                                          |
| Detective evaluation trigger type    | Oversized configuration changes, Configuration changes                 |
| Last successful detective evaluation | ✅ May 21, 2026 11:01 AM                                               |
| Scope of changes                     | All changes                                                            |

**Resources in scope (filtered: Noncompliant):**

| ID                  | Type         | Status | Annotation                  | Compliance      |
| ------------------- | ------------ | ------ | --------------------------- | --------------- |
| i-0650d00fe3c6c47d0 | EC2 Instance | —      | Detailed CloudWatch Moni... | ⚠️ Noncompliant |

The Lambda function correctly detected that `i-0650d00fe3c6c47d0` does **not** have Detailed CloudWatch Monitoring enabled and returned `NON_COMPLIANT` to AWS Config.

![test-demo-ec2 rule - DETECTIVE mode, last evaluation May 21 11:01 AM, i-0650d00fe3c6c47d0 Noncompliant, Detailed CloudWatch Monitoring annotation](<assets/Screenshot (434).png>)

---

## How the Compliance Check Works

```
Lambda receives event from Config
            │
            ▼
Parse invokingEvent JSON
            │
            ▼
Check resourceType == 'AWS::EC2::Instance'?
    │                           │
   YES                         NO
    │                           │
    ▼                           ▼
Get configuration.monitoring.state    compliance = NOT_APPLICABLE
    │
    ├── state == "enabled"  → COMPLIANT
    └── state != "enabled"  → NON_COMPLIANT
            │
            ▼
config.put_evaluations(result) → Sent back to AWS Config
```

---

## Key Concepts Covered

### AWS Config vs CloudWatch

| Service        | Purpose                                                         |
| -------------- | --------------------------------------------------------------- |
| **AWS Config** | Records _what_ your resources look like (configuration state)   |
| **CloudWatch** | Records _how_ your resources are behaving (metrics/logs/alarms) |

Config answers: "Did this EC2 instance ever have monitoring disabled?"
CloudWatch answers: "What is the CPU utilization of this instance right now?"

### Custom Lambda Rule vs Managed Rule

| Type                 | Flexibility | Setup effort | Best for                            |
| -------------------- | ----------- | ------------ | ----------------------------------- |
| AWS managed rule     | Low         | Low          | Standard compliance checks          |
| **Custom Lambda** ✅ | High        | Medium       | Business-specific compliance logic  |
| Guard Custom policy  | Medium      | Medium       | Policy-as-code with HCL-like syntax |

### `put_evaluations` — The Return Path

The Lambda must call `config.put_evaluations()` to submit results back to AWS Config. Without this call, Config has no verdict and the rule remains unevaluated. The `ResultToken` from the incoming event must be included to correlate the evaluation.

### Why Increase the Lambda Timeout?

The default Lambda timeout is 3 seconds. Config rule Lambdas make multiple AWS API calls (`boto3.client('ec2')`, `config.put_evaluations()`). Network latency + API response time can easily exceed 3 seconds, causing silent failures. **10 seconds** is a safe baseline for compliance functions.

---

## AWS Services Used

| Service           | Purpose                                                              |
| ----------------- | -------------------------------------------------------------------- |
| AWS Lambda        | Runs Python compliance evaluation code (test-config-lamda-function)  |
| AWS Config        | Records EC2 config state, triggers rule, displays compliance results |
| Amazon EC2        | Test instance (i-0650d00fe3c6c47d0) evaluated for monitoring state   |
| Amazon S3         | Config delivery bucket (config-bucket-248189914762)                  |
| AWS IAM           | Execution role with EC2, Config, CloudWatch, CloudTrail permissions  |
| Amazon CloudWatch | Lambda logs streamed here; also the monitoring feature being checked |

---

## Resources

- [AWS Config Custom Lambda Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_develop-rules_lambda-functions.html)
- [AWS Config Developer Guide](https://docs.aws.amazon.com/config/latest/developerguide/)
- [Lambda with AWS Config](https://docs.aws.amazon.com/lambda/latest/dg/services-config.html)
- [put_evaluations API](https://docs.aws.amazon.com/config/latest/APIReference/API_PutEvaluations.html)
- [EC2 Detailed Monitoring](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
