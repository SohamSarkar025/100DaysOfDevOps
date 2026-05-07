![Progress](https://img.shields.io/badge/Progress-56%25-brightgreen?style=for-the-badge&logo=amazonaws)

# Day 56: AWS VPC & IAM — Interview Questions Deep Dive

Welcome to Day 56 of my **#100DaysOfDevOps** journey! After spending the past few days building production-grade VPC infrastructure with Auto Scaling and ALBs, today I shifted gears to consolidate knowledge through a structured set of **AWS interview questions** covering VPC networking patterns and IAM fundamentals. These are the exact scenario-based questions that come up in real DevOps and Cloud Engineer interviews.

---

## 📌 Why Interview Questions?

Hands-on labs teach you _how_ to build things. Interview questions teach you _why_ — they force you to articulate the reasoning behind architectural decisions, which is where real understanding lives. Today's session covered 10 scenario-based questions across two domains:

- **VPC Networking** — subnets, routing, NAT, NACLs, VPC endpoints, Bastion Hosts
- **IAM** — users, groups, roles, and policies

---

## 🏗️ Section 1: VPC Architecture & Networking

---

### ❓ Q1: Designing a High-Availability 2-Tier VPC Architecture

**Question:** You have been assigned to design a VPC architecture for a 2-tier application. The application needs to be highly available and scalable. How would you design the VPC architecture?

![Q1 - 2-Tier HA VPC Architecture Design](<assets/Screenshot%20(90).png>)

**Answer:**

- Create **2 subnet tiers**: a **public subnet** for load balancers (internet-facing) and a **private subnet** for application servers (no direct internet exposure).
- Distribute both subnet tiers across **multiple Availability Zones** to eliminate single points of failure.
- Deploy an **Application Load Balancer** in the public subnets to distribute traffic evenly across the private instances.
- Configure an **Auto Scaling Group** for the application servers in the private subnets to handle variable load automatically.
- Use **NAT Gateways** in each public subnet to allow private instances to reach the internet for updates without being directly reachable from the internet.

> **Key Principle:** Public subnets are the entry point for external traffic. Private subnets are where your compute lives. Never expose application servers directly to the internet.

---

### ❓ Q2: Restricting Outbound Internet Access Per Subnet

**Question:** Your organization has a VPC with multiple subnets. You want to restrict outbound internet access for resources in one subnet, but allow outbound internet access for resources in another subnet. How would you achieve this?

![Q2 - Controlling Outbound Internet Access via Route Tables](<assets/Screenshot%20(91).png>)

**Answer:**

- This is solved entirely at the **route table level** — no Security Group changes needed.
- For the subnet that should **NOT** have internet access: edit its associated route table and **remove the default route** (`0.0.0.0/0`) that points to the Internet Gateway. Without this route, traffic has no path to the internet.
- For the subnet that **should** have internet access: keep the default route pointing to the Internet Gateway intact.
- Since each subnet can be associated with its own route table, this gives you fine-grained per-subnet control over internet reachability.

> **Key Principle:** Route tables define where traffic can go. No route = no internet. It's that simple.

---

### ❓ Q3: Giving Private Subnet Instances Outbound Internet Access

**Question:** You have a VPC with a public subnet and a private subnet. Instances in the private subnet need to access the internet for software updates. How would you allow internet access for instances in the private subnet?

![Q3 - NAT Gateway for Private Subnet Internet Access](<assets/Screenshot%20(92).png>)

**Answer:**

- Deploy a **NAT Gateway** (managed, highly available) or a **NAT Instance** (self-managed, cheaper) in the **public subnet**.
- Update the **private subnet's route table** to add a default route (`0.0.0.0/0`) pointing to the NAT Gateway.
- Private instances can now initiate outbound connections (e.g., `apt update`, `yum install`) through the NAT Gateway — but the internet cannot initiate inbound connections back to them.

> **Key Principle:** NAT = outbound only. Your private instances can call out; nobody can call in. This is what makes the private subnet pattern secure.

---

### ❓ Q4: EC2-to-EC2 Communication via Private IP Addresses

**Question:** You have launched EC2 instances in your VPC, and you want them to communicate with each other using private IP addresses. What steps would you take to enable this communication?

![Q4 - Private IP Communication Between EC2 Instances](<assets/Screenshot%20(93).png>)

**Answer:**

- By **default**, instances within the same VPC can communicate with each other using private IP addresses — no additional routing is required for same-VPC traffic.
- To ensure communication works correctly:
  1. Confirm all instances are **in the same VPC**.
  2. If they are in **different subnets**, verify those subnets are connected (same VPC local route handles this automatically).
  3. If they are in **different VPCs**, set up a **VPC Peering Connection** and update route tables in both VPCs to route traffic across the peering link.
  4. Review **Security Group inbound/outbound rules** on each instance to explicitly allow traffic on the required protocols and ports between the instances.

> **Key Principle:** VPC local routing is free and automatic. Security Groups are the most common reason same-VPC instances can't talk to each other.

---

### ❓ Q5: Implementing Strict Network Access Control

**Question:** You want to implement strict network access control for your VPC resources. How would you achieve this?

![Q5 - Strict Network Access Control with NACLs](<assets/Screenshot%20(94).png>)

**Answer:**

- Use **Network Access Control Lists (NACLs)** at the subnet level for broad, stateless traffic filtering.
- NACLs allow you to define **both Allow and Deny rules** based on source/destination IP addresses, ports, and protocols — for both inbound and outbound traffic independently.
- Because NACLs are **stateless**, you must explicitly define rules for both directions (e.g., if you allow inbound TCP 443, you must also allow outbound on the ephemeral port range for return traffic).
- By carefully ordering and numbering NACL rules (lower numbers are evaluated first), you can enforce fine-grained access control at the network perimeter before traffic even reaches an instance.

> **Key Principle:** NACLs are your subnet-level firewall. They can DENY traffic that Security Groups cannot — making them essential for blocking specific IPs or port ranges at scale.

---

### ❓ Q6: Setting Up an Isolated Environment for Sensitive Workloads

**Question:** Your organization requires an isolated environment within the VPC for running sensitive workloads. How would you set up this isolated environment?

![Q6 - Isolated Subnet for Sensitive Workloads](<assets/Screenshot%20(95).png>)

**Answer:**

- Create a dedicated **"isolated subnet"** — a subnet with **no Internet Gateway** attached to its route table.
- Place all sensitive workloads (e.g., databases, compliance-regulated services) inside this subnet. With no IGW route, there is zero inbound or outbound internet connectivity.
- If these workloads still need to reach the internet for updates (but not be reachable from it), deploy a **NAT Gateway in a separate subnet** and configure the isolated subnet's route table to route outbound traffic through it.
- Layer on **strict NACL rules** and **Security Groups** for additional defense-in-depth.

> **Key Principle:** True isolation means no IGW in the route table. NAT gives you a controlled, one-way exit if you need it.

---

### ❓ Q7: Securely Accessing AWS Services (S3, DynamoDB) from Within a VPC

**Question:** Your application needs to access AWS services, such as S3, securely within your VPC. How would you achieve this?

![Q7 - VPC Endpoints for Secure AWS Service Access](<assets/Screenshot%20(96).png>)

**Answer:**

- Use **VPC Endpoints** to establish a private connection between your VPC and AWS services.
- VPC Endpoints allow instances in your VPC to communicate with services like **S3** and **DynamoDB** privately — without traffic leaving the AWS network, and without needing an Internet Gateway, NAT Gateway, or VPN.
- Two types:
  - **Gateway Endpoints** — for S3 and DynamoDB (free, route-table based).
  - **Interface Endpoints** (PrivateLink) — for most other AWS services (ENI-based, per-hour cost).
- Create the endpoint and associate it with the VPC/subnets, then update route tables or DNS as needed.

> **Key Principle:** VPC Endpoints keep your AWS service traffic inside Amazon's private network. This improves security, reduces latency, and eliminates NAT Gateway data processing costs for S3/DynamoDB traffic.

---

### ❓ Q8: NACL vs Security Group — Key Differences with Use Case

**Question:** What is the difference between NACL and Security Group? Explain with a use case.

![Q8 - NACL vs Security Group Comparison with Use Case](<assets/Screenshot%20(97).png>)

**Answer:**

| Feature        | Security Group                         | NACL                                    |
| :------------- | :------------------------------------- | :-------------------------------------- |
| **Level**      | Instance Level                         | Subnet Level                            |
| **State**      | Stateful (return traffic auto-allowed) | Stateless (must define both directions) |
| **Rules**      | Allow only                             | Allow AND Deny                          |
| **Evaluation** | All rules evaluated together           | Rules evaluated in number order         |
| **Scope**      | Applied per ENI/instance               | Applied to entire subnet                |

**Use Case — Defense in Depth:**

- At the **subnet level**, configure NACLs to enforce inbound and outbound traffic restrictions based on source/destination IPs, ports, and protocols. Use a Deny rule to block a known malicious IP range before it reaches any instance.
- At the **instance level**, use Security Groups to allow only the specific ports and protocols each application needs (e.g., port 8000 for a web app, port 22 for SSH from the Bastion only).
- By combining both layers, you achieve **granular security at both the network and instance level** — if one layer is misconfigured, the other still protects you.

> **Key Principle:** Use NACLs to block bad actors at the network boundary. Use Security Groups to enforce least-privilege access per instance.

---

### ❓ Q9: Setting Up a Bastion Host for Secure Administrative Access

**Question:** You have a private subnet in your VPC that contains instances that should not have direct internet access. However, you still need to securely access these instances for administrative purposes. How would you set up a Bastion Host?

![Q9 - Bastion Host Setup for Private Subnet Admin Access](<assets/Screenshot%20(99).png>)

**Answer:**

1. **Launch a new EC2 instance** in the **public subnet** — this is your Bastion Host (also called a Jump Server or Jump Box). Ensure it has a public IP or an Elastic IP for persistent access.
2. **Configure the Bastion's Security Group** to allow inbound SSH (port 22) — or RDP (port 3389) for Windows — only from your trusted IP address or a restricted IP range. Never open it to `0.0.0.0/0`.
3. **Configure the private instances' Security Groups** to allow inbound SSH/RDP traffic sourced only from the Bastion Host's Security Group ID (not a CIDR range). This ensures only traffic coming through the Bastion can reach them.
4. **Connect to the Bastion** using your private key, then from the Bastion **SSH into private instances** using their private IP addresses.

> **Key Principle:** The Bastion is your single, hardened entry point. It makes your entire private fleet manageable without exposing any of it to the internet directly.

---

## 🔐 Section 2: IAM — Users, Groups, Roles & Policies

---

### ❓ Q10: IAM Users vs Groups vs Roles vs Policies

**Question:** What is the difference between IAM users, groups, roles, and policies?

![Q10 - IAM Users, Groups, Roles and Policies Explained](<assets/Screenshot%20(98).png>)

**Answer:**

| IAM Concept | What It Is                                                       | Key Characteristic                                                            |
| :---------- | :--------------------------------------------------------------- | :---------------------------------------------------------------------------- |
| **User**    | A permanent identity for an individual or application            | Has long-term credentials (username/password or Access Keys)                  |
| **Group**   | A collection of IAM users                                        | Permissions assigned to the group are inherited by all members                |
| **Role**    | A temporary identity assumed by users, services, or applications | No permanent credentials — generates temporary security tokens                |
| **Policy**  | A JSON document defining permissions                             | Attached to Users, Groups, or Roles to define what actions are allowed/denied |

**In Detail:**

- **IAM User:** Represents a person or application. Assigned directly to policies or added to groups. Has permanent credentials (username/password or Access Key ID + Secret Access Key).
- **IAM Role:** Not tied to a specific individual. Assumed by entities (EC2 instances, Lambda functions, cross-account users) to get **temporary credentials**. Policies attached to the role define what the assuming entity can do.
- **IAM Group:** Organizes users for easier permission management. Example: a `Developers` group with policies granting S3 read access — every developer added to the group automatically inherits that access.
- **IAM Policy:** The actual permission document in JSON. Specifies the `Effect` (Allow/Deny), `Action` (which API calls), `Resource` (which AWS resources), and optional `Condition`. Can be attached to users, groups, or roles independently.

> **Key Principle:** Never assign permissions directly to individual users if you can use groups. Use roles for services and cross-account access — never embed Access Keys in application code.

---

## 📚 Key Takeaways from Day 56

Today's session reinforced several architectural principles that apply across almost every real-world AWS environment:

**Networking:**

- Route tables control where traffic can go — they are the most powerful tool for subnet-level internet access control.
- NACLs and Security Groups work together as complementary layers. Neither replaces the other.
- NAT Gateways provide outbound-only internet access for private instances — always use them instead of assigning public IPs to private instances.
- VPC Endpoints eliminate the need to route AWS service traffic through the public internet — always use them for S3 and DynamoDB in production.
- A Bastion Host is the standard pattern for administrative access to private instances — keep it locked down to known IPs only.

**IAM:**

- Use Groups to manage permissions at scale, not individual user policies.
- Use Roles for any service-to-service or cross-account access — temporary credentials are always safer than long-term Access Keys.
- Every permission decision should follow the principle of **least privilege**.

---
