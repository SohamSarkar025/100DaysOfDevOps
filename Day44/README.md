![Progress](https://img.shields.io/badge/Progress-44%25-green?style=for-the-badge&logo=kubernetes)

# Day 44: Decoding the Linux File System Hierarchy 📂

Welcome to Day 44 of my **100 Days of DevOps** journey! After setting up our persistent Linux workspace yesterday, today was all about exploring the internal anatomy of the Linux Operating System.

Navigating a Linux server efficiently requires a deep understanding of its directory structure. In Windows, we have `C:\` or `D:\` drives, but in Linux, everything is organized under a single, unified tree structure starting from the **Root**.

---

## 🌳 The Root of Everything (`/`)

In Linux, the absolute top level of the file system is the root directory, represented by a forward slash `/`. Every single file, directory, and device in the system hangs off this root.

![Understanding the Root Hierarchy](<assets/Screenshot%20(695).png>)

When you log into a server as the root user, your prompt looks like `root@hostname:~#`. Using the `pwd` (Print Working Directory) command tells you exactly where you are in this massive tree.

---

## 📁 Key Directories & Their Purposes

Let's break down the critical folders every DevOps Engineer must know:

### 1. The Binaries: `/usr/bin` vs `/usr/sbin`

Binaries are the actual executable files (commands) that run on the system. Linux separates these based on user privileges.

- **`/usr/bin` (User Binaries):** Contains standard executable programs that any normal user can run. Examples include `awk`, `apt`, `less`, `curl`, and `python`.
- **`/usr/sbin` (System Binaries):** Contains administrative commands that typically require `root` or `sudo` privileges to execute. These are used for system maintenance. Examples include `fsck` (file system check), `netplan`, `addgroup`, and `fdisk`.

![Binaries Flow](<assets/Screenshot%20(696).png>)

**Exploring `/usr/bin` (Standard Commands):**
![User Binaries](<assets/Screenshot%20(700).png>)

**Exploring `/usr/sbin` (Admin Commands):**
![System Binaries](<assets/Screenshot%20(701).png>)

> **Note:** In modern Linux distributions (like Ubuntu), `/bin` is just a symbolic link pointing to `/usr/bin`, and `/sbin` points to `/usr/sbin`.

### 2. The Brain: `/etc` (Configuration Files)

This is arguably the most important directory for system administrators. It contains all the system-wide configuration files. If you need to change how a service behaves, you edit a file here.

- `resolv.conf`: DNS resolver configuration.
- `fstab`: File system table (defining how drives are mounted).
- `hosts`: Local DNS lookups.
- `nftables.conf` / `ufw`: Firewall configurations.

**Inside the `/etc` directory:**
![ETC Directory Part 1](<assets/Screenshot%20(697).png>)
![ETC Directory Part 2](<assets/Screenshot%20(698).png>)

### 3. The Engine: `/boot`

This directory contains everything required to boot the Linux operating system.

- `vmlinuz`: The actual compressed Linux Kernel.
- `initrd.img`: Initial RAM disk used during the boot process.
- `grub`: The bootloader configuration.

**Exploring the `/boot` directory:**
![Boot Directory](<assets/Screenshot%20(699).png>)

### 4. Other Essential Directories

- **`/home`:** Contains personal directories for regular users (e.g., `/home/ubuntu`).
- **`/root`:** The specific home directory for the superuser (`root`).
- **`/var`:** Contains variable data files, most notably system and application logs (`/var/log`).
- **`/tmp`:** Temporary files created by the system and users. Cleared upon reboot.
- **`/dev`:** Device files (representing hardware components like hard drives as files).

---

## 🛠️ Navigating and Inspecting Files

To truly understand what is inside a directory, simple `ls` isn't enough. We use detailed flags.

### The Power of `ls -ltr`

Running `ls -ltr` in the root directory gives a comprehensive view:

- **`l` (Long format):** Shows permissions, number of links, owner, group, size, and timestamp.
- **`t` (Sort by time):** Orders files by modification time.
- **`r` (Reverse):** Reverses the sorting order (oldest at the top, newest at the bottom).

Notice how directories like `bin`, `lib`, and `sbin` are highlighted in cyan with an arrow (`->`)—this indicates they are **symbolic links** pointing to `/usr/bin`, `/usr/lib`, etc.

![Root Directory Listing](<assets/Screenshot%20(702).png>)

---
