# Day 23: Docker Networking — Isolation & Connectivity Lab

## Overview

Today I dived deep into Docker Networking. In a microservices world, containers need to talk to each other while remaining isolated from unauthorized access. I performed a hands-on lab to understand Bridge, Host, and Custom Networks, and verified connectivity using the `ping` utility.

<img src="assets/Screenshot (252).png" alt="Docker networking overview"/>

## Core Concepts

### 1. The Docker Network Stack

By default, Docker provides three network drivers: `bridge`, `host`, and `none`.

Run:

```bash
docker network ls
```

### 2. Bridge Networking (Default)

It creates a private network between the host and containers.

Hands-on: I launched a container named `login` and installed `iputils-ping` to test internal communication.

Inspection: Using `docker inspect`, I identified the private IP assigned to my container (example: `172.17.0.3`) within the default bridge.

<img src="assets/Screenshot (253).png" alt="Bridge network inspect"/>

## Practical Lab: Isolation & Custom Networks

### Phase 1: Default Connectivity

I launched two containers: `login` and `logout`. By default, they both joined the `bridge` network.

Test: Inside the `login` container, I was able to successfully ping the `logout` container (example IP `172.17.0.3`).

<img src="assets/Screenshot (254).png" alt="Ping between containers on default bridge"/>

### Phase 2: Creating a Secure Custom Network

To isolate sensitive services, I created a custom bridge network called `secure-network`:

```bash
docker network create -d bridge secure-network
```

I then attached a new container to this network. In the inspection output it received an IP in a different subnet (example: `172.18.0.2`).

<img src="assets/Screenshot (255).png" alt="Custom network inspect"/>

### Phase 3: Verifying Network Isolation (The Security Test)

I tried to ping the container in `secure-network` from a container in the default `bridge` network.

Result: 100% Packet Loss.

<img src="assets/Screenshot (256).png" alt="Ping failed across networks"/>
<img src="assets/Screenshot (257).png" alt="Overlay network diagram"/>
Learning: Containers on different networks cannot communicate by default, providing a strong layer of security for databases or internal APIs.

## Other Network Modes

### Host Networking

The container shares the host system's network stack. It uses the same IP as the host.

```bash
docker run --network="host" nginx
```

Note: This reduces isolation and should be used with caution for specific high-performance needs.

### Overlay Networking

Used in Docker Swarm or multi-host environments to enable communication between containers running on different physical machines.

## Key Takeaways

- **Container Isolation:** Use custom networks to group related containers and isolate them from others.
- **Ping for Debugging:** Ensure `iputils-ping` is installed if you need to troubleshoot connectivity between services.
- **Dynamic Connection:** Use `docker network connect` to add a running container to an additional network without restarting it.

## Mastered Commands

| Command                    | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| `docker network ls`        | List all networks.                        |
| `docker network create`    | Create a new isolated network.            |
| `docker inspect <id>`      | Find container IP and network details.    |
| `docker run --net=<name>`  | Launch a container in a specific network. |
| `apt install iputils-ping` | Install `ping` tool inside a container.   |

## Connect with Me

![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin) ![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github)
