![Progress](https://img.shields.io/badge/Progress-42%25-green?style=for-the-badge&logo=kubernetes)

# Day 42: Cloud-Native CI with GitHub Actions 🚀

Welcome to Day 42 of my **100 Days of DevOps** journey! After successfully architecting a heavy, self-hosted CI/CD pipeline using Jenkins and ArgoCD yesterday, today I shifted gears to explore modern, serverless automation using **GitHub Actions**.

The goal for today was to set up an automated Continuous Integration (CI) pipeline that triggers on every push, dynamically provisions a runner, installs dependencies, and executes Python unit tests using `pytest`.

## 🏗️ Workflow Architecture Overview

Unlike Jenkins, which requires dedicated infrastructure (like an EC2 instance), GitHub Actions executes workflows on managed virtual environments directly within the repository.

## 🛠️ Tech Stack & Tools Used

- **CI/CD Platform:** GitHub Actions
- **Language:** Python
- **Testing Framework:** Pytest
- **Version Control:** Git & GitHub

---

**The CI Flow:**

1. **Trigger:** A developer pushes code to the `main` branch.
2. **Runner Allocation:** GitHub spins up a fresh `ubuntu-latest` virtual machine.
3. **Matrix Strategy:** The pipeline concurrently runs jobs for multiple Python versions (3.8 and 3.9) to ensure cross-version compatibility.
4. **Execution Steps:**
   - Checkout the repository code.
   - Set up the specified Python environment.
   - Install dependencies (`pytest`).
   - Run unit tests against the source code (`addition.py`).

---

## 📸 Project Showcase & Execution

### 1. The Source Code & Test Logic 🐍

A simple Python script containing an addition function and its corresponding assertions for unit testing.
![Python Test Script](<assets/Screenshot%20(675).png>)

### 2. The GitHub Actions Workflow (YAML) ⚙️

The declarative `.github/workflows/main.yml` file that defines the pipeline, showcasing the use of the Matrix strategy.
![GitHub Actions YAML](<assets/Screenshot%20(674).png>)

### 3. Pipeline Trigger & Execution 🏃‍♂️

The workflow automatically triggering upon code push. Notice the parallel jobs running for both Python 3.8 and 3.9.
![Workflow Triggered](<assets/Screenshot%20(670).png>)

### 4. Build Logs & Dependency Installation 📦

Deep dive into the runner logs, showing successful fetching of the environment and installation of `pytest`.
![Dependency Installation Logs](<assets/Screenshot%20(671).png>)
![Test Execution Logs](<assets/Screenshot%20(672).png>)

### 5. Final Victory: CI Pipeline Success ✅

The workflow completes successfully, validating that the code passes all checks across all specified environments.
![Workflow Success](<assets/Screenshot%20(673).png>)

---

## Comparing with Jenkins

### Advantages of GitHub Actions over Jenkins

- Hosting: Jenkins is self-hosted, meaning it requires its own server to run, while GitHub Actions is hosted by GitHub and runs directly in your GitHub repository.

- User interface: Jenkins has a complex and sophisticated user interface, while GitHub Actions has a more streamlined and user-friendly interface that is better suited for simple to moderate automation tasks.

- Cost: Jenkins can be expensive to run and maintain, especially for organizations with large and complex automation needs. GitHub Actions, on the other hand, is free for open-source projects and has a tiered pricing model for private repositories, making it more accessible to smaller organizations and individual developers.

### Advantages of Jenkins over GitHub Actions

- Integration: Jenkins can integrate with a wide range of tools and services, but GitHub Actions is tightly integrated with the GitHub platform, making it easier to automate tasks related to your GitHub workflow.

In conclusion, Jenkins is better suited for complex and large-scale automation tasks, while GitHub Actions is a more cost-effective and user-friendly solution for simple to moderate automation needs.
