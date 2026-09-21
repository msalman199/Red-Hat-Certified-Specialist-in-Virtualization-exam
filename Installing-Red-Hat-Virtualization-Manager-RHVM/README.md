<div align="center">

# 🖥️ Lab 1: Installing Red Hat Virtualization Manager (RHVM)

### Deploy oVirt Engine — the upstream open-source RHVM — on RHEL 8 with PostgreSQL, Apache & OpenJDK

<br>

![Red Hat](https://img.shields.io/badge/Red_Hat-Virtualization-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![RHEL](https://img.shields.io/badge/RHEL-8.x-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![oVirt](https://img.shields.io/badge/oVirt-4.5-1E90FF?style=for-the-badge)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache](https://img.shields.io/badge/Apache_HTTPD-D22128?style=for-the-badge&logo=apache&logoColor=white)
![OpenJDK](https://img.shields.io/badge/OpenJDK-11-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [💻 System Requirements](#-system-requirements)
- [🌐 Lab Environment](#-lab-environment)
- [🧠 Key Concepts](#-key-concepts)
- [📦 Task 1: Set Up the Repository for RHVM Installation](#-task-1-set-up-the-repository-for-rhvm-installation)
- [🧩 Task 2: Install Required Packages](#-task-2-install-required-packages)
- [🔧 Task 3: Install and Configure RHVM (oVirt Engine)](#-task-3-install-and-configure-rhvm-ovirt-engine)
- [🔍 Task 4: Verify RHVM Installation Using Web Console](#-task-4-verify-rhvm-installation-using-web-console)
- [🩺 Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [🔒 Best Practices and Security Considerations](#-best-practices-and-security-considerations)
- [🎉 Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

By the end of this lab, students will be able to:

| # | Objective |
|---|-----------|
| 1 | Set up the necessary repositories for RHVM installation on a RHEL server |
| 2 | Install and configure required packages including PostgreSQL, Apache, and Java |
| 3 | Successfully install Red Hat Virtualization Manager (RHVM) |
| 4 | Verify the RHVM installation through the web console interface |
| 5 | Understand the basic architecture and components of RHVM |
| 6 | Navigate the RHVM web administration portal |

---

## 📋 Prerequisites

Before starting this lab, students should have:

| # | Prerequisite |
|---|--------------|
| 1 | Basic knowledge of Linux command line operations |
| 2 | Understanding of RHEL/CentOS system administration |
| 3 | Familiarity with package management using `yum`/`dnf` |
| 4 | Basic networking concepts (IP addresses, ports, DNS) |
| 5 | Understanding of virtualization concepts |
| 6 | Administrative (root) access to a RHEL-based system |

---

## 💻 System Requirements

| Component | Requirement |
|-----------|-------------|
| 🐧 **Operating System** | RHEL 8.x or CentOS Stream 8 server |
| 🧠 **Memory** | Minimum 4 GB RAM (8 GB recommended) |
| 💾 **Disk Space** | 20 GB available |
| 🌍 **Network** | Connectivity for package downloads |
| 🔥 **Firewall** | Access to required ports |

---

## 🌐 Lab Environment

> [!TIP]
> ### ☁️ Ready-to-Use Cloud Machines
>
> **Good News!** Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click **Start Lab** and you'll have immediate access to a RHEL server ready for RHVM installation. No need to build your own virtual machine or worry about initial system setup.

Your cloud machine comes with:

| Feature | Status |
|---------|--------|
| 🐧 Fresh RHEL 8.x installation | ✅ Ready |
| 🔑 Root access configured | ✅ Ready |
| 🌍 Network connectivity established | ✅ Ready |
| 🧰 Basic system tools pre-installed | ✅ Ready |

---

## 🧠 Key Concepts

| Concept | Description |
|---------|-------------|
| **RHVM (Red Hat Virtualization Manager)** | The central management platform for enterprise virtualization environments |
| **oVirt Engine** | The open-source upstream project of RHVM — used in this lab as the RHVM equivalent |
| **PostgreSQL** | The backend database that stores RHVM/oVirt Engine data |
| **Apache HTTP Server (`httpd` + `mod_ssl`)** | Serves the RHVM web interface and handles HTTP/HTTPS requests |
| **OpenJDK 11** | The Java runtime required by RHVM's application server components |
| **`engine-setup`** | The main configuration command that deploys and wires together the oVirt Engine |
| **Image I/O Proxy** | An Engine component configured during `engine-setup` |
| **WebSocket Proxy** | An Engine component configured during `engine-setup` |
| **Internal Profile** | The authentication profile used to log in to the Administration Portal as `admin` |
| **Administration Portal** | The web console for managing compute, network, storage, and users |
| **`engine-backup`** | The backup utility used in the regular-maintenance script |

---

## 📦 Task 1: Set Up the Repository for RHVM Installation

![dnf](https://img.shields.io/badge/dnf-EE0000?style=flat-square&logo=redhat&logoColor=white)
![EPEL](https://img.shields.io/badge/EPEL-Repository-blue?style=flat-square)
![oVirt](https://img.shields.io/badge/oVirt-4.5-1E90FF?style=flat-square)

### 🔄 Subtask 1.1: Update the System

First, ensure your system is up to date with the latest packages.

```bash
# 📦 Update all system packages
sudo dnf update -y

# 🔁 Reboot if kernel updates were installed
sudo reboot
```

> ⏳ Wait for the system to restart, then reconnect to your cloud machine.

### 🗂️ Subtask 1.2: Enable Required Repositories

RHVM requires specific repositories to be enabled for installation.

```bash
# ✅ Enable the required repositories for RHVM
sudo dnf config-manager --enable rhel-8-for-x86_64-appstream-rpms
sudo dnf config-manager --enable rhel-8-for-x86_64-baseos-rpms

# 🐧 For CentOS Stream users, enable PowerTools
sudo dnf config-manager --enable powertools

# ➕ Install EPEL repository for additional packages
sudo dnf install -y epel-release
```

### 🌍 Subtask 1.3: Add oVirt Repository

> [!NOTE]
> Since we're using open-source tools, we'll use **oVirt** (the upstream project for RHVM).

```bash
# ➕ Add the oVirt repository
sudo dnf install -y centos-release-ovirt45

# 🛠️ Alternative method - add repository manually
sudo cat > /etc/yum.repos.d/ovirt-4.5.repo << EOF
[ovirt-4.5]
name=oVirt 4.5
baseurl=https://resources.ovirt.org/pub/ovirt-4.5/rpm/el8/
enabled=1
gpgcheck=1
gpgkey=https://resources.ovirt.org/pub/ovirt-4.5/rpm/RPM-GPG-ovirt-4.5
EOF
```

### ✅ Subtask 1.4: Verify Repository Configuration

```bash
# 📋 List enabled repositories
sudo dnf repolist enabled

# 🧹 Clean repository cache
sudo dnf clean all

# 🔄 Update repository metadata
sudo dnf makecache
```

---

## 🧩 Task 2: Install Required Packages

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![Apache](https://img.shields.io/badge/Apache-D22128?style=flat-square&logo=apache&logoColor=white)
![OpenJDK](https://img.shields.io/badge/OpenJDK_11-ED8B00?style=flat-square&logo=openjdk&logoColor=white)
![Python](https://img.shields.io/badge/Python_3-3776AB?style=flat-square&logo=python&logoColor=white)

### 🐘 Subtask 2.1: Install PostgreSQL Database

PostgreSQL serves as the backend database for RHVM.

```bash
# 📥 Install PostgreSQL server and client
sudo dnf install -y postgresql-server postgresql-contrib

# 🏗️ Initialize the PostgreSQL database
sudo postgresql-setup --initdb

# ▶️ Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# 🔍 Verify PostgreSQL is running
sudo systemctl status postgresql
```

### 🔐 Subtask 2.2: Configure PostgreSQL for RHVM

```bash
# 👤 Switch to postgres user and create database
sudo -u postgres psql << EOF
CREATE USER engine WITH PASSWORD 'engine123';
CREATE DATABASE engine OWNER engine TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
\q
EOF

# 💾 Configure PostgreSQL authentication
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.backup

# ✏️ Update pg_hba.conf for local connections
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /var/lib/pgsql/data/pg_hba.conf

# 🔄 Restart PostgreSQL to apply changes
sudo systemctl restart postgresql
```

### 🌐 Subtask 2.3: Install Apache HTTP Server

Apache serves the RHVM web interface and handles HTTP/HTTPS requests.

```bash
# 📥 Install Apache HTTP server
sudo dnf install -y httpd mod_ssl

# ▶️ Enable and start Apache service
sudo systemctl enable httpd
sudo systemctl start httpd

# 🔍 Verify Apache is running
sudo systemctl status httpd

# 🧪 Test Apache installation
curl -I http://localhost
```

### ☕ Subtask 2.4: Install Java Runtime Environment

RHVM requires Java for its application server components.

```bash
# 📥 Install OpenJDK 11 (recommended for oVirt/RHVM)
sudo dnf install -y java-11-openjdk java-11-openjdk-devel

# 🌱 Set JAVA_HOME environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' | sudo tee -a /etc/environment

# 🔄 Reload environment variables
source /etc/environment

# 🔍 Verify Java installation
java -version
javac -version
```

### 🧰 Subtask 2.5: Install Additional Required Packages

```bash
# 📥 Install additional packages needed for RHVM
sudo dnf install -y \
    python3-pip \
    python3-devel \
    gcc \
    openssl-devel \
    libffi-devel \
    git \
    wget \
    curl \
    unzip

# 🐍 Install Python packages for oVirt
sudo pip3 install ovirt-engine-sdk-python
```

---

## 🔧 Task 3: Install and Configure RHVM (oVirt Engine)

![oVirt](https://img.shields.io/badge/oVirt_Engine-1E90FF?style=flat-square)
![firewalld](https://img.shields.io/badge/firewalld-EE0000?style=flat-square&logo=redhat&logoColor=white)
![systemd](https://img.shields.io/badge/systemd-Services-lightgrey?style=flat-square&logo=linux&logoColor=black)

### 📦 Subtask 3.1: Install oVirt Engine

```bash
# 📥 Install oVirt Engine package
sudo dnf install -y ovirt-engine

# 🔍 Verify installation
rpm -qa | grep ovirt-engine
```

### 🔥 Subtask 3.2: Configure Firewall Rules

```bash
# 🔥 Configure firewall for RHVM services
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=6100/tcp
sudo firewall-cmd --permanent --add-port=54323/tcp

# 🔄 Reload firewall configuration
sudo firewall-cmd --reload

# 🔍 Verify firewall rules
sudo firewall-cmd --list-all
```

### ⚙️ Subtask 3.3: Run oVirt Engine Setup

This is the **main configuration step** for RHVM installation.

```bash
# 🚀 Run the engine setup command
sudo engine-setup
```

During the setup process, you'll be prompted for various configuration options. Here are the recommended responses:

**📝 Setup Prompts and Responses:**

| Prompt | Response |
|--------|----------|
| Configure Engine on this host? | `Yes` |
| Configure Image I/O Proxy on this host? | `Yes` |
| Configure WebSocket Proxy on this host? | `Yes` |
| Engine database host | `localhost` |
| Engine database port | `5432` |
| Engine database secured connection | `No` |
| Engine database name | `engine` |
| Engine database user | `engine` |
| Engine database password | `engine123` |
| Set application as default page | `Yes` |
| Configure Apache SSL | `Yes` |
| Organization name for certificate | `Your Organization` |
| Admin password | Create a strong password (**remember this!**) |

### 🏁 Subtask 3.4: Complete the Installation

```bash
# 🤖 The setup will automatically:
# - Configure the database
# - Set up SSL certificates
# - Configure Apache virtual hosts
# - Start required services

# ⏳ Wait for the setup to complete (this may take 10-15 minutes)
# ✅ You should see a message indicating successful installation
```

---

## 🔍 Task 4: Verify RHVM Installation Using Web Console

![Web Console](https://img.shields.io/badge/Web_Console-Admin_Portal-success?style=flat-square)
![systemd](https://img.shields.io/badge/systemd-Services-lightgrey?style=flat-square&logo=linux&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)

### 🩻 Subtask 4.1: Check Service Status

```bash
# 🔍 Verify all oVirt services are running
sudo systemctl status ovirt-engine
sudo systemctl status httpd
sudo systemctl status postgresql

# 🔁 Check if services are enabled for startup
sudo systemctl is-enabled ovirt-engine
sudo systemctl is-enabled httpd
sudo systemctl is-enabled postgresql
```

### 🌍 Subtask 4.2: Verify Network Connectivity

```bash
# 🧪 Check if the web interface is accessible locally
curl -k https://localhost/ovirt-engine/

# 👂 Check listening ports
sudo netstat -tlnp | grep -E ':(80|443|6100)'

# 🆔 Get the server's IP address
ip addr show | grep inet
```

### 🖱️ Subtask 4.3: Access the Web Console

Open a web browser and navigate to:

```text
https://YOUR_SERVER_IP/ovirt-engine/
```

1. 🔓 Accept the SSL certificate (since it's self-signed)
2. 🔑 Login with administrator credentials:

| Field | Value |
|-------|-------|
| **Username** | `admin` |
| **Password** | The password you set during `engine-setup` |
| **Profile** | `internal` |

### 🧭 Subtask 4.4: Explore the RHVM Interface

Once logged in, you should see the oVirt Administration Portal with several main sections:

| Section | Purpose |
|---------|---------|
| 📊 **Dashboard** | Overview of the virtualization environment |
| 🖥️ **Compute** | Virtual machines and hosts management |
| 🌐 **Network** | Network configuration and management |
| 💾 **Storage** | Storage domains and disks |
| 👥 **Administration** | Users, roles, and system configuration |

### ✅ Subtask 4.5: Verify Installation Completeness

```bash
# 🔍 Check engine status
sudo systemctl status ovirt-engine

# 📜 View engine logs for any errors
sudo tail -f /var/log/ovirt-engine/engine.log

# 🗄️ Check database connectivity
sudo -u postgres psql -d engine -c "SELECT version();"

# 🌐 Verify web service configuration
sudo httpd -t
```

---

## 🩺 Troubleshooting Common Issues

<details>
<summary><b>❌ Issue 1: Database Connection Problems</b></summary>

<br>

If you encounter database connection issues:

```bash
# 🔍 Check PostgreSQL status
sudo systemctl status postgresql

# 🗄️ Verify database exists
sudo -u postgres psql -l | grep engine

# 🧪 Test database connection
sudo -u postgres psql -d engine -c "SELECT 1;"
```

</details>

<details>
<summary><b>🔥 Issue 2: Firewall Blocking Access</b></summary>

<br>

If you can't access the web interface:

```bash
# ⚠️ Temporarily disable firewall for testing
sudo systemctl stop firewalld

# ✅ If this resolves the issue, add proper rules:
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

</details>

<details>
<summary><b>🔐 Issue 3: SSL Certificate Issues</b></summary>

<br>

For SSL certificate problems:

```bash
# 🔄 Regenerate certificates if needed
sudo engine-setup --offline --config-append=/etc/ovirt-engine/engine.conf.d/99-custom-truststore.conf
```

</details>

---

## 🔒 Best Practices and Security Considerations

### 🛡️ Security Hardening

```bash
# 🔑 Change default database password
sudo -u postgres psql -d engine -c "ALTER USER engine PASSWORD 'new_strong_password';"

# ✏️ Update engine configuration with new password
sudo engine-config -s EngineDBPassword=new_strong_password

# 🔄 Restart engine service
sudo systemctl restart ovirt-engine
```

### 🗓️ Regular Maintenance

```bash
# 💾 Create a backup script
sudo cat > /usr/local/bin/engine-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/ovirt-engine"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
engine-backup --mode=backup --file=$BACKUP_DIR/engine-backup-$DATE.tar.gz --log=/var/log/ovirt-engine/backup-$DATE.log
EOF

sudo chmod +x /usr/local/bin/engine-backup.sh
```

---

## 🎉 Conclusion

**Congratulations!** You have successfully completed the installation and configuration of Red Hat Virtualization Manager (RHVM) using open-source oVirt components.

### 🏆 Key Accomplishments

In this lab, you have:

- ✅ Set up the necessary repositories for RHVM installation on a RHEL server
- ✅ Installed and configured critical components including PostgreSQL database, Apache web server, and Java runtime environment
- ✅ Successfully deployed oVirt Engine as the open-source equivalent of RHVM
- ✅ Verified the installation through the web console interface
- ✅ Gained hands-on experience with enterprise virtualization management tools

### 🌍 Why This Matters — Real-World Applications

RHVM/oVirt serves as the central management platform for enterprise virtualization environments. The skills you've developed in this lab are directly applicable to:

| Area | Application |
|------|-------------|
| 🏢 **Enterprise Infrastructure Management** | Managing large-scale virtualized environments |
| ☁️ **Cloud Computing** | Understanding the foundation of private cloud platforms |
| 🐧 **System Administration** | Advanced Linux system configuration and service management |
| 🎓 **Career Development** | Preparation for the Red Hat Certified Specialist in Virtualization exam |

### 🚀 Next Steps

Now that you have a working RHVM installation, you can:

- ➕ Add virtualization hosts to create a cluster
- 💾 Configure storage domains for virtual machine storage
- 🖥️ Create and manage virtual machines
- 🌐 Set up networking for virtual environments
- 🛟 Implement backup and disaster recovery procedures

The foundation you've built in this lab provides the platform for advanced virtualization management tasks and prepares you for real-world enterprise virtualization scenarios.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Education-0A66C2?style=for-the-badge)

**Lab 1: Installing Red Hat Virtualization Manager (RHVM)**

*Powered by Al Nafi — hands-on labs on ready-to-use cloud machines*

</div>
