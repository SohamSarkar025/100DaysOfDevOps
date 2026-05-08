![Progress](https://img.shields.io/badge/Progress-57%25-brightgreen?style=for-the-badge&logo=amazonaws)
![S3](https://img.shields.io/badge/AWS-S3_Static_Hosting-FF9900?style=for-the-badge&logo=amazons3&logoColor=white)
![Status](https://img.shields.io/badge/Status-Live-success?style=for-the-badge)

# Day 57: Hosting a Static Website on Amazon S3

Welcome to Day 57 of my **#100DaysOfDevOps** journey! Today I took a deep dive into **Amazon S3 (Simple Storage Service)** — starting from the core concepts and finishing with a fully deployed static website served live from an S3 bucket. No servers. No OS. No maintenance. Just files, a bucket policy, and a public URL.

---

## 📌 Project Overview

| Detail            | Value                                                |
| :---------------- | :--------------------------------------------------- |
| **Service**       | Amazon S3 (Simple Storage Service)                   |
| **Region**        | US East (N. Virginia) — us-east-1                    |
| **Bucket Name**   | `app1-aws-prod-248189914762-example.com`             |
| **File Uploaded** | `index.html` (31.0 KB)                               |
| **Versioning**    | Enabled                                              |
| **Encryption**    | SSE-S3 (Server-Side Encryption with S3 Managed Keys) |
| **Public Access** | Block Public Access — OFF                            |
| **Hosting Type**  | Static Website Hosting                               |

---

## 📚 Section 1: Understanding Amazon S3

### What is Amazon S3?

![What is S3](<assets/Screenshot%20(100).png>)

**Amazon S3 (Simple Storage Service)** is a scalable, highly available, secure, and cost-effective cloud storage service provided by Amazon Web Services (AWS). It allows you to store and retrieve any amount of data from anywhere on the web.

S3 is not a file system — it is an **object storage** service. Every file you store becomes an "object" with a unique key (path), stored inside a container called a **bucket**.

---

### What Can You Store in S3?

![What can you store in S3](<assets/Screenshot%20(101).png>)

S3 allows you to create buckets in which you can store virtually **anything**:

- Images and photos (`.jpg`, `.png`, `.gif`)
- Videos and media files
- Documents, spreadsheets, and PDFs (`.csv`, `.xlsx`)
- Application files, logs, and backups
- Static website files (`.html`, `.css`, `.js`)
- Machine learning datasets

There is **no limit** on the amount of data you can store in a bucket, and objects can be up to **5 TB** in size.

---

### Is S3 a Global Service?

![S3 Global Service](<assets/Screenshot%20(103).png>)

S3 is a **globally accessible** service — objects stored in S3 are reachable via HTTP from anywhere in the world. Each object gets a unique URL in the format:

```
https://s3.amazonaws.com/{bucket-name}/{object-key}
```

However, **buckets themselves are region-specific**. When you create a bucket, you choose a region where the data physically resides. The data is then replicated across multiple Availability Zones within that region for durability.

---

## ⭐ Section 2: Benefits & Advantages of S3

### The 5 Major Advantages

![S3 Benefits and Advantages](<assets/Screenshot%20(105).png>)

S3 offers five core advantages that make it one of the most widely used storage services in the world:

---

### 1. Availability & Durability

![S3 Reliability - 11 nines](<assets/Screenshot%20(106).png>)

S3 provides **99.999999999% (eleven nines) durability** for objects — meaning if you store 10 million objects, you can expect to lose at most one object every 10,000 years. This is achieved by automatically replicating your data across a minimum of **three Availability Zones** within the selected region.

Availability is **99.9%** for S3 Standard, ensuring your data is accessible almost all the time.

---

### 2. Scalability

S3 automatically scales to handle any volume of data and any number of requests — from a single file to petabytes of data. You never need to provision storage capacity in advance. You pay only for what you use.

---

### 3. Security

![S3 Security Features](<assets/Screenshot%20(107).png>)

S3 provides multiple layers of security:

- **Bucket Policies** — Resource-based JSON policies that control access at the bucket and object level.
- **Access Control** — Block Public Access settings to prevent accidental public exposure.
- **Encryption at Rest** — Server-side encryption options: SSE-S3 (AWS managed keys), SSE-KMS (AWS KMS managed keys), or DSSE-KMS (dual-layer encryption).
- **Encryption in Transit** — SSL/TLS enforced for all data transfers between clients and S3.
- **Access Logging** — Detailed request logs capture every access attempt for audit and monitoring.
- **Object Lock** — Write-Once-Read-Many (WORM) protection for compliance and data immutability.
- **CloudTrail Integration** — Full audit trail of all S3 API calls.

---

### 4. Cost Effective

![S3 Storage Classes and Pricing](<assets/Screenshot%20(108).png>)

S3's cost depends on the **storage class** you select. There is no minimum fee — you pay only for what you store and access:

| Storage Class                 | Cost/GB/Month | Access Time  | Use Case                      |
| :---------------------------- | :------------ | :----------- | :---------------------------- |
| **S3 Standard**               | $0.02         | 1–15 seconds | Frequently accessed data      |
| **S3 Standard-IA**            | $0.01         | 3–5 minutes  | Infrequently accessed data    |
| **One Zone-IA**               | $0.01         | 3–5 minutes  | Non-critical infrequent data  |
| **S3 Glacier**                | $0.00         | 12–48 hours  | Long-term archive             |
| **Glacier Instant Retrieval** | $0.00         | 1–5 minutes  | Archive with instant access   |
| **Glacier Deep Archive**      | $0.00         | 12–48 hours  | Coldest long-term archive     |
| **S3 Intelligent-Tiering**    | $0.015–0.025  | Varies       | Unpredictable access patterns |

For static website hosting, **S3 Standard** is the right choice — low cost, immediate access, and 99.9% availability.

---

### 5. Performance

S3 delivers high throughput for parallel multi-part uploads and supports thousands of requests per second per prefix in a bucket. For global delivery at low latency, S3 integrates with **Amazon CloudFront** (CDN) to cache content at edge locations worldwide.

---

## 🛠️ Section 3: Hands-On Lab — Creating the S3 Bucket

### Step 1: Navigate to Amazon S3

![Amazon S3 Console Homepage](<assets/Screenshot%20(104).png>)

Open the AWS Management Console and navigate to **Amazon S3**. The homepage gives you a quick overview of the service and a direct **"Create bucket"** button. S3 is an object storage service that offers industry-leading scalability, data availability, security, and performance.

---

### Step 2: Configure the Bucket — General Settings

![Create Bucket - General Config](<assets/Screenshot%20(109).png>)

Click **"Create bucket"** and configure the general settings:

- **AWS Region**: US East (N. Virginia) — `us-east-1`
- **Bucket Type**: General Purpose (recommended for most use cases — stores objects redundantly across multiple AZs)
- **Bucket Namespace**: Global namespace (bucket names must be globally unique across all AWS accounts)
- **Bucket Name**: Start with a descriptive, globally unique name following the naming rules (3–63 characters, lowercase, no underscores)

---

### Step 3: Set the Final Bucket Name & Object Ownership

![Bucket Name and Object Ownership](<assets/Screenshot%20(115).png>)

Set the final bucket name to `app1-aws-prod-248189914762-example.com`. Including the account ID in the bucket name is a best practice that guarantees global uniqueness.

Configure **Object Ownership**:

- **ACLs disabled (recommended)** — All objects in this bucket are owned by this account. Access is controlled exclusively through bucket policies, not ACLs. This is the modern, recommended approach.

![Object Ownership ACL Settings](<assets/Screenshot%20(110).png>)

---

### Step 4: Disable Block Public Access

![Block Public Access Settings - Unchecked](<assets/Screenshot%20(111).png>)

For static website hosting, the bucket and its objects must be publicly readable. Uncheck **"Block all public access"** and all four individual sub-settings:

- Block public access to buckets and objects granted through _new_ ACLs
- Block public access to buckets and objects granted through _any_ ACLs
- Block public access to buckets and objects granted through _new_ bucket or access point policies
- Block public and cross-account access through _any_ public bucket or access point policies

> ⚠️ **AWS Warning:** A yellow warning banner confirms this action — AWS recommends keeping Block Public Access enabled for all buckets except when public access is specifically required, such as for static website hosting. Acknowledge the warning by checking the confirmation checkbox.

---

### Step 5: Enable Bucket Versioning & Add Tags

![Bucket Versioning Enabled and Tags](<assets/Screenshot%20(112).png>)

Configure additional settings:

**Bucket Versioning — Enable:**
Versioning preserves every version of every object in the bucket. This means you can recover from accidental deletes or overwrites by restoring a previous version. This is especially valuable when actively updating your website's `index.html`.

**Tags (optional):**
Add a tag with Key: `project`, Value: `app1` to organize and track costs for this bucket across AWS Cost Explorer.

---

### Step 6: Configure Default Encryption

![Default Encryption - SSE-S3](<assets/Screenshot%20(113).png>)

Configure **Default Encryption** for all objects stored in the bucket:

- **Encryption Type**: Server-side encryption with Amazon S3 managed keys (SSE-S3)
  - S3 manages the encryption keys automatically
  - No additional cost
  - AES-256 encryption applied to every object at rest
- **Bucket Key**: Enabled (reduces calls to AWS KMS, lowering costs if upgrading to SSE-KMS later)

Click **"Create bucket"** to finalize.

---

### Step 7: Bucket Created Successfully

![Bucket Created Successfully](<assets/Screenshot%20(114).png>)

The green success banner confirms: **"Successfully created bucket 'app1-aws-prod-248189914762-example.com'"**. The bucket is now live with 0 objects. The console shows all available actions: Upload, Create folder, Copy S3 URI, Download, Open, and Delete.

---

## 🚀 Section 4: Uploading the Website

### Step 8: Upload index.html

![Upload index.html - Ready to Upload](<assets/Screenshot%20(116).png>)

Click **"Upload"** from the bucket's Objects tab. Add the `index.html` file (31.0 KB, `text/html` type). The upload screen shows:

- **Files and folders**: 1 total, 31.0 KB
- **Destination**: `s3://app1-aws-prod-248189914762-example.com`
- **Permissions**: Expandable section to grant public access
- **Properties**: Storage class, encryption settings, tags

Click **"Upload"** to proceed.

---

### Step 9: Upload Succeeded

![Upload Succeeded - 100%](<assets/Screenshot%20(117).png>)

The green success banner confirms: **"Upload succeeded"**. The summary shows:

- **Destination**: `s3://app1-aws-prod-248189914762-example.com`
- **Succeeded**: 1 file, 31.0 KB (100.00%)
- **Failed**: 0 files, 0 B (0%)

The `index.html` object is now stored in the bucket with status **"Succeeded"**.

---

## 🔧 Section 5: Permissions & Versioning

### Step 10: Configure Public Access & Bucket Policy (Initial State)

![Permissions Tab - Block Public Access OFF, No Policy Yet](<assets/Screenshot%20(120).png>)

Navigate to the **Permissions** tab. Confirm:

- **Block all public access**: Off ⚠️ (required for static hosting)
- **Bucket policy**: No policy to display yet

---

### 🔐 Bonus: Testing IAM-Based Bucket Policy (Deny Policy)

As part of learning bucket policies in depth, I first applied a **restrictive Deny policy** to test how bucket policies interact with IAM users — before switching to the public read policy for hosting.

**Step A — Writing the Deny Policy:**

![Edit Bucket Policy - Deny All Except Root](<assets/Screenshot%20(121).png>)

In **Permissions → Bucket policy → Edit**, I wrote a `RestrictBucketToIAMUsersOnly` policy with `Sid: AllowOwnerOnlyAccess`. This policy:

- **Effect**: Deny
- **Principal**: `*` (everyone)
- **Action**: `s3:*` (all S3 actions)
- **Resource**: both the bucket and all objects (`/*`)
- **Condition**: `StringNotEquals` on `aws:PrincipalArn` — meaning the Deny applies to everyone **except** the root account `arn:aws:iam::248189914762:root`

```json
{
  "Version": "2012-10-17",
  "Id": "RestrictBucketToIAMUsersOnly",
  "Statement": [
    {
      "Sid": "AllowOwnerOnlyAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::app1-aws-prod-248189914762-example.com/*",
        "arn:aws:s3:::app1-aws-prod-248189914762-example.com"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalArn": "arn:aws:iam::248189914762:root"
        }
      }
    }
  ]
}
```

**Step B — Policy Saved Successfully:**

![Bucket Policy Saved - Deny Policy Active](<assets/Screenshot%20(122).png>)

The green banner confirms: **"Successfully edited bucket policy."** The Deny policy is now live and active on the bucket.

---

**Step C — IAM User `test-user-100` Setup:**

![IAM User test-user-100 Permissions](<assets/Screenshot%20(123).png>)

To verify the policy works, I checked the IAM user `test-user-100`:

- **ARN**: `arn:aws:iam::248189914762:user/test-user-100`
- **Console access**: Enabled (without MFA)
- **Last sign-in**: 4 days ago
- **Permissions policies (3)**:
  - `AmazonEC2FullAccess` — attached directly
  - `AmazonS3FullAccess` — attached via group `devops`

Even though `test-user-100` has `AmazonS3FullAccess` through the `devops` group, the **explicit Deny in the bucket policy overrides all IAM Allow permissions** — demonstrating the core IAM evaluation logic: **Deny always wins**.

---

**Step D — Access Denied for `test-user-100`:**

![test-user-100 - Insufficient Permissions to List Objects](<assets/Screenshot%20(124).png>)

Logged in as `test-user-100` and navigated to the bucket. The console shows a red error banner:

> ❌ **Insufficient permissions to list objects**
> After you or your AWS administrator has updated your permissions to allow the `s3:ListBucket` action, refresh the page.

Despite having `AmazonS3FullAccess` in their IAM policy, `test-user-100` is completely blocked by the bucket's explicit Deny policy.

![Confirming IAM User Identity - test-user-100 logged in](<assets/Screenshot%20(125).png>)

The account dropdown confirms the active identity is `test-user-100` (IAM user under account `40_Soham`), and the **"Access denied"** indicator is visible in red — proving the bucket policy Deny is working exactly as intended.

> **Key Lesson:** In AWS IAM evaluation order — explicit Deny in a resource policy **always overrides** any Allow, whether from an identity policy, managed policy, or group membership. This is the principle of **least privilege enforcement** at the resource level.

---

### Step 11: Bucket Properties & Versioning Confirmed

![Bucket Properties Tab - Versioning Enabled](<assets/Screenshot%20(119).png>)

Navigate to the **Properties** tab to confirm bucket configuration:

- **AWS Region**: US East (N. Virginia) us-east-1
- **ARN**: `arn:aws:s3:::app1-aws-prod-248189914762-example.com`
- **Creation date**: May 4, 2026, 17:01:41 (UTC+05:30)
- **Bucket Versioning**: ✅ Enabled
- **MFA Delete**: Disabled

---

### Step 12: Object Versions — Versioning in Action

![index.html Versions - 2 Versions Stored](<assets/Screenshot%20(118).png>)

Navigate to the `index.html` object and click the **Versions** tab. Since versioning was enabled at bucket creation, S3 automatically tracked both uploads of `index.html`:

| Version                                 | Type | Last Modified         | Size    | Storage Class |
| :-------------------------------------- | :--- | :-------------------- | :------ | :------------ |
| `CNPztqhxL9OZF8WvaPXhmkmg...` (Current) | html | May 4, 2026, 17:06:35 | 31.0 KB | Standard      |
| `O_VZuMc08qzQNrRAsuOGChy...`            | html | May 4, 2026, 17:04:50 | 31.0 KB | Standard      |

This means if you accidentally overwrite `index.html` with a broken version, you can instantly restore the previous working version — zero data loss.

---

## 🌐 Section 6: Enabling Static Website Hosting

### Step 13: Static Website Hosting — Initially Disabled

![Properties Tab - Static Website Hosting Disabled](<assets/Screenshot%20(126).png>)

Navigate to **Properties → Static website hosting**. By default, static hosting is **Disabled**. AWS also shows a recommendation banner suggesting **AWS Amplify Hosting** as a more feature-rich alternative — but for this lab we are using native S3 static hosting to understand the fundamentals.

Click **Edit** to enable it.

---

### Step 14: Configure Static Website Hosting Settings

![Edit Static Website Hosting - Enable, index.html, error.html](<assets/Screenshot%20(127).png>)

In the **Edit static website hosting** screen, configure:

- **Static website hosting**: ✅ Enable
- **Hosting type**: Host a static website (use the bucket endpoint as the web address)
- **Index document**: `index.html` — the homepage served when users visit the root URL
- **Error document**: `error.html` — the page served for any 4xx errors (optional but recommended)
- **Redirection rules**: Leave empty unless you need URL redirects

> ℹ️ **AWS Info Banner:** "For your customers to access content at the website endpoint, you must make all your content publicly readable. To do so, you can edit the S3 Block Public Access settings for the bucket."

![Redirection Rules Editor - Empty, Save Changes](<assets/Screenshot%20(128).png>)

Leave the redirection rules JSON editor empty and click **"Save changes"** to activate static website hosting.

---

### Step 15: Add the Public Read Bucket Policy

With static hosting enabled, objects still need a bucket policy granting public read access. Navigate to **Permissions → Bucket policy → Edit** and replace the previous Deny policy with the `PublicReadGetObject` Allow policy:

![Edit Bucket Policy - PublicReadGetObject Allow Policy](<assets/Screenshot%20(129).png>)

The new policy:

- **Sid**: `PublicReadGetObject`
- **Effect**: `Allow`
- **Principal**: `*` (anonymous public — anyone on the internet)
- **Action**: `s3:GetObject` (read objects only — cannot list, delete, or modify)
- **Resource**: `arn:aws:s3:::app1-aws-prod-248189914762-example.com/*` (all objects in the bucket)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::app1-aws-prod-248189914762-example.com/*"]
    }
  ]
}
```

> **Why only `s3:GetObject`?** We grant the minimum permission needed — anonymous users can only read (GET) objects. They cannot list the bucket contents, upload files, or delete anything. This is the principle of least privilege applied to public hosting.

---

### Step 16: Static Website Hosting Enabled — Endpoint Live

![Static Website Hosting Enabled - Endpoint URL Copied](<assets/Screenshot%20(130).png>)

Back in **Properties → Static website hosting**, the status now shows:

- **S3 static website hosting**: ✅ Enabled
- **Hosting type**: Bucket hosting
- **Bucket website endpoint**:
  `http://app1-aws-prod-248189914762-example.com.s3-website-us-east-1.amazonaws.com`

The toast notification **"Bucket website endpoint copied"** confirms the URL is copied to clipboard and ready to open.

---

### Step 17: ✅ Website Live — Final Verification

![Live Website - Day 57 Hosted on S3](<assets/Screenshot%20(131).png>)

Opening the S3 website endpoint URL in a browser confirms the deployment is successful. The custom-built Day 57 website loads perfectly — served entirely from S3 with zero servers:

- **URL**: `app1-aws-prod-248189914762-example.com.s3-website-us-east-1.amazonaws.com`
- **Title**: "Day 57 | 100 Days of DevOps"
- **Content**: Full hero section with "Hosting on Amazon S3" headline, navigation, and CTAs
- **Note**: The browser shows "Not secure" — S3 static hosting uses HTTP only. For HTTPS, the next step is pairing S3 with **Amazon CloudFront**.

---

## 📐 Architecture Summary

```
User / Browser
      │
      │  HTTP Request (Port 80)
      ▼
 S3 Website Endpoint
 app1-aws-prod-248189914762-example.com
 .s3-website-us-east-1.amazonaws.com
      │
      │  s3:GetObject (allowed via PublicReadGetObject Bucket Policy)
      ▼
 S3 Bucket: app1-aws-prod-248189914762-example.com
      │
      ├── index.html  (31.0 KB — Current Version)  ← served to browser
      ├── index.html  (Previous Version — preserved by Versioning)
      │
      ├── Encryption : SSE-S3 (AES-256) at rest
      ├── Region     : us-east-1
      ├── Redundancy : 3+ Availability Zones
      └── Versioning : Enabled (full rollback capability)

IAM Policy Test (Bonus):
  test-user-100 (AmazonS3FullAccess via group)
      │
      │  Attempted s3:ListBucket
      ▼
  ❌ DENIED — Explicit Deny in bucket policy overrides IAM Allow
```

---

## 📚 Key Takeaways from Day 57

**About Amazon S3:**

- S3 is object storage — not a file system. Everything is a flat object with a unique key.
- Buckets are region-specific but globally accessible via HTTP.
- S3 Standard offers 11 nines of durability by replicating across multiple AZs automatically.
- Storage classes let you optimize cost — from $0.02/GB for Standard down to near-zero for Glacier.

**About Static Hosting:**

- Block Public Access must be disabled AND a bucket policy granting `s3:GetObject` to `*` must be applied — both are required.
- Enable static website hosting under Properties → Static website hosting → Enable, with `index.html` as the index document.
- The S3 website endpoint URL is HTTP only — for HTTPS and a custom domain, pair S3 with **CloudFront** (next step!).
- SSE-S3 encryption is applied by default — your files are encrypted at rest even on a public website.
- Enable versioning before uploading for instant rollback capability from day one.

**About Bucket Policies & IAM:**

- An explicit **Deny** in a bucket policy overrides any **Allow** in an IAM identity policy — always, no exceptions.
- `s3:GetObject` is the only permission needed for static hosting — never grant `s3:*` to anonymous users.
- The `PublicReadGetObject` pattern is the standard policy for S3 static website hosting.
- Use the `StringNotEquals` / `aws:PrincipalArn` condition pattern to create owner-only access policies during development.

---
