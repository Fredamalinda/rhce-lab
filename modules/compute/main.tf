# modules/compute/main.tf

# --- AMI Lookup ---
data "aws_ami" "rhel8" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat
  filter {
    name   = "name"
    values = ["RHEL-8.*-x86_64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- 1. Ansible Control Node ---
resource "aws_instance" "control" {
  ami                    = data.aws_ami.rhel8.id
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  key_name               = var.aws_ssh_key # Use existing key name
  vpc_security_group_ids = [var.security_group]
  
  tags = { Name = "ansible-control" }

  # Cloud-Init:
  # 1. Enable root login by copying authorized keys from ec2-user
  # 2. Inject the Private Key into /root/.ssh/id_rsa so Ansible works immediately
  # 3. Set FQDN Hostname (hyfer.com)
  user_data = <<-EOF
    #cloud-config
    hostname: ansible-control.hyfer.com
    manage_etc_hosts: true
    disable_root: false
    ssh_pwauth: true
    runcmd:
      - [ sh, -c, "cp /home/ec2-user/.ssh/authorized_keys /root/.ssh/" ]
      - [ sh, -c, "chmod 600 /root/.ssh/authorized_keys" ]
      - [ sh, -c, "chown root:root /root/.ssh/authorized_keys" ]
    write_files:
      - content: |
          ${indent(10, var.aws_ssh_key_content)}
        path: /root/.ssh/id_rsa
        permissions: '0600'
        owner: root:root
  EOF
}

# --- 2. Managed Nodes (2, 3, 4) ---
resource "aws_instance" "managed" {
  count                  = 3
  ami                    = data.aws_ami.rhel8.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = var.aws_ssh_key # Use existing key name
  vpc_security_group_ids = [var.security_group]

  tags = { Name = "ansible${count.index + 2}" }

  user_data = <<-EOF
    #cloud-config
    hostname: ansible${count.index + 2}.hyfer.com
    manage_etc_hosts: true
    disable_root: false
    runcmd:
      - [ sh, -c, "cp /home/ec2-user/.ssh/authorized_keys /root/.ssh/" ]
      - [ sh, -c, "chmod 600 /root/.ssh/authorized_keys" ]
      - [ sh, -c, "chown root:root /root/.ssh/authorized_keys" ]
  EOF
}

# --- 3. Database Node (5) with Extra Disk ---
resource "aws_instance" "db_node" {
  ami                    = data.aws_ami.rhel8.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = var.aws_ssh_key # Use existing key name
  vpc_security_group_ids = [var.security_group]

  tags = { Name = "ansible5" }

  user_data = <<-EOF
    #cloud-config
    hostname: ansible5.hyfer.com
    manage_etc_hosts: true
    disable_root: false
    runcmd:
      - [ sh, -c, "cp /home/ec2-user/.ssh/authorized_keys /root/.ssh/" ]
      - [ sh, -c, "chmod 600 /root/.ssh/authorized_keys" ]
      - [ sh, -c, "chown root:root /root/.ssh/authorized_keys" ]
  EOF
}

resource "aws_ebs_volume" "secondary_disk" {
  availability_zone = "us-east-1a"
  size              = 1
  tags = { Name = "ansible5-secondary" }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.secondary_disk.id
  instance_id = aws_instance.db_node.id
}