# Top 12 Docker Interview Q&A — Cheat Sheet

Quick reference of common Docker interview questions and concise answers.

1. **Q1: What is Docker and why is it used?**
   Answer: Docker is an open-source platform that uses containerization to package an application and all its dependencies into a standardized unit. We use it to eliminate the "it works on my machine" problem, ensuring the app runs identically in development, testing, and production.

2. **Q2: How do Containers differ from Virtual Machines (VMs)?**
   Answer: VMs run on a hypervisor and include a full guest OS, making them resource-heavy. Containers share the host OS kernel and only package app libraries/binaries, making them lightweight, faster to boot, and more efficient.

3. **Q3: Explain the Docker Architecture.**
   Answer: Follows a client-server model:
   - Client: CLI where commands like `docker build`, `docker run` are issued.
   - Docker Host (Daemon): `dockerd` manages images, containers, networks, volumes.
   - Registry: Storage for images (e.g., Docker Hub).

4. **Q4: What is the difference between an Image and a Container?**
   Answer: An Image is a read-only template (blueprint). A Container is a running instance of an image (like a class vs object in OOP).

5. **Q5: What is the difference between COPY and ADD?**
   Answer: `COPY` is preferred for simple local file copies into the image. `ADD` can also fetch remote URLs and auto-extract compressed tar files.

6. **Q6: CMD vs ENTRYPOINT — Which is better?**
   Answer: `ENTRYPOINT` sets the primary executable and is harder to override. `CMD` provides default arguments that are easy to override. Best practice: use `ENTRYPOINT` for the executable and `CMD` for default flags.

7. **Q7: What are Docker Volumes and why are they needed?**
   Answer: Containers are ephemeral; volumes persist data on the host, decoupling storage from container lifecycle. Essential for databases and persistent state.

8. **Q8: What is a Multi-Stage Build?**
   Answer: Use multiple `FROM` statements in one Dockerfile. Build in a heavier image, then copy only the final artifact into a slim production image to drastically reduce image size.

9. **Q9: What are Distroless Images?**
   Answer: Distroless images contain only the app and minimal runtime dependencies (no shell, package manager, or extras). They reduce attack surface and image size.

10. **Q10: What is the default networking driver?**
    Answer: The default driver is `bridge`, which creates an internal network for containers on the host; external access requires explicit port mapping.

11. **Q11: What are the main challenges/limitations of Docker?**
    Answer:
    - Docker daemon is a single point of failure for that host.
    - Security risks because the daemon often runs with elevated privileges.
    - Orchestration complexity: managing many containers requires tools like Kubernetes.

12. **Q12: How do you secure a Docker Container?**
    Answer:
    - Use minimal base images (Alpine or Distroless).
    - Scan images for vulnerabilities (Trivy, Snyk).
    - Run processes as a non-root user.
    - Set resource limits (CPU/memory) to prevent noisy-neighbor issues.

---
