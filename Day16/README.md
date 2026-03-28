![Progress](https://img.shields.io/badge/Progress-16%25-orange?style=for-the-badge&logo=progress)

# 📂 Day 16: Infrastructure as Code (IaC) & Terraform Architecture

## 📖 Overview
On Day 16, I transitioned from managing software configurations (Ansible) to managing the physical infrastructure itself using **Infrastructure as Code (IaC)**. I explored why Terraform has become the industry standard for modern DevOps, especially in hybrid and multi-cloud environments.

---

## 🏗️ Core Concepts & Visual Insights

### 1. The Evolution of Infrastructure
Before IaC, managing hundreds of servers meant writing manual scripts for each. Cloud providers introduced native tools, but they created "Vendor Lock-in."
* **AWS:** CloudFormation (CFT)
* **Azure:** Azure Resource Manager (ARM)
* **OpenStack:** Heat Templates

![IaC Evolution](./assets/Screenshot(181).jpg)
*Visualizing the transition from manual scripting to automated cloud-specific templates.*

---

### 2. Solving the Hybrid Cloud Challenge
Large organizations often use a **Hybrid Cloud** strategy—combining AWS, Azure, and On-premise data centers. Managing different tools for each cloud is inefficient. Terraform provides a **Unified Workflow** to manage them all.

![Hybrid Cloud Strategy](./assets/Screenshot(182).jpg)
*How Terraform acts as the single source of truth for diverse infrastructure across providers.*

---

### 3. Terraform: The "API as Code" Engine
Terraform doesn't just "click buttons" for you; it communicates directly with **Cloud APIs**. It translates HashiCorp Configuration Language (HCL) into API calls that cloud providers understand.

![Terraform API Workflow](./assets/Screenshot(183).jpg)
*The architecture showing how Terraform interacts with AWS, Azure, and GCP APIs via providers.*

---

### 4. Modules & Scalability
I learned how Terraform uses **Modules** to manage complex resources like EC2, VPCs, and Databases. This modularity allows DevOps engineers to reuse code and scale infrastructure effortlessly.

![Terraform Modules](./assets/Screenshot(184).jpg)
*Breaking down infrastructure into reusable, manageable, and version-controlled code blocks.*

---

## 🧠 DevOps Interview Q&A
**Q: What is the main advantage of Terraform being "Cloud Agnostic"?**
**A:** It allows a DevOps engineer to use a single tool and language (HCL) to manage multiple cloud providers. This reduces the learning curve and prevents "Vendor Lock-in," making the infrastructure portable and easier to manage in a Multi-Cloud setup.

---
## 🤝 Connect with Me
[<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin">](https://www.linkedin.com/in/soham-sarkar-85a5a6247) | [<img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">](https://github.com/SohamSarkar025)
