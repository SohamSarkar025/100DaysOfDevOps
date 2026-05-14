![Progress](https://img.shields.io/badge/Progress-63%25-brightgreen?style=for-the-badge&logo=amazonaws)
![CloudWatch](https://img.shields.io/badge/AWS-CloudWatch-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![SNS](https://img.shields.io/badge/AWS-SNS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Monitoring](https://img.shields.io/badge/Observability-Monitoring_%26_Alerting-4EAA25?style=for-the-badge)

# Day 63 - AWS CloudWatch: Metrics, CPU Spike Lab & Alarm End-to-End

## Overview

On Day 63, I explored **AWS CloudWatch** — the observability backbone of AWS. The day covered CloudWatch's core capabilities conceptually, then applied them end-to-end: browsing EC2 metrics, enabling detailed monitoring, simulating a CPU spike using a Python script, observing it in CloudWatch, creating an alarm, confirming the SNS email subscription, triggering the alarm for real (CPU hit **98.2%**), and watching it return to **OK** state after the spike.

**Full alarm lifecycle completed: INSUFFICIENT_DATA → IN ALARM (98.2% CPU) → OK ✅**

---

## Concept Notes

### What is CloudWatch?

CloudWatch is AWS's native monitoring and observability service — the "gatekeeper/watchman" of the AWS environment. Every AWS service (EC2, S3, RDS, Lambda, etc.) automatically publishes metrics to CloudWatch.

```
AWS Services (EC2, S3, ...) ──► CloudWatch ──► Gatekeeper / Watchman
                                     │
                              ┌──────┴──────┐
                           SNS (Page)    Gatekeeper
                                         ├── Monitoring  ✓
                                         ├── Alerting    ✓
                                         ├── Reporting   ✓
                                         └── Logging     ✓
```

![CloudWatch concept diagram](<assets/Screenshot%20(229).png>)

### Core CloudWatch Capabilities

**Monitoring** — Real-time visibility into what AWS resources are doing.

**Real-life metrics** — Time-series data points emitted by services. Examples: CPU utilization, network I/O, disk ops. Collected every 5 minutes by default (basic) or every 1 minute with detailed monitoring enabled.

**Alarms** — Rules that watch a metric over time and trigger actions when a threshold is crossed. Example: CPUUtilization ≥ 80% → notify via SNS; CPUUtilization ≥ 90% → trigger Auto Scaling.

**Log Insights** — Query and analyze CloudWatch Logs using a SQL-like syntax.

**Custom Metrics** — Publish application-specific metrics (active users, queue depth, error rates) that aren't natively emitted by AWS.

**Cost Optimization** — Alarms can trigger Lambda functions to automatically shut down idle resources.

**Scaling** — Alarms can trigger Auto Scaling policies (CPU > 80% → scale out).

![CloudWatch capabilities](<assets/Screenshot%20(231).png>)

![Extended concepts](<assets/Screenshot%20(232).png>)

### How Metrics Flow

```
EC2 Instance
    │
    │ (hypervisor-level: CPU, network, disk)
    ▼
CloudWatch API  ◄── Custom metrics via CloudWatch Agent (memory, app metrics)
    │
    ▼
CloudWatch Metrics
    │
    ├── Alarms ──► SNS ──► Email / Lambda / Auto Scaling
    └── Dashboards ──► Visualization
```

> **Note:** Memory utilization is an **OS-level metric** — CloudWatch cannot see it by default. Install the **CloudWatch Agent** on the instance to publish memory as a custom metric under the `CWAgent` namespace.

---

## Steps Performed

### Step 1 — Explore the CloudWatch Console

Navigate to **AWS CloudWatch → Overview**.

No alarms or dashboards exist yet. Key sections: Dashboards, Alarms, Logs, Metrics, Network Monitoring.

Navigate to **CloudWatch → Metrics → All metrics**.

Key namespaces emitting metrics in this account:

| Namespace  | Metrics |
| ---------- | ------- |
| EC2        | 148     |
| EBS        | 75      |
| NATGateway | 32      |
| Logs       | 18      |
| S3         | 2       |
| Usage      | 467     |

![CloudWatch console overview](<assets/Screenshot%20(233).png>)

![All metrics namespaces](<assets/Screenshot%20(234).png>)

---

### Step 2 — SSH into EC2 & Write the CPU Spike Script

SSH into the Ubuntu 22.04 instance (`DevOps-Lab-20260509-1348`, `i-04fbf53315f045e13`, IP `98.92.133.4`):

```bash
ssh -i linux-for-devops-key.pem ubuntu@98.92.133.4
python3 --version  # Python 3.10.12
vim cpu_spike.py
```

![SSH and script creation](<assets/Screenshot%20(235).png>)

```python
import time

def simulate_cpu_spike(duration=30, cpu_percent=80):
    print(f"Simulating CPU spike at {cpu_percent}%...")
    start_time = time.time()

    target_percent = cpu_percent / 100
    total_iterations = int(target_percent * 5_000_000)

    for _ in range(total_iterations):
        result = 0
        for i in range(1, 1001):
            result += i

    elapsed_time = time.time() - start_time
    remaining_time = max(0, duration - elapsed_time)
    time.sleep(remaining_time)

    print("CPU spike simulation completed.")

if __name__ == '__main__':
    simulate_cpu_spike(duration=30, cpu_percent=80)
```

![cpu_spike.py in vim](<assets/Screenshot%20(236).png>)

---

### Step 3 — Enable Detailed Monitoring

Navigate to **EC2 → Instances → i-04fbf53315f045e13 → Monitoring → Manage detailed monitoring**.

Enable **1-minute granularity** so the CPU spike appears in CloudWatch within 1 minute rather than waiting up to 5 minutes.

![Enable detailed monitoring dialog](<assets/Screenshot%20(238).png>)

---

### Step 4 — First CPU Spike Run

Select `CPUUtilization` metric for the instance in CloudWatch Metrics, then run:

```bash
python3 cpu_spike.py
# Simulating CPU spike at 80%...
```

The spike was visible in the EC2 monitoring tab at **37.4%** at 13:55:00 LOCAL.

![CPU spike graph - 37.4%](<assets/Screenshot%20(240).png>)

---

### Step 5 — Create the CloudWatch Alarm

Navigate to **CloudWatch → Alarms → Create alarm**.

**Metric selection:**

Browse: All metrics → EC2 → Per-Instance Metrics → `CPUUtilization` for `DevOps-Lab-20260509-1348`.

The metric selection graph already shows the spike at **49.6%** peak.

![Select metric - namespace browser](<assets/Screenshot%20(242).png>)

![EC2 metric sub-categories](<assets/Screenshot%20(243).png>)

![CPUUtilization selected - instance highlighted](<assets/Screenshot%20(244).png>)

**Alarm condition:**

| Setting        | Value                    |
| -------------- | ------------------------ |
| Threshold type | Static                   |
| Condition      | CPUUtilization **>= 50** |
| Statistic      | Maximum                  |
| Period         | 1 minute                 |

![Alarm condition - >= 50](<assets/Screenshot%20(245).png>)

**Actions:**

| Setting        | Value                              |
| -------------- | ---------------------------------- |
| Trigger state  | In alarm                           |
| SNS topic      | `Default_CloudWatch_Alarms_Topic`  |
| Email endpoint | `sohamsarkarofficial000@gmail.com` |

![SNS notification action](<assets/Screenshot%20(246).png>)

![Available action types](<assets/Screenshot%20(247).png>)

**Alarm details:**

| Setting     | Value                                                |
| ----------- | ---------------------------------------------------- |
| Name        | `Priority: EC2 CPU Utilization Alert`                |
| Description | `Hey Team , The cpu utilization is above threshold.` |

![Alarm name and description](<assets/Screenshot%20(248).png>)

---

### Step 6 — Preview & Create the Alarm

The alarm preview (Step 4 of the wizard) shows:

- **Graph:** The blue CPUUtilization line vs the red threshold line at 50%
- The spike from the first run is visible at **98.2%** — already crossing the threshold
- **Namespace:** AWS/EC2
- **Metric name:** CPUUtilization
- **InstanceId:** `i-04fbf53315f045e13`
- **Instance name:** `DevOps-Lab-20260509-1348`
- **Statistic:** Maximum
- **Period:** 1 minute
- **Condition summary:** "This alarm will trigger when the blue line goes above the red line for 1 datapoints within 1 minute"

![Alarm preview - 98.2% CPU spike visible, threshold at 50](<assets/Screenshot%20(250).png>)

![Final alarm summary before creation](<assets/Screenshot%20(251).png>)

Click **Create alarm**.

**Result: ✅ Successfully created alarm "Priority: EC2 CPU Utilization Alert"**

The alarm immediately shows:

- State: **Insufficient data** (waiting for the first evaluation)
- Actions: **enabled** with a Warning that SNS subscriptions are pending confirmation

![Alarm created - insufficient data state, pending SNS confirmation](<assets/Screenshot%20(252).png>)

---

### Step 7 — Confirm the SNS Email Subscription

After creating the alarm, AWS SNS sent a subscription confirmation email to `sohamsarkarofficial000@gmail.com`. Clicking the confirmation link:

> **Subscription confirmed!**
> You have successfully subscribed.
> Subscription ARN: `arn:aws:sns:us-east-1:248189914762:Default_CloudWatch_Alarms_Topic:347ef1bd-8fcf-4c63-81c0-f0615ad2426a`

![SNS subscription confirmed page](<assets/Screenshot%20(255).png>)

In the SNS console, the subscription is now visible as **Confirmed**:

| Endpoint                           | Status       | Protocol |
| ---------------------------------- | ------------ | -------- |
| `sohamsarkarofficial000@gmail.com` | ✅ Confirmed | EMAIL    |

![SNS topic subscriptions - confirmed](<assets/Screenshot%20(256).png>)

> **Why confirmation is required:** SNS uses a double opt-in model for email subscriptions to prevent spam. Until the recipient clicks "Confirm subscription" in the email, no alarm notifications are delivered. This is the step the console warned about ("Some subscriptions are pending confirmation").

---

### Step 8 — Second CPU Spike: Alarm Fires at 98.2%

SSH back into the instance and run the script again:

```bash
python3 cpu_spike.py
# Simulating CPU spike at 80%...
```

![Second CPU spike run](<assets/Screenshot%20(253).png>)

This time the CPU hit **98.241%** at 14:26:00 LOCAL — well above the 50% threshold.

The alarm view shows:

- **Alarm state:** ✅ OK (spike has passed by the time the screenshot was taken)
- **Peak:** 98.241637361% at 14:26:00
- **Threshold line:** clearly visible at 50.7%
- The spike crossed the threshold band (shown in the grey highlight on the timeline)

The alarm correctly evaluated the breach and sent the email notification to the confirmed SNS endpoint.

![Alarm detail - spike at 98.2%, now back to OK](<assets/Screenshot%20(254).png>)

---

## Full Alarm Lifecycle

```
Alarm created
    │
    ▼
INSUFFICIENT_DATA  ← Not enough 1-min data points yet
    │
    │ (cpu_spike.py run again → CPU hits 98.2%)
    ▼
IN ALARM  ← CPUUtilization >= 50 for 1 datapoint in 1 minute
    │       SNS email sent to sohamsarkarofficial000@gmail.com
    │
    │ (spike ends, CPU returns to baseline ~3%)
    ▼
OK ✅  ← Metric back below threshold
```

---

## Key Concepts Covered

### Basic vs Detailed Monitoring

|                      | Basic             | Detailed          |
| -------------------- | ----------------- | ----------------- |
| Granularity          | 5-minute          | 1-minute          |
| Cost                 | Free              | Additional charge |
| Alarm responsiveness | Up to 5 min delay | ~1 min delay      |

### CloudWatch Alarm States

| State                 | Meaning                            |
| --------------------- | ---------------------------------- |
| **OK**                | Metric is within threshold         |
| **IN ALARM**          | Metric has breached the threshold  |
| **INSUFFICIENT_DATA** | Not enough data points to evaluate |

### Static vs Anomaly Detection

- **Static** — A fixed numeric value (≥ 50). Simple, predictable.
- **Anomaly detection** — ML-based band that adapts to normal patterns (e.g., higher CPU on weekday mornings is expected). Alarm fires only when behavior is genuinely abnormal.

### SNS Double Opt-In

SNS email subscriptions require confirmation before delivery. The flow is: alarm created → SNS sends confirmation email → recipient clicks link → subscription confirmed → future alarms deliver. Skipping this step means alarms fire silently.

### Why the Spike Hit 98% Instead of 80%

On a **t2.micro** (1 vCPU), the arithmetic loop runs on a single thread. With no other work competing for the CPU, the loop can consume the entire vCPU, resulting in utilization higher than the 80% target. The script's iteration-based approach doesn't precisely cap CPU — it just creates load proportional to the iteration count. On multi-core instances the observed utilization would be lower.

---

## Alarm Configuration Summary

| Property          | Value                                                |
| ----------------- | ---------------------------------------------------- |
| Alarm name        | `Priority: EC2 CPU Utilization Alert`                |
| Namespace         | `AWS/EC2`                                            |
| Metric            | `CPUUtilization`                                     |
| Instance          | `DevOps-Lab-20260509-1348` (`i-04fbf53315f045e13`)   |
| Statistic         | Maximum                                              |
| Period            | 1 minute                                             |
| Condition         | CPUUtilization **>= 50**                             |
| Threshold type    | Static                                               |
| Action on ALARM   | SNS → `Default_CloudWatch_Alarms_Topic` → Email      |
| SNS subscription  | `sohamsarkarofficial000@gmail.com` ✅ Confirmed      |
| Description       | "Hey Team , The cpu utilization is above threshold." |
| Peak CPU observed | **98.241%** at 2026-05-09 14:26:00                   |
| Final state       | ✅ **OK**                                            |

---

## AWS Services Used

| Service        | Purpose                                        |
| -------------- | ---------------------------------------------- |
| AWS CloudWatch | Metrics collection, alarm evaluation, graphing |
| AWS EC2        | Target instance (Ubuntu 22.04, t2.micro)       |
| AWS SNS        | Email notification delivery on alarm           |
| Python 3.10    | CPU spike simulation script                    |

---

## Resources

- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [EC2 Metrics Available in CloudWatch](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html)
- [Enable Detailed Monitoring for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html)
- [Creating CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)
- [Amazon SNS Email Subscriptions](https://docs.aws.amazon.com/sns/latest/dg/sns-email-notifications.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
