![Progress](https://img.shields.io/badge/Progress-17%25-green?style=for-the-badge&logo=progress)

# 📂 Day 17: Provisioning My First EC2 Instance with Terraform

## 📖 Overview

On Day 17, I moved from theory to practical implementation of **Infrastructure as Code (IaC)**. I successfully configured my Windows machine and provisioned an AWS EC2 instance. I also explored the critical role of `outputs.tf` and **State Management**.

---

## 🛠️ Windows Installation Guide

1. **Download:** 64-bit binary from HashiCorp.
2. **Path Setup:** Added `C:\terraform` to System Environment Variables.
3. **Verify:** Checked via `terraform --version`.

---

## 🏗️ Lab Execution Steps

### 1. The Configuration (`main.tf`)

![Main Configuration](<./assets/Screenshot(188).png>)

### 2. Initialization & Planning

![Initialization](<./assets/Screenshot(189).png>)
![Execution Plan](<./assets/Screenshot(190).png>)

### 3. Deployment & Verification

![AWS Console Verification](<./assets/Screenshot(193).png>)
![Application Complete](<./assets/Screenshot(194).png>)

---

## 🚀 Advanced Learning: Using Outputs

I used `outputs.tf` to fetch the **Instance ID** and **Public IP** directly in the terminal.

![Outputs Configuration](<./assets/Screenshot(196).png>)
![Terminal Output Result](<./assets/Screenshot(197).png>)

---

## 🧠 Advanced Concepts: Terraform State

### 1. The Power of the State File

The state file is the **Single Source of Truth**. Without it, Terraform cannot track your infrastructure.

![Terraform Problems](<./assets/Screenshot(201).jpg>)
_Understanding the limitations and critical role of the state file._

### 2. Best Practices for State Management

- **Remote Storage:** Use AWS S3.
- **State Locking:** Use DynamoDB.
- **Isolation:** Reduce the "Blast Radius".

![State File Best Practices](./assets/state-file-best-practices.jpg)

### 3. The Ideal Terraform Architecture

A professional setup involving CI/CD pipelines and remote backends.

![Ideal Terraform Setup](./assets/ideal-terraform-setup.jpg)

---

## 🛠️ Commands Mastered

| Command             | Purpose              |
| :------------------ | :------------------- |
| `terraform init`    | Initialize directory |
| `terraform plan`    | Preview changes      |
| `terraform apply`   | Build infrastructure |
| `terraform output`  | View defined outputs |
| `terraform destroy` | Tear down resources  |

---

## 🤝 Connect with Me

[<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin">](https://www.linkedin.com/in/soham-sarkar-85a5a6247) | [<img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">](https://github.com/SohamSarkar025)
