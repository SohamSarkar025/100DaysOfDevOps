![Progress](https://img.shields.io/badge/Progress-48%25-green?style=for-the-badge&logo=amazonaws)

# Day 48: AWS Networking Deep Dive – VPC, Subnets, CIDR & OSI Model ☁️

Welcome to Day 48 of the #100DaysOfDevOps challenge! Today's session was packed with the foundational layers of cloud infrastructure and networking. Having completed configuration management and orchestration tools, we are now moving towards the AWS Cloud platform. We moved from understanding basic IP address structures to advanced subnetting math, and finally diving into how data physically travels across the internet via the OSI model.

Here is a complete breakdown of everything covered today.

---

## 📋 Topics Covered

- **IPv4 Fundamentals:** Bits, bytes, octets, and device uniqueness.
- **Subnetting & Security:** Public vs. Private subnets and VPC routing.
- **CIDR Calculations:** Classless Inter-Domain Routing, network bits, and host bits.
- **Application Ports:** Service mapping (HTTP, HTTPS, MySQL).
- **Connection Protocols:** DNS resolution and the TCP 3-Way Handshake.
- **The OSI Model:** The 7 layers of networking and the journey of a packet.

---

## 1. IPv4 Fundamentals & VPC Subnetting

An IPv4 address is a 32-bit numeric address written as four numbers separated by periods (octets). This system ensures every device on a network has a unique identifier.

- **Total Bits:** 32 bits (4 Bytes).
- **Calculation:** Each octet represents 8 bits, meaning there are $2^8$ (256) possibilities per octet (0-255).

![IP Hierarchy and Device Uniqueness](<assets/Screenshot (751).png>)
![Binary Structure: Bits and Bytes](<assets/Screenshot (752).png>)
![Octet Conversion and Binary Math](<assets/Screenshot (753).png>)

### Subnet Security and Isolation

Subnetting is the practice of dividing a large network into smaller, manageable, and isolated network segments.

- **Security:** By using subnets, sensitive resources (like databases or financial systems) are isolated from malicious actors on the public internet.
- **Public vs. Private:** Public subnets route out to the Internet Gateway, while private subnets stay entirely internal.

![Subnet Security and Malicious Isolation](<assets/Screenshot (754).png>)
![AWS Networking Flow (Public vs Private)](<assets/Screenshot (755).png>)

---

## 2. CIDR (Classless Inter-Domain Routing)

CIDR notation is used to define the specific range of IP addresses available in your VPC or Subnet.

- In `172.16.0.0/24`, the `/24` tells us that the first 24 bits are fixed for the **network**, and the remaining 8 bits are for **hosts**.
- **The Math:** $32 - 24 = 8$ host bits. $2^8 = 256$ total IP addresses (Note: AWS reserves 5, leaving 251 usable).

![VPC to Subnet CIDR Mapping](<assets/Screenshot (756).png>)
![Network Bits vs. Host Bits Allocation](<assets/Screenshot (757).png>)
![IP Range Divisions and Boundaries](<assets/Screenshot (758).png>)

We also broke down advanced CIDR calculations, such as figuring out the exact number of available IPs for `/27`, `/28`, and `/31` masks.

![Advanced CIDR Calculations](<assets/Screenshot (759).png>)
![Advanced Subnet Mask Math](<assets/Screenshot (760).png>)

---

## 3. Ports & Service Mapping

While an IP address gets your traffic to the right server (VM), **Ports** get your traffic to the right application running on that server.

- **:80** $\rightarrow$ HTTP
- **:443** $\rightarrow$ HTTPS
- **:8080** $\rightarrow$ Custom Web Apps
- **:3306** $\rightarrow$ MySQL Database

![IP Addresses vs. Application Ports](<assets/Screenshot (761).png>)

---

## 4. DNS & The TCP 3-Way Handshake

Before your browser can securely load a web page, two major steps occur behind the scenes:

1. **DNS Resolution:** The browser queries a DNS server to translate a human-readable domain (`google.com`) into an IP address (`8.8.8.8`).
2. **TCP Handshake:** A reliable connection is established between your machine and the server using a 3-step process: **SYN** $\rightarrow$ **SYN-ACK** $\rightarrow$ **ACK**.

![DNS Resolution & TCP Handshake](<assets/Screenshot (763).png>)

---

## 5. The OSI Model (7 Layers of Networking)

Finally, we looked at the overarching journey of data. The OSI model dictates how a packet gets from a user's browser, down through the hardware, across the world, and back up to the server's application.

- **L7 - Application:** Browser requests (HTTP/HTTPS)
- **L6 - Presentation:** Encryption and formatting
- **L5 - Session:** Initiating and maintaining the connection
- **L4 - Transport:** TCP/UDP, Segmenting data
- **L3 - Network:** IP Addressing, Routers, Packets
- **L2 - Data Link:** MAC Addresses, Frames, Switches
- **L1 - Physical:** Optical cables, electronic signals (1s and 0s)

![The Journey of Data Overview](<assets/Screenshot (762).png>)
![The 7 Layers of the OSI Model](<assets/Screenshot (764).png>)
![Client-Server OSI Data Flow](<assets/Screenshot (766).png>)

---

### 💡 Key Takeaway

Today bridged the gap between basic server provisioning and actual cloud architecture. From calculating the exact number of IP addresses needed for a subnet, to understanding how packets traverse the OSI model via TCP handshakes and routing tables, these networking fundamentals are absolutely critical before spinning up production environments in an AWS VPC.
