![Progress](https://img.shields.io/badge/Progress-64%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Serverless](https://img.shields.io/badge/Compute-Serverless-4EAA25?style=for-the-badge)
![SNS](https://img.shields.io/badge/AWS-CloudWatch_Logs-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

# Day 64 - AWS Lambda: Serverless Compute — Concepts & First Function

## Overview

On Day 64, I explored **AWS Lambda** — AWS's serverless compute service. The day began with conceptual notes comparing Lambda to EC2, understanding the event-driven execution model, cost implications, and real-world use cases. It concluded with creating a first Lambda function (`demoLamda`) in Python 3.14, exploring the console in depth, exposing it via a public Function URL, and verifying it live in the browser.

**Result: `"Hello from Lambda!"` served live from a public Lambda Function URL ✅**

---

## Concept Notes

### Lambda vs EC2 — Two Compute Models

```
                EC2 (Server)                    Lambda (Serverless)
                ─────────────                   ───────────────────
Model:          Virtual Machine                 Function-as-a-Service
Managed by:     You (OS, patches, scaling)      AWS (fully managed)
Billing:        Per hour (running or idle)      Per invocation + duration
Scaling:        Manual / Auto Scaling Group     Automatic, hosted
IP Address:     Static (Elastic IP)             No fixed IP
Use case:       Long-running workloads          Event-driven, short tasks
                Food delivery backend           Notification on new order
```

![Lambda vs EC2 concept diagram](<assets/Screenshot%20(257).png>)

### What is "Serverless"?

Serverless does NOT mean "no servers" — it means **you don't manage the servers**. AWS provisions, patches, scales, and terminates the compute infrastructure automatically. You only write and deploy the function code.

```
Request ──► Lambda ──► Your code runs ──► Response
                        (AWS manages everything underneath)
```

The key characteristics:

- **Event-driven** — Lambda only runs when triggered (HTTP request, S3 upload, CloudWatch alarm, schedule, etc.)
- **Stateless** — Each invocation is independent; no persistent in-memory state between calls
- **Auto-scaling** — AWS automatically handles concurrent invocations; no capacity planning needed
- **Pay per use** — Billed only for the milliseconds your code runs + number of invocations

![Serverless vs Server model](<assets/Screenshot%20(258).png>)

![Serverless detail — EC2 pay-as-you-go vs Lambda, scale up/down](<assets/Screenshot%20(259).png>)

### Lambda vs EC2 — Side-by-Side Comparison

| Dimension         | Lambda (Serverless)              | EC2 (Server)                                |
| ----------------- | -------------------------------- | ------------------------------------------- |
| Server management | ❌ Not needed                    | ✅ Required                                 |
| IP address        | None (no fixed IP)               | Static / Elastic IP                         |
| Scaling           | Hosted auto-scaling              | Manual or ASG                               |
| Cost model        | Per invocation                   | Per hour                                    |
| Best for          | Event-driven tasks, short bursts | Persistent workloads, food delivery backend |
| Example           | Notification on order placed     | Always-on API server                        |

![Lambda vs EC2 comparison with cost axis](<assets/Screenshot%20(260).png>)

### Real-World Lambda Use Cases

**Event-driven architecture:**

- Triggered at 10am daily (CloudWatch Events / EventBridge) → Lambda runs → sends report
- S3 file uploaded → Lambda triggered → processes/transforms the file
- New order in food delivery app → Lambda → sends push notification

**Cost optimization:**

- Lambda triggered by CloudWatch alarm → deletes idle EC2 instances after 30 days of low usage
- EBS volume not attached → Lambda sends delete notification to organization

**Scaling:**

- Traffic increases → Lambda automatically scales to handle more invocations (8 → 16 → ...)
- Traffic drops → Lambda scales down to zero; no idle cost

**Organisation / Governance:**

- Triggered by EventBridge (10am) → Lambda scans account → sends compliance notification

![Lambda event-driven and cost optimization use cases](<assets/Screenshot%20(261).png>)

![EBS lifecycle, Lambda triggers, organisation use cases](<assets/Screenshot%20(262).png>)

### Lambda Execution Model

```
Event Source (HTTP / S3 / CloudWatch / EventBridge / SQS)
        │
        ▼
    Lambda Trigger
        │
        ▼
  Execution Environment (AWS managed container)
        │
        ├── Runtime: Python 3.14 / Node.js / Java / Ruby / .NET
        ├── Handler function called with (event, context)
        ├── Max execution: 15 minutes
        └── Memory: 128 MB – 10 GB
        │
        ▼
    Response / Destination / CloudWatch Logs
```

---

## Steps Performed

### Step 1 — Navigate to Lambda Console

Search for **Lambda** in the AWS console.

Lambda is listed under **Compute** — alongside EC2. The console landing page confirms: _"Run code without managing servers. Focus on your application, not your infrastructure. Lambda automatically provisions, scales, and monitors while you build."_

Supported runtimes shown: .NET, Java, **Node.js**, **Python**, Ruby, Custom runtime.

![AWS console Lambda search](<assets/Screenshot%20(263).png>)

![Lambda console landing page](<assets/Screenshot%20(264).png>)

---

### Step 2 — Create the Function

Navigate to **Lambda → Functions → Create function → Author from scratch**.

| Setting               | Value                                                |
| --------------------- | ---------------------------------------------------- |
| Function name         | `demoLamda`                                          |
| Runtime               | **Python 3.14**                                      |
| Permissions           | Auto-created execution role (CloudWatch Logs access) |
| Function URL          | ✅ Enabled (Auth type: **NONE** — public)            |
| Durable execution     | Off                                                  |
| EC2 capacity provider | Off                                                  |

**Function URL Auth Types:**

- **AWS_IAM** — Only authenticated IAM users/roles can invoke. Suitable for internal use.
- **NONE** — Anyone with the URL can invoke the function. AWS auto-attaches a resource-based policy making it public. Suitable for public APIs/webhooks.

> For this demo, **NONE** was selected — the function is publicly accessible via its URL.

![Create function - basic info, Python 3.14](<assets/Screenshot%20(265).png>)

![Function URL config - auth type NONE, resource policy shown](<assets/Screenshot%20(266).png>)

**Function created successfully:**

> ✅ **Successfully created the function "demoLamda".**

| Property     | Value                                                                   |
| ------------ | ----------------------------------------------------------------------- |
| Function ARN | `arn:aws:lambda:us-east-1:248189914762:function:demoLamda`              |
| Runtime      | Python 3.14                                                             |
| Layers       | 0                                                                       |
| Function URL | `https://zh2eir5ynadqltw6ecoumzdage0xhdge.lambda-url.us-east-1.on.aws/` |

![demoLamda created - function overview with ARN and URL](<assets/Screenshot%20(267).png>)

---

### Step 3 — Explore the Code Editor

The Lambda inline editor shows `lambda_function.py` with the default handler:

```python
import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
```

**Handler anatomy:**

- `event` — The input data passed to the function (JSON from the trigger — HTTP request body, S3 event, etc.)
- `context` — Runtime metadata (function name, memory limit, request ID, remaining time)
- Return value — For Function URL invocations, must include `statusCode` and `body`

![Lambda code editor - lambda_function.py](<assets/Screenshot%20(268).png>)

---

### Step 4 — Explore the Configuration Tabs

Navigate through **Configuration** to understand what's available:

**Triggers (0)**

No triggers configured yet. Triggers are event sources that invoke the function: API Gateway, S3, SQS, EventBridge, CloudWatch Logs, DynamoDB Streams, etc.

![Triggers tab - no triggers](<assets/Screenshot%20(269).png>)

**Permissions**

Auto-created execution role: `demoLamda-role-lxmb6rz1`

Resource summary (CloudWatch Logs — 3 actions, 2 resources):

| Resource                                                                | Actions                                     |
| ----------------------------------------------------------------------- | ------------------------------------------- |
| `arn:aws:logs:us-east-1:248189914762:*`                                 | `logs:CreateLogGroup`                       |
| `arn:aws:logs:us-east-1:248189914762:log-group:/aws/lambda/demoLamda:*` | `logs:CreateLogStream`, `logs:PutLogEvents` |

This is the **minimum permissions** Lambda needs by default — just enough to write its own execution logs to CloudWatch. No other AWS service access is granted unless explicitly added.

![Permissions - execution role and CloudWatch Logs resource summary](<assets/Screenshot%20(270).png>)

**Destinations (0)**

Destinations route async invocation results (success/failure) to another AWS service — SNS, SQS, EventBridge, or another Lambda. Not configured for this demo.

![Destinations tab - none configured](<assets/Screenshot%20(271).png>)

**Function URL**

| Property    | Value                                                                   |
| ----------- | ----------------------------------------------------------------------- |
| URL         | `https://zh2eir5ynadqltw6ecoumzdage0xhdge.lambda-url.us-east-1.on.aws/` |
| Auth type   | NONE (public)                                                           |
| Invoke mode | BUFFERED                                                                |
| CORS        | Not enabled                                                             |

The URL is a permanent HTTPS endpoint — no API Gateway needed. Any HTTP GET/POST to this URL invokes the Lambda function.

![Function URL config tab](<assets/Screenshot%20(272).png>)

**Environment Variables (0)**

No environment variables set. In production, environment variables store configuration values (API keys, DB endpoints, feature flags) without hardcoding them in the function code.

![Environment variables - none set](<assets/Screenshot%20(273).png>)

---

### Step 5 — Invoke the Function via URL

Open the Function URL in the browser:

```
https://zh2eir5ynadqltw6ecoumzdage0xhdge.lambda-url.us-east-1.on.aws/
```

**Response:**

```json
"Hello from Lambda!"
```

The browser displays the JSON response from the Lambda function — proof that the serverless function is live, publicly accessible, and executing correctly without any server management.

![Live Function URL response in browser](<assets/Screenshot%20(274).png>)

---

## Lambda Function Anatomy

```python
import json

def lambda_handler(event, context):
    """
    event   : dict  — Input from the trigger (HTTP body, S3 event, etc.)
    context : obj   — Runtime info (function_name, memory_limit_in_mb,
                      aws_request_id, get_remaining_time_in_millis())
    """
    return {
        'statusCode': 200,                      # HTTP status code
        'body': json.dumps('Hello from Lambda!')  # Response body (must be string)
    }
```

---

## Lambda Console Tabs — Summary

| Tab               | Purpose                                                      |
| ----------------- | ------------------------------------------------------------ |
| **Code**          | Write, edit, and deploy function code inline                 |
| **Test**          | Create test events and invoke the function manually          |
| **Monitor**       | CloudWatch metrics and logs for invocations                  |
| **Configuration** | Triggers, permissions, URL, env vars, VPC, concurrency       |
| **Aliases**       | Named pointers to specific versions (e.g. `prod`, `staging`) |
| **Versions**      | Immutable snapshots of the function at a point in time       |

---

## Key Concepts Covered

### Cold Start vs Warm Start

When Lambda receives the first invocation after a period of inactivity, it must provision a new execution environment — downloading the runtime, initializing the function package. This is a **cold start** and adds latency (typically 100ms–1s). Subsequent invocations reuse the existing environment (**warm start**) and are much faster.

### Execution Role — Least Privilege by Default

Lambda's auto-created role only grants CloudWatch Logs write access. To call other AWS services (S3, DynamoDB, SNS, EC2), you must explicitly attach the relevant policies to the execution role. This enforces **least privilege** by default.

### Function URL vs API Gateway

|          | Function URL                       | API Gateway                          |
| -------- | ---------------------------------- | ------------------------------------ |
| Setup    | Zero config — enabled at creation  | Requires separate setup              |
| Cost     | Free (Lambda invocation cost only) | Additional per-request charge        |
| Features | Simple HTTPS endpoint              | Routing, auth, rate limiting, stages |
| Best for | Simple webhooks, demos             | Production APIs with complex routing |

### Stateless Execution

Lambda functions are stateless — each invocation starts fresh. To persist data between invocations, use DynamoDB, S3, ElastiCache, or pass state through the event payload.

---

## Function Summary

| Property       | Value                                                                   |
| -------------- | ----------------------------------------------------------------------- |
| Function name  | `demoLamda`                                                             |
| Runtime        | Python 3.14                                                             |
| ARN            | `arn:aws:lambda:us-east-1:248189914762:function:demoLamda`              |
| Function URL   | `https://zh2eir5ynadqltw6ecoumzdage0xhdge.lambda-url.us-east-1.on.aws/` |
| Auth type      | NONE (public)                                                           |
| Execution role | `demoLamda-role-lxmb6rz1`                                               |
| Permissions    | CloudWatch Logs only (CreateLogGroup, CreateLogStream, PutLogEvents)    |
| Triggers       | None                                                                    |
| Response       | `"Hello from Lambda!"`                                                  |

---

## AWS Services Used

| Service                | Purpose                                         |
| ---------------------- | ----------------------------------------------- |
| AWS Lambda             | Serverless function execution                   |
| Amazon CloudWatch Logs | Automatic invocation logging via execution role |
| Lambda Function URL    | Public HTTPS endpoint to invoke the function    |

---

## Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Lambda Function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)
- [Lambda Execution Role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- [Lambda vs EC2](https://aws.amazon.com/lambda/faqs/)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
