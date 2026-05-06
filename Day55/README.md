![Progress](https://img.shields.io/badge/Progress-55%25-orange?style=for-the-badge&logo=amazonaws)

# AWS Project: High-Availability Production VPC & Auto Scaling Infrastructure

## 📌 Project Overview: Day 55

This project demonstrates the implementation of a production-grade Virtual Private Cloud (VPC) with high availability and automated scaling. The architecture is designed to host mission-critical application servers within private subnets while ensuring they remain resilient across multiple Availability Zones.

![Project Banner](<assets/Screenshot%20(31).png>)

## 🎯 Architectural Goals

To meet modern production standards, this environment features:

- **Multi-AZ Resiliency**: Infrastructure is spread across two Availability Zones using an Auto Scaling Group and an Application Load Balancer.
- **Network Security**: Application servers are completely isolated in **private subnets** with no public IP addresses.
- **Redundant Connectivity**: Dual NAT Gateways provide high-availability outbound internet access for maintenance.
- **Secure Management**: A hardened Bastion Host (Jump Server) provides a secure gateway for administrative tasks.

![Architectural Strategy](<assets/Screenshot%20(30).png>)

---

## 🏗️ Architecture & Core Components

The foundation relies on a custom VPC layout that strictly separates public-facing entry points from private compute resources.

![Architecture Detail](<assets/Screenshot%20(33).png>)
![Subnet Overview](<assets/Screenshot%20(32).png>)

### Key Components:

- **Auto Scaling Group (ASG)**: Orchestrates the fleet of EC2 instances to maintain availability.
- **Launch Template**: Acts as the gold image/blueprint for all instances.
- **Bastion Host / Jump Server**: A strictly controlled entry point in the public subnet.
- **Application Load Balancer (ALB)**: The entry point for public traffic, routing requests to the private instances.

![Component Breakdown](<assets/Screenshot%20(34).png>)

---

## 🛠️ Phase 1: Custom Networking Foundation

We began by building the networking layer from scratch to ensure a secure and redundant path for traffic.

![VPC Dashboard](<assets/Screenshot%20(35).png>)
![Subnet Configuration](<assets/Screenshot%20(36).png>)
![Route Table Setup](<assets/Screenshot%20(37).png>)
![Gateway Configuration](<assets/Screenshot%20(38).png>)

---

## 🚀 Phase 2: Compute & Scaling Setup

With the network ready, we configured the compute layer using standardized images and automated scaling.

### 1. Launch Template Configuration

We established a blueprint using **Ubuntu Server 24.04 LTS** and **t2.micro** instances. Security groups were configured to allow traffic on port 8000 for our application.

![Template Details](<assets/Screenshot%20(43).png>)
![Security Group Settings](<assets/Screenshot%20(45).png>)

### 2. Auto Scaling Group (ASG) Deployment

The ASG was configured to distribute instances exclusively within the **Private Subnets** across two Availability Zones.

![ASG Subnet Mapping](<assets/Screenshot%20(48).png>)
![ASG Scaling Limits](<assets/Screenshot%20(49).png>)

---

## 🛡️ Phase 3: Secure Management & App Deployment

To manage the internal fleet and deploy the application, we utilized a Bastion Host and secure tunneling.

### 1. Bastion Host Configuration

The Bastion is a hardened instance with a public IP, configured only for SSH access.

![Bastion Security Rules](<assets/Screenshot%20(58).png>)
![Bastion Summary](<assets/Screenshot%20(60).png>)

### 2. Tunneling & Deployment

We transferred our PEM key to the Bastion via `scp` and successfully jumped into the private instances to deploy a simple web server on Port 8000.

**Step 1 — Fixing key permissions & SSH into the private instance via Bastion:**

![Secure Access & Tunneling](<assets/Screenshot%20(66).png>)

**Step 2 — Writing the HTML page served by the app:**

![HTML Configuration](<assets/Screenshot%20(67).png>)

**Step 3 — Starting the Python HTTP server on Port 8000:**

![Starting Python Server](<assets/Screenshot%20(68).png>)

---

## ⚖️ Phase 4: External Access (Application Load Balancer)

The final phase involves exposing the private application to the internet securely via an ALB.

### 1. Target Group Creation

We created a target group named `aws-prod-example` to organize our private instances.

- **Target Type**: Instances.
- **Protocol/Port**: HTTP on Port 8000.

**Step 1 — Choosing target type and naming the group:**

![Target Type Selection — Instances chosen, group named aws-prod-example](<assets/Screenshot%20(74).png>)

**Step 2 — Configuring protocol (HTTP), port (8000), and VPC:**

![Target Group Settings — HTTP protocol, Port 8000, VPC selected](<assets/Screenshot%20(75).png>)

**Step 3 — Target optimizer and default attributes:**

![Target Group Attributes — Default attributes, Target optimizer off](<assets/Screenshot%20(73).png>)

**Step 4 — Registering the two private instances (port 8000) as pending targets:**

![Register Targets — 2 instances selected, port 8000, pending inclusion](<assets/Screenshot%20(76).png>)

**Step 5 — Final review of health check settings and registered targets before creation:**

![Review Targets — Health check config, 2 targets in us-east-1a and us-east-1b](<assets/Screenshot%20(77).png>)

**Target Group Overview — 2 registered targets, HTTP:8000, linked to aws-prod-example ALB:**

![Target Group Details Overview](<assets/Screenshot%20(87).png>)

### 2. ALB Configuration & Routing

We provisioned an Internet-facing ALB named `aws-prod-example-vpc`.

- **Network Mapping**: The ALB was mapped to the **Public Subnets** in both `us-east-1a` and `us-east-1b`.
- **Listeners**: A listener on **Port 80** was added to forward HTTP traffic directly to the `aws-prod-example` target group.

**ALB basic configuration — name and Internet-facing scheme:**

![ALB Basic Config — Name and Internet-facing scheme](<assets/Screenshot%20(69).png>)

**Network mapping — public subnets selected in both Availability Zones:**

![ALB Network Mapping — Public subnets in us-east-1a and us-east-1b](<assets/Screenshot%20(70).png>)

**Security group assignment and HTTP:80 listener:**

![ALB Security Group — aws-prod-vpc-security-group assigned](<assets/Screenshot%20(71).png>)

**Listener default action — forwarding all traffic to the `aws-prod-example` target group (100%):**

![ALB Listener Forwarding — aws-prod-example target group selected, HTTP, 100% weight](<assets/Screenshot%20(78).png>)

**Final review before ALB creation — creation workflow and status:**

![ALB Final Review — Create load balancer screen with security group warning](<assets/Screenshot%20(79).png>)

### 3. Troubleshooting: Security Group Fix

After creation, the ALB console flagged a **"Reachability may be impacted"** warning — the existing security group only allowed port 8000 and SSH (22), but not port 80 for the ALB listener.

**Security tab showing the reachability warning:**

![ALB Security Tab — Reachability warning due to missing port 80 rule](<assets/Screenshot%20(81).png>)

**Editing inbound rules — adding HTTP port 80 to the security group:**

![Edit Inbound Rules — Adding HTTP port 80 rule alongside existing port 8000 and SSH](<assets/Screenshot%20(82).png>)

**Security group updated successfully with all 3 required rules (8000, 80, 22):**

![Security Group Updated — 3 inbound rules: TCP 8000, HTTP 80, SSH 22](<assets/Screenshot%20(83).png>)

### 4. ALB Provisioning & DNS Verification

**ALB provisioning — status set to "Provisioning", DNS name copied:**

![ALB Provisioning — Internet-facing ALB being provisioned, DNS name copied](<assets/Screenshot%20(84).png>)

**ALB active — listeners and rules confirmed, HTTP:80 forwarding to aws-prod-example:**

![ALB Active — Listener HTTP:80 forwarding to aws-prod-example at 100%](<assets/Screenshot%20(80).png>)

**Initial DNS test — site unreachable while ALB was still propagating:**

![DNS Not Reachable Yet — DNS_PROBE_FINISHED_NXDOMAIN during ALB propagation](<assets/Screenshot%20(85).png>)

---

## ✅ Final Verification

After DNS propagation completed and the security group was corrected, the ALB successfully served the application. External traffic entered via the ALB DNS on Port 80 and was routed to the private app tier running on Port 8000 — confirming a fully operational production-grade architecture.

**"VPC PROD: ONLINE" — application successfully reached via the ALB public DNS:**

![VPC PROD ONLINE — Application live via ALB DNS, Connectivity Verified Successfully](<assets/Screenshot%20(86).png>)

**Target group health status — 1 healthy target in us-east-1a, 1 unhealthy in us-east-1b (server not yet started on second instance):**

![Target Group Health — 2 total targets, 1 healthy (us-east-1a), 1 unhealthy (us-east-1b)](<assets/Screenshot%20(88).png>)

---
