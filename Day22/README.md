![Progress](https://img.shields.io/badge/Progress-22%25-orange?style=for-the-badge&logo=docker)

# 🐳 Day 22: Persistent Storage — Bind Mounts vs. Volumes

## 📖 Overview

Today's lab was dedicated to **Docker Storage**. I explored how to bypass the union file system to provide persistent storage to containers. Understanding the difference between Bind Mounts and Volumes is essential for managing databases, logs, and stateful applications in production.

---

## 🏗️ Architectural Concepts

I analyzed how data flows between the Host OS and Containers.

### 1. Bind Mounts

- Maps a **specific path** on the Host machine to a path in the Container.
- Great for development (e.g., source code hot-reloading).
- Dependent on the host's directory structure.

### 2. Docker Volumes

- Managed entirely by Docker in a dedicated part of the host filesystem (`/var/lib/docker/volumes/`).
- Higher performance and decoupled from the host's directory structure.
- Best for production databases and backups.

![Storage Architecture Analysis](<./assets/Screenshot%20(240).png>)

---

## 🛠️ Hands-on Lab: Volume Management

### 1. Creating and Inspecting a Volume

```bash
docker volume create Soham
docker volume ls
docker volume inspect Soham
```

Observation: Docker created a mount point at `/var/lib/docker/volumes/Soham/_data` on my EC2 instance.

### 2. Mounting Volume to a Container

I ran an Nginx container and mounted my volume using the `--mount` flag (industry-preferred syntax for clarity):

```bash
docker run -d --mount source=Soham,target=/app nginx:latest

```

![Docker Commands](<./assets/Screenshot%20(245).png>)

Detailed JSON output showed the volume `Soham` successfully mounted to the destination `/app`.

![Docker Container Inspect](<./assets/Screenshot%20(244).png>)

### 🔍 Deep Dive: How Data Survives

Even if you remove a container (`docker rm -f <container_id>`), the data inside the `Soham` volume remains on the host. This is the foundation for running stateful apps like MySQL or PostgreSQL in Docker.

### 📊 Comparison: Bind Mounts vs Volumes

| Feature          |           Bind Mounts |                                     Docker Volumes |
| ---------------- | --------------------: | -------------------------------------------------: |
| Storage Location |      Any path on Host | Docker's internal area (`/var/lib/docker/volumes`) |
| Managed By       | User (path sensitive) |                                      Docker Engine |
| Performance      |          Standard I/O |                             Higher-performance I/O |
| Portability      |   Harder (paths vary) |           Easier (same volume name across systems) |

### 🛠️ Mastered Commands

```
docker volume create <name>    # Create a managed persistent storage
docker volume ls               # List all volumes
docker volume inspect <name>   # Check mount details and source paths
docker run --mount ...         # Mount storage with explicit syntax
docker volume prune            # Clean up unused storage
```

---

## 🤝 Connect with Me

<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin"> | <img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">
