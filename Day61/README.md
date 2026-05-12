![Progress](https://img.shields.io/badge/Progress-61%25-brightgreen?style=for-the-badge&logo=amazonaws)
![CodeBuild](https://img.shields.io/badge/AWS-CodeBuild-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![CodePipeline](https://img.shields.io/badge/AWS-CodePipeline-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Hub-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub](https://img.shields.io/badge/Source-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![SSM](https://img.shields.io/badge/AWS-SSM_Parameter_Store-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM_Role-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Continuous_Integration-4EAA25?style=for-the-badge&logo=githubactions&logoColor=white)

# Day 61 - AWS CodeBuild CI/CD Pipeline with Docker & SSM Parameter Store

## Overview

On Day 61, I set up a **Continuous Integration (CI) pipeline** using **AWS CodeBuild**, connected to a **GitHub repository**, with **Docker image building** and secure credential management via **AWS Systems Manager (SSM) Parameter Store**.

The pipeline follows this architecture:

```
User → Code Commit → AWS CodeCommit → AWS CodePipeline
                                              │
                              ┌───────────────┘
                              │
                    AWS CodeBuild (CI)
                              │
         ┌────────────────────────────────────────┐
         │                                        │
    [check out] → [Build & UT] → [Code Scan] → [Image Build] → [Image Scan] → [Image Push]
```

---

## Architecture Diagram

![CI/CD Architecture](<assets/Screenshot%20(179).png>)

---

## Steps Performed

### Step 1 — Create a CodeBuild Project

Navigate to **AWS CodeBuild → Build Projects → Create Build Project**.

- **Project Name:** `aws-sample-python-app`
- **Project Type:** Default project

![Create Build Project](<assets/Screenshot%20(180).png>)

---

### Step 2 — Connect GitHub as Source Provider

Under the **Source** section, select **GitHub** as the source provider. Authorize the **AWS Connector for GitHub** app to access your GitHub account.

![Authorize GitHub](<assets/Screenshot%20(181).png>)

Once authorized, select **Public repository** and enter the repository URL:
`https://github.com/SohamSarkar025/100DaysOfDevOps`

![GitHub Source Config](<assets/Screenshot%20(183).png>)

---

### Step 3 — Configure the Build Environment

Set the build environment to:

| Setting          | Value                           |
| ---------------- | ------------------------------- |
| Compute          | Container (Docker)              |
| Operating System | Ubuntu                          |
| Runtime          | Standard                        |
| Image            | `aws/codebuild/standard:8.0`    |
| Image Version    | Always use the latest           |
| Service Role     | New service role (auto-created) |

![Environment Config](<assets/Screenshot%20(182).png>)

---

### Step 4 — Configure Service Role & Buildspec

A new **IAM Service Role** is automatically named:
`codebuild-aws-sample-python-app-service-role`

For the **Buildspec**, select **"Insert build commands"** (or use a `buildspec.yml` file in the repo).

![Service Role & Buildspec](<assets/Screenshot%20(184).png>)

---

### Step 5 — Create a Custom IAM Role for CodeBuild

Navigate to **IAM → Roles → Create Role**.

![IAM Roles](<assets/Screenshot%20(185).png>)

- **Trusted Entity:** AWS Service
- **Use Case:** CodeBuild

![Create Role - Use Case](<assets/Screenshot%20(186).png>)

On the **Add Permissions** screen, you can optionally attach policies (we'll add SSM access later).

![Add Permissions](<assets/Screenshot%20(187).png>)

- **Role Name:** `aws-codebuild-service-role-soham`
- **Description:** Allows CodeBuild to call AWS services on your behalf.

![Role Name & Review](<assets/Screenshot%20(188).png>)

Create the role with no permissions initially (will add SSM later).

![Create Role - No Permissions Yet](<assets/Screenshot%20(189).png>)

---

### Step 6 — Attach Custom IAM Role to CodeBuild Project

Back in the CodeBuild project, switch to **Existing service role** and paste the ARN of the role created above:

`arn:aws:iam::248189914762:role/aws-codebuild-service-role-soham`

✅ Enable **"Allow AWS CodeBuild to modify this service role"**.

![Attach Existing Role](<assets/Screenshot%20(190).png>)

---

### Step 7 — Store Docker Credentials in SSM Parameter Store

Navigate to **AWS Systems Manager → Parameter Store**.

![SSM Parameter Store](<assets/Screenshot%20(191).png>)

Create the following **SecureString** parameters to store Docker Hub credentials securely:

| Parameter Name                       | Type         | Value                        |
| ------------------------------------ | ------------ | ---------------------------- |
| `/myapp/docker-credentials/username` | SecureString | `sohamdocker25`              |
| `/myapp/docker-credentials/password` | SecureString | `<your-docker-password>`     |
| `/myapp/docker-registry/url`         | SecureString | `<your-docker-registry-url>` |

**Creating the username parameter:**

![Create Parameter - Name](<assets/Screenshot%20(192).png>)

![Create Parameter - Value](<assets/Screenshot%20(193).png>)

All 3 parameters created successfully:

![All Parameters Created](<assets/Screenshot%20(194).png>)

---

### Step 8 — Attach AmazonSSMFullAccess Policy to CodeBuild Role

Navigate to **IAM → Roles → aws-codebuild-service-role-soham → Add Permissions**.

Search for **SSM** and select **AmazonSSMFullAccess**.

![Add SSM Policy](<assets/Screenshot%20(195).png>)

Policy successfully attached to the role:

![SSM Policy Attached](<assets/Screenshot%20(196).png>)

---

### Step 9 — Enable Privileged Mode & Configure Logs

Under **Additional Configuration** in CodeBuild:

- ✅ **Enable Privileged mode** — required for building Docker images inside CodeBuild

![Privileged Mode](<assets/Screenshot%20(197).png>)

Under **Logs**, CloudWatch logging is enabled by default:

- **Log Group:** `aws/codebuild/aws-sample-python-app`

![CloudWatch Logs](<assets/Screenshot%20(198).png>)

Click **Create build project** to finish.

---

### Step 10 — Project Created Successfully

The CodeBuild project `aws-sample-python-app` is created successfully. The project summary shows:

- **Source Provider:** GitHub
- **Primary Repository:** `SohamSarkar025/100DaysOfDevOps`
- **Service Role:** `arn:aws:iam::248189914762:role/aws-codebuild-service-role-soham`
- **Public Builds:** Disabled

![CodeBuild Project Created](<assets/Screenshot%20(199).png>)

---

### Step 11 — Start Build & Verify Success

Click **Start build** to trigger the first build run. The build executes all phases defined in the `buildspec.yml`.

**Build Status: ✅ Succeeded**

| Field        | Value                          |
| ------------ | ------------------------------ |
| Status       | Succeeded                      |
| Initiator    | root                           |
| Build Number | 2                              |
| Start Time   | May 5, 2026 4:47 PM (UTC+5:30) |
| End Time     | May 5, 2026 4:48 PM (UTC+5:30) |

All phases (SUBMITTED → QUEUED → PROVISIONING → ...) completed successfully.

![Build Succeeded](<assets/Screenshot%20(200).png>)

---

### Step 12 — Docker Image Pushed to Docker Hub

After a successful build, the Docker image is pushed to Docker Hub under the repository:

**`sohamdocker25/simple-python-flask-app`** — tagged as `latest`

![Docker Hub Image](<assets/Screenshot%20(201).png>)

---

## Key Concepts Covered

### Continuous Integration (CI)

The pipeline automates the following stages every time code is pushed:

1. **Checkout** — Pull source code from GitHub
2. **Build & Unit Tests** — Compile code and run tests
3. **Code Scan** — Static code analysis / security scanning
4. **Image Build** — Build a Docker image from the app
5. **Image Scan** — Scan Docker image for vulnerabilities
6. **Image Push** — Push the image to a container registry (Docker Hub / ECR)

### AWS SSM Parameter Store

Used to securely store and retrieve sensitive configuration data (Docker credentials) without hardcoding them in the buildspec. Parameters are encrypted using AWS KMS.

### IAM Roles & Least Privilege

A dedicated IAM role (`aws-codebuild-service-role-soham`) was created for CodeBuild with only the permissions it needs:

- **AmazonSSMFullAccess** — to read Docker credentials from Parameter Store

### Privileged Mode

Must be enabled in CodeBuild when building Docker images, as it gives the build container elevated (root-level) access to the Docker daemon.

---

## Sample buildspec.yml

```yaml
version: 0.2

env:
  parameter-store:
    DOCKER_USERNAME: /myapp/docker-credentials/username
    DOCKER_PASSWORD: /myapp/docker-credentials/password
    DOCKER_REGISTRY_URL: /myapp/docker-registry/url

phases:
  pre_build:
    commands:
      - echo Logging in to Docker Hub...
      - echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $DOCKER_REGISTRY_URL

  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t aws-sample-python-app .
      - docker tag aws-sample-python-app:latest $DOCKER_REGISTRY_URL/aws-sample-python-app:latest

  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $DOCKER_REGISTRY_URL/aws-sample-python-app:latest
      - echo Image pushed successfully!

artifacts:
  files:
    - "**/*"
```

---

## AWS Services Used

| Service             | Purpose                           |
| ------------------- | --------------------------------- |
| AWS CodeBuild       | CI build environment              |
| AWS CodePipeline    | Orchestrate the CI/CD pipeline    |
| GitHub              | Source code repository            |
| IAM                 | Role & permissions management     |
| SSM Parameter Store | Secure secrets/credential storage |
| CloudWatch Logs     | Build log monitoring              |
| Docker Hub          | Container image registry          |

---

## Resources

- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
