![Progress](https://img.shields.io/badge/Progress-37%25-green?style=for-the-badge&logo=amazonaws)

# 🚀 Day 37: Deploying a Static Portfolio on AWS EC2 (Amazon Linux)

**100 Days of DevOps Journey — Day 37**

## 📌 Overview

Today's mission was to bridge the gap between local frontend development and cloud infrastructure. I built a responsive, terminal-themed portfolio website and manually provisioned an **Amazon Linux 2023 EC2 instance** on AWS to host it using the **Apache Web Server (`httpd`)**. This exercise solidifies foundational Linux system administration and cloud networking skills.

---

## 💻 Phase 1: Local Development & Version Control

Before touching the cloud, the code needs to be written and securely stored.

### 1. Developing the Frontend

I designed a clean, dark-themed HTML/CSS page using Tailwind CSS to showcase my DevOps milestones. The code was structured locally using VS Code.

![VS Code Development](<assets/Screenshot%20(529).png>)
_Development: Writing the HTML and inline Tailwind CSS logic in VS Code._

### 2. Local Testing

Before pushing to production, I utilized a local Live Server to ensure the styling and responsiveness were rendering correctly.

![Local Server Test](<assets/Screenshot%20(530).png>)
_Testing: Verifying the UI on `127.0.0.1:5500` before cloud deployment._

### 3. Pushing to GitHub

I created a new public repository and pushed the code. During this, I handled branch renaming (`master` to `main`) and set up the remote origin correctly to store my code safely.

![GitHub Repo Creation](<assets/Screenshot%20(533).png>)
_Version Control: Creating the `apache-static-website-aws-deploy` repository._

![Git Push Success](<assets/Screenshot%20(535).png>)
_Terminal: Successfully initializing, committing, and pushing the code to the `main` branch._

![GitHub Live Code](<assets/Screenshot%20(536).png>)
_Validation: The `index.html` file is safely stored in the remote repository._

---

## ☁️ Phase 2: Provisioning Cloud Infrastructure (AWS EC2)

With the code safe in version control, I moved to the AWS Console to build the server infrastructure.

### 1. Accessing the AWS Console

I navigated to the AWS Management Console and accessed the EC2 Dashboard in the `us-east-1` (N. Virginia) region.

![AWS Console](<assets/Screenshot%20(537).png>)
_AWS: Entering the EC2 Dashboard from the main console._

### 2. Configuring the Instance & Storage

I selected the industry-standard **Amazon Linux 2023 AMI** to utilize the `yum` package manager.

- **Instance Type:** `t2.micro` (Free Tier Eligible)
- **Storage:** Provisioned an 8 GiB `gp3` root volume for optimal baseline performance.

![EC2 Storage Configuration](<assets/Screenshot%20(542).png>)
_Storage: Configuring the 8 GiB General Purpose SSD (gp3)._

### 3. Network Security Groups

Security is paramount. I configured the Security Group to allow **SSH (Port 22)** for administrative access and explicitly allowed **HTTP (Port 80)** traffic so the website can be accessed from the internet.

![EC2 Network Settings](<assets/Screenshot%20(541).png>)
_Networking: Ensuring inbound rules permit HTTP traffic from anywhere._

### 4. Launch & Verification

After assigning my `linux-for-devops-key` key pair, I launched the instance and verified its "Running" state, noting down the newly assigned Public IPv4 address.

![EC2 Instance Running](<assets/Screenshot%20(544).png>)
_Dashboard: The instance is active and ready for connection at `44.221.44.198`._

---

## ⚙️ Phase 3: Server Configuration & Deployment

This is where Linux administration comes into play. I connected to the server to transform it into a web host.

### 1. Secure SSH Connection

Using Git Bash, I secured my private key (`chmod 400`) and established an SSH connection to the EC2 instance as the `ec2-user`.

![SSH Instructions](<assets/Screenshot%20(545).png>)
_AWS Connect: Following the official SSH client instructions._

![SSH Terminal Success](<assets/Screenshot%20(546).png>)
_Terminal: Successfully authenticated into the Amazon Linux 2023 environment._

### 2. Package Management & Installation

I updated the system repositories and installed the necessary packages: **Apache (`httpd`)** and **Git**.

![Yum Install](<assets/Screenshot%20(547).png>)
_Package Manager: Running `sudo yum update -y` and `sudo yum install httpd git -y`._

### 3. Service Activation & Code Deployment

I started the Apache service, cloned my GitHub repository directly onto the server, and copied the web files into Apache's default serving directory.

![Deploying Code](<assets/Screenshot%20(549).png>)
_Execution: Starting `httpd`, cloning the repo, and moving files to `/var/www/html/`._

---

## 🌐 Phase 4: The Final Result

With the files in place and the web server running, I navigated to the EC2 instance's Public IP address in my browser. The deployment was a success!

![Live Website](<assets/Screenshot%20(548).png>)
_Live: The static portfolio is now publicly accessible on the internet!_

---
