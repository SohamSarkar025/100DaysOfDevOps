![Progress](https://img.shields.io/badge/Progress-35%25-green?style=for-the-badge&logo=kubernetes)

# 🚀 Day 35: Kubernetes ConfigMaps & Secrets (Hands-on Lab)

**100 Days of DevOps Journey — Day 35**

## 📌 Overview

Today was a hands-on deep dive into decoupling application configuration from code. I practiced creating **ConfigMaps** and **Secrets** and injecting them into a Python web application using two primary methods: **Environment Variables** and **Volume Mounts**.

---

## 🛠️ Phase 1: Configuring with ConfigMaps (Env Variables)

### 1. Creating the ConfigMap Manifest

I started by defining a simple ConfigMap named `test-cm` to store a non-sensitive port value.

![ConfigMap YAML](<assets/Screenshot%20(438).png>)
_Manifest: Defining `db-port: "3306"` in the ConfigMap data section._

### 2. Method A: Injection via Environment Variables

I updated the Python app's `deployment.yml` to pull the `DB-PORT` directly from the ConfigMap using `valueFrom.configMapKeyRef`.

![Injection via Env](<assets/Screenshot%20(439).png>)
_Deployment: Mapping ConfigMap keys to Container environment variables._

### 3. Applying and Describing

I described the ConfigMap to ensure it was created correctly and then applied the deployment manifest.

![Applying Manifests](<assets/Screenshot%20(440).png>)
_Terminal: Verifying the ConfigMap data and applying the deployment._

### 4. Verification Inside the Pod

After applying the manifests, I used `kubectl exec` to verify that the environment variable was correctly injected inside the running Pod.

![Env Verification](<assets/Screenshot%20(441).png>)
_Terminal: Running `env | grep DB` inside the pod confirms `DB-PORT=3306`._

---

## 📂 Phase 2: Configuration via Volume Mounts

### 1. Mounting ConfigMap as a File

Sometimes apps need configuration as physical files. I re-configured the deployment to mount the ConfigMap data into the `/opt` directory using `volumeMounts`.

![Volume Mount YAML](<assets/Screenshot%20(442).png>)
_Manifest: Adding `volumeMounts` and defining a `volume` of type `configMap`._

### 2. Verifying the File System

Inside the pod, the key (`db-port`) became a filename, and the value became the file's content.

![Volume Verification](<assets/Screenshot%20(444).png>)
_Terminal: Successfully reading the port value from `/opt/db-port`._

### 3. Testing Hot-Reloading

I updated the ConfigMap value from `3306` to `3309` to see if Kubernetes dynamically updates mounted files.

![Editing ConfigMap](<assets/Screenshot%20(445).png>)
_Update: Changing the port value to `3309`._

![Hot Reload](<assets/Screenshot%20(446).png>)
_Result: The file content inside `/opt/db-port` automatically updated to `3309` in real-time without restarting the pod!_

---

## 🔐 Phase 3: Handling Sensitive Data with Secrets

### 1. Creating and Editing Secrets

I created a Generic Secret. Unlike ConfigMaps, Kubernetes Secrets obfuscate data using Base64 encoding.

![Secret Edit](<assets/Screenshot%20(447).png>)
_Security: Using `kubectl edit secret` shows the data is stored as a Base64 string `MzMwNg==`._

### 2. Decoding Secrets

I practiced creating a secret from literal values and verified the encoding/decoding process via the terminal.

![Secret Decoding](<assets/Screenshot%20(448).png>)
_Terminal: Decoding the Base64 string `MzMwNg==` using the `base64 --decode` command to reveal the original port `3306`._

---

## ✅ Key Takeaways for SREs

- **Decoupling is Key:** ConfigMaps allow the exact same Docker image to work across Dev, QA, and Prod environments just by changing the injected manifest.
- **Flexibility in Injection:** Environment variables are excellent for simple flags, whereas Volume Mounts are perfect for complex configuration files (like `nginx.conf`) and support hot-reloading.
- **Secret Management:** Native Kubernetes Secrets provide obfuscation (Base64), not strong encryption. For true production environments, implementing **RBAC** and encryption-at-rest in `etcd` is mandatory.

---

**Soham Sarkar** | _SRE Aspirant | Day 35 Hands-on Lab Completed_
