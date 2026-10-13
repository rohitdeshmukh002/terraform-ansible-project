# Terraform EC2 project

This Terraform configuration provisions an EC2 instance in AWS, along with a
VPC, public subnet, internet gateway, route table, and security group. It also
registers the local SSH public key as an EC2 key pair so AWS can associate it
with the instance.

## Prerequisites

- Terraform CLI
- AWS credentials configured for the AWS CLI or another supported credentials
  provider, with permission to manage the resources in this configuration
- An EC2 SSH key pair in this directory:
  - `terra-ansible`: the private key used to connect to the instance
  - `terra-ansible.pub`: the public key Terraform uploads to AWS

If you do not already have this key pair, create it from this directory:

```sh
ssh-keygen -t ed25519 -f terra-ansible -C terraform-ansible
```

Do not overwrite an existing private key. Keep the private key secret and out
of version control; these key files are ignored by `.gitignore`.

## Configure and apply

From this directory, review `terraform.tfvars`. It currently targets
`ap-south-1`, uses the `ap-south-1a` availability zone, and registers the
public key as the EC2 key pair `terra-ansible`. The AMI ID must be valid in the
configured region.

Configure AWS credentials, then initialize and review the proposed changes:

```sh
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Create the infrastructure after reviewing the plan:

```sh
terraform apply
```

Terraform stores state locally in this directory. Keep the state file and its
backups private; they are ignored by Git.

## Connect to the instance

After apply completes, get the instance's public IP:

```sh
terraform output -raw ec2_public_ip
```

Connect using the private key that matches `terra-ansible.pub`:

```sh
ssh -i terra-ansible ubuntu@<public-ip>
```

The configured security group allows inbound HTTP on port 80 and SSH on port
22. SSH is currently open to all IPv4 addresses; restrict this rule to your
own IP address before using this configuration beyond a personal test.

## Remove the infrastructure

When you no longer need the resources, review and confirm their removal:

```sh
terraform plan -destroy
terraform destroy
```
