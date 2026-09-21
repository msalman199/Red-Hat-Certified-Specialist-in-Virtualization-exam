<div align="center">

# 🔐 Lab 3: Integrating RHVM with FreeIPA for Authentication

### Centralize identity management — install FreeIPA, create users & groups, and authenticate Red Hat Virtualization Manager against it

<br>

![Red Hat](https://img.shields.io/badge/Red_Hat-Virtualization-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![RHEL](https://img.shields.io/badge/RHEL-8%2F9-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![FreeIPA](https://img.shields.io/badge/FreeIPA-Identity_Management-2C7BB6?style=for-the-badge)
![Kerberos](https://img.shields.io/badge/Kerberos-Authentication-8A2BE2?style=for-the-badge)
![LDAP](https://img.shields.io/badge/LDAP-Directory-336791?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🌐 Lab Environment](#-lab-environment)
- [🧠 Key Concepts](#-key-concepts)
- [🧱 Task 1: Install and Configure FreeIPA Server](#-task-1-install-and-configure-freeipa-server)
- [👥 Task 2: Create Users and Groups in FreeIPA](#-task-2-create-users-and-groups-in-freeipa)
- [🔗 Task 3: Configure RHVM to Integrate with FreeIPA](#-task-3-configure-rhvm-to-integrate-with-freeipa)
- [🔍 Task 4: Verify User Authentication Through RHVM](#-task-4-verify-user-authentication-through-rhvm)
- [🩺 Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [🎉 Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | Install and configure FreeIPA server on a RHEL system |
| 2 | Understand the components and architecture of FreeIPA |
| 3 | Configure Red Hat Virtualization Manager (RHVM) to authenticate against FreeIPA |
| 4 | Create and manage users and groups in FreeIPA |
| 5 | Verify user authentication and authorization through RHVM |
| 6 | Troubleshoot common integration issues between RHVM and FreeIPA |

---

## 📋 Prerequisites

Before starting this lab, you should have:

| # | Prerequisite |
|---|--------------|
| 1 | Basic understanding of Linux system administration |
| 2 | Familiarity with Red Hat Enterprise Linux (RHEL) command line |
| 3 | Knowledge of DNS concepts and configuration |
| 4 | Understanding of LDAP and Kerberos authentication principles |
| 5 | Basic knowledge of Red Hat Virtualization Manager (RHVM) |
| 6 | Network connectivity between systems |

---

## 🌐 Lab Environment

> [!TIP]
> ### ☁️ Ready-to-Use Cloud Machines
>
> Al Nafi provides ready-to-use Linux-based cloud machines for this lab. Simply click **"Start Lab"** to access your pre-configured environment. No need to build your own VMs.

Your lab environment includes:

| System | Description | Hostname |
|--------|-------------|----------|
| 🔐 **FreeIPA Server** | RHEL 8/9 system | `ipa.example.com` |
| 🖥️ **RHVM Manager** | Red Hat Virtualization Manager system | `rhvm.example.com` |
| 💻 **Client System** | RHEL system for testing | `client.example.com` |

---

## 🧠 Key Concepts

| Concept | Description |
|---------|-------------|
| **FreeIPA** | A centralized identity management solution providing users, groups, DNS, and Kerberos/LDAP authentication in one place |
| **LDAP** | The directory protocol RHVM uses to look up FreeIPA users and groups |
| **Kerberos** | The ticket-based authentication protocol FreeIPA provides for strong authentication and SSO |
| **Realm** | The Kerberos realm for the domain — `EXAMPLE.COM` in this lab |
| **`ipa-server-install`** | Installs and configures the FreeIPA server (with integrated DNS in this lab) |
| **`ipa-client-install`** | Enrolls a system — here, the RHVM manager — into the FreeIPA domain |
| **Authentication Domain** | The RHVM configuration entry that points RHVM at the FreeIPA LDAP directory |
| **Namespace** | The domain namespace used when searching for and adding FreeIPA users in RHVM |
| **Roles (`SuperUser`, `UserRole`)** | RHVM permissions assigned to FreeIPA users on an object such as `System` |
| **SSO** | Single Sign-On — a Kerberos-authenticated user logs in without re-entering credentials |

**🧩 FreeIPA services** (as reported by `ipactl status`):

| Service | Role |
|---------|------|
| `Directory Service` | LDAP directory holding users and groups |
| `krb5kdc` | Kerberos Key Distribution Center |
| `kadmin` | Kerberos administration service |
| `named` | DNS service |
| `httpd` | Web interface and API |
| `ipa-custodia` | Secrets management service |
| `pki-tomcatd` | Certificate authority (PKI) service |
| `ipa-otpd` | One-time-password (OTP) service |

---

## 🧱 Task 1: Install and Configure FreeIPA Server

![FreeIPA](https://img.shields.io/badge/FreeIPA-2C7BB6?style=flat-square)
![DNS](https://img.shields.io/badge/DNS-BIND-lightgrey?style=flat-square)
![Kerberos](https://img.shields.io/badge/Kerberos-8A2BE2?style=flat-square)
![firewalld](https://img.shields.io/badge/firewalld-EE0000?style=flat-square&logo=redhat&logoColor=white)

### 🛠️ Subtask 1.1: Prepare the System for FreeIPA Installation

First, we need to prepare our RHEL system for FreeIPA installation by configuring hostname, DNS, and firewall settings.

**🏷️ Step 1 — Set the hostname for the FreeIPA server:**

```bash
sudo hostnamectl set-hostname ipa.example.com
```

**📦 Step 2 — Update the system packages:**

```bash
sudo dnf update -y
```

**📝 Step 3 — Configure the hosts file:**

```bash
sudo vi /etc/hosts
```

Add the following entries:

```text
192.168.1.10    ipa.example.com ipa
192.168.1.20    rhvm.example.com rhvm
192.168.1.30    client.example.com client
```

> [!NOTE]
> Replace the IP addresses with your actual system IPs.

**🔥 Step 4 — Configure firewall rules for FreeIPA:**

```bash
sudo firewall-cmd --permanent --add-service=freeipa-ldap
sudo firewall-cmd --permanent --add-service=freeipa-ldaps
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=kerberos
sudo firewall-cmd --permanent --add-service=kpasswd
sudo firewall-cmd --reload
```

### 📥 Subtask 1.2: Install FreeIPA Server Packages

**📦 Step 1 — Install the FreeIPA server packages:**

```bash
sudo dnf install -y ipa-server ipa-server-dns
```

**🔍 Step 2 — Verify the installation:**

```bash
rpm -qa | grep ipa-server
```

### ⚙️ Subtask 1.3: Configure FreeIPA Server

**🚀 Step 1 — Run the FreeIPA server installation:**

```bash
sudo ipa-server-install --setup-dns --forwarder=8.8.8.8 --forwarder=8.8.4.4
```

**💬 Step 2 — Follow the interactive prompts:**

| Prompt | Response |
|--------|----------|
| Server host name [ipa.example.com] | Press Enter |
| Please confirm the domain name [example.com] | Press Enter |
| Please provide a realm name [EXAMPLE.COM] | Press Enter |
| Directory Manager password | Enter a strong password |
| Password (confirm) | Confirm the password |
| IPA admin password | Enter a strong password |
| Password (confirm) | Confirm the password |
| NetBIOS domain name [EXAMPLE] | Press Enter |
| Do you want to configure DNS forwarders? [yes] | Press Enter |
| Do you want to search for missing reverse zones? [yes] | Press Enter |
| Continue to configure the system with these values? [no] | `yes` |

> ⏳ Wait for the installation to complete (this may take 10-15 minutes).

**✅ Step 3 — Verify the installation:**

```bash
sudo ipactl status
```

Expected output should show all services running:

```text
Directory Service: RUNNING
krb5kdc Service: RUNNING
kadmin Service: RUNNING
named Service: RUNNING
httpd Service: RUNNING
ipa-custodia Service: RUNNING
pki-tomcatd Service: RUNNING
ipa-otpd Service: RUNNING
```

### 🎫 Subtask 1.4: Configure Kerberos Authentication

**🔑 Step 1 — Obtain Kerberos ticket for admin user:**

```bash
kinit admin
```

> Enter the admin password you set during installation.

**🎟️ Step 2 — Verify Kerberos ticket:**

```bash
klist
```

**🧪 Step 3 — Test IPA command functionality:**

```bash
ipa user-find admin
```

---

## 👥 Task 2: Create Users and Groups in FreeIPA

![FreeIPA](https://img.shields.io/badge/FreeIPA-2C7BB6?style=flat-square)
![ipa CLI](https://img.shields.io/badge/ipa_CLI-Users_%26_Groups-success?style=flat-square)

### 🗂️ Subtask 2.1: Create User Groups

**🛡️ Step 1 — Create a group for RHVM administrators:**

```bash
ipa group-add rhvm-admins --desc="RHVM Administrators"
```

**👤 Step 2 — Create a group for RHVM users:**

```bash
ipa group-add rhvm-users --desc="RHVM Users"
```

**🔍 Step 3 — Verify group creation:**

```bash
ipa group-find
```

### 🙋 Subtask 2.2: Create Users

**👑 Step 1 — Create an RHVM administrator user:**

```bash
ipa user-add jdoe --first=John --last=Doe --email=jdoe@example.com --password
```

> Enter a temporary password when prompted.

**👤 Step 2 — Create a regular RHVM user:**

```bash
ipa user-add jsmith --first=Jane --last=Smith --email=jsmith@example.com --password
```

**➕ Step 3 — Add users to appropriate groups:**

```bash
ipa group-add-member rhvm-admins --users=jdoe
ipa group-add-member rhvm-users --users=jsmith
```

**✅ Step 4 — Verify user and group membership:**

```bash
ipa user-show jdoe
ipa group-show rhvm-admins
```

---

## 🔗 Task 3: Configure RHVM to Integrate with FreeIPA

![RHVM](https://img.shields.io/badge/RHVM-EE0000?style=flat-square&logo=redhat&logoColor=white)
![LDAP](https://img.shields.io/badge/LDAP-336791?style=flat-square)
![ipa-client](https://img.shields.io/badge/ipa--client-2C7BB6?style=flat-square)

### 🧰 Subtask 3.1: Prepare RHVM System for FreeIPA Integration

**🔌 Step 1 — Connect to your RHVM system:**

```bash
ssh root@rhvm.example.com
```

**🌍 Step 2 — Configure DNS to point to FreeIPA server:**

```bash
sudo vi /etc/resolv.conf
```

Add or modify:

```text
nameserver 192.168.1.10
search example.com
```

**📝 Step 3 — Update hosts file:**

```bash
sudo vi /etc/hosts
```

Add:

```text
192.168.1.10    ipa.example.com ipa
```

**📥 Step 4 — Install IPA client packages:**

```bash
sudo dnf install -y ipa-client
```

### 🤝 Subtask 3.2: Join RHVM to FreeIPA Domain

**🔗 Step 1 — Join the RHVM system to FreeIPA domain:**

```bash
sudo ipa-client-install --domain=example.com --server=ipa.example.com --realm=EXAMPLE.COM
```

**💬 Step 2 — Follow the prompts:**

| Prompt | Response |
|--------|----------|
| Proceed with fixed values and no DNS discovery? [no] | `yes` |
| User authorized to enroll computers | `admin` |
| Password for admin@EXAMPLE.COM | Enter admin password |

**🔍 Step 3 — Verify the client installation:**

```bash
sudo ipa-client-install --unattended --enable-dns-updates
```

**🎫 Step 4 — Test Kerberos authentication:**

```bash
kinit admin
klist
```

### 🖥️ Subtask 3.3: Configure RHVM Authentication

**🌐 Step 1 — Access RHVM web interface:**

Open a web browser and navigate to:

```text
https://rhvm.example.com/ovirt-engine
```

**🔑 Step 2 — Login with default admin credentials:**

| Field | Value |
|-------|-------|
| **Username** | `admin@internal` |
| **Password** | Your RHVM admin password |

**🧭 Step 3 — Navigate to Administration → Configure:**

Click on **Configure** in the top menu.

**➕ Step 4 — Add Authentication Domain:**

Click **New** to add a new authentication domain, then enter:

| Field | Value |
|-------|-------|
| **Name** | `example.com` |
| **User Name** | `uid=admin,cn=users,cn=accounts,dc=example,dc=com` |
| **Password** | FreeIPA admin password |
| **Domain** | `example.com` |
| **LDAP Servers** | `ipa.example.com:389` |
| **Search Base** | `cn=accounts,dc=example,dc=com` |

**🔧 Step 5 — Configure Advanced Settings:**

| Setting | Value |
|---------|-------|
| **User Object Class** | `inetOrgPerson` |
| **User Name Attribute** | `uid` |
| **User Unique ID Attribute** | `ipaUniqueID` |
| **Group Object Class** | `groupOfNames` |
| **Group Name Attribute** | `cn` |
| **Group Member Attribute** | `member` |
| **Namespace** | `*` |

**🧪 Step 6 — Test the connection:**

Click **Test** to verify connectivity to FreeIPA.

**💾 Step 7 — Save the configuration:**

Click **OK** to save the authentication domain.

### 🛂 Subtask 3.4: Configure RHVM Authorization

**🧭 Step 1 — Navigate to Administration → Users:**

Click on **Users** in the Administration menu.

**➕ Step 2 — Add FreeIPA users to RHVM:**

1. Click **Add**
2. **Search:** Enter `jdoe`
3. **Namespace:** Select `example.com`
4. Click **Go**
5. Select the user and click **Add and Close**

**🎭 Step 3 — Assign roles to users:**

1. Select the user `jdoe`
2. Click the **Permissions** tab
3. Click **Add**
4. **Role:** Select `SuperUser`
5. **Object:** Select `System`
6. Click **OK**

**🔁 Step 4 — Repeat for additional users:**

Add `jsmith` with `UserRole` permissions.

---

## 🔍 Task 4: Verify User Authentication Through RHVM

![RHVM](https://img.shields.io/badge/RHVM-EE0000?style=flat-square&logo=redhat&logoColor=white)
![SSO](https://img.shields.io/badge/Kerberos-SSO-8A2BE2?style=flat-square)

### 🔓 Subtask 4.1: Test FreeIPA User Login

**🚪 Step 1 — Logout from RHVM:**

Click on the admin user dropdown and select **Sign Out**.

**🔑 Step 2 — Login with FreeIPA user:**

| Field | Value |
|-------|-------|
| **Username** | `jdoe@example.com` |
| **Password** | User's password |

**✅ Step 3 — Verify successful authentication:**

You should see the RHVM dashboard with appropriate permissions.

**🔎 Step 4 — Check user permissions:**

Navigate through different sections to verify the user has appropriate access based on assigned roles.

### 🧪 Subtask 4.2: Test Group-Based Authorization

**👤 Step 1 — Create a new user in FreeIPA:**

From the FreeIPA server:

```bash
ipa user-add testuser --first=Test --last=User --email=testuser@example.com --password
ipa group-add-member rhvm-users --users=testuser
```

**➕ Step 2 — Add the new user to RHVM:**

1. Login to RHVM as admin
2. Navigate to **Administration → Users**
3. Add the new user following previous steps
4. Assign appropriate role based on group membership

**🔓 Step 3 — Test the new user login:**

Logout and login with the new user credentials to verify authentication.

### 🎟️ Subtask 4.3: Verify Single Sign-On (SSO)

**⚙️ Step 1 — Configure Kerberos SSO (Optional):**

On a client machine joined to the FreeIPA domain:

```bash
kinit jdoe@EXAMPLE.COM
```

**🌐 Step 2 — Access RHVM web interface:**

Navigate to RHVM URL in a browser configured for Kerberos authentication.

**✅ Step 3 — Verify automatic authentication:**

The user should be automatically logged in without entering credentials.

---

## 🩺 Troubleshooting Common Issues

<details>
<summary><b>🌍 Issue 1: DNS Resolution Problems</b></summary>

<br>

**Symptoms:** Cannot resolve FreeIPA server hostname

**Solution:**

```bash
# 🔍 Check DNS configuration
nslookup ipa.example.com

# 📄 Verify /etc/resolv.conf
cat /etc/resolv.conf

# 🧪 Test DNS resolution
dig ipa.example.com
```

</details>

<details>
<summary><b>🎫 Issue 2: Kerberos Authentication Failures</b></summary>

<br>

**Symptoms:** `kinit` fails or tickets expire quickly

**Solution:**

```bash
# 📄 Check Kerberos configuration
cat /etc/krb5.conf

# ⏱️ Verify time synchronization
sudo chrony sources -v

# 🧹 Clear Kerberos cache
kdestroy
kinit admin
```

</details>

<details>
<summary><b>📡 Issue 3: LDAP Connection Issues</b></summary>

<br>

**Symptoms:** RHVM cannot connect to FreeIPA LDAP

**Solution:**

```bash
# 🧪 Test LDAP connectivity
ldapsearch -x -H ldap://ipa.example.com -b "dc=example,dc=com"

# 🔥 Check firewall rules
sudo firewall-cmd --list-services

# 🔐 Verify certificates
openssl s_client -connect ipa.example.com:636
```

</details>

<details>
<summary><b>🚫 Issue 4: User Authentication Failures</b></summary>

<br>

**Symptoms:** Users cannot login to RHVM

**Solution:**

1. **Verify user exists in FreeIPA:**

   ```bash
   ipa user-show username
   ```

2. **Check user group membership:**

   ```bash
   ipa user-show username --all
   ```

3. **Verify RHVM user configuration:**

   Check user permissions and domain assignment in RHVM web interface.

</details>

---

## 🎉 Conclusion

### 🏆 Key Accomplishments

In this lab, you have successfully:

- ✅ Installed and configured FreeIPA server on RHEL, creating a centralized identity management solution
- ✅ Integrated RHVM with FreeIPA for external authentication, eliminating the need for separate user management
- ✅ Created users and groups in FreeIPA and mapped them to appropriate RHVM roles
- ✅ Verified authentication and authorization through practical testing
- ✅ Learned troubleshooting techniques for common integration issues

### 🌍 Why This Matters — Real-World Benefits

This integration provides several important benefits:

| Benefit | Description |
|---------|-------------|
| 🗂️ **Centralized Identity Management** | All users and groups are managed in one location |
| 🔒 **Enhanced Security** | Leverages Kerberos for strong authentication |
| 🧹 **Simplified Administration** | Reduces administrative overhead by eliminating duplicate user accounts |
| 📈 **Scalability** | Easily supports large numbers of users and complex organizational structures |
| 📋 **Compliance** | Meets enterprise requirements for centralized authentication and audit trails |

> [!IMPORTANT]
> The skills you've developed in this lab are essential for enterprise virtualization environments and directly applicable to the **Red Hat Certified Specialist in Virtualization** exam. Understanding FreeIPA integration with RHVM demonstrates your ability to implement enterprise-grade identity management solutions in virtualized infrastructures.

### 🚀 Next Steps

Consider exploring advanced topics to further enhance your identity management expertise:

- 🤝 Trust relationships with Active Directory
- 📜 Certificate management
- 🤖 Automated user provisioning

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Education-0A66C2?style=for-the-badge)

**Lab 3: Integrating RHVM with FreeIPA for Authentication**

*Powered by Al Nafi — hands-on labs on ready-to-use cloud machines*

</div>
