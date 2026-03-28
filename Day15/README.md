![Progress](https://img.shields.io/badge/Progress-15%25-orange?style=for-the-badge&logo=progress)

# 📂 Day 15: Ansible Ad-hoc Commands, Playbooks & Roles

## 📖 Overview
On Day 15, I transitioned from basic connectivity to actual infrastructure management. I explored the hierarchy of Ansible execution—moving from quick one-liner **Ad-hoc commands** to structured **YAML Playbooks** and understanding the scalability of **Ansible Roles**.

---

## 🏗️ Configuration Strategies Learned

### 1. Ad-hoc Commands (The Quick Fix)
Ad-hoc commands are perfect for one-time tasks. I used the `shell` module to perform real-time operations across managed nodes without writing a full script.
* **Lab Task:** Created a file `devopsclass`, verified its permissions, and checked disk space (`df -h`) across the fleet.
* **Command:** `ansible -i inventory all -m "shell" -a "touch devopsclass"`



### 2. Ansible Playbooks (The Automation Engine)
I wrote my first Playbook to automate a web server deployment. Playbooks are idempotent, meaning they ensure the system reaches the desired state without redundant actions.
* **Key Tasks:** Updating `apt` cache, installing `nginx`, and ensuring the service is `started`.
* **Troubleshooting:** Encountered a `404 Not Found` repository error. Resolved it by adding a `Update apt cache` task using the `apt` module with `update_cache: yes`.



### 3. Ansible Roles (Scalable Architecture)
I explored **Ansible Galaxy** to initialize a Role. Roles are the professional way to organize playbooks into reusable components (tasks, handlers, vars, etc.).
* **Command:** `ansible-galaxy role init kubernetes`

---

## 🛠️ Lab Evidence

### 1. Ad-hoc Execution & Verification
![Ad-hoc Success](./assets/Screenshot%20(177).png)
*Successfully executed shell commands and verified file creation on the managed node.*

### 2. Playbook Writing (YAML Structure)
![YAML Syntax](./assets/Screenshot%20(178).png)
*Defined a structured automation for Nginx installation with 'become: true' for sudo privileges.*

### 3. Successful Playbook Run (RECAP: Failed=0)
![Playbook Result](./assets/Screenshot%20(179).png)
*Resolved the repository sync issue and successfully achieved the 'changed' state for Nginx.*

### 4. Ansible Role Structure
![Role Init](./assets/Screenshot%20(180).png)
*Initialized a professional Role directory structure for scalable infrastructure management.*

---

## 🧠 DevOps Interview Q&A
**Q: Why did your first playbook fail and how did you fix it?**
**A:** The playbook failed because the target server's package repository list was outdated, causing a `404` error during the Nginx installation task. I fixed it by adding the `update_cache: yes` parameter to the `apt` module, ensuring the server fetches the latest package metadata before attempting the install.

---
## 🤝 Connect with Me
[<img src="https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin">](https://www.linkedin.com/in/soham-sarkar-85a5a6247) | [<img src="https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github">](https://github.com/SohamSarkar025)
