![Progress](https://img.shields.io/badge/Progress-47%25-green?style=for-the-badge&logo=kubernetes)

# Day 47: Advanced Process Management, Monitoring, Services, & Disk Management 🐧

Welcome to Day 47 of the #100DaysOfDevOps challenge! Today's session was packed with crucial Linux system administration concepts. We moved from basic process management to advanced monitoring, handling system services, and finally diving into disk management and attaching/mounting AWS EBS volumes.

Here is a complete breakdown of everything covered today.

---

## 📋 Topics Covered

- **Process Management:** `ps`, `kill`, job control (`STOP`/`CONT`).
- **Process Priorities:** Understanding niceness (`renice`).
- **System Services:** Managing daemons with `systemctl`.
- **Resource Monitoring:** `top`, `htop`, `vmstat`, `free`, `nproc`.
- **Disk Management:** `df`, `du`, attaching AWS EBS volumes, formatting, and mounting.

---

## 1. Viewing and Managing Processes

The `ps` (process status) command is the fundamental tool for viewing what is currently running on the system.

- **`ps aux`**: Displays all processes running on the system for all users.
- **`ps -ef`**: Another standard way to view all processes, providing a full-format listing which includes the Parent Process ID (PPID).

![Listing processes with ps aux](<assets/Screenshot%20(725).png>)
![Full process listing with ps -ef](<assets/Screenshot%20(726).png>)

By combining commands with the pipe (`|`) operator, we can pass the output of `ps aux` into `wc -l` to count running processes.
![Counting processes with wc -l](<assets/Screenshot%20(727).png>)

### Terminating and Suspending Processes

We use the `kill` command to send signals to processes.

- **`kill -9 <PID>`:** Forces a process to terminate immediately (SIGKILL).
  ![Killing processes](<assets/Screenshot%20(729).png>)
  ![Verifying process termination](<assets/Screenshot%20(730).png>)

- **`kill -STOP <PID>`:** Pauses the process (Notice the state changes to `T`).
- **`kill -CONT <PID>`:** Resumes the paused process.
  ![Suspending a process](<assets/Screenshot%20(731).png>)
  ![Resuming a process](<assets/Screenshot%20(733).png>)

---

## 2. Process Priority (Niceness)

Linux uses "niceness" to determine process priority.

- The scale goes from **-20 (Highest Priority)** to **19 (Lowest Priority)**.
- Lower nice value = less "nice" to other processes = more CPU time.

![Understanding Niceness Whiteboard](<assets/Screenshot%20(735).png>)

You can change the priority of a running process using `renice -n <value> -p <PID>`. Keep in mind that decreasing a nice value (making it higher priority) requires `sudo` privileges.
![Trying to renice a process](<assets/Screenshot%20(734).png>)

---

## 3. System Services (`systemd`)

A process is just an executing program, but a **Service** is a background process (daemon) configured to start automatically on boot and stay running. Web servers (Nginx/Apache) or cron jobs are great examples.

![Process vs Services Whiteboard](<assets/Screenshot%20(736).png>)

We use `systemctl` to manage these services.

- **`systemctl list-units --type=service`**: Lists all active services.
- **`systemctl stop <service_name>`**: Stops a running service (e.g., `cron.service`).

![Listing Services](<assets/Screenshot%20(737).png>)
![Stopping a Service](<assets/Screenshot%20(738).png>)

---

## 4. System Monitoring

To keep a server healthy, you need to monitor its resources in real-time.

- **`top`**: The classic real-time process viewer. Shows CPU, memory, and running tasks.
- **`htop`**: An enhanced, colorful, and interactive version of `top` (much easier to read!).

![top command](<assets/Screenshot%20(739).png>)
![htop command](<assets/Screenshot%20(740).png>)

Other critical commands for checking system capacity:

- **`vmstat`**: Reports virtual memory statistics.
- **`free -h`**: Shows available and used RAM in a human-readable format.
- **`nproc`**: Prints the number of processing units available.

![vmstat, free, and nproc](<assets/Screenshot%20(742).png>)

---

## 5. Disk Management & AWS Volumes

Finally, we looked at how to manage storage, check disk space, and attach external volumes.

- **`df -h`**: (Disk Free) Shows the amount of disk space available on the file system.
- **`du -sh *`**: (Disk Usage) Summarizes the size of specific files and directories.

![df and du commands](<assets/Screenshot%20(743).png>)

### Attaching and Mounting an EBS Volume

As part of cloud infrastructure, we often need more storage. I went into the AWS Console, created an Elastic Block Store (EBS) volume, and attached it to my running EC2 instance as `/dev/sdf`.

![Attaching EBS Volume in AWS](<assets/Screenshot%20(744).png>)

Once attached, we can verify the OS sees the new raw disk using **`lsblk`** (List Block Devices). The new 10G volume appears as `xvdf`.

![lsblk command showing raw disk](<assets/Screenshot%20(745).png>)

**Step-by-Step Mounting Process:**

1. **Create a Mount Point:** We need a directory to attach the disk to. Using root privileges, I created `/mnt/demo-volume`.
   ![Creating a mount directory](<assets/Screenshot%20(746).png>)

2. **Format the Volume:** A raw disk cannot store files until it has a filesystem. I formatted the `xvdf` volume using the `ext4` filesystem with `mkfs -t ext4 /dev/xvdf`.
   ![Formatting the volume to ext4](<assets/Screenshot%20(747).png>)

3. **Mount the Volume:** Now, attach the formatted disk to the directory we created using `mount /dev/xvdf /mnt/demo-volume/`.
   ![Mounting the volume](<assets/Screenshot%20(748).png>)

4. **Verify the Mount:** Running `lsblk` again confirms that `xvdf` is now successfully mounted at `/mnt/demo-volume`.
   ![lsblk showing mounted volume](<assets/Screenshot%20(749).png>)

5. **Test the Storage:** Finally, I navigated into the mounted directory, created a test file (`touch abhishek`), and used `df -h` to verify the new 10GB drive is actively contributing to the system's available storage!
   ![Testing the mounted volume](<assets/Screenshot%20(750).png>)

---

### 💡 Key Takeaway

Today bridged the gap between seeing what a server is doing and actively managing its resources. From controlling rogue processes and prioritizing important ones, to fully provisioning, formatting, and mounting raw cloud storage, these are the day-to-day commands every SysAdmin and DevOps engineer relies on.
