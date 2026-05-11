![Progress](https://img.shields.io/badge/Progress-60%25-brightgreen?style=for-the-badge&logo=amazonaws)
![CodeCommit](https://img.shields.io/badge/AWS-CodeCommit-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Source_Control-4EAA25?style=for-the-badge&logo=git&logoColor=white)

# Day 60: AWS CodeCommit — Managed Source Control & CI/CD Foundation

Welcome to Day 60 of my **#100DaysOfDevOps** journey! After deploying infrastructure with CloudFormation on Day 59, today I stepped into the world of **CI/CD on AWS** — starting with **AWS CodeCommit**, Amazon's fully managed Git-based source control service. Rather than hosting code on GitHub or GitLab, CodeCommit keeps your repositories entirely within the AWS ecosystem, integrating natively with CodeBuild, CodeDeploy, and CodePipeline to form a complete DevOps pipeline.

---

## 📌 Project Overview

| Detail                | Value                                              |
| :-------------------- | :------------------------------------------------- |
| **Topic**             | AWS CodeCommit — CI/CD Source Control              |
| **Repository Name**   | `demo-aws-codecommit`                              |
| **Region**            | US East (N. Virginia) — us-east-1                  |
| **File Committed**    | `template.yml` (CloudFormation S3 bucket template) |
| **Branch**            | `main`                                             |
| **IAM Policy Used**   | `AWSCodeCommitPowerUser`                           |
| **Cross-User Access** | Verified via `test-user-100`                       |

---

## 📚 Section 1: Understanding AWS CI/CD Services

### The AWS CI/CD Ecosystem

![AWS CI/CD Services Overview](<assets/Screenshot%20(156).png>)

AWS provides a comprehensive set of **CI/CD (Continuous Integration / Continuous Deployment)** services that enable developers to automate and streamline their software delivery pipeline from code commit to production deployment.

The four core services form a complete pipeline:

| Service              | Role in the Pipeline                                            |
| :------------------- | :-------------------------------------------------------------- |
| **AWS CodeCommit**   | Source control — managed Git repositories                       |
| **AWS CodeBuild**    | Build automation — compile, test, package                       |
| **AWS CodeDeploy**   | Deployment automation — deploy to EC2, Lambda, ECS              |
| **AWS CodePipeline** | Orchestration — connects all stages into one automated pipeline |

Today's focus is the **first stage** of that pipeline — CodeCommit, where all code changes begin.

> **Key Insight:** In a typical AWS DevOps workflow, a developer pushes code to CodeCommit → CodePipeline detects the change → CodeBuild compiles and tests it → CodeDeploy ships it to production. Today we set up the very beginning of that chain.

---

### Advantages of AWS CodeCommit

![CodeCommit Advantages](<assets/Screenshot%20(157).png>)

- **Fully Managed Git** — No servers to set up, patch, or maintain. AWS handles all the infrastructure behind the repository service.
- **Automatic Scalability** — Scales seamlessly to accommodate any repository size, any number of files, and any team size — no storage limits to manage.
- **High Reliability** — Built on AWS's global infrastructure with high availability and automatic replication across multiple Availability Zones — your code is never at risk of being lost.
- **Native AWS Integration** — Connects directly with CodeBuild, CodeDeploy, CodePipeline, IAM, CloudTrail, and CloudWatch — no third-party tokens or webhooks needed.
- **Encryption** — All repositories are encrypted at rest using AWS KMS and in transit using HTTPS or SSH.

---

### Disadvantages of AWS CodeCommit

![CodeCommit Disadvantages](<assets/Screenshot%20(158).png>)

- **Limited Features** — Fewer advanced collaboration features compared to GitHub or GitLab — no built-in CI runners, limited pull request tooling, no native project boards or wiki features.
- **AWS Lock-in** — Tightly coupled to the AWS ecosystem. If your strategy ever involves multi-cloud or moving away from AWS, migrating repositories adds friction.
- **Smaller Community** — Far less community adoption, tutorials, and third-party integrations compared to GitHub. Most open-source workflows assume GitHub as the default.
- **No Free Tier for Teams** — Unlike GitHub's generous free tier, CodeCommit charges beyond 5 active users per month.

> **When to use CodeCommit:** Best suited for teams already deeply invested in the AWS ecosystem who want a simple, secure, fully integrated Git backend — especially when compliance requires keeping all assets within a single cloud provider.

---

## 🛠️ Section 2: Hands-On Lab — Creating & Using a CodeCommit Repository

### Step 1: Navigate to CodeCommit

![CodeCommit Repositories Page](<assets/Screenshot%20(170).png>)

Open the AWS Management Console and navigate to **Developer Tools → CodeCommit → Repositories**. The repositories list is empty — no repos exist yet. Click **"Create repository"** to start.

---

### Step 2: Create the Repository

![Create Repository — Name and Description](<assets/Screenshot%20(171).png>)

Fill in the repository creation form:

- **Repository name**: `demo-aws-codecommit`
  - Names must be unique within your AWS account per region
  - Only letters, numbers, underscores, hyphens, and periods allowed
- **Description**: `a repository to understand aws codecommit feature`
- **Amazon CodeGuru Reviewer** (optional): Can be enabled to automatically review Java and Python code for quality issues and security vulnerabilities on each pull request

Click **Create** to provision the repository.

---

### Step 3: Repository Created — Empty State

![Empty Repository After Creation](<assets/Screenshot%20(173).png>)

The repository `demo-aws-codecommit` is now live but empty — no branches, no commits, no files yet. The console offers two paths forward:

- **Add a file** — upload directly through the browser (no local setup needed)
- **Clone the repository** — copy the HTTPS or SSH clone URL, set up Git credentials, and push from your local machine

For this lab, we'll add a file directly via the browser console.

---

### Step 4: Upload a File & Make the First Commit

![Commit a File — Author, Email, Commit Message](<assets/Screenshot%20(174).png>)

Click **"Add file" → "Upload file"** and select the `template.yml` CloudFormation file. Fill in the commit details:

- **Branch**: `main`
- **Author name**: `Soham`
- **Email address**: `sohamsarkarofficial000@gmail.com`
- **Commit message**: `demo commit`

Click **Commit changes** to write the first commit to the repository.

---

### Step 5: File Successfully Committed

![File Committed — template.yml on main branch](<assets/Screenshot%20(175).png>)

The `template.yml` file is now committed to the `main` branch. The repository view shows:

- **File**: `template.yml`
- **Latest commit message**: `demo commit`
- **Committer**: Soham

The file contains a CloudFormation template that creates an S3 bucket with versioning enabled — the same resource pattern from Day 59:

```yaml
Resources:
  S3Bucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: "soham-devops-lab-bucket"
      VersioningConfiguration:
        Status: Enabled
```

---

## 🔐 Section 3: Managing CodeCommit Access with IAM

### Step 6: Attach CodeCommit IAM Policy to a User

![IAM — Attach CodeCommit Policy to test-user-100](<assets/Screenshot%20(176).png>)

To grant another IAM user access to CodeCommit, navigate to **IAM → Users → test-user-100 → Add permissions → Attach policies directly** and search for `CodeCommit`.

Three levels of access are available:

| IAM Policy                | Access Level                                                         | Use Case            |
| :------------------------ | :------------------------------------------------------------------- | :------------------ |
| `AWSCodeCommitFullAccess` | Full access — create, delete, manage repos                           | Admins              |
| `AWSCodeCommitPowerUser`  | Push, pull, create branches, manage PRs — **cannot delete repos** ✅ | Developers          |
| `AWSCodeCommitReadOnly`   | Read-only — clone and browse only                                    | Auditors, reviewers |

For `test-user-100`, **`AWSCodeCommitPowerUser`** was selected — the standard policy for developers who need full Git workflow access (push, pull, branch, merge) without the ability to accidentally delete repositories.

> **IAM Best Practice:** Always use the least-privilege policy. Developers should never need `FullAccess` for day-to-day work — `PowerUser` provides everything needed for normal development without the destructive permissions.

---

### Step 7: Cross-User Repository Access Verification

![test-user-100 Accessing the Repository](<assets/Screenshot%20(177).png>)

Switching to the `test-user-100` IAM account and navigating to CodeCommit confirms that:

- The `demo-aws-codecommit` repository is visible and accessible
- The `template.yml` file is present and readable
- The `PowerUser` policy grants the correct level of access

This validates the IAM policy configuration — `test-user-100` can work with the repository as a developer without having administrative permissions over it.

---

## 📁 Repository Structure

```
demo-aws-codecommit/
└── template.yml        # CloudFormation template — S3 bucket with versioning enabled
```

---

## 📐 Architecture Summary

```
Developer (Soham)
      │
      │  Commits template.yml
      ▼
┌─────────────────────────────────────┐
│  AWS CodeCommit                     │
│  Repository: demo-aws-codecommit    │
│  Branch: main                       │
│  Commit: "demo commit"              │
└─────────────────────────────────────┘
      │
      │  IAM Policy: AWSCodeCommitPowerUser
      ▼
┌─────────────────────────────────────┐
│  IAM User: test-user-100            │
│  Access: Read + Write (PowerUser)   │
│  Can: push, pull, branch, merge     │
│  Cannot: delete repository          │
└─────────────────────────────────────┘
      │
      │  (Future: connect to pipeline)
      ▼
┌─────────────────────────────────────┐
│  AWS CodePipeline (next steps)      │
│  ├── CodeBuild  — build & test      │
│  └── CodeDeploy — ship to prod      │
└─────────────────────────────────────┘
```

---

## 📚 Key Takeaways from Day 60

**About AWS CI/CD:**

- CodeCommit is the source stage of the AWS CI/CD pipeline — it is where all automation begins.
- The four services (CodeCommit → CodeBuild → CodeDeploy → CodePipeline) form a complete, fully managed DevOps pipeline entirely within AWS.
- Unlike GitHub Actions or Jenkins, this pipeline requires no external services — everything is native AWS.

**About CodeCommit:**

- CodeCommit is standard Git under the hood — `git clone`, `git push`, `git pull` all work identically.
- Authentication uses IAM credentials (HTTPS via Git credentials) or SSH keys — not personal access tokens.
- Every API call to CodeCommit is logged in AWS CloudTrail — giving you a full audit trail of who pushed what and when.
- Repositories are encrypted at rest with AWS KMS by default — no configuration required.

**About IAM & CodeCommit Access:**

- Three policy tiers: `FullAccess` (admins), `PowerUser` (developers), `ReadOnly` (auditors).
- Always grant `PowerUser` to developers — it covers the entire Git workflow without destructive permissions.
- IAM policies for CodeCommit are resource-specific — you can scope them to specific repositories using ARN conditions for fine-grained access control.

---
