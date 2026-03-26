![Progress](https://img.shields.io/badge/Progress-14%25-orange?style=for-the-badge&logo=progress)

# 📂 Day 14: Ansible Setup & SSH Passwordless Authentication

## 📖 Overview
On Day 14, I moved from theoretical architecture to a **Hands-on Lab**. The goal was to establish a secure, **Agentless** bridge between my **Ansible Control Node** and a **Managed Node**. This is the foundation that allows Ansible to "push" configurations without human intervention.

---

## 🏗️ The Agentless Setup: Why it Matters?
Ansible's biggest strength is its agentless nature. However, for the Control Node to manage target servers, it requires a secure trust relationship. I implemented **Public Key Infrastructure (PKI)** using SSH keys to bypass manual password prompts during automation tasks.

1. **Private Key:** Stays secure on the Control Node (`id_ed25519`).
2. **Public Key:** Shared with the Managed Node's `authorized_keys`.
3. **Outcome:** A seamless, secure, and automated communication channel.

---

## 🛠️ Hands-on Lab: Establishing the Bridge
I performed the following technical steps to prepare the infrastructure for Ansible:

1. **Key Generation:** Generated high-security **Ed25519** keys on the Control Node.
   * Command: `ssh-keygen -t ed25519`
2. **Manual Key Injection:** Accessed the Target Server and appended the public key to the `~/.ssh/authorized_keys` file.
3. **Hardening Permissions:** Applied strict Linux permissions to satisfy SSH security requirements.
   * `chmod 700 ~/.ssh`
   * `chmod 600 ~/.ssh/authorized_keys`

**Lab Evidence:**
* **Key Generation:** ![Ed25519 Success](./assets/Screenshot%20(170).png)
* **Manual Key Injection:** ![Key Injection](./assets/Screenshot%20(174).png)
* **Handshake Verification:** ![SSH Success](./assets/Screenshot%20(172).png)

---

## ⚠️ Troubleshooting Log (Real-World SME Experience)
Real-world DevOps is 90% troubleshooting. During the lab, I encountered a `Permission denied (publickey)` error which led to a temporary lockout. 
* **The Issue:** Mismatched key types and corrupt formatting in the `authorized_keys` file.
* **The Fix:** Recovered access via **AWS EC2 Instance Connect**, flushed the corrupt keys, and used a direct `echo` string injection to ensure zero formatting errors. Verified the fix using **Verbose Mode** (`ssh -v`).

---

## 🧠 DevOps Interview Q&A
**Q: Why establish Passwordless SSH for Ansible?**
**A:** Ansible is designed for automation at scale. If a DevOps Engineer has to manually enter a password for 1,000 servers, the automation fails. Passwordless SSH using keys ensures secure, programmatic access that is both scalable and audit-ready.

---
## 🤝 Connect with Me
[<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin">](https://www.linkedin.com/in/soham-sarkar-85a5a6247) | [<img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">](https://github.com/SohamSarkar025)
