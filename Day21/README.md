![Progress](https://img.shields.io/badge/Progress-21%25-orange?style=for-the-badge&logo=docker)

# 🐳 Day 21: Docker Optimization — Multi-Stage Builds & Distroless Images

## 📖 Overview

Today, I moved beyond just building Docker images to **optimizing** them for production. In a professional DevOps environment, a bloated image is a liability. I performed a hands-on lab using a **Golang** application to demonstrate how **Multi-Stage Builds** can shrink image sizes from hundreds of MBs to just a few KBs/MBs.

---

## 🏗️ The Problem: Bloated Images

When building applications (Java, Go, React), we need heavy build tools (compilers, SDKs). However, these tools are useless in the production environment once the binary is generated.

**Initial Attempt (Standard Build):**
I built a Golang app using a single-stage Dockerfile.

- **Base Image:** `ubuntu` + `golang-go` compiler.
- **Resulting Size:** **653 MB** (Extremely heavy for a simple calculator app).

![Standard Build Analysis](<./assets/Screenshot%20(236).png>)
_Even for a small app, the image is massive due to the Ubuntu OS and Go toolchain._

---

## 🛠️ The Solution: Multi-Stage Builds

Multi-stage builds allow us to use multiple `FROM` statements. We compile the app in one stage and copy only the final executable to a second, minimal stage.

### 📝 The Multi-Stage Dockerfile Logic:

1. **Stage 1 (build):** Uses `ubuntu` + `golang` to compile the source code into a binary called `/app`.
2. **Stage 2 (final):** Uses `scratch` (the smallest possible Docker image).
3. **The Magic:** `COPY --from=build /app /app` transfers ONLY the binary, leaving the heavy OS and compiler behind.

![Multi-Stage Dockerfile](<./assets/Screenshot%20(237).png>)

---

## 🚀 Practical Lab: Shrinking Images by 300x!

I executed two builds to compare the efficiency:

1. **Build 1 (Without Multi-stage):** `without-multistage:latest` -> **653 MB**
2. **Build 2 (With Multi-stage):** `multistage-docker:latest` -> **1.96 MB** 🤯

![Final Size Comparison](<./assets/Screenshot%20(238).png>)
_The results are staggering: A reduction from 653MB to less than 2MB!_

---

## 🛡️ Distroless & Scratch Images

I explored Google's **Distroless** and Docker's **Scratch** images.

- **Scratch:** An empty image. Perfect for statically compiled binaries (like Go).
- **Security Impact:** Since there is no `shell` (`/bin/sh`) or `apt` manager in the final image, the attack surface is near zero.

![System Verification](<./assets/Screenshot%20(233).png>)
_Ensuring Docker Daemon is healthy on EC2 before optimization labs._

---

## 🛠️ Mastered Commands & Syntax

| Instruction         | Purpose                                                                |
| :------------------ | :--------------------------------------------------------------------- |
| `FROM ... AS build` | Defines the compilation stage.                                         |
| `COPY --from=build` | Transfers only the artifact (binary/jar) to the next stage.            |
| `FROM scratch`      | Starting from an absolutely empty layer for maximum efficiency.        |
| `CGO_ENABLED=0`     | Ensuring the Go binary is statically linked for Scratch compatibility. |

---

## 🧠 Key Takeaways

1. **Performance:** Smaller images mean faster `docker pull` and faster deployments.
2. **Cost:** Significantly reduces storage costs in ECR/Docker Hub.
3. **Security:** Removing the shell and OS utilities makes the container "production-hardened."

---

## 🤝 Connect with Me

[<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin">](https://www.linkedin.com/in/soham-sarkar-85a5a6247) | [<img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">](https://github.com/SohamSarkar025)
