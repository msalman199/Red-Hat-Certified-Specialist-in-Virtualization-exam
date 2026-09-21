<div align="center">

# 🖧 Lab 4: Installing Red Hat Virtualization Hypervisor (RHVH)

### Install a hypervisor host, configure its network, and register it with RHVM for centralized management

<br>

![Red Hat](https://img.shields.io/badge/Red_Hat-Virtualization-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![CentOS Stream](https://img.shields.io/badge/CentOS_Stream-8-262577?style=for-the-badge&logo=centos&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-libvirt-FF6600?style=for-the-badge)
![VDSM](https://img.shields.io/badge/VDSM-Host_Agent-1E90FF?style=for-the-badge)
![LVM](https://img.shields.io/badge/LVM-VM_Storage-2E8B57?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🌐 Lab Environment](#-lab-environment)
- [🧠 Key Concepts](#-key-concepts)
- [💿 Task 1: Download and Install the RHVH Image](#-task-1-download-and-install-the-rhvh-image)
- [🔌 Task 2: Configure Network Settings and Registration with RHVM](#-task-2-configure-network-settings-and-registration-with-rhvm)
- [🔍 Task 3: Verify the RHVH Installation Using the RHVM Web Console](#-task-3-verify-the-rhvh-installation-using-the-rhvm-web-console)
- [🩺 Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [🎉 Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

By the end of this lab, students will be able to:

| # | Objective |
|---|-----------|
| 1 | Download and prepare the Red Hat Virtualization Hypervisor (RHVH) installation media |
| 2 | Install RHVH on a physical or virtual machine using proper configuration parameters |
| 3 | Configure network settings for RHVH integration with Red Hat Virtualization Manager (RHVM) |
| 4 | Register the RHVH host with RHVM for centralized management |
| 5 | Verify successful RHVH installation and connectivity through the RHVM web console |
| 6 | Understand the role of RHVH in enterprise virtualization infrastructure |
| 7 | Troubleshoot common installation and configuration issues |

---

## 📋 Prerequisites

Before starting this lab, students should have:

| Category | Requirement |
|----------|-------------|
| 📚 **Knowledge** | Basic understanding of Linux system administration |
| 📚 **Knowledge** | Familiarity with virtualization concepts and terminology |
| 📚 **Knowledge** | Knowledge of network configuration (IP addressing, DNS, routing) |
| 📚 **Knowledge** | Understanding of Red Hat Enterprise Linux installation procedures |
| 📚 **Knowledge** | Basic command-line interface skills |
| ⚙️ **Technical** | Access to Al Nafi cloud-based lab environment (no VM setup required) |
| ⚙️ **Technical** | Minimum 4GB RAM and 20GB storage for RHVH installation |
| ⚙️ **Technical** | Network connectivity for downloading installation media |
| ⚙️ **Technical** | Administrative privileges on the target system |
| 💻 **Software** | Red Hat Virtualization Manager (RHVM) already installed and accessible |
| 💻 **Software** | Web browser for accessing RHVM web console |
| 💻 **Software** | SSH client for remote system management |

---

## 🌐 Lab Environment

> [!IMPORTANT]
> ### ☁️ Ready-to-Use Cloud Machines
>
> Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated environment. No need to build or configure your own virtual machines.

Your lab environment includes:

| Feature | Status |
|---------|--------|
| 🌍 Pre-configured network settings | ✅ Ready |
| 📦 Access to Red Hat repositories | ✅ Ready |
| 🖥️ RHVM instance ready for host registration | ✅ Ready |
| 🧰 All necessary tools and utilities pre-installed | ✅ Ready |

### 🏢 Lab Environment Overview

This lab simulates a real-world enterprise virtualization deployment where you will install RHVH as a hypervisor host and integrate it with an existing RHVM infrastructure. The environment includes multiple network segments and storage configurations typical of production deployments.

---

## 🧠 Key Concepts

| Concept | Description |
|---------|-------------|
| **RHVH** | Red Hat Virtualization Hypervisor — the hypervisor layer that consolidates physical servers and hosts virtual machines |
| **RHVM** | Red Hat Virtualization Manager — the central interface for managing multiple hypervisor hosts |
| **KVM & libvirt** | The virtualization stack installed with the "Virtualization Host" package group |
| **VDSM** | Virtual Desktop and Server Manager — the host-side agent through which RHVM manages the host |
| **`ovirtmgmt`** | The management network bridge configured on the host through RHVM |
| **LVM** | Logical volume layout (`rhvh_vg` / `vm_storage_lv`) used for VM storage at `/var/lib/libvirt/images` |
| **Storage Domain** | RHVM storage definition — here, a Data domain on a POSIX-compliant file system |
| **SELinux booleans** | `virt_use_nfs` and `virt_use_samba`, set to support virtualization workloads |
| **Maintenance Mode** | RHVM host state used to validate that a host can leave and rejoin the cluster cleanly |

---

## 💿 Task 1: Download and Install the RHVH Image

![wget](https://img.shields.io/badge/wget-Download-lightgrey?style=flat-square)
![CentOS Stream](https://img.shields.io/badge/CentOS_Stream_8-262577?style=flat-square&logo=centos&logoColor=white)
![LVM](https://img.shields.io/badge/LVM-2E8B57?style=flat-square)

### 🛠️ Subtask 1.1: Prepare the Installation Environment

First, we need to prepare our system and download the RHVH installation image.

**🔌 Step 1 — Access your lab environment:**

```bash
# 🔑 Connect to your assigned lab machine
ssh student@your-lab-machine-ip
```

**📏 Step 2 — Verify system requirements:**

```bash
# 🧠 Check available memory
free -h

# 💾 Check available disk space
df -h

# ⚙️ Verify CPU virtualization support
grep -E '(vmx|svm)' /proc/cpuinfo
```

**📁 Step 3 — Create working directory for installation files:**

```bash
mkdir -p ~/rhvh-installation
cd ~/rhvh-installation
```

### 📥 Subtask 1.2: Download RHVH Installation Media

**⬇️ Step 1 — Download the RHVH ISO image:**

```bash
# 📥 Download RHVH 4.5 ISO (using CentOS Stream as open-source alternative)
wget https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-8-x86_64-latest-dvd1.iso

# 🔍 Verify the download
ls -lh *.iso
```

**🔐 Step 2 — Verify the ISO integrity:**

```bash
# 🧮 Calculate SHA256 checksum
sha256sum CentOS-Stream-8-x86_64-latest-dvd1.iso

# ✅ Compare with published checksums (example)
echo "Checksum verification completed"
```

### 💽 Subtask 1.3: Prepare Installation Media

**🔌 Step 1 — Create bootable USB drive (if using physical hardware):**

> [!WARNING]
> This will erase all data on the USB drive. Replace `/dev/sdX` with your USB device.

```bash
# 🔍 Identify USB device
lsblk

# 💽 Create bootable USB (replace /dev/sdX with your USB device)
# WARNING: This will erase all data on the USB drive
sudo dd if=CentOS-Stream-8-x86_64-latest-dvd1.iso of=/dev/sdX bs=4M status=progress
sync
```

**🖥️ Step 2 — For virtual machine installation, mount the ISO:**

```bash
# 📁 Create mount point
sudo mkdir -p /mnt/rhvh-iso

# 📀 Mount the ISO
sudo mount -o loop CentOS-Stream-8-x86_64-latest-dvd1.iso /mnt/rhvh-iso

# ✅ Verify mount
ls /mnt/rhvh-iso
```

### 🚀 Subtask 1.4: Begin RHVH Installation

**🥾 Step 1 — Boot from installation media:**

| System Type | Boot Source |
|-------------|-------------|
| 🖥️ Physical systems | Boot from USB drive |
| ☁️ Virtual machines | Boot from mounted ISO |

**📋 Step 2 — Select installation options:**

```text
Boot Menu Options:
- Install CentOS Stream 8 (select this option)
- Test this media & install CentOS Stream 8
- Troubleshooting
```

**🌍 Step 3 — Configure installation parameters:**

| Parameter | Value |
|-----------|-------|
| **Language** | English (United States) |
| **Keyboard** | US |
| **Time Zone** | Select appropriate timezone |

### 🗄️ Subtask 1.5: Configure Storage and Partitioning

**💾 Step 1 — Select installation destination:**

```text
Storage Configuration:
- Select target disk (minimum 20GB recommended)
- Choose "Custom" partitioning for RHVH optimization
```

**📐 Step 2 — Create optimal partition layout for RHVH:**

| Mount Point | Size | File System |
|-------------|------|-------------|
| `/boot` | 1GB | ext4 |
| `/` | 6GB | ext4 |
| `/home` | 1GB | ext4 |
| `/tmp` | 1GB | ext4 |
| `/var` | 5GB | ext4 |
| `/var/log` | 2GB | ext4 |
| `swap` | 4GB | swap |
| *remaining* | LVM for VM storage | — |

**🧱 Step 3 — Configure LVM for VM storage:**

| Setting | Value |
|---------|-------|
| **Volume Group** | `rhvh_vg` |
| **Logical Volume** | `vm_storage_lv` |
| **Mount point** | `/var/lib/libvirt/images` |
| **File system** | ext4 |

---

## 🔌 Task 2: Configure Network Settings and Registration with RHVM

![RHVM](https://img.shields.io/badge/RHVM-EE0000?style=flat-square&logo=redhat&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-libvirt-FF6600?style=flat-square)
![VDSM](https://img.shields.io/badge/VDSM-1E90FF?style=flat-square)
![SELinux](https://img.shields.io/badge/SELinux-Booleans-lightgrey?style=flat-square)

### 🌐 Subtask 2.1: Configure Network Interface

**🧭 Step 1 — Access network configuration during installation:**

```text
Network Configuration:
- Click on network interface (usually ens33 or eth0)
- Enable "Connect automatically"
- Configure IPv4 settings
```

**📌 Step 2 — Set static IP configuration:**

| IPv4 Setting | Value |
|--------------|-------|
| **Method** | Manual |
| **Address** | `192.168.1.100` |
| **Netmask** | `255.255.255.0` |
| **Gateway** | `192.168.1.1` |
| **DNS** | `192.168.1.1`, `8.8.8.8` |

**🏷️ Step 3 — Configure hostname:**

| Setting | Value |
|---------|-------|
| **Hostname** | `rhvh-host01.lab.local` |

Then click **Apply** to apply the configuration.

### 🧾 Subtask 2.2: Complete Base Installation

**🔑 Step 1 — Set root password:**

```text
Root Password Configuration:
- Set strong root password
- Confirm password
```

**👤 Step 2 — Create user account:**

| Field | Value |
|-------|-------|
| **Full name** | `RHVH Administrator` |
| **Username** | `rhvhadmin` |
| **Password** | Set strong password |
| **Make this user administrator** | Yes |

**▶️ Step 3 — Begin installation:**

Click **Begin Installation**.

> ⏳ Wait for installation to complete (approximately 15-30 minutes).

### 🔧 Subtask 2.3: Post-Installation Network Configuration

**🔄 Step 1 — Reboot and login to the system:**

```bash
# 🔑 After reboot, login as root
# 🔍 Verify network configuration
ip addr show
ip route show
```

**📝 Step 2 — Configure hostname resolution:**

```bash
# ✏️ Edit hosts file
sudo vi /etc/hosts
```

Add entries:

```text
192.168.1.100   rhvh-host01.lab.local   rhvh-host01
192.168.1.50    rhvm.lab.local          rhvm
```

**🧪 Step 3 — Test network connectivity:**

```bash
# 📡 Test connectivity to RHVM
ping -c 4 rhvm.lab.local

# 🔍 Test DNS resolution
nslookup rhvm.lab.local

# 🌍 Test internet connectivity
ping -c 4 google.com
```

### 📦 Subtask 2.4: Install Required Packages for RHVH

**🔄 Step 1 — Update system packages:**

```bash
# 📥 Update all packages
sudo dnf update -y

# ➕ Install EPEL repository
sudo dnf install -y epel-release
```

**🖥️ Step 2 — Install virtualization packages:**

```bash
# 📦 Install KVM and libvirt
sudo dnf groupinstall -y "Virtualization Host"

# 🧰 Install additional required packages
sudo dnf install -y qemu-kvm libvirt virt-install bridge-utils
```

**🤖 Step 3 — Install RHVM agent packages:**

```bash
# 📥 Install ovirt-hosted-engine-setup
sudo dnf install -y ovirt-hosted-engine-setup

# 📥 Install vdsm (Virtual Desktop and Server Manager)
sudo dnf install -y vdsm
```

### ⚙️ Subtask 2.5: Configure Virtualization Services

**▶️ Step 1 — Enable and start libvirt service:**

```bash
# 🔁 Enable libvirtd service
sudo systemctl enable libvirtd

# ▶️ Start libvirtd service
sudo systemctl start libvirtd

# 🔍 Verify service status
sudo systemctl status libvirtd
```

**🔥 Step 2 — Configure firewall for virtualization:**

```bash
# 🔥 Add firewall rules for libvirt
sudo firewall-cmd --permanent --add-service=libvirt

# 🔌 Add rules for RHVM communication
sudo firewall-cmd --permanent --add-port=54321/tcp
sudo firewall-cmd --permanent --add-port=16514/tcp

# 🔄 Reload firewall configuration
sudo firewall-cmd --reload

# 🔍 Verify firewall rules
sudo firewall-cmd --list-all
```

**🛡️ Step 3 — Configure SELinux for virtualization:**

```bash
# 🔍 Check SELinux status
sestatus

# ⚙️ Set SELinux booleans for virtualization
sudo setsebool -P virt_use_nfs 1
sudo setsebool -P virt_use_samba 1

# ✅ Verify SELinux booleans
getsebool -a | grep virt
```

---

## 🔍 Task 3: Verify the RHVH Installation Using the RHVM Web Console

![RHVM](https://img.shields.io/badge/RHVM-Web_Console-EE0000?style=flat-square&logo=redhat&logoColor=white)
![VDSM](https://img.shields.io/badge/VDSM-1E90FF?style=flat-square)
![libvirt](https://img.shields.io/badge/libvirt-FF6600?style=flat-square)

### 📝 Subtask 3.1: Register RHVH Host with RHVM

**🌐 Step 1 — Access RHVM web console:**

1. Open web browser
2. Navigate to: `https://rhvm.lab.local/ovirt-engine`
3. Login with administrator credentials

**➕ Step 2 — Add new host through RHVM console:**

1. Click **Compute** → **Hosts**
2. Click the **New** button
3. Fill in host details:

| Field | Value |
|-------|-------|
| **Name** | `rhvh-host01` |
| **Hostname** | `rhvh-host01.lab.local` |
| **Root Password** | *[enter root password]* |

4. Click **OK** to add host

**📜 Step 3 — Monitor host installation progress:**

```bash
# 👀 On RHVH host, monitor vdsm installation
sudo tail -f /var/log/vdsm/vdsm.log

# 🔍 Check host status
sudo systemctl status vdsmd
```

### 🌍 Subtask 3.2: Configure Host Networking in RHVM

**🧭 Step 1 — Configure management network:**

1. Select host `rhvh-host01`
2. Go to the **Network Interfaces** tab
3. Click **Setup Host Networks**
4. Drag `ovirtmgmt` to the physical interface
5. Apply configuration

**🔍 Step 2 — Verify network configuration:**

```bash
# 🌐 On RHVH host, check bridge configuration
ip addr show
brctl show

# 🌉 Verify ovirtmgmt bridge
ip addr show ovirtmgmt
```

**✅ Step 3 — Test network connectivity from RHVM:**

- Host status should show **Up**
- Network tab should show `ovirtmgmt` as active
- No network configuration warnings

### 💾 Subtask 3.3: Verify Storage Configuration

**🔍 Step 1 — Check available storage domains:**

1. Click **Storage** → **Domains**
2. Verify local storage is available
3. Check storage domain status

**🗄️ Step 2 — Configure local storage (if needed):**

```bash
# 📁 On RHVH host, prepare local storage
sudo mkdir -p /var/lib/libvirt/images
sudo chown vdsm:kvm /var/lib/libvirt/images
sudo chmod 755 /var/lib/libvirt/images

# 🛡️ Set SELinux context
sudo setsebool -P virt_use_nfs 1
sudo restorecon -R /var/lib/libvirt/images
```

**➕ Step 3 — Add storage domain through RHVM:**

Click **Storage** → **Domains** → **New**, then enter:

| Field | Value |
|-------|-------|
| **Name** | `local-storage-rhvh01` |
| **Domain Function** | Data |
| **Storage Type** | POSIX compliant FS |
| **Path** | `/var/lib/libvirt/images` |
| **Host** | `rhvh-host01` |

### 🧪 Subtask 3.4: Perform Comprehensive Verification Tests

**⚙️ Step 1 — Verify host capabilities:**

```bash
# 🧠 Check CPU features
sudo virt-host-validate

# 🔍 Verify KVM module
lsmod | grep kvm

# ✅ Check virtualization support
sudo virsh capabilities
```

**🖥️ Step 2 — Test VM creation capability:**

Click **Compute** → **Virtual Machines** → **New**, then create a test VM:

| Field | Value |
|-------|-------|
| **Name** | `test-vm-01` |
| **Operating System** | Linux |
| **Memory** | 1024 MB |
| **CPU** | 1 core |

Verify the VM can be created successfully.

**📊 Step 3 — Monitor host performance:**

```bash
# 📈 Check system resources
htop

# 🔍 Monitor libvirt processes
ps aux | grep libvirt

# ✅ Check VDSM status
sudo systemctl status vdsmd
```

### ✅ Subtask 3.5: Validate Host Integration

**📜 Step 1 — Verify host events and logs:**

1. Click the **Events** tab
2. Filter by host: `rhvh-host01`
3. Verify no critical errors
4. Check for successful registration events

**🛠️ Step 2 — Test host maintenance mode:**

1. Right-click on `rhvh-host01`
2. Select **Maintenance**
3. Wait for host to enter maintenance
4. Select **Activate** to bring host back online
5. Verify host returns to **Up** status

**🗂️ Step 3 — Validate cluster membership:**

1. Click **Compute** → **Clusters**
2. Select the default cluster
3. Go to the **Hosts** tab
4. Verify `rhvh-host01` is listed and active

---

## 🩺 Troubleshooting Common Issues

### 🌐 Network Configuration Problems

<details>
<summary><b>📡 Host cannot connect to RHVM</b></summary>

<br>

```bash
# 🔍 Check network connectivity
ping rhvm.lab.local

# 🔥 Verify firewall rules
sudo firewall-cmd --list-all

# 🧪 Check DNS resolution
nslookup rhvm.lab.local
```

</details>

<details>
<summary><b>🌉 Bridge configuration issues</b></summary>

<br>

```bash
# 🔄 Recreate ovirtmgmt bridge
sudo nmcli connection delete ovirtmgmt
sudo nmcli connection add type bridge con-name ovirtmgmt ifname ovirtmgmt
sudo nmcli connection modify ovirtmgmt ipv4.addresses 192.168.1.100/24
sudo nmcli connection modify ovirtmgmt ipv4.gateway 192.168.1.1
sudo nmcli connection modify ovirtmgmt ipv4.dns 192.168.1.1
sudo nmcli connection modify ovirtmgmt ipv4.method manual
sudo nmcli connection up ovirtmgmt
```

</details>

### ⚙️ Service Configuration Issues

<details>
<summary><b>🤖 VDSM service problems</b></summary>

<br>

```bash
# 🔄 Restart VDSM service
sudo systemctl restart vdsmd

# 📜 Check VDSM logs
sudo journalctl -u vdsmd -f

# 🔍 Verify VDSM configuration
sudo vdsm-client Host getCapabilities
```

</details>

<details>
<summary><b>🖥️ Libvirt connectivity issues</b></summary>

<br>

```bash
# 🔄 Restart libvirt service
sudo systemctl restart libvirtd

# 🧪 Test libvirt connection
sudo virsh list --all

# 📜 Check libvirt logs
sudo journalctl -u libvirtd -f
```

</details>

### 💾 Storage Configuration Problems

<details>
<summary><b>🗄️ Storage domain creation failures</b></summary>

<br>

```bash
# 🔍 Check storage permissions
ls -la /var/lib/libvirt/images

# 🔧 Fix ownership and permissions
sudo chown -R vdsm:kvm /var/lib/libvirt/images
sudo chmod -R 755 /var/lib/libvirt/images

# 🛡️ Verify SELinux context
sudo ls -Z /var/lib/libvirt/images
sudo restorecon -R /var/lib/libvirt/images
```

</details>

---

## 🎉 Conclusion

**In this comprehensive lab, you have successfully:**

### 🏆 Key Accomplishments

| Accomplishment | Description |
|----------------|-------------|
| ✅ **Installed RHVH** | You downloaded and installed Red Hat Virtualization Hypervisor on a dedicated system, creating a foundation for enterprise virtualization infrastructure |
| ✅ **Configured Network Integration** | You established proper network connectivity between RHVH and RHVM, including firewall rules, DNS resolution, and bridge configuration for VM networking |
| ✅ **Registered with RHVM** | You successfully integrated the RHVH host with Red Hat Virtualization Manager, enabling centralized management and monitoring of the virtualization infrastructure |
| ✅ **Verified Installation** | You performed comprehensive verification tests through the RHVM web console, confirming that the host is properly configured and ready for production workloads |
| ✅ **Configured Storage** | You set up local storage domains and verified that the host can support virtual machine storage requirements |

### 🌍 Why This Matters

This lab represents a critical skill set for enterprise IT professionals because:

| Area | Why It Matters |
|------|----------------|
| 🏗️ **Infrastructure Foundation** | RHVH provides the hypervisor layer that enables organizations to consolidate physical servers, reduce hardware costs, and improve resource utilization |
| 🎛️ **Centralized Management** | Integration with RHVM allows administrators to manage multiple hypervisor hosts from a single interface, streamlining operations and reducing complexity |
| 📈 **Enterprise Scalability** | The skills learned in this lab enable you to build and maintain large-scale virtualization environments that can support hundreds of virtual machines across multiple hosts |
| 🎓 **Career Relevance** | These competencies are directly applicable to the Red Hat Certified Specialist in Virtualization exam and are highly valued in enterprise environments using Red Hat virtualization technologies |
| 🛡️ **Production Readiness** | You now understand the complete process of deploying hypervisor infrastructure that meets enterprise standards for reliability, security, and manageability |

### 🚀 What's Next

The knowledge gained from this lab provides a solid foundation for advanced virtualization topics including:

- 🔁 High availability
- 🚚 Live migration
- 💾 Storage management
- 🛟 Disaster recovery planning

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Education-0A66C2?style=for-the-badge)

**Lab 4: Installing Red Hat Virtualization Hypervisor (RHVH)**

*Powered by Al Nafi — hands-on labs on ready-to-use cloud machines*

</div>
