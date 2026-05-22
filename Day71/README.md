![Progress](https://img.shields.io/badge/Progress-71%25-brightgreen?style=for-the-badge&logo=amazonaws)
![ALB](https://img.shields.io/badge/AWS-ALB-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![NLB](https://img.shields.io/badge/AWS-NLB-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![GWLB](https://img.shields.io/badge/AWS-GWLB-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![OSI](https://img.shields.io/badge/Networking-OSI_Model-0052CC?style=for-the-badge&logoColor=white)

# Day 71 - AWS Load Balancers: ALB, NLB & GWLB Deep Dive

## Overview

On Day 71, I studied the **three types of AWS Load Balancers** — Application Load Balancer (ALB), Network Load Balancer (NLB), and Gateway Load Balancer (GWLB) — along with the **OSI model layers** they operate on. The session covered why load balancers exist, how HTTP/HTTPS traffic flows through OSI layers, ALB's path/host/domain-based routing, NLB's low-latency TCP/UDP handling, and GWLB's role in security appliance chaining. All concepts were explored through whiteboard diagrams.

**Core insight: Every AWS Load Balancer maps to a specific OSI layer — ALB=L7, NLB=L4, GWLB=L3/L4 — and that layer determines what it can "see" and route on.**

---

## Concept Notes

### Why Load Balancers Exist

Without a load balancer, all traffic hits a single EC2 instance. As user count grows:

```
Without LB:                          With LB:
                                      100 requests
1000 users                                 │
     │                             ┌───────▼────────┐
     ▼                             │  Load Balancer  │ ← Round Robin
  EC2 ← overloaded                 │  (ALB/NLB/GWLB) │
  ↓ Slowness                       └───┬───┬───┬────┘
  ↓ Downtime                           │   │   │
                                      E1  E2  E3
                                    33%  33%  33%
                                    → Highly Available ✅
```

Problems a load balancer solves: **Slowness**, **Downtime**, and **single point of failure**. The solution: **High Availability** by distributing traffic using **Round Robin** across multiple EC2 instances.

Software load balancers (self-managed alternatives): **nginx**, **F5**, **Envoy**

![AWS Load Balancers overview — why LB is needed, ALB/NLB/GWLB types, Round Robin, EC2 distribution, nginx/F5/Envoy](<assets/Screenshot (438).png>)

---

### The OSI Model — Why It Matters for Load Balancers

A load balancer operates at a specific **OSI layer**. The layer it operates at determines what information it can inspect and route on. Higher layer = more context = smarter routing.

```
User types: linkedin.com
     │
     ▼  HTTP request sent
┌─────────────────────────┐
│  Application Layer  L7  │ ← HTTP, HTTPS, DNS  ← ALB operates here
├─────────────────────────┤
│  Presentation Layer L6  │ ← SSL / TLS encryption/decryption
├─────────────────────────┤
│  Session Layer      L5  │ ← Session management
├─────────────────────────┤
│  Transport Layer    L4  │ ← TCP / UDP, ports  ← NLB operates here
├─────────────────────────┤
│  Network Layer      L3  │ ← IP addresses, routing
├─────────────────────────┤
│  Datalink Layer     L2  │ ← MAC addresses, frames
├─────────────────────────┤
│  Physical Layer     L1  │ ← Cables, signals, bits
└─────────────────────────┘
     │
     ▼
Reaches linkedin.com server
```

**Key insight:** When you visit linkedin.com, your browser sends an HTTP request. That request travels DOWN through all 7 OSI layers on your machine, across the network, and back UP through all 7 layers on the server side.

![OSI Model whiteboard — linkedin.com HTTP request, all 7 layers L7 Application to L1 Physical with SSL/TLS Presentation and Session layers](<assets/Screenshot (439).png>)

---

## The Three AWS Load Balancer Types

### 1. Application Load Balancer (ALB) — Layer 7

ALB operates at the **Application Layer (L7)** — the highest OSI layer. Because it can see the full HTTP request (headers, path, hostname, cookies), it can make **smart routing decisions**.

```
                    ALB (Layer 7)
                    amazon.com
                         │
          ┌──────────────┼──────────────┐
          │              │              │
   /pay endpoint    /transaction    /login
   Service (P)      Service         Service
```

**ALB Routing capabilities — it can route based on:**

| Routing type | Example                                                       |
| ------------ | ------------------------------------------------------------- |
| **Host**     | `amazon.in` → India servers, `amazon.com` → US servers        |
| **Path**     | `/pay` → Payment service, `/login` → Auth service             |
| **Domain**   | `company.com`, `abc.com`, `sena.com` → separate microservices |

**ALB Additional Capabilities:**

| Feature            | Description                                                                             |
| ------------------ | --------------------------------------------------------------------------------------- |
| **SSL Offloading** | ALB handles HTTPS decryption — backend EC2s receive plain HTTP, reducing their CPU load |
| **Headers**        | Route based on HTTP headers (e.g. User-Agent, custom headers)                           |
| **Path routing**   | `/static` → S3, `/api` → EC2, `/app` → ECS                                              |
| **Microservices**  | One ALB → multiple target groups → different services (company/abc/sena)                |

**SSL Offloading explained:**

```
HTTPS request (encrypted)
        │
        ▼
     ALB  ← decrypts SSL here (offloads from backend)
        │
        ▼
  HTTP (plain) → EC2 instances
  (no SSL overhead on backend)
```

**Real-world example — amazon.com path-based routing:**

```
amazon.com/pay        → Payment microservice
amazon.com/transaction → Transaction microservice
amazon.com/login      → Authentication microservice
```

**ALB is "Costly"** — because it inspects the full HTTP request (L7), there is processing overhead. It inspects every packet deeply. But for HTTP/HTTPS workloads, this is the correct choice.

![ALB whiteboard — SSL offloading, headers/path routing, ALB additional capabilities, amazon.com/pay/transaction/login microservices, host/path/domain routing, ALB→microservices diagram](<assets/Screenshot (440).png>)

---

### 2. Network Load Balancer (NLB) — Layer 4

NLB operates at the **Transport Layer (L4)**. It works with **TCP and UDP** — it does NOT inspect HTTP headers, paths, or hostnames. It routes based purely on IP address and port number.

```
         ALB (L7 — HTTP)
              │
              ▼
         NLB (L4 — TCP/UDP)
         ┌───────────────────┐
         │   Transport Layer  │
         │   TCP | UDP        │
         └───────────────────┘
              │
     ┌────────┼────────┐
     ▼        ▼        ▼
    EC2      EC2      EC2
```

**NLB Key Characteristics:**

| Property            | Value / Description                                 |
| ------------------- | --------------------------------------------------- |
| **Protocol**        | TCP / UDP                                           |
| **OSI Layer**       | L4 — Transport Layer                                |
| **Latency**         | **Ultra low latency** — no deep packet inspection   |
| **Throughput**      | **High transmission of data** — millions of req/sec |
| **Sticky Sessions** | **3 months** — client always routes to same target  |
| **Cost**            | Lower than ALB (less processing)                    |

**NLB Use Cases:**

- **Game servers** — require ultra-low latency, TCP connections, millions of concurrent players
- **YouTube / video streaming** — high throughput, UDP-based, massive data transfer
- Any workload where **speed > intelligence** in routing

```
NLB — Sticky Sessions (3 months):
Client A → always → Server 1  (same connection for 3 months)
Client B → always → Server 2
Client C → always → Server 3
```

**NLB vs ALB — When to use which:**

| Scenario                         | Use |
| -------------------------------- | --- |
| HTTP/HTTPS web app routing       | ALB |
| Microservices path-based routing | ALB |
| Game server, UDP traffic         | NLB |
| YouTube-scale video streaming    | NLB |
| Need lowest possible latency     | NLB |
| SSL termination needed           | ALB |

![NLB whiteboard — TCP/UDP, Transport Layer, low latency high transmission, 3-month sticky sessions, YouTube use cases, NLB(L4) diagram, Game Servers](<assets/Screenshot (441).png>)

---

### 3. Gateway Load Balancer (GWLB) — Layer 3/4

GWLB operates at the **Network Layer (L3)**. It is designed for **security appliance chaining** — routing traffic through firewalls, intrusion detection systems (IDS), intrusion prevention systems (IPS), and VPN appliances before it reaches your application.

```
Internet traffic
       │
       ▼
  GWLB (L3/L4)
  Gateway LB
       │
       ▼
  VPN / Firewall   ← Traffic inspected by security appliance
  Security appliance
       │
       ▼
  Your Application (EC2 / ALB)
```

**GWLB Use Cases:**

| Scenario              | Why GWLB                                                      |
| --------------------- | ------------------------------------------------------------- |
| **Security** (Highly) | All traffic passes through a firewall/IDS before reaching app |
| **VPN**               | Gateway → VPN appliance → internal network                    |
| **Compliance**        | Regulated industries requiring traffic inspection             |

**OSI Layer Comparison — All Three LBs:**

```
GWLB  → L3 (Network)    → Sees IP packets, routes to security appliances
NLB   → L4 (Transport)  → Sees TCP/UDP ports, ultra-low latency
ALB   → L7 (Application)→ Sees HTTP headers/path/host, smart routing
```

---

## Complete Comparison Table

| Feature              | ALB (L7)                      | NLB (L4)                     | GWLB (L3)                    |
| -------------------- | ----------------------------- | ---------------------------- | ---------------------------- |
| OSI Layer            | 7 — Application               | 4 — Transport                | 3 — Network                  |
| Protocol             | HTTP, HTTPS, gRPC             | TCP, UDP, TLS                | IP (all protocols)           |
| Routing intelligence | Host, Path, Headers, Domain   | IP + Port only               | Routes to virtual appliances |
| Latency              | Higher (deep inspection)      | Ultra-low                    | Low                          |
| Sticky sessions      | Cookie-based                  | 3 months                     | 5-tuple hash                 |
| SSL offloading       | ✅ Yes                        | ✅ Yes (TLS LB)              | ❌ No                        |
| Use case             | Web apps, microservices, APIs | Gaming, streaming, real-time | Firewalls, IDS/IPS, VPN      |
| Cost                 | Higher (costly)               | Medium                       | Medium                       |
| AWS services example | ECS, EC2, Lambda targets      | EC2, IP targets              | Security virtual appliances  |

---

## OSI Layer → AWS Load Balancer Mapping

```
L7 Application   ──► ALB  (HTTP/HTTPS — headers, path, host)
L6 Presentation  ──► ALB  (SSL/TLS offloading)
L5 Session       ──► ALB  (session stickiness via cookies)
L4 Transport     ──► NLB  (TCP/UDP — port-based)
L3 Network       ──► GWLB (IP packet routing to appliances)
L2 Datalink      ──► (not LB territory)
L1 Physical      ──► (not LB territory)
```

---

## Real-World Routing Architecture

```
Internet
    │
    ▼
Route 53 (DNS)
    │
    ├──► GWLB ──► Firewall / IDS appliance ──► (clean traffic) ──┐
    │                                                              │
    └──► ALB (amazon.com)                    ◄─────────────────────┘
              │
    ┌─────────┼──────────┐
    │         │          │
/pay      /transaction  /login
    │         │          │
Payment  Transaction  Auth
Service   Service    Service
    │         │          │
   NLB       NLB        NLB   ← inside each microservice for TCP
    │         │          │
  EC2s      EC2s       EC2s
```

---

## Key Takeaways

| Concept             | Summary                                                                |
| ------------------- | ---------------------------------------------------------------------- |
| **ALB = L7**        | Sees everything HTTP — use for web apps, APIs, microservices           |
| **NLB = L4**        | Sees TCP/UDP only — use for gaming, streaming, ultra-low latency needs |
| **GWLB = L3**       | Routes to security appliances — use for firewalls, IDS, VPN            |
| **SSL Offloading**  | ALB decrypts HTTPS so backends don't have to — reduces EC2 CPU load    |
| **Round Robin**     | Default distribution — 33% to each of 3 EC2s for 100 requests          |
| **Sticky Sessions** | NLB holds client→target mapping for up to 3 months via 5-tuple hash    |
| **OSI awareness**   | Higher OSI layer = more routing intelligence = more processing cost    |
| **Software LBs**    | nginx, F5, Envoy — alternatives when running LB yourself on EC2        |

---

## Resources

- [AWS Elastic Load Balancing Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Network Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/)
- [Gateway Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/)
- [OSI Model — AWS Networking](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
