![Progress](https://img.shields.io/badge/Progress-31%25-green?style=for-the-badge&logo=kubernetes)

# 🚀 Day 31: Mastering Kubernetes Networking & Observability [Service Deep Dive]

## 📌 Overview

Day 30 was a pivotal milestone where I transitioned from local containerization to orchestrating a full-stack Python application on Kubernetes (Minikube). This lab focused on deployment strategies, service discovery, handling Windows networking hurdles, and implementing deep-packet observability using Kubeshark.

---

## 🛠️ Step 1: Application Deployment & Self-Healing

- I wrote a `deployment.yml` for my Python web app and set `replicas: 2` to ensure high availability.
- Important: set `containerPort: 8000` to match the application's listening port.
- Observation: when I manually deleted a Pod, Kubernetes immediately recreated it (example: `python-web-app-5688f497b8-zr9c7`) to maintain the desired state.

Screenshots:

- Deployment manifest: ![Deployment Manifest](<assets/Screenshot%20(360).png>)
- Pod self-healing: ![Pod Self-Healing](<assets/Screenshot%20(363).png>)

---

## 🌐 Step 2: Service Discovery & NodePort Configuration

- To expose the app outside the cluster I created a `NodePort` Service named `python-django-app-service`.
- Port mapping: Service `port: 80` -> Pod `targetPort: 8000`.
- Exposed `nodePort: 30007` on the Minikube node.

Screenshot: ![Service YAML](<assets/Screenshot%20(364).png>)

---

## 🚧 Step 3: Overcoming Windows Networking Hurdles

- Using the Docker driver on Windows 11, the Minikube node IP (e.g. `192.168.49.2`) was not directly reachable from the host.
- Solution: use the Minikube service tunnel to bridge host ↔ cluster networking.

Example command used:

```bash
minikube service python-django-app-service
```

- Result: Successfully accessed the app at `http://127.0.0.1:52729/demo/` via the tunnel.

Screenshots:

- Browser success: ![Browser Success](<assets/Screenshot%20(365).png>)
- Minikube tunnel terminal: ![Tunnel Terminal](<assets/Screenshot%20(366).png>)

---

## 📦 Step 4: Mastering Helm (The Package Manager)

- Instead of manual YAMLs, I used Helm to manage the Kubeshark installation.

Commands used:

```bash
helm repo add kubeshark https://helm.kubeshark.com
helm install kubeshark kubeshark/kubeshark
```

Screenshot: ![Helm Install Success](<assets/Screenshot%20(369).png>)

---

## 🔍 Step 5: Real-time Observability with Kubeshark

- Captured live HTTP traffic using Kubeshark (eBPF-based, zero-instrumentation).
- By curling the tunneled URL (`curl -L http://127.0.0.1:52729/demo/`) I could visualize L7 traffic flowing into the Pods and inspect request/response headers and payloads directly from the dashboard.

Screenshot: ![Kubeshark Dashboard](<assets/Screenshot%20(371).png>)

Technical insight: Kubeshark leverages eBPF at the kernel level for deep packet inspection without modifying application code.

---

## ✅ Conclusion & Key Takeaways

- **Self-Healing:** Kubernetes maintains desired state and replaces failed pods automatically.
- **Tunneling on Windows:** For Minikube with the Docker driver, `minikube service` (or tunnels) are essential to access services from the host.
- **Observability:** Tools like Kubeshark provide powerful, zero-instrumentation visibility into microservice network traffic.

---
