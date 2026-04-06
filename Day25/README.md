![Progress](https://img.shields.io/badge/Progress-25%25-orange?style=for-the-badge&logo=docker)

# Day 25: Introduction to Kubernetes (K8s) — Beyond Docker

## Overview

Today I transitioned from managing individual containers to **Container Orchestration**. While Docker is excellent for creating and running containers on a single host, Kubernetes (K8s) provides the "pilot" needed to manage them at an enterprise scale. I explored why industry giants like Netflix rely on K8s for high availability and automated scaling.

<img src="assets/Screenshot (276).png" alt="Kubernetes Intro Overview"/>

## The Problem: Why Docker Alone Isn't Enough

In my previous labs, I ran Docker on a **Single Host**. However, production environments face challenges that standalone Docker cannot solve:

- **Ephemeral Nature:** Containers have a "short life." If the host fills up or crashes, the containers die and stay down.
- **Manual Intervention:** If 10 containers in a 100-container fleet crash, an engineer must manually identify and restart them.
- **No Native Auto-Scaling:** Docker cannot automatically spin up new replicas during a traffic spike (e.g., jumping from 10,000 to 1,000,000 users).

<img src="assets/Screenshot (270).png" alt="Single Host Limitations"/>

## The Solution: Kubernetes (The Orchestrator)

Originally developed by **Google** (based on their internal tool **Borg**), Kubernetes is now the industry standard maintained by the **CNCF**. It provides "Enterprise Level" support.

### Core Enterprise Features:

1.  **Auto-Healing:** If a container (Pod) fails, the K8s API Server detects it and automatically rolls out a new container to fix the damage.
2.  **Auto-Scaling (HPA):** Using the Horizontal Pod Autoscaler, K8s monitors CPU usage. If it hits a threshold (e.g., 80%), it automatically scales replicas from 1 to 10.
3.  **Load Balancing:** K8s intelligently distributes user traffic across all healthy containers so no single unit is overwhelmed.

<img src="assets/Screenshot (281).png" alt="K8s Auto-Healing Process"/>

## Architecture & Terminology

### The Cluster Environment

Kubernetes manages a **Cluster**, which is a group of nodes working together.

- **Master Node (Control Plane):** The "Brain" that monitors the cluster and makes global decisions.
- **Worker Nodes:** The "Muscle" where the actual applications (Pods) run.

<img src="assets/Screenshot (277).png" alt="K8s Cluster Architecture"/>

### Desired State vs. Actual State

We define our requirements in a **YAML** file (Deployment). Kubernetes constantly performs a "reconciliation loop" to ensure the **Actual State** matches our **Desired State**.

## Docker vs. Kubernetes: Comparison

| Feature            | Docker (Single Host)   | Kubernetes (Orchestrator)       |
| :----------------- | :--------------------- | :------------------------------ |
| **Primary Goal**   | Build & Run Containers | Manage & Orchestrate Clusters   |
| **Scaling**        | Manual                 | **Automatic (via HPA)**         |
| **Self-Healing**   | No (Manual Restart)    | **Yes (Automatic Replacement)** |
| **Infrastructure** | Single Machine         | **Cluster of Nodes**            |
| **Standard**       | Basic Containerization | **Enterprise Level Standard**   |

## Mastered Concepts

| Term              | Definition                                                         |
| :---------------- | :----------------------------------------------------------------- |
| **Cluster**       | A collection of nodes (servers) grouped to run containerized apps. |
| **API Server**    | The central management point that receives all commands.           |
| **HPA**           | Horizontal Pod Autoscaler (for automatic scaling).                 |
| **Desired State** | The configuration defined in YAML that K8s maintains.              |
| **Borg**          | The Google internal system that served as the predecessor to K8s.  |

## Key Takeaways

- **Orchestration is Essential:** For microservices, managing containers manually is impossible; K8s automates the entire lifecycle.
- **Fault Tolerance:** If a node becomes a "Faulty Node," K8s automatically moves the containers to a healthy one.
- **Scalability:** K8s allows applications to handle massive traffic spikes automatically, ensuring 100% uptime.

## Connect with Me

![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin) ![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github)
