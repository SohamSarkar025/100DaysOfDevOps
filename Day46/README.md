![Progress](https://img.shields.io/badge/Progress-46%25-green?style=for-the-badge&logo=kubernetes)

# Day 46: Linux File Permissions & Ownership 🔐🐧

Welcome to Day 46 of my **100 Days of DevOps** journey! After mastering User and Group management yesterday, today's focus naturally shifted to **File Permissions**. In Linux, security is everything, and understanding who can read, write, or execute a file is a non-negotiable skill for any DevOps Engineer.

---

## 🛑 1. Why Do We Need File Permissions?

In a corporate environment, you have multiple teams: Developers, QA (QE), and DevOps. You don't want a QA engineer accidentally modifying a critical production script written by a Developer. File permissions isolate access and protect system integrity.

![Why Permissions Matter](<assets/Screenshot (716).png>)

### The Three Entities:

Every file and directory in Linux has three levels of access:

1. **User (u):** The actual owner of the file.
2. **Group (g):** Other users who are members of the file's assigned group.
3. **Others (o):** Everyone else on the system.

### The Three Permissions:

- **Read (`r`):** View file contents.
- **Write (`w`):** Modify or delete file contents.
- **Execute (`x`):** Run the file as a script or program.

![rwx Explained](<assets/Screenshot (717).png>)

---

## 🔢 2. The Numeric (Octal) Notation (`chmod`)

To change permissions, we use the `chmod` (change mode) command. The most efficient way to assign permissions is using the numeric system:

- **Read (`r`) = 4**
- **Write (`w`) = 2**
- **Execute (`x`) = 1**

You add these numbers together for each entity (User, Group, Others).

### Examples:

- `chmod 777 file`: (4+2+1 = 7) Everyone has full access (Dangerous in production! ⚠️)
- `chmod 666 file`: (4+2 = 6) Everyone can read and write, but not execute.
- `chmod 444 file`: (4) Read-only for everyone.

![Numeric Notation Example](<assets/Screenshot (718).png>)

**Symbolic vs Numeric:**
Instead of numbers, you can also use symbols: `chmod u=rwx,g=rw,o=r file`. This is exactly equivalent to typing `chmod 764 file`.

![Chmod 764 Example](<assets/Screenshot (719).png>)

---

## 👤 3. Changing Ownership (`chown`)

Sometimes, you need to hand over a file to another user or group. We use the `chown` (change owner) command for this.

_Syntax:_ `chown user:group filename`

_Learning Moment:_ When I tried to run `chown qe:qe test.sh` as a regular user, Linux blocked it with an `Operation not permitted` error. **Only root/sudo** can change the ownership of a file to someone else! After switching to the root user, the command executed successfully, and `ls -ltr` confirmed the new owner.

![Changing Ownership in Terminal](<assets/Screenshot (720).png>)

---

## 📁 4. Files vs. Directory Permissions

Permissions act slightly differently on directories compared to files:

- **Read (`r`) on a folder:** Allows you to list (`ls`) the contents.
- **Write (`w`) on a folder:** Allows you to create or delete files inside it.
- **Execute (`x`) on a folder:** Allows you to `cd` into the folder. _(Without execute permissions, you can't even enter the directory!)_

![Folder vs File Analogy](<assets/Screenshot (721).png>)

---

## 💡 Key Takeaway

"Mastering `chmod` and `chown` is the foundation of Linux security. Always follow the **Principle of Least Privilege**—give users exactly the permissions they need to do their job, and not a single bit more (and definitely avoid `chmod 777` unless absolutely necessary!)."

---
