# RHCE Training Lab Infrastructure (Terraform & AWS)
This repository contains **Terraform** code to provision a fully functional **Red Hat Certified Engineer (RHCE) EX294** exam preparation environment on AWS.

It automates the deployment of 5 RHEL 8 virtual machines, configures private DNS, handles root-level SSH access between nodes, and attaches required storage, strictly adhering to the lab topology required for common RHCE practice exams.

## 🏗 Lab Topology
The infrastructure provisions the following resources in a private VPC:

| Hostname | DNS Name | Role | Hardware Specs | 
| ----- | ----- | ----- | ----- | 
| **ansible-control** | `ansible-control.hl.local` | Control Node | t3.medium | 
| **ansible2** | `ansible2.hl.local` | Managed Host | t3.micro | 
| **ansible3** | `ansible3.hl.local` | Managed Host | t3.micro | 
| **ansible4** | `ansible4.hl.local` | Managed Host | t3.micro | 
| **ansible5** | `ansible5.hl.local` | Database Host | t3.micro + **1GB Extra Disk** | 

### Key Features
* **Networking:** Custom VPC with a private Route53 Hosted Zone (`hl.local`) to ensure exam-style DNS resolution.
* **Root Access:** Cloud-Init scripts automatically enable Root login and inject SSH keys to allow the Control Node to SSH into all managed nodes as `root` without a password.
* **Storage:** `ansible5` is automatically provisioned with the required `/dev/sdb` (1GB) for LVM tasks.
* **CI/CD:** Fully automated deployment via GitHub Actions and Terraform Cloud.

## 🚀 Setup & Prerequisites

### 1. AWS
* You need an AWS Account.
* An existing **EC2 Key Pair** (PEM format) created in your target region (e.g., `us-east-1`).
* **Cost Warning:** This lab runs 5 EC2 instances. While they are small, they **will incur costs** while running. Always use the **Destroy** workflow when finished practicing.

### 2. Terraform Cloud

1. Create a Workspace named `rhce-lab`.
2. Set the **Execution Mode** to **Remote**.
3. Add the following **Environment Variables**:
   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`
4. Add the following **Terraform Variables**:
| Variable | Type | Description | 
| ----- | ----- | ----- | 
| `aws_ssh_key` | String | The **Name** of your key pair in AWS (e.g., `my-laptop-key`). | 
| `aws_ssh_key_content` | Sensitive | The **Private Key Content** (PEM) of that key. This is copied to the Control Node. | 
| `ssh_allowed_cidr` | String | Your IP address (e.g., `1.2.3.4/32`) to allow SSH access. | 

### 3. GitHub
1. Go to **Settings > Secrets and variables > Actions**.
2. Add a secret named `TF_API_TOKEN` containing your Terraform Cloud User/Team API Token.

## 🕹 Usage

### Deploying (Apply)
1. **Push to Main:** Any push to the `main` branch will automatically trigger a `terraform apply`.
2. **Manual Trigger:** Go to the **Actions** tab in GitHub, select **Terraform Infrastructure**, click **Run workflow**, and ensure **Terraform Action** is set to `apply`.

### Destroying (Cleanup)
**Critical:** To stop billing, destroy the lab when done.
1. Go to the **Actions** tab in GitHub.
2. Select **Terraform Infrastructure**.
3. Click **Run workflow**.
4. Change **Terraform Action** to `destroy`.
5. Run the workflow.

## 💻 Connecting to the Lab
1. After the `apply` finishes, get the **Control Node Public IP** from the Terraform Output or AWS Console.
2. SSH into the control node using your local key:
```bash
ssh -i /path/to/your-key.pem ec2-user@<CONTROL_NODE_IP>
```
3. Switch to root:
```bash
sudo -i
```
4. Verify connectivity to the lab network, this should work without a password:
```bash
ssh ansible2.hl.local
```

## 📝 License
This project is for educational purposes.