![Progress](https://img.shields.io/badge/Progress-45%25-green?style=for-the-badge&logo=kubernetes)

# Day 45: Linux User Management, File Operations & The Vi Editor 🐧

Welcome to Day 45 of my **100 Days of DevOps** journey! Today I explored Linux user and group management, basic file operations, and the `vi` editor — all essential skills for DevOps and sysadmin work.

---

## 👥 1. User Management in Linux

Linux is a multi-user OS — creating and managing users securely is critical for server security.

### Creating Users and inspecting `/etc/passwd`

I created a user named `Soham`, then inspected `/etc/passwd` to confirm the account entry.

```bash
sudo useradd Soham
cat /etc/passwd
```

![User Management example](assets/Screenshot (705).png)

### Setting a password and home directory troubleshooting

Set a password for the new user:

```bash
sudo passwd Soham
```

If `su - Soham` fails because the home directory is missing, recreate the user with a home directory:

```bash
sudo userdel Soham
sudo useradd -m Soham
sudo su - Soham
pwd  # should print /home/Soham
```

Passwords are stored as hashes in `/etc/shadow` and are readable only by root:

```bash
sudo cat /etc/shadow
```

---

## 🛡️ 2. Group Management

Groups let you manage permissions for multiple users. I created a `Devops` group and added `Soham` to it.

```bash
sudo groupadd Devops
sudo usermod -aG Devops Soham
cat /etc/group
```

![Group Management example](assets/Screenshot (706).png)

Note: always use `-aG` when adding a user to a supplementary group to avoid removing existing group memberships.

---

## 📁 3. Basic File & Directory Operations

Practiced common file operations in `/tmp`:

- `mkdir` — create directories
- `touch` — create files / update timestamps
- `cp` — copy files
- `mv` — move/rename files
- `rm` — remove files

Example:

```bash
cd /tmp
mkdir devops-practice
touch readme.txt
cp readme.txt copy-readme.txt
mv copy-readme.txt notes.txt
ls -la
```

![File operations](assets/Screenshot (707).png)

---

## 📝 4. Text Editing & Viewing

The `vi` editor is available on almost every Unix-like system. Basic workflow:

- Press `i` to enter insert mode
- Type/edit text
- Press `Esc` to return to normal mode
- `:wq` to save and quit, `:q!` to quit without saving

Viewing files without editing:

```bash
head -10 devops.txt   # view first 10 lines
tail -5 devops.txt    # view last 5 lines
```

![vi editor basics](assets/Screenshot (709).png)

---

## 💡 Key Takeaway

The CLI is the language of the system. Mastering user & group management, file operations, and editors like `vi` makes you an effective operator.

---

# User Management in Linux

## Introduction to User Management in Linux

Linux is a multi-user operating system, meaning multiple users can operate on a system simultaneously. Proper user management ensures security, controlled access, and system integrity.

Key files involved in user management:

- `/etc/passwd` – Stores user account details.
- `/etc/shadow` – Stores encrypted user passwords.
- `/etc/group` – Stores group information.
- `/etc/gshadow` – Stores secure group details.

## Creating Users in Linux

To create a new user in Linux, use:

### `useradd` Command (For most Linux distributions)

```bash
useradd username
```

This creates a user without a home directory.

To create a user with a home directory:

```bash
useradd -m username
```

To specify a shell:

```bash
useradd -s /bin/bash username
```

### `adduser` Command (For Debian-based systems)

```bash
adduser username
```

This is an interactive command that asks for a password and additional details.

## Managing User Passwords

To set or change a user’s password:

```bash
passwd username
```

### Enforcing Password Policies

- **Password expiration**: Set password expiry days
  ```bash
  chage -M 90 username
  ```
- **Lock a user account**
  ```bash
  passwd -l username
  ```
- **Unlock a user account**
  ```bash
  passwd -u username
  ```

## Modifying Users

Modify an existing user with `usermod`:

- Change the username:
  ```bash
  usermod -l new_username old_username
  ```
- Change the home directory:
  ```bash
  usermod -d /new/home/directory -m username
  ```
- Change the default shell:
  ```bash
  usermod -s /bin/zsh username
  ```

## Deleting Users

To remove a user but keep their home directory:

```bash
userdel username
```

To remove a user and their home directory:

```bash
userdel -r username
```

## Working with Groups

### Creating Groups

```bash
groupadd groupname
```

### Adding Users to Groups

```bash
usermod -aG groupname username
```

### Viewing Group Memberships

```bash
groups username
```

### Changing Primary Group

```bash
usermod -g new_primary_group username
```

## Sudo Access and Privilege Escalation

### Adding a User to Sudo Group

On Debian-based systems:

```bash
usermod -aG sudo username
```

On RHEL-based systems:

```bash
usermod -aG wheel username
```

### Granting Specific Commands with Sudo

Edit the sudoers file:

```bash
visudo
```

Then add:

```bash
username ALL=(ALL) NOPASSWD: /path/to/command
```

# File management in Linux

### File and Directory Management

1. **`ls`** – Lists files and directories in the current location.
2. **`cd /path/to/directory`** – Changes the working directory.
3. **`pwd`** – Prints the current working directory.
4. **`mkdir new_folder`** – Creates a new directory.
5. **`rmdir empty_folder`** – Removes an empty directory.
6. **`rm file.txt`** – Deletes a file.
7. **`rm -r folder`** – Deletes a folder and its contents.
8. **`cp file1.txt file2.txt`** – Copies a file.
9. **`cp -r dir1 dir2`** – Copies a directory recursively.
10. **`mv old_name new_name`** – Moves or renames a file or directory.

### File Viewing and Editing

11. **`cat file.txt`** – Displays file content.
12. **`tac file.txt`** – Displays file content in reverse order.
13. **`less file.txt`** – Opens a file for viewing with scrolling support.
14. **`more file.txt`** – Similar to `less`, but only moves forward.
15. **`head -n 10 file.txt`** – Displays the first 10 lines of a file.
16. **`tail -n 10 file.txt`** – Displays the last 10 lines of a file.
17. **`nano file.txt`** – Opens a simple text editor.
18. **`vi file.txt`** – Opens a powerful text editor.
19. **`echo 'Hello' > file.txt`** – Writes text to a file, overwriting existing content.
20. **`echo 'Hello' >> file.txt`** – Appends text to a file without overwriting.
