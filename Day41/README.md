![Progress](https://img.shields.io/badge/Progress-41%25-green?style=for-the-badge&logo=kubernetes)

# Day 41: End-to-End GitOps CI/CD Pipeline 🚀

Welcome to Day 41 of my **100 Days of DevOps** journey! Today's milestone involved architecting and deploying a fully automated, production-grade Continuous Integration and Continuous Deployment (CI/CD) pipeline using the GitOps methodology.

As a transitioning Junior Software Engineer and Subject Matter Expert (SME), building this robust architecture from scratch was a massive leap in mastering Site Reliability Engineering (SRE) practices.

## 🏗️ Architecture Overview

This project successfully automates the lifecycle of a Java Spring Boot application ("Soham's DevOps Lab") from code commit to Kubernetes deployment.
![Ultimate Pipeline](assets/ultimate-cicd-pipeline-structure.jpeg)

**The CI/CD Flow:**

1. **Source Code Management:** Developer pushes code to **GitHub**.
2. **Continuous Integration (Jenkins):** - Code checkout.
   - Maven Build & Test.
   - Static Code Analysis via **SonarQube**.
   - Docker Image creation & push to **DockerHub**.
   - Automated Git commit to update `deployment.yml` with the new image tag.
3. **Continuous Deployment (ArgoCD):**
   - ArgoCD monitors the GitHub repository and detects the updated manifest.
   - Automatically synchronizes and deploys the new pods to the **Kubernetes** cluster.

---

## 🛠️ Tech Stack & Tools Used

- **Infrastructure:** AWS EC2 (Ubuntu 24.04), VirtualBox
- **Containerization & Orchestration:** Docker, Kubernetes (Minikube)
- **CI/CD Tools:** Jenkins, ArgoCD (GitOps)
- **Code Quality:** SonarQube, Maven
- **Version Control:** Git, GitHub

---

**Project Overview**: Step-by-step setup for EC2, Docker, SonarQube, Minikube, and ArgoCD

**Prerequisites**:

- **OS**: Ubuntu 24.04 (on AWS EC2)
- **User**: a sudo-capable user on the instance
- **Ports**: make sure your security group allows SSH (22) and any required service ports (SonarQube, Minikube, ArgoCD)

**Phase 1: Infrastructure & Environment Setup (EC2 & Docker)**

- **Purpose**: Prepare an Ubuntu 24.04 EC2 instance with Java and Docker for Jenkins, SonarQube, and container workloads.
- **Commands**:

```bash
# 1. System update
sudo apt update && sudo apt upgrade -y

# 2. Install Java 17 & 21 (for Jenkins & SonarQube coexistence)
sudo apt install -y openjdk-17-jdk openjdk-21-jdk

# 3. Install Docker and adjust permissions
sudo apt install -y docker.io
sudo systemctl enable --now docker
# Allow non-root Docker access for simplicity (optional; consider use of docker group in production)
sudo chmod 666 /var/run/docker.sock

# Verify installations
java -version
docker --version
```

**Phase 2: Static Code Analysis Setup (SonarQube)**

- **Purpose**: Install SonarQube for code quality gates and scanning.

- **Commands**:

```bash
# 1. Create dedicated system user for SonarQube
sudo adduser --system --no-create-home --group sonarqube

# 2. Download and extract SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
unzip sonarqube-*.zip
sudo mv sonarqube-10.4.1.88267 /opt/sonarqube

# 3. Fix permissions & ownership
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# 4. Start SonarQube as the sonarqube user (interactive)
sudo su -s /bin/bash - sonarqube -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"

# 5. Verify status
/opt/sonarqube/bin/linux-x86-64/sonar.sh status
```

**Phase 3: GitOps Foundation (Minikube & ArgoCD)**

- **Purpose**: Bring up a local Kubernetes cluster (Minikube) and deploy ArgoCD via the ArgoCD operator for GitOps workflows.

- **Commands** (on a desktop/VM that supports virtualization):

```bash
# 1. Start Minikube (use a driver available on your host, e.g., virtualbox, docker)
minikube start --driver=virtualbox

# 2. Install Operator Lifecycle Manager (OLM)
curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.42.0/install.sh | bash -s v0.42.0

# 3. Deploy ArgoCD Operator
kubectl apply -f https://operatorhub.io/install/argocd-operator.yaml

# 4. Verify Operator CSV in the operators namespace
kubectl get csv -n operators

# 5. Apply the ArgoCD Custom Resource manifest
# (use the provided manifest in this repo if available)
kubectl apply -f "java-maven-sonar-argocd-helm-k8s/Argo%20CD/argocd-basic.yaml"
```

**Phase 4: Deployment Validation & Access**

- **Purpose**: Validate cluster resources, extract credentials, and expose services.

- **Commands**:

```bash
# 1. Check cluster resources
kubectl get pods -A

# 2. Extract ArgoCD initial admin password (example secret name varies with deployment)
kubectl get secret example-argocd-cluster -n operators -o jsonpath="{.data.admin\.password}" | base64 -d

# 3. Discover service ports (to find which service exposes ArgoCD or the app)
kubectl get svc -n operators

# 4. Tunnel to the Spring Boot application via Minikube (service name example)
minikube service spring-boot-app-service --url
```

**Verification**:

- Use the `kubectl` output to confirm pods are `Running` and `READY`.
- Access the Spring Boot app URL printed by `minikube service --url` in your browser.

---

## 📸 Project Showcase

### 1. The Final Result: Live Application 🌐

Successfully deployed the Spring Boot application, accessible via the Minikube service.
![Live Website Home](<Screenshot%20(664).png>)
![Final Deployment Success](<Screenshot%20(653).png>)

### 2. Infrastructure & Environment Setup 💻

Provisioning AWS EC2 and configuring the essential security groups for traffic management.
![AWS EC2 Instance Details](<Screenshot%20(621).png>)
![Security Group Inbound Rules](<Screenshot%20(623).png>)
![Initial Environment Setup via Terminal](<Screenshot%20(622).png>)
![Minikube & OLM Setup](<Screenshot%20(642).png>)

### 3. Static Code Analysis (SonarQube) 🔍

Detailed setup and troubleshooting of the SonarQube service.
![SonarQube Download](<Screenshot%20(627).png>)
![SonarQube Extraction & Installation](<Screenshot%20(628).png>)
![Starting the SonarQube Service](<Screenshot%20(629).png>)
![Fixing SonarQube Runtime Issues](<Screenshot%20(634).png>)
![SonarQube Status Verification](<Screenshot%20(632).png>)
![SonarQube UI Loading](<Screenshot%20(633).png>)
![SonarQube Project Passed](<Screenshot%20(652).png>)

### 4. Continuous Integration (Jenkins) ⚙️

Configuring Jenkins plugins, pipeline credentials, and GitHub integrations.
![Jenkins Plugin Management](<Screenshot%20(631).png>)
![GitHub Source Integration](<Screenshot%20(625).png>)
![Jenkins Pipeline Script Configuration](<Screenshot%20(624).png>)
![Console Output: Pipeline Start](<Screenshot%20(650).png>)
![Final Success Log](<Screenshot%20(651).png>)

### 5. Secure Credential Management 🔐

Managing secrets for DockerHub and GitHub Personal Access Tokens (PAT).
![GitHub Token Generation](<Screenshot%20(646).png>)
![GitHub Token Permissions](<Screenshot%20(647).png>)
![Adding DockerHub Credentials to Jenkins](<Screenshot%20(644).png>)
![Adding GitHub Token to Jenkins](<Screenshot%20(648).png>)
![Stored Jenkins Credentials Dashboard](<Screenshot%20(649).png>)

### 6. GitOps Deployment (ArgoCD) ⛴️

Installing and configuring ArgoCD within the Kubernetes cluster.
![ArgoCD Operator Overview](<Screenshot%20(640).png>)
![Step-by-Step ArgoCD Installation](<Screenshot%20(641).png>)
![ArgoCD CSV Verification](<Screenshot%20(643).png>)
![ArgoCD Login Page](<Screenshot%20(659).png>)
![ArgoCD Dashboard Ready](<Screenshot%20(660).png>)
![Configuring ArgoCD App Source](<Screenshot%20(661).png>)
![Application Syncing on ArgoCD](<Screenshot%20(663).png>)

### 7. Cluster Validation & Troubleshooting 🛠️

Verifying the state of pods, services, and manifests.
![Editing ArgoCD Manifest](<Screenshot%20(654).png>)
![CLI Troubleshooting Commands](<Screenshot%20(655).png>)
![Kubernetes Resources Status](<Screenshot%20(656).png>)
![Pods Running Successfully](<Screenshot%20(657).png>)

---
