![Progress](https://img.shields.io/badge/Progress-39%25-green?style=for-the-badge&logo=jenkins)

# 🚀 Day 39: Jenkins Setup, Docker Integration & First Pipeline

**100 Days of DevOps Journey — Day 39**

## 📌 Overview

Today's lab transitioned from CI/CD theory to intense practical implementation. I successfully provisioned a fresh **Ubuntu 24.04 LTS** EC2 instance, manually installed **Jenkins**, integrated it natively with **Docker**, and configured my very first Pipeline job to pull source code directly from GitHub. This sets the foundation for fully automated "Pipeline as Code" workflows.

---

## ☁️ Phase 1: Cloud Infrastructure & Prerequisites

_(Reference GitHub for full AWS EC2 & Security Group provisioning screenshots)_

1. Launched an Ubuntu 24.04 EC2 instance (`t2.micro`).
2. Configured Security Groups for SSH (22) and Jenkins HTTP (8080).
3. Installed `openjdk-17-jdk` as the foundational runtime dependency.

---

## ⚙️ Phase 2: Jenkins Installation & Admin Setup

After securely importing the official Jenkins GPG keys and configuring the `debian-stable` apt repository, I successfully installed and verified the Jenkins service.

### 1. Account Initialization

After unlocking Jenkins with the initial admin password and installing suggested plugins, I created the primary Administrator account to secure the dashboard.

![Create Admin](<assets/Screenshot%20(582).png>)
_Security: Setting up the root `soham` admin user profile._

![Jenkins Ready](<assets/Screenshot%20(583).png>)
_Initialization: The setup wizard completed successfully._

![Jenkins Dashboard](<assets/Screenshot%20(584).png>)
_Dashboard: Welcome to the Jenkins Master Console._

---

## 🐳 Phase 3: Docker Integration (Crucial SRE Step)

Modern CI/CD pipelines build and push containerized applications. Therefore, the Jenkins server must have Docker installed and the correct permissions configured.

### 1. Installing the Docker Daemon

I installed Docker directly onto the EC2 instance hosting Jenkins.

![Install Docker](<assets/Screenshot%20(585).png>)
_Terminal: Running `sudo apt install docker.io` on the host machine._

### 2. User Group Permissions

**Critical Step:** By default, Jenkins cannot interact with Docker. I added both the `jenkins` user and the `ubuntu` user to the `docker` group to prevent permission denied (`sock`) errors during pipeline builds.

![Docker Permissions](<assets/Screenshot%20(586).png>)
_Permissions: Executing `usermod -aG docker jenkins` and restarting the service._

### 3. Daemon Verification

![Docker Hello World](<assets/Screenshot%20(587).png>)
_Verification: Running `docker run hello-world` to confirm the engine is operational._

### 4. Jenkins Docker Plugin

To allow Jenkinsfiles to natively understand Docker commands, I installed the official "Docker Pipeline" and "Docker" plugins from the Jenkins Plugin Manager and safely restarted the server.

![Docker Plugin](<assets/Screenshot%20(588).png>)
_Plugins: Searching and installing the required Docker Pipeline extensions._

![Jenkins Restart](<assets/Screenshot%20(589).png>)
_Maintenance: Performing a safe restart to apply plugin changes._

---

## 🚀 Phase 4: Creating the First Pipeline Job (Pipeline as Code)

With the infrastructure and plugins ready, it was time to link Jenkins to my actual code.

### 1. The Declarative Jenkinsfile

I created a declarative `Jenkinsfile` in VS Code. It spins up a `node:16-alpine` Docker container as the agent and runs a simple shell command (`node --version`) to verify the environment.

![Jenkinsfile Code](<assets/Screenshot%20(595).png>)
_Code: Writing the declarative pipeline logic using the `docker` agent._

### 2. Job Creation & SCM Configuration

I created a new item named `first-jenkins-job` and explicitly chose the **Pipeline** type. Instead of hardcoding the pipeline steps in the Jenkins UI, I configured it to pull the `Jenkinsfile` directly from my GitHub repository (`100DaysOfDevOps`).

![New Pipeline Job](<assets/Screenshot%20(590).png>)
_Configuration: Initializing the new Pipeline workspace._

![SCM Configuration](<assets/Screenshot%20(591).png>)
_SCM: Connecting Jenkins to my remote Git repository._

![Script Path Setup](<assets/Screenshot%20(597).png>)
_Pathing: Pointing Jenkins exactly to the `Day39/my-first-jenkinsfile/Jenkinsfile` location._

---

## 🏁 Phase 5: Pipeline Execution & Verification

### 1. Triggering the Build

I manually triggered the build. Jenkins successfully fetched the repository, read the `Jenkinsfile`, downloaded the required Docker image, and executed the stages.

![Build Console Output 1](<assets/Screenshot%20(592).png>)
_Console: Jenkins pulling the `node:16-alpine` image._

![Build Console Output 2](<assets/Screenshot%20(593).png>)
_Console: Fetching the exact commit revision from GitHub._

![Successful Execution](<assets/Screenshot%20(594).png>)
_Success: The pipeline executed perfectly, outputting `v16.20.2` and finishing with SUCCESS._

### 2. Advanced Multi-Stage Pipelines (Bonus)

To push my learning further, I created a more complex `multi-stage-multi-build` Jenkinsfile featuring separate stages for Back-end (Maven) and Front-end (Node).

![Multi-stage Jenkinsfile](<assets/Screenshot%20(596).png>)
_Architecture: Defining distinct stages with different container agents._

![Multi-stage Console 1](<assets/Screenshot%20(598).png>)
_Execution: Jenkins handling the multi-stage build process._

![Multi-stage Console 2](<assets/Screenshot%20(599).png>)
_Final Result: Successful execution of the complex pipeline flow._

---

## ✅ Key Takeaways

- **Permission Management:** Understanding Linux user groups (`usermod -aG`) is mandatory for allowing CI tools like Jenkins to control daemonized services like Docker.
- **Pipeline as Code:** Configuring jobs to fetch from SCM ensures that infrastructure and deployment logic is version-controlled alongside the application code.
- **Ecosystem Integration:** Jenkins is powerful, but its true strength unlocks when paired with plugins (like Docker Pipeline) that bridge it to other enterprise tools.

---

**Soham Sarkar** | _SRE Aspirant | Day 39 Successfully Completed_
