![Progress](https://img.shields.io/badge/Progress-72%25-brightgreen?style=for-the-badge&logo=amazonaws)
![Migration](https://img.shields.io/badge/AWS-Cloud_Migration-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![7Rs](https://img.shields.io/badge/Strategy-7_R's-0052CC?style=for-the-badge&logoColor=white)
![EKS](https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![RDS](https://img.shields.io/badge/AWS-RDS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

# Day 72 - AWS Cloud Migration Strategies: The 7 R's & Migration Phases

## Overview

On Day 72, I studied **AWS Cloud Migration Strategies** — how large organizations (MNCs) move their existing on-premise infrastructure to AWS. The session covered the **real-world motivation** for migration (monolithic → microservices), the **5-phase migration process**, the **7 R's framework** for deciding how each workload migrates, and a **banking sector case study** showing how 170 on-premise servers were partially migrated to AWS. All concepts were explored through whiteboard diagrams.

**Core insight: Migration is never "move everything at once" — it's a phased, strategic process using the 7 R's to decide the right approach for each workload.**

---

## Why Companies Migrate to AWS

### The MNC Problem — Monolith to Microservices

A large MNC running a **monolithic application** hits scaling and agility limits. The solution: break it into **microservices** — but that means migrating to cloud infrastructure that can support them.

```
MNC (Large Enterprise)
        │
        ▼
  Monolithic App ──► on-premise servers
  (single codebase)   (hardware owned)
        │
        │  Problems:
        │  - Hard to scale individual components
        │  - Slow deployments
        │  - Hardware aging (O.S / Hardware / Environment costs)
        │
        ▼
  Decision: Migrate to AWS
        │
        ▼
  200 Microservices  ──► broken down further
        │
        ▼
  50 core services   ──► migrated in phases
  Phase-by-phase migration (e.g., Phase 5 = 50 services)
```

**Why migrate?** The on-premise environment has three key cost drivers:

- **O.S** — operating system licensing
- **Hardware** — servers, racks, data centers
- **Environment** — power, cooling, physical space

Moving to AWS eliminates all three and introduces pay-as-you-go pricing.

![AWS Cloud Migration Strategies overview — MNC monolithic to 200 microservices, 7 R's list, migration phases, Lift & Shift, O.S/Hardware/Environment costs](<assets/Screenshot (442).png>)

---

## The 5 Phases of Cloud Migration

Migration to AWS is **not a one-time activity** for the full system — it's broken into phases. Each phase follows the same lifecycle:

```
Phase lifecycle (repeated for each batch of services):
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Preparation  ──► Assess current state, define scope │
│         │                                               │
│         ▼                                               │
│  2. Planning     ──► Choose strategy (7 R's), timeline  │
│         │                                               │
│         ▼                                               │
│  3. Migration    ──► Execute the move to AWS            │
│         │                                               │
│         ▼                                               │
│  4. Monitor      ──► CloudWatch, EC2 metrics, test      │
│         │                                               │
│         ▼                                               │
│  5. Improve / Optimize ──► Cost + performance tuning    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Phase 5 (Optimize) is recurring** — it's not a one-time step. Once migrated, you continuously evaluate, achieve cost targets, and optimize further.

```
Optimize loop:
evaluate ──► achieve (target: 40% → 50% cost savings)
    │                           │
    └───────────────────────────┘  (continuous improvement)
```

**Migration tooling used per phase:**

| Tool           | Purpose                                  |
| -------------- | ---------------------------------------- |
| **Scripts**    | Automate migration tasks, data transfer  |
| **EC2**        | Target compute for migrated workloads    |
| **CloudWatch** | Monitor migrated services post-migration |
| **Test**       | Validate workloads after migration       |

**Phased migration example — monolithic with 200 services:**

```
Monolithic (200 services)
        │
        ▼
  Phase 1: 50 services migrated  ──► Phones / Core
        │
  Phase 2: 20 services
        │
  Phase 3: 20 services
        │
  Phase 4: 20 services
        │
  Phase 5: 100 services  ──► Final large batch
        │
        ▼
  Full cloud migration complete ✅
```

**The 7 R's** = the framework used during **Planning** (Phase 2) to decide _how_ each service migrates.

![Migration phases whiteboard — 5 phases Preparation/Planning/Migrate/Monitor/Optimize, monolithic 200→50→20→20→20→100, evaluate→achieve→optimize loop, 40%→50% savings, Scripts/EC2/CloudWatch, Lift & Shift, 7 R's](<assets/Screenshot (443).png>)

---

## The 7 R's of Cloud Migration

The **7 R's** is the AWS framework for categorizing how each workload (application, service, database) should be migrated. Different workloads need different strategies.

```
7 R's Migration Decision Tree:

Is the app still needed?
    ├── NO  ──► Retire (decommission it)
    └── YES
          │
          Is it already SaaS?
          ├── YES ──► Retain (keep as-is for now)
          └── NO
                │
                Buy a SaaS replacement?
                ├── YES ──► Repurchase (e.g., move CRM to Salesforce)
                └── NO
                      │
                      How much change is acceptable?
                      ├── None     ──► Rehost (Lift & Shift)
                      ├── Minimal  ──► Replatform
                      ├── Medium   ──► Relocate
                      └── High     ──► Refactor / Rearchitecture
```

---

### R1 — Rehost (Lift & Shift) ✅ Most Common

Move the application to AWS **exactly as it is** — no code changes, no architecture changes.

```
On-premise server (app running)
        │
        ▼
EC2 instance (same app, same config)
        │
  No changes to:  code / OS / DB / config
```

- **When:** Time pressure, large-scale migration, "just get it to cloud first"
- **Tools:** AWS MGN (Application Migration Service), VM Import/Export
- **Effort:** Minimum
- **Benefit:** Fast migration, immediate cost savings from hardware elimination
- **Drawback:** Doesn't take full advantage of cloud-native features

**Example:** MNC with 200 services migrates 100 of them via Lift & Shift in Phase 5 — fastest way to move bulk workloads.

---

### R2 — Replatform (Lift, Tinker & Shift)

Move to AWS with **minor optimizations** — change the underlying platform without changing the core application.

```
On-premise:  App + MySQL on physical server
        │
        ▼
AWS:         App on EC2 + Amazon RDS (managed MySQL)
             (same app code, better platform)
```

- **When:** Want managed services (RDS, ElastiCache) without rewriting the app
- **Effort:** Low-Medium
- **Benefit:** Reduced ops burden (AWS manages DB patching, backups, HA)
- **Example:** Move self-managed MySQL → Amazon RDS

---

### R3 — Repurchase

**Replace** the existing application with a **SaaS product** (buy instead of migrate).

```
On-premise CRM (custom built)
        │
        ▼
Salesforce (SaaS) / HubSpot / ServiceNow
```

- **When:** A commercial SaaS product does the same job better
- **Effort:** Low (just licensing + data migration)
- **Benefit:** No maintenance burden, vendor-managed updates
- **Examples:** Custom HR system → Workday, On-prem email → Microsoft 365

---

### R4 — Refactor / Rearchitecture ✅ Highest Value

**Redesign** the application from scratch using cloud-native architecture to fully leverage AWS.

```
Monolithic on-premise app
        │
        ▼
Microservices on AWS:
  ┌─────────────────────────────────────┐
  │  EKS (Elastic Kubernetes Service)   │
  │  or OpenShift (ROSA)                │
  │  Containers + auto-scaling          │
  │  Kubernetes orchestration           │
  └─────────────────────────────────────┘
```

- **When:** The application needs to scale massively, or the current architecture is a bottleneck
- **Effort:** Highest — requires significant development work
- **Benefit:** Full cloud-native capabilities — auto-scaling, serverless, resilience
- **Tools:** EKS, OpenShift/ROSA, Lambda, Step Functions
- **Example:** MNC breaks 200-service monolith into microservices on EKS

**Best practices for Refactor:**

- Use containers (Docker) for portability
- Kubernetes (EKS / OpenShift ROSA) for orchestration
- Adopt cloud-native databases (RDS, DynamoDB)

---

### R5 — Relocate

Move infrastructure to AWS with **minimal changes** — often used for VMware workloads moving to **VMware Cloud on AWS**.

```
VMware on-premise VMs
        │
        ▼
VMware Cloud on AWS (vCenter stays the same)
        │
  k → Kubernetes workloads relocated as-is
```

- **When:** Large VMware environment, want to keep VMware tooling
- **Effort:** Low (no re-architecture)
- **Benefit:** Keep existing VMware skills and tools while gaining AWS infrastructure

---

### R6 — Retire

**Decommission** applications that are no longer needed.

```
Legacy app audit:
200 services ──► 10 identified as unused/redundant
        │
        ▼
Retire (turn off) — save licensing + support costs
```

- **When:** App is duplicated, obsolete, or usage is near zero
- **Benefit:** Immediate cost savings, reduced complexity
- **Tip:** Migration assessment often reveals 10–20% of apps can simply be retired

---

### R7 — Retain (Keep as-is)

**Keep** certain workloads on-premise for now — don't migrate yet.

```
On-premise (stays)
  ├── Recently upgraded hardware (not cost-effective to migrate yet)
  ├── Compliance requirements not yet met for cloud
  └── Complex legacy systems needing more assessment
```

- **When:** Not ready to migrate — compliance, technical debt, or recent CAPEX
- **Benefit:** Don't force migration where it doesn't make sense yet
- **Revisit:** These are candidates for future migration phases

![7 R's whiteboard — Refactor/Rehost/Replatform/Relocate/Retain/Retire/Repurchase, Lift & Shift minimum changes, EKS/OpenShift(ROSA), Kubernetes, databases→AWS RDS, backups→huge/preprod, banking use case 170 on-premise→30 AWS](<assets/Screenshot (444).png>)

---

## Database Migration Strategy

Databases require special treatment during migration — they hold critical data and can't have downtime.

```
On-premise Databases (Project DBs)
        │
        ▼  Migration path:
  ┌─────────────────────────────────────┐
  │  Step 1: Pilot (Pit)               │
  │  ──► Move to AWS RDS (managed DB)  │
  │  ──► Test with subset of data      │
  │                                    │
  │  Step 2: Backups                   │
  │  ──► Stage: Huge backup snapshot   │
  │  ──► Pre-prod: Validate backup     │
  │  ──► Production: Full cutover      │
  └─────────────────────────────────────┘
```

**AWS Database Migration Tools:**

- **AWS DMS** (Database Migration Service) — migrate databases with minimal downtime
- **AWS RDS** — managed relational DB (MySQL, PostgreSQL, Oracle, SQL Server)
- **Schema Conversion Tool (SCT)** — convert schema from Oracle/SQL Server to open-source

---

## Real-World Case Study — Banking Sector

Banking is one of the most **security-conscious** industries. Migration must be careful, phased, and compliant.

```
Bank's Infrastructure:
  170 servers (on-premise)
        │
        │  Security requirements: HIGH
        │  Compliance: strict
        │
        ▼
  Migration Decision:
  ┌───────────────────────────────────┐
  │  30 servers → AWS                 │ ← Phase 1 (non-critical)
  │  140 servers → remain on-premise  │ ← Retain for now
  └───────────────────────────────────┘
        │
        ▼
  AWS: Secure environment ✅
  - Private VPC
  - Strict IAM policies
  - Compliance controls
        │
        ▼
  Target: 10/k scale  ── future phases
```

**Why only 30 of 170 servers initially?**

- Banking regulations require extensive security validation before moving workloads
- Core banking systems (transactions, customer data) stay on-premise until fully validated
- AWS provides the **secure, compliant environment** but migration must be gradual
- The 6-stage framework guides phased bank migration

**Banking migration approach:**

- Use **Rehost** for non-critical admin/reporting systems first
- Use **Replatform** for databases → AWS RDS
- Use **Refactor** eventually for core banking on EKS
- **Retain** core transaction systems until compliance is fully verified

---

## 7 R's Quick Reference

| Strategy         | Change Level | Time    | Cost Savings | When to Use                           |
| ---------------- | ------------ | ------- | ------------ | ------------------------------------- |
| **Rehost** (L&S) | None         | Fast    | Medium       | Time-pressure, bulk migration         |
| **Replatform**   | Minimal      | Medium  | Medium-High  | Want managed services, minor tuning   |
| **Repurchase**   | Replace      | Fast    | Varies       | Better SaaS option exists             |
| **Refactor**     | High         | Slow    | Highest      | Scale, modernize, cloud-native needed |
| **Relocate**     | Minimal      | Fast    | Medium       | VMware environment, keep tooling      |
| **Retire**       | N/A          | Instant | Immediate    | App is unused/redundant               |
| **Retain**       | None         | N/A     | None yet     | Not ready / compliance / recent CAPEX |

---

## Migration Strategy Selection — Decision Flow

```
Start: Assess each workload
            │
    ┌───────▼────────┐
    │ Still needed?   │──NO──► RETIRE
    └───────┬────────┘
           YES
    ┌───────▼────────┐
    │ Ready to migrate│──NO──► RETAIN
    └───────┬────────┘
           YES
    ┌───────▼──────────┐
    │ Replace with SaaS?│──YES─► REPURCHASE
    └───────┬──────────┘
            NO
    ┌───────▼──────────────┐
    │ VMware environment?   │──YES─► RELOCATE
    └───────┬──────────────┘
            NO
    ┌───────▼──────────────────┐
    │ Time/effort available?    │
    ├── Minimal ──► REHOST      │
    ├── Some    ──► REPLATFORM  │
    └── High    ──► REFACTOR    │
    └──────────────────────────┘
```

---

## Key Takeaways

| Concept                    | Summary                                                                     |
| -------------------------- | --------------------------------------------------------------------------- |
| **Lift & Shift = Rehost**  | Move as-is — fastest, minimum changes, most common for bulk migration       |
| **Refactor = highest ROI** | Complete redesign — microservices on EKS/ROSA, full cloud-native benefits   |
| **5 phases**               | Prepare → Plan → Migrate → Monitor → Optimize (recurring)                   |
| **Migration is phased**    | MNC with 200 services migrates in batches — never all at once               |
| **DB migration**           | Pilot → Backup (huge) → Pre-prod → Production cutover                       |
| **Banking = gradual**      | 30 of 170 servers first — security and compliance drive pace                |
| **Cost target**            | 40% → 50% cost savings achievable after optimization phase                  |
| **7 R's is the framework** | Applied during Planning phase to decide strategy per workload               |
| **Retire & Retain**        | Often overlooked — 10–20% of apps can be retired; some must stay on-premise |

---

## AWS Services Used in Migration

| Service                         | Role in Migration                                     |
| ------------------------------- | ----------------------------------------------------- |
| AWS MGN (Application Migration) | Rehost — lift & shift physical/virtual servers        |
| Amazon EC2                      | Target compute for migrated workloads                 |
| Amazon RDS                      | Replatform — managed database replacement             |
| AWS DMS                         | Database migration with minimal downtime              |
| Amazon EKS                      | Refactor — Kubernetes for containerized microservices |
| OpenShift / ROSA                | Refactor — Red Hat OpenShift on AWS                   |
| Amazon CloudWatch               | Monitor phase — metrics, logs, alarms post-migration  |
| AWS Schema Conversion Tool      | Convert DB schemas during database migration          |

---

## Resources

- [AWS Cloud Migration Strategies](https://aws.amazon.com/cloud-migration/)
- [AWS Migration Hub](https://docs.aws.amazon.com/migrationhub/)
- [AWS Application Migration Service (MGN)](https://docs.aws.amazon.com/mgn/)
- [AWS Database Migration Service (DMS)](https://docs.aws.amazon.com/dms/)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Red Hat OpenShift on AWS (ROSA)](https://docs.aws.amazon.com/rosa/)
- [The 7 R's of Migration — AWS](https://aws.amazon.com/blogs/enterprise-strategy/6-strategies-for-migrating-applications-to-the-cloud/)
- [100DaysOfDevOps Repository](https://github.com/SohamSarkar025/100DaysOfDevOps)
