![Progress](https://img.shields.io/badge/Progress-65%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?style=for-the-badge&logo=python&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM-DD344C?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![EBS](https://img.shields.io/badge/AWS-EBS_Snapshots-527FFF?style=for-the-badge&logo=amazonaws&logoColor=white)

# Day 65 - AWS Lambda: Real-World Cost Optimization — Automated EBS Snapshot Cleanup

## Overview

On Day 65, I moved beyond "Hello from Lambda!" into a **real-world Lambda use case**: automated EBS snapshot cost optimization. The day covered launching an EC2 instance with an EBS volume, manually creating an EBS snapshot, building a `cost-optimization` Lambda function in Python that auto-deletes stale snapshots (snapshots whose associated volume no longer exists or is not attached to a running instance), creating and attaching a least-privilege custom IAM policy, and verifying the function live — watching it delete the orphaned snapshot in real time.

**Result: Lambda detected and deleted orphaned EBS snapshot `snap-093f7336088b2959a` — confirmed in execution logs ✅**

---

## Concept Notes

### Why EBS Snapshot Cleanup Matters

EBS snapshots are **incremental point-in-time backups** of EBS volumes. They persist in S3 (AWS-managed) and are billed monthly per GB stored — even after the source volume or EC2 instance is deleted. Over time, forgotten snapshots accumulate and silently drain budget.

```
EC2 Instance deleted ──► EBS Volume deleted ──► Snapshot STILL EXISTS
                                                  └── billed indefinitely ❌
```

A Lambda function triggered on a schedule (EventBridge) can automatically detect and delete these orphaned snapshots — replacing a manual audit with zero-cost automation.

### The Automation Pattern

```
EventBridge Schedule (e.g. daily/weekly)
        │
        ▼
   Lambda Trigger
        │
        ▼
  lambda_handler(event, context)
        │
        ├── ec2.describe_instances()  → Get all running instance IDs
        ├── ec2.describe_snapshots()  → Get all snapshots owned by account
        │
        └── For each snapshot:
              ├── No VolumeId?         → Delete (not attached to any volume)
              └── VolumeId exists?
                    ├── ec2.describe_volumes() → Check if volume exists
                    │     └── Volume not found? → Delete (volume was deleted)
                    └── Volume found but not attached to running instance?
                              └── Delete (orphaned volume)
        │
        ▼
   CloudWatch Logs — execution summary
```

### IAM Permissions Required

Lambda's default execution role only has CloudWatch Logs access. To interact with EC2 and EBS, two custom policies were created and attached:

| Policy                     | Actions Granted                                | Purpose                                 |
| -------------------------- | ---------------------------------------------- | --------------------------------------- |
| `cost-optimization-policy` | `ec2:DescribeSnapshots`, `ec2:DeleteSnapshot`  | List and delete EBS snapshots           |
| `ec2-permission-policy`    | `ec2:DescribeInstances`, `ec2:DescribeVolumes` | Read running instances and volume state |

This enforces **least privilege** — Lambda can only perform exactly the actions the cleanup logic needs, nothing more.

---

## Steps Performed

### Step 1 — Launch EC2 Instance with EBS Volume

Navigate to **EC2 → Launch an instance**.

Configured an Ubuntu 26.04 instance (`t3.micro`) with the default **8 GiB gp3 EBS root volume** (3000 IOPS, not encrypted). The free tier allows up to 30 GiB of EBS General Purpose (SSD) or Magnetic storage.

| Setting        | Value                          |
| -------------- | ------------------------------ |
| AMI            | Canonical, Ubuntu 26.04, amd64 |
| Instance type  | t3.micro                       |
| Storage        | 1 × 8 GiB gp3 (root volume)    |
| Security group | New security group             |

![EC2 launch - configure storage, gp3 8GiB, summary panel](<assets/Screenshot%20(275).png>)

---

### Step 2 — Create an EBS Snapshot

Navigate to **EC2 → Elastic Block Store → Snapshots → Create snapshot**.

| Setting       | Value                                |
| ------------- | ------------------------------------ |
| Resource type | Volume                               |
| Volume ID     | `vol-0b47d53256f92921e` (us-east-1f) |

This creates a point-in-time backup of the root volume. In this demo, the snapshot is intentionally created so that the Lambda function has an orphaned snapshot to detect and delete.

![Create snapshot - Volume resource type, volume ID selected](<assets/Screenshot%20(276).png>)

**Snapshot created successfully:**

> ✅ **Successfully created snapshot `snap-093f7336088b2959a`.**

| Property     | Value                    |
| ------------ | ------------------------ |
| Snapshot ID  | `snap-093f7336088b2959a` |
| Volume size  | 8 GiB                    |
| Storage tier | Standard                 |
| Status       | Pending → Completed      |

![Snapshots list - snap-093f7336088b2959a, 8GiB, Standard, Pending](<assets/Screenshot%20(277).png>)

---

### Step 3 — Verify EC2 Dashboard State

Navigate to **EC2 → Dashboard** to confirm the current resource inventory before building the Lambda function.

| Resource            | Count |
| ------------------- | ----- |
| Instances (running) | 1     |
| Volumes             | 1     |
| Snapshots           | 1     |
| Key pairs           | 1     |
| Security groups     | 8     |

EC2 cost over the past 6 months: **$0.39** across 2 regions — confirming the free tier is largely intact.

![EC2 Dashboard - resources summary, $0.39 total cost, service health normal](<assets/Screenshot%20(278).png>)

---

### Step 4 — Create the `cost-optimization` Lambda Function

Navigate to **Lambda → Functions → Create function → Author from scratch**.

The function was created with the Python runtime and a new auto-generated execution role (`cost-optimization-role-afj5h0xj`). The core logic:

```python
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    # Get all active (running) EC2 instance IDs
    instances_response = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    active_instance_ids = set()
    for reservation in instances_response['Reservations']:
        for instance in reservation['Instances']:
            active_instance_ids.add(instance['InstanceId'])

    # Get all snapshots owned by this account
    response = ec2.describe_snapshots(OwnerIds=['self'])

    # Iterate through snapshots and delete if stale
    for snapshot in response['Snapshots']:
        snapshot_id = snapshot['SnapshotId']
        volume_id = snapshot.get('VolumeId')

        if not volume_id:
            # Snapshot not attached to any volume — delete
            ec2.delete_snapshot(SnapshotId=snapshot_id)
            print(f"Deleted EBS snapshot {snapshot_id} as it was not attached to any volume.")
        else:
            try:
                vol_response = ec2.describe_volumes(VolumeIds=[volume_id])
                if not vol_response['Volumes'][0]['Attachments']:
                    # Volume exists but not attached to any running instance — delete
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"Deleted EBS snapshot {snapshot_id} as it was taken from a volume not attached to any instance.")
            except ec2.exceptions.ClientError as e:
                if e.response['Error']['Code'] == 'InvalidVolume.NotFound':
                    # Volume no longer exists — delete orphaned snapshot
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"Deleted EBS snapshot {snapshot_id} as its associated volume was not found.")
```

> ✅ **Successfully created the function "cost-optimization".**

![cost-optimization Lambda - code editor showing describe_instances and snapshot iteration logic](<assets/Screenshot%20(279).png>)

---

### Step 5 — Configure Timeout

The default Lambda timeout is **3 seconds** — too short for API calls across potentially large snapshots lists. Navigate to **Configuration → General configuration → Edit**.

| Setting           | Value                             |
| ----------------- | --------------------------------- |
| Memory            | 128 MB                            |
| Ephemeral storage | 512 MB                            |
| Timeout           | **0 min 10 sec**                  |
| SnapStart         | None                              |
| Execution role    | `cost-optimization-role-afj5h0xj` |

SnapStart is supported for Python 3.12, Python 3.13, and Python 3.14 — it caches a snapshot of the initialized function to reduce cold start latency.

![Edit basic settings - timeout 10s, ephemeral 512MB, execution role, SnapStart None](<assets/Screenshot%20(280).png>)

---

### Step 6 — Explore the IAM Role

Navigate to **IAM → Roles → `cost-optimization-role-afj5h0xj`** to inspect the auto-created execution role.

| Property             | Value                                                                         |
| -------------------- | ----------------------------------------------------------------------------- |
| ARN                  | `arn:aws:iam::248189914762:role/service-role/cost-optimization-role-afj5h0xj` |
| Created              | May 09, 2026, 20:12 (UTC+05:30)                                               |
| Max session duration | 1 hour                                                                        |
| Permissions policies | CloudWatch Logs only (default)                                                |

By default, the role only allows Lambda to write its own logs. EC2 and EBS access must be explicitly added.

![IAM role - cost-optimization-role-afj5h0xj, summary, permissions loading](<assets/Screenshot%20(281).png>)

---

### Step 7 — Create `cost-optimization-policy` (Snapshot Permissions)

Navigate to **IAM → Policies → Create policy**.

**Service:** EC2 — **Actions selected:**

| Category | Action              | Purpose                                  |
| -------- | ------------------- | ---------------------------------------- |
| List     | `DescribeSnapshots` | List all snapshots owned by this account |
| Write    | `DeleteSnapshot`    | Delete stale/orphaned snapshots          |

**Resources:** All (`*`) — AWS warns the wildcard may be overly permissive; specific snapshot ARNs could be added for tighter control in production.

**Policy name:** `cost-optimization-policy`

![Create policy - snapshot filter, DescribeSnapshots + DeleteSnapshot checked](<assets/Screenshot%20(283).png>)

![Resources - All resources selected, wildcard warning shown](<assets/Screenshot%20(284).png>)

![Review and create - policy name cost-optimization-policy, permissions defined](<assets/Screenshot%20(285).png>)

---

### Step 8 — Attach `cost-optimization-policy` to the Role

Navigate to **IAM → Roles → `cost-optimization-role-afj5h0xj` → Add permissions → Attach policies**.

Search for `cost-optimization-policy` → select → **Add permissions**.

Current permissions policies: **2** (CloudWatch Logs + cost-optimization-policy).

![Attach policy - cost-optimization-policy selected, Customer managed, 1 match](<assets/Screenshot%20(286).png>)

---

### Step 9 — Create `ec2-permission-policy` (Instance + Volume Permissions)

The Lambda code also calls `describe_instances` and `describe_volumes` — a second policy was created for these read-only EC2 permissions.

**Actions selected:**

| Category | Action              | Purpose                                                 |
| -------- | ------------------- | ------------------------------------------------------- |
| List     | `DescribeInstances` | Get all running EC2 instance IDs                        |
| List     | `DescribeVolumes`   | Check if a volume still exists and its attachment state |

**Policy name:** `ec2-permission-policy`

![Create policy - DescribeVolumes checked under describevo search](<assets/Screenshot%20(287).png>)

![Create policy - DescribeInstances checked under describein search](<assets/Screenshot%20(288).png>)

---

### Step 10 — Attach `ec2-permission-policy` to the Role

Navigate back to **IAM → Roles → `cost-optimization-role-afj5h0xj` → Add permissions**.

Search for `ec2-p` → select `ec2-permission-policy` → **Add permissions**.

Current permissions policies: **3** (CloudWatch Logs + cost-optimization-policy + ec2-permission-policy).

![Attach policy - ec2-permission-policy selected, Customer managed, 1 match](<assets/Screenshot%20(289).png>)

---

### Step 11 — First Test Invocation (Before Termination)

With the EC2 instance still running and its snapshot present, the Lambda function was invoked via the **Test** tab using an empty test event named `test`.

**Execution result:**

```
Status: Succeeded
Test Event Name: test

Response:
null

Function Logs:
START RequestId: 481dcd26-aa20-48f7-88f7-9febd156bf12 Version: $LATEST
END   RequestId: 481dcd26-aa20-48f7-88f7-9febd156bf12
REPORT RequestId: 481dcd26-aa20-48f7-88f7-9febd156bf12
    Duration: 3493.63 ms   Billed Duration: 3812 ms
    Memory Size: 128 MB    Max Memory Used: 103 MB
    Init Duration: 317.71 ms
```

**No snapshot was deleted** — the snapshot's volume was still attached to the running `demo-instance`. The function correctly identified no stale snapshots and exited cleanly.

![First test - Status Succeeded, Response null, no deletion in logs](<assets/Screenshot%20(290).png>)

---

### Step 12 — Terminate the EC2 Instance

Navigate to **EC2 → Instances → demo-instance → Instance state → Terminate (delete) instance**.

Terminating the instance also deletes the attached EBS root volume. The snapshot `snap-093f7336088b2959a` now references a **volume that no longer exists** — making it an orphaned snapshot eligible for deletion.

| Resource                 | State after termination            |
| ------------------------ | ---------------------------------- |
| `demo-instance`          | Terminated                         |
| `vol-0b47d53256f92921e`  | Deleted (root volume auto-deleted) |
| `snap-093f7336088b2959a` | Still exists — **orphaned**        |

![EC2 Instances - demo-instance selected, Instance state dropdown, Terminate highlighted](<assets/Screenshot%20(291).png>)

---

### Step 13 — Verify Snapshot Still Exists

Navigate to **EC2 → Snapshots** to confirm the snapshot persists even after instance and volume deletion.

The snapshot `snap-093f7336088b2959a` (8 GiB, Standard tier) is still present — still billing — with no associated volume. This is exactly the scenario the Lambda function targets.

![Snapshots - snap-093f7336088b2959a still present, 8GiB, Standard, Pending status](<assets/Screenshot%20(292).png>)

---

### Step 14 — Second Test Invocation (After Termination) ✅

Re-invoke the Lambda function via the **Test** tab.

**Execution result:**

```
Status: Succeeded
Test Event Name: test

Response:
null

Function Logs:
START RequestId: f0877045-b463-4e98-ab11-69c38128540e Version: $LATEST
Deleted EBS snapshot snap-093f7336088b2959a as its associated volume was not found.
END   RequestId: f0877045-b463-4e98-ab11-69c38128540e
REPORT RequestId: f0877045-b463-4e98-ab11-69c38128540e
    Duration: 1120.99 ms   Billed Duration: 1121 ms
    Memory Size: 128 MB    Max Memory Used: 104 MB
```

> **The Lambda function detected that `snap-093f7336088b2959a`'s associated volume was not found and deleted it automatically.**

Duration dropped from ~3.5s (first run with live volume) to ~1.1s (second run, immediate deletion on volume-not-found exception) — demonstrating the fast path through the `InvalidVolume.NotFound` exception handler.

![Second test - Status Succeeded, "Deleted EBS snapshot snap-093f7336088b2959a as its associated volume was not found." in logs](<assets/Screenshot%20(293).png>)

![Second test full view - Execution Results panel with deletion log line confirmed](<assets/Screenshot%20(294).png>)

---

## IAM Policy Design — Summary

```
cost-optimization-role-afj5h0xj
        │
        ├── [AWS Managed]     AWSLambdaBasicExecutionRole
        │                     └── logs:CreateLogGroup
        │                         logs:CreateLogStream
        │                         logs:PutLogEvents
        │
        ├── [Customer Managed] cost-optimization-policy
        │                     └── ec2:DescribeSnapshots
        │                         ec2:DeleteSnapshot
        │
        └── [Customer Managed] ec2-permission-policy
                              └── ec2:DescribeInstances
                                  ec2:DescribeVolumes
```

Total: **3 policies, 7 actions** — exactly what the function needs, nothing more.

---

## Deletion Logic — Decision Tree

```
For each snapshot owned by account:
        │
        ├── volume_id is None?
        │         └── YES → Delete (snapshot has no volume)
        │
        └── volume_id exists?
                  │
                  └── describe_volumes(volume_id)
                            │
                            ├── InvalidVolume.NotFound → Delete ✅ (our case)
                            │
                            └── Volume found:
                                      └── No attachments? → Delete
                                          Attached to running instance? → Keep
```

---

## Execution Comparison

| Invocation       | State                               | Snapshot Action                 | Duration |
| ---------------- | ----------------------------------- | ------------------------------- | -------- |
| First (Step 11)  | Volume attached to running instance | No deletion — snapshot is valid | ~3.5s    |
| Second (Step 14) | Instance terminated, volume deleted | **Deleted** — volume not found  | ~1.1s    |

---

## Key Concepts Covered

### Orphaned EBS Snapshots

Snapshots reference a `VolumeId` at the time of creation. If that volume is deleted, the reference becomes stale — the snapshot is "orphaned." AWS does not auto-delete these; they must be managed explicitly or via automation.

### `boto3` — AWS SDK for Python

Lambda functions interact with AWS services via `boto3`. The `ec2` client exposes methods like `describe_instances()`, `describe_snapshots()`, `describe_volumes()`, and `delete_snapshot()`. No external dependencies are needed — boto3 is pre-installed in all Python Lambda runtimes.

### Exception-Driven Logic

The function uses Python's `try/except` to catch `InvalidVolume.NotFound` — a boto3 `ClientError` raised when `describe_volumes()` is called with a volume ID that no longer exists. This is cleaner than a two-step existence check and directly maps the AWS error code to the deletion action.

### Least Privilege IAM

Two separate customer-managed policies were created rather than a single broad policy. This makes permissions auditable, independently revocable, and aligned with the principle of least privilege. In production, resources should be scoped to specific ARNs rather than `*`.

### Timeout Tuning

Lambda's default 3-second timeout is insufficient for functions that make multiple sequential AWS API calls (describe_instances → describe_snapshots → describe_volumes per snapshot). The timeout was raised to 10 seconds to accommodate realistic snapshot inventories.

---

## Function Summary

| Property          | Value                                                                |
| ----------------- | -------------------------------------------------------------------- |
| Function name     | `cost-optimization`                                                  |
| Runtime           | Python 3.13                                                          |
| Timeout           | 10 seconds                                                           |
| Memory            | 128 MB                                                               |
| Execution role    | `cost-optimization-role-afj5h0xj`                                    |
| Policies attached | 3 (CloudWatch Logs, cost-optimization-policy, ec2-permission-policy) |
| Trigger           | Manual (Test) — EventBridge schedule in production                   |
| First invocation  | No deletion (volume still attached)                                  |
| Second invocation | **Deleted `snap-093f7336088b2959a`** (volume not found)              |

---

## AWS Services Used

| Service                | Purpose                                                     |
| ---------------------- | ----------------------------------------------------------- |
| AWS Lambda             | Serverless function — snapshot cleanup logic                |
| Amazon EC2             | Source instance and EBS volume for the demo                 |
| Amazon EBS Snapshots   | Target resource — orphaned snapshot detected and deleted    |
| AWS IAM                | Custom least-privilege policies for EC2 and snapshot access |
| Amazon CloudWatch Logs | Automatic execution logging via execution role              |

---

## Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [boto3 EC2 Client — describe_snapshots](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_snapshots.html)
- [boto3 EC2 Client — delete_snapshot](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/delete_snapshot.html)
- [IAM — Creating Customer Managed Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create.html)
- [Amazon EBS Snapshots](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
