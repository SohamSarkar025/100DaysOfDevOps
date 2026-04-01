![Progress](https://img.shields.io/badge/Progress-20%25-orange?style=for-the-badge&logo=docker)

# 🐳 Day 20: Launching my Web app using Dockerfile [ Advanced Dockerfile & Port Mapping Lab ]

## 📖 Overview

On Day 20 I containerized a full-stack Python (Django) web application. This lab covers advanced Dockerfile techniques, optional virtual environments inside containers, and exposing container services to the public internet via port mapping.

---

## 🏗️ Phase 1: The Advanced Dockerfile

I created a robust Dockerfile that handles environment isolation and dependency management.

**Key instructions used:**

- `WORKDIR /app` — set the working directory inside the image.
- `RUN python3 -m venv venv1` — create an (optional) virtual environment inside the container.
- `EXPOSE 8000` — document the container's internal port.
- `CMD` — activate the venv and start the Django server (as configured in the Dockerfile).

### Screenshots

Below are screenshots from the lab

![Screenshot 223](<assets/Screenshot%20(223).png>)
![Screenshot 224](<assets/Screenshot%20(224).png>)
![Screenshot 225](<assets/Screenshot%20(225).png>)
![Screenshot 226](<assets/Screenshot%20(226).png>)
![Screenshot 227](<assets/Screenshot%20(227).png>)
![Screenshot 228](<assets/Screenshot%20(228).png>)
![Screenshot 229](<assets/Screenshot%20(229).png>)

---

## 🛠️ Phase 2: Build & Port Mapping

### Build the image

```bash
docker build -t sohamdocker25/python-web-app .
```

### Run the container with port mapping

To make the app reachable from the host (and beyond), map a host port to the container port using `-p`:

```bash
docker run -it -p 8000:8000 sohamdocker25/python-web-app
```

Logic: `Host_Port:Container_Port` — mapping `8000:8000` exposes the container's port 8000 on the host's port 8000.

---

## 🌐 Phase 3: Networking & AWS Security Groups

1. Opening the gates: On EC2, add an inbound security group rule to allow TCP traffic on port `8000` (source as needed; `0.0.0.0/0` allows all).
2. Accessing the app: Use the EC2 public IP (for example `http://<EC2_PUBLIC_IP>:8000/demo/`) — `0.0.0.0` is not a reachable address from a browser; it's a wildcard bind address.

---

## 🧠 Lessons Learned

- **Port exposure vs mapping:** `EXPOSE` is documentation only; `-p` (or `--publish`) actually publishes container ports to the host.
- **Logs monitoring:** Use `docker logs -f <container>` to follow requests and debug runtime issues.
- **Environment isolation:** Creating a venv inside a container is optional; containers already isolate dependencies, but venvs can help for complex workflows or parity with local dev.

---

## 🛠️ Common Commands

- **Run container with port mapping:** `docker run -p 8000:8000 sohamdocker25/python-web-app`
- **Follow logs:** `docker logs -f <container-id|name>`
- **Start Django dev server (inside container or host):** `python manage.py runserver 0.0.0.0:8000`

---

## 🤝 Connect with Me

<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin"> | <img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">
