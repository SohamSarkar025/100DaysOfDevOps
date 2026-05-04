![Progress](https://img.shields.io/badge/Progress-53%25-brightgreen?style=for-the-badge&logo=amazonaws)

# Day 53: AWS Network Security - Mastering SGs and NACLs

Welcome to Day 53 of my #100DaysOfDevOps journey! Today’s focus was a deep dive into securing cloud infrastructure by mastering the layers of protection: **Security Groups (SG)** and **Network Access Control Lists (NACLs)**.

---

## 1. Concepts & Architecture

To secure a network, you must first understand the path traffic takes. Traffic enters via the Internet Gateway and must pass through the NACL (Subnet Level) and then the Security Group (Instance Level).

![VPC Traffic Architecture](<assets/Screenshot (7).png>)

### Key Comparisons

| Feature   | Security Group (SG)        | Network ACL (NACL)                      |
| :-------- | :------------------------- | :-------------------------------------- |
| **Level** | Instance Level             | Subnet Level                            |
| **State** | Stateful (Returns allowed) | Stateless (Needs explicit return rules) |
| **Rules** | Allow rules only           | Allow and Deny rules                    |

![SG and NACL Comparison](<assets/Screenshot (1).png>)

---

## 2. Security Layers in Action

### Security Groups (SG)

Acting as a stateful firewall for individual instances, SGs control traffic based on specific protocols and ports.

![SG Traffic Flow](<assets/Screenshot (4).png>)

### Network ACLs (NACL)

NACLs serve as a stateless firewall for entire subnets. They provide a broad perimeter defense.

![NACL Logic](<assets/Screenshot (5).png>)

---

## 3. Practical Lab: VPC & EC2 Deployment

### Phase 1: Custom VPC Infrastructure

I configured a custom VPC (`10.0.0.0/16`) to host the resources.

![VPC Dashboard](<assets/Screenshot (10).png>)
![VPC Creation Settings](<assets/Screenshot (11).png>)

The VPC wizard automatically provisioned the subnets, internet gateways, and route tables.

![VPC Success](<assets/Screenshot (12).png>)
![Resource Map](<assets/Screenshot (13).png>)

### Phase 2: Launching the EC2 Instance

I launched an Ubuntu instance to act as our test server.

![Instance Launch](<assets/Screenshot (14).png>)
![Instance Type and Key Pair](<assets/Screenshot (15).png>)
![Network Settings](<assets/Screenshot (16).png>)
![Launch Summary](<assets/Screenshot (17).png>)

---

## 4. Hands-on Testing & Troubleshooting

### Step 1: Initial Connection (SSH)

I successfully connected to the instance via SSH and updated the package lists.

![SSH Connection](<assets/Screenshot (18).png>)

### Step 2: Testing Application Access (Port 8000)

I attempted to access a simple web service on port 8000. Initially, the connection timed out because the Security Group was only configured for port 22 (SSH).

![Connection Timed Out](<assets/Screenshot (19).png>)
![Initial SG Rules](<assets/Screenshot (20).png>)

### Step 3: Modifying Security Group Rules

To fix this, I added a **Custom TCP** rule to allow inbound traffic on **Port 8000** from any IP (`0.0.0.0/0`).

![Editing SG Inbound Rules](<assets/Screenshot (21).png>)

### Step 4: Verification

After updating the SG, the application became accessible in the browser.

![Successful Directory Listing](<assets/Screenshot (22).png>)

---

## 5. Testing the NACL "Deny" Override

To prove that NACLs can override Security Group "Allow" rules, I performed a final test.

1. **The Rule:** I added a "Deny" rule to the NACL for all traffic.
2. **The Result:** Even though the Security Group still allows Port 8000, the NACL blocks it at the subnet boundary, causing the site to become unreachable again.

![NACL Deny Rule](<assets/Screenshot (23).png>)
![Access Blocked by NACL](<assets/Screenshot (24).png>)

---

## 6. Key Takeaways

- **Defense in Depth:** SGs and NACLs work together to provide multi-layered security.
- **Troubleshooting:** If an instance is reachable via SSH but not web, check the SG first. If the SG is correct but traffic is still blocked, investigate the NACL.
- **Deny Power:** NACLs are essential for explicitly blocking specific IP ranges or ports at the network entry point.

---
