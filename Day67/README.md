![Progress](https://img.shields.io/badge/Progress-67%25-brightgreen?style=for-the-badge&logo=amazonaws)
![ECR](https://img.shields.io/badge/AWS-ECR-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Image-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![CLI](https://img.shields.io/badge/AWS-CLI-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Container](https://img.shields.io/badge/Compute-Containers-00bfa5?style=for-the-badge)

# Day 67 - Amazon ECR: Elastic Container Registry — Concepts & First Image Push

## Overview

On Day 67, I explored **Amazon ECR (Elastic Container Registry)** — AWS's fully managed Docker container registry. The day began with concept notes comparing ECR to DockerHub, understanding private vs public registries, and why DevOps teams on AWS prefer ECR. It concluded with creating a private ECR repository (`demo-app-repo`), authenticating Docker to ECR via the AWS CLI, writing a minimal `Dockerfile`, building a Docker image, tagging it with the ECR URI, and pushing it live — verifying the image appeared in the ECR console.

**Result: Docker image `demo-app-repo:latest` pushed to Amazon ECR private registry — 3 images confirmed in console ✅**

---

## Concept Notes

### What is ECR?

Amazon ECR is a **fully managed container registry** that stores, manages, and deploys Docker container images. It integrates natively with AWS services (ECS, EKS, Lambda, CodePipeline) and provides scalability, high availability, and IAM-based security out of the box.

```
Docker Image ──► ECR Repository ──► ECS / EKS / Lambda
                 (private, AWS-managed)
                        │
                 Available ✅  Scalable ✅
```

ECR sits alongside EC2, EBS, and EKS as a core compute-layer service. It is the AWS-native alternative to DockerHub for teams building containerized workloads on AWS.

**Container registries — the ecosystem:**

- **DockerHub** — Public default registry; free public repos, paid private repos
- **ECR** — AWS-native private registry; IAM-secured, integrates with AWS services
- **Quay.io** — Red Hat's registry
- **GCR** — Google Container Registry

![ECR concept - Available, Container, Docker Image, Container Registry, ECR, Elastic, Scalable + Available, EC2 EBS EKS, DockerHub Quay.io GCR](<assets/Screenshot%20(370).png>)

### ECR vs DockerHub — Comparison

| Dimension         | ECR                                        | DockerHub                                      |
| ----------------- | ------------------------------------------ | ---------------------------------------------- |
| Access            | IAM users / AWS services                   | Public (free login) or paid private            |
| Repository types  | Private only (by default)                  | Public + Private                               |
| Security          | IAM policies, VPC endpoints, image signing | Login-based auth                               |
| AWS integration   | Native (ECS, EKS, CodePipeline)            | Requires credentials injection                 |
| Image pull limits | 1,000 pulls/account (private)              | 10,000 pulls (with limits for unauthenticated) |
| Cost              | Pay per GB stored + data transfer          | Free for public; paid for private              |
| Best for          | AWS DevOps teams, production workloads     | Open source, public images                     |

**Why ECR for AWS DevOps?** ECR is the natural choice when your containers run on ECS or EKS — no external registry credentials to manage, IAM controls access, and image pulls stay within the AWS network (faster, cheaper, more secure).

```
ECR (AWS)                          DockerHub
──────────                         ─────────
+ IAM security (no passwords)      + Public repos free (login)
+ AWS service integration          + Public repository
+ Private by default               + Private (paid)
+ Scalable, Available              - Pull rate limits apply
- AWS account required             - External credential management
```

**GCR → ECR for AWS DevOps** — If you're coming from GCP or using GCR, ECR is the equivalent on AWS. The migration path is straightforward: tag your existing images with the ECR URI and push.

![ECR vs DockerHub - AWS services, Quay, IAM users, Security, Public, Free login, Public/Private repo, Private repository, AWS DevOps → ECR, 1000/10000 pulls](<assets/Screenshot%20(371).png>)

---

## Steps Performed

### Step 1 — Search for ECR in AWS Console

Navigate to the AWS Console and search for **ECR**.

**Elastic Container Registry** appears as the top result — described as a _"Fully-managed Docker container registry: Share and deploy container software"_

Top features shown: Repositories, Private registry, Managed image signing.

Related services also visible in results: Secrets Manager (rotate/manage/retrieve secrets), Key Management Service (generate and manage encryption keys).

![AWS console search ECR - Elastic Container Registry result, top features: Repositories, Private registry, Managed image signing](<assets/Screenshot%20(372).png>)

---

### Step 2 — Create a Private Repository (`demo-app-repo`)

Navigate to **Amazon ECR → Private registry → Repositories → Create a private repository**.

**General settings:**

| Setting          | Value                                                        |
| ---------------- | ------------------------------------------------------------ |
| Repository name  | `demo-app-repo`                                              |
| Full URI         | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo` |
| Name constraints | 2–256 chars, lowercase letters, numbers, `._-/`              |

**Image tag settings:**

| Setting                | Value        | Description                                                                       |
| ---------------------- | ------------ | --------------------------------------------------------------------------------- |
| Image tag mutability   | **Mutable**  | Image tags can be overwritten (e.g. pushing a new `latest` replaces the old one)  |
| Immutable              | Not selected | Would prevent tag overwrites — useful for production to guarantee reproducibility |
| Mutable tag exclusions | None         | Tags matching filters would be immutable even in Mutable mode                     |

**Encryption settings:**

| Setting                  | Value                 |
| ------------------------ | --------------------- |
| Encryption configuration | **AES-256** (default) |
| AWS KMS                  | Not selected          |

> ⚠ **Encryption settings cannot be changed after repository creation.** AES-256 uses the industry standard Advanced Encryption Standard. AWS KMS is available for stricter key management requirements (customer-managed keys).

**Image scanning settings:** — marked as _deprecated_ in the console (superseded by ECR Enhanced Scanning via Amazon Inspector).

![Create private repository - demo-app-repo, full URI, Mutable tag selected](<assets/Screenshot%20(373).png>)

![Encryption settings - AES-256 selected, AWS KMS option, Image scanning deprecated, Create button](<assets/Screenshot%20(374).png>)

**Repository created successfully:**

Navigate to **ECR → Private registry → Repositories → demo-app-repo → Images**.

The repository is empty — **No active images** yet. Available tabs: Summary, Images, Lifecycle policy, Permissions, Repository tags.

Available actions on the Images tab: Delete, Copy URI, Details, Scan, **View push commands**.

![demo-app-repo created - Images tab, No active images, View push commands button](<assets/Screenshot%20(375).png>)

---

### Step 3 — Authenticate Docker to ECR

Open **Git Bash (MINGW64)** in the `aws-shell-script` directory.

**Verify AWS CLI version:**

```bash
$ aws --version
aws-cli/2.34.9 Python/3.13.11 Windows/11 exe/AMD64
```

**Authenticate Docker to ECR** using the AWS CLI `get-login-password` command piped directly to `docker login`:

```bash
$ aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    248189914762.dkr.ecr.us-east-1.amazonaws.com
Login Succeeded
```

**How this works:**

- `aws ecr get-login-password` — Calls the ECR API and retrieves a temporary authentication token (valid 12 hours)
- `| docker login --username AWS --password-stdin` — Pipes the token directly to Docker as the password; username is always `AWS` for ECR
- The ECR registry URI (`248189914762.dkr.ecr.us-east-1.amazonaws.com`) scopes the login to this specific account and region

Docker is now authenticated to push/pull from this ECR private registry.

![Git Bash - aws --version, aws ecr get-login-password | docker login, Login Succeeded, vim Dockerfile](<assets/Screenshot%20(376).png>)

---

### Step 4 — Write the Dockerfile

Create and edit `Dockerfile` using vim:

```bash
$ vim Dockerfile
```

**Dockerfile contents:**

```dockerfile
FROM ubuntu:latest
```

This minimal Dockerfile uses the official Ubuntu base image with the `latest` tag. In production, a specific version tag (e.g. `ubuntu:24.04`) would be preferred for reproducibility, but `ubuntu:latest` is sufficient for demonstrating the ECR push workflow.

Saved with `:wq` in vim.

![vim Dockerfile - FROM ubuntu:latest, :wq saved, unix format, 18/05/2026](<assets/Screenshot%20(380).png>)

---

### Step 5 — Build Docker Image, Tag, and Push to ECR

**Build the Docker image:**

```bash
$ docker build -t demo-app-repo .
[+] Building 0.5s (5/5) FINISHED          docker:desktop-linux
=> [internal] load build definition from Dockerfile
=> => transferring dockerfile: 56B
=> [internal] load metadata for docker.io/library/ubuntu:latest
=> [internal] load .dockerignore
=> => transferring context: 2B
=> CACHED [1/1] FROM docker.io/library/ubuntu:latest@sha256:d1e2e92c075e...
=> => resolve docker.io/library/ubuntu:latest
=> => exporting image
=> => exporting layers
=> => exporting manifest sha256:7247de7831b6a641c8065fbcae9e8d2d05992ba...
=> => exporting config sha256:cbb9408d87c33a4d903c5ec28f6dab287bc7a964...
=> => exporting attestation manifest sha256:4c84f6e50f6fe44c8d3a4a49903...
=> => exporting manifest list sha256:bd047b697176c46d822ebe0c8dfbeed372...
=> => naming to docker.io/library/demo-app-repo:latest
=> => unpacking to docker.io/library/demo-app-repo:latest
```

The `ubuntu:latest` layer was **CACHED** — Docker reused the already-pulled layer rather than re-downloading from DockerHub.

**List local images to confirm the build:**

```bash
$ docker images
IMAGE                                                              ID              DISK USAGE    CONTENT SIZE
248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest 6a904ad5dfb0   117MB         29.7MB
SohamDocker25/python-web-app-demo:latest                           f8d739fa85c1   918MB         236MB
SohamDocker25/python-web-app-demo:v1                               f8d739fa85c1   918MB         236MB
demo-app-repo:latest                                               bd047b697176   117MB         29.7MB
gcr.io/k8s-minikube/kicbase:v0.0.50                               b97074569ae9   1.94GB        545MB
soham2572004/python-web-app-demo:v1                                f8d739fa85c1   918MB         236MB
ubuntu:latest                                                      d1e2e92c075e   119MB         31.7MB
ultimate-cicd-pipeline:v1                                          a573080143f6   242MB         70.7MB
```

**Tag the image with the ECR URI:**

```bash
$ docker tag demo-app-repo:latest \
  248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest
```

This creates a new image reference pointing at the ECR registry URI — required before pushing. The local `demo-app-repo:latest` and the ECR-tagged image share the same underlying layers (same Image ID `bd047b697176`).

**Push to ECR:**

```bash
$ docker push 248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest
The push refers to repository [248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo]
01d7766a2e4a: Pushed
947949d5c9f0: Pushed
latest: digest: sha256:bd047b697176c46d822ebe0c8dfbeed372a570b30763c6c8182c15094492afec size: 855
```

Two layers pushed (`01d7766a2e4a`, `947949d5c9f0`), then the manifest digest confirmed. The image is now live in ECR.

![docker build + docker images + docker tag output](<assets/Screenshot%20(381).png>)

![docker images + docker tag + docker push - Pushed layers, digest confirmed](<assets/Screenshot%20(382).png>)

---

### Step 6 — Verify Image in ECR Console

Navigate back to **ECR → Private registry → Repositories → demo-app-repo → Images**.

**Images (3)** now appear:

| Image tag | Type        | Created at                        | Image size (MB) | Image digest     |
| --------- | ----------- | --------------------------------- | --------------- | ---------------- |
| `latest`  | Image Index | 18 May 2026, 20:53:33 (UTC+05:30) | 29.73           | sha256:bd047b... |
| —         | Image       | 18 May 2026, 20:53:32 (UTC+05:30) | 29.73           | sha256:7247de... |
| —         | Image       | 18 May 2026, 20:53:32 (UTC+05:30) | 0.00            | sha256:4c84f6... |

**Why 3 entries for 1 push?** Docker's multi-platform image format (OCI Image Index) produces multiple manifests: the **Image Index** (manifest list, tagged `latest`) points to platform-specific **Image** manifests (one for the actual image layers, one for the attestation manifest). This is normal behavior for modern Docker builds using `docker:desktop-linux` builder.

![ECR demo-app-repo Images tab - 3 images: latest Image Index 29.73MB, 2 untagged Images](<assets/Screenshot%20(384).png>)

---

### Step 7 — View Push Commands Reference

Navigate to **ECR → demo-app-repo → View push commands**.

ECR provides the exact 4-step push workflow for both macOS/Linux and Windows:

```bash
# Step 1 — Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    248189914762.dkr.ecr.us-east-1.amazonaws.com

# Step 2 — Build Docker image
docker build -t demo-app-repo .

# Step 3 — Tag image with ECR URI
docker tag demo-app-repo:latest \
  248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest

# Step 4 — Push image to ECR
docker push 248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo:latest
```

This panel is the canonical reference for the push workflow — available directly in the ECR console for every repository.

![Push commands for demo-app-repo - macOS/Linux tab, 4-step workflow: auth, build, tag, push](<assets/Screenshot%20(385).png>)

---

## End-to-End Workflow — Summary

```
AWS CLI                    Local (MINGW64)              Amazon ECR
───────                    ───────────────              ──────────
aws ecr get-login-password
        │
        └──────────────► docker login ──────────────► Login Succeeded ✅
                                │
                         vim Dockerfile
                         FROM ubuntu:latest
                                │
                         docker build -t demo-app-repo .
                         (ubuntu:latest CACHED — 0.5s build)
                                │
                         docker tag demo-app-repo:latest
                         248189914762.dkr.ecr.../demo-app-repo:latest
                                │
                         docker push ──────────────────► ECR repo
                         01d7766a2e4a: Pushed               │
                         947949d5c9f0: Pushed               │
                         digest: sha256:bd047b...    Images (3) ✅
```

---

## Repository Summary

| Property             | Value                                                                     |
| -------------------- | ------------------------------------------------------------------------- |
| Repository name      | `demo-app-repo`                                                           |
| Registry type        | Private                                                                   |
| Full URI             | `248189914762.dkr.ecr.us-east-1.amazonaws.com/demo-app-repo`              |
| Region               | us-east-1 (N. Virginia)                                                   |
| Image tag mutability | Mutable                                                                   |
| Encryption           | AES-256                                                                   |
| Image pushed         | `latest` (Image Index)                                                    |
| Image size           | 29.73 MB                                                                  |
| Image digest         | `sha256:bd047b697176c46d822ebe0c8dfbeed372a570b30763c6c8182c15094492afec` |
| Dockerfile           | `FROM ubuntu:latest`                                                      |
| AWS CLI version      | 2.34.9                                                                    |
| Auth token validity  | 12 hours                                                                  |

---

## Key Concepts Covered

### ECR URI Structure

```
248189914762   .dkr.ecr.  us-east-1  .amazonaws.com/  demo-app-repo  :latest
└─ Account ID ─┘          └─ Region ─┘                └─ Repo name ──┘└─ Tag ─┘
```

Every ECR repository has a globally unique URI composed of the AWS account ID, the regional ECR endpoint, and the repository name. This URI is used for both `docker tag` and `docker push`.

### Mutable vs Immutable Tags

|                   | Mutable                                 | Immutable                          |
| ----------------- | --------------------------------------- | ---------------------------------- |
| Re-push `latest`  | ✅ Overwrites old image                 | ❌ Rejected — must use new tag     |
| Reproducibility   | Lower — `latest` can silently change    | Higher — tags are permanent        |
| CI/CD convenience | High — `latest` always points to newest | Requires versioned tags (`v1.2.3`) |
| Production use    | Risky for `latest`                      | Recommended                        |

### Image Index vs Image (OCI)

Modern Docker builds using BuildKit produce an **OCI Image Index** (manifest list) that references platform-specific images. This is why a single push creates 3 ECR entries: the Image Index (`latest` tag), the platform image manifest, and an attestation manifest (supply chain provenance). All 3 are part of one logical image.

### ECR Authentication Token

`aws ecr get-login-password` returns a temporary password valid for **12 hours**. It is piped directly to `docker login` — never stored in a file. In CI/CD pipelines, this command runs at the start of every job to refresh the token.

---

## AWS Services Used

| Service        | Purpose                                                          |
| -------------- | ---------------------------------------------------------------- |
| Amazon ECR     | Private Docker container registry — stores `demo-app-repo` image |
| AWS CLI        | `aws ecr get-login-password` — authenticates Docker to ECR       |
| Docker (local) | Build, tag, and push container image                             |

---

## Resources

- [Amazon ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECR Private Registry Authentication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html)
- [ECR Image Tag Mutability](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html)
- [OCI Image Index Specification](https://github.com/opencontainers/image-spec/blob/main/image-index.md)
- [ECR vs DockerHub](https://aws.amazon.com/ecr/faqs/)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
