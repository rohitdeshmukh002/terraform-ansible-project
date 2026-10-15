# Terraform and Ansible on AWS

Terraform creates a VPC, public subnet, control instance, and two managed
instances. Ansible runs on the control instance, discovers running managed
instances by their `Role=ansible-managed` tag, and installs and starts Docker
on them.

The control instance retrieves the SSH private key from AWS Secrets Manager
using its EC2 instance role at boot. The key is not passed through Terraform or
stored in Terraform state. The matching public key is registered with EC2 as
the key pair used by all three instances.

## Prerequisites

- Terraform CLI and AWS CLI
- AWS credentials with permission to manage the infrastructure, read the
  Secrets Manager secret, and access the S3 state bucket
- An existing S3 bucket in `ap-south-1` for Terraform state
- An SSH key pair in this directory. Do not overwrite an existing private key:

  ```sh
  ssh-keygen -t ed25519 -f terra-ansible -C terraform-ansible
  ```

- A Secrets Manager secret whose secret string is the contents of
  `terra-ansible` (the private key). Create it once:

  ```sh
  aws secretsmanager create-secret \
    --name terraform-ansible/dev/ansible-ssh-key \
    --secret-string file://terra-ansible \
    --region ap-south-1
  ```

  Save the returned ARN. If the secret already exists, update its value with
  `aws secretsmanager put-secret-value` instead of creating another secret.

Do not commit the private key. The key files are ignored by `.gitignore`.
Restrict `ssh_allowed_cidr` in `terraform.tfvars` to your own public IP.

For GitHub Actions, configure repository variables `AWS_ROLE_ARN`,
`SSH_PUBLIC_KEY`, `ANSIBLE_SSH_SECRET_ARN`, and `TF_STATE_BUCKET`. The
`SSH_PUBLIC_KEY` must match the private key stored in the Secrets Manager
secret. The GitHub OIDC role needs permission to manage the Terraform resources
and access the state bucket; only the control instance role reads the SSH
secret.

## Provision the infrastructure

Set the secret ARN and your S3 state bucket name in the shell:

```sh
export TF_VAR_ansible_ssh_secret_arn="<Secrets Manager secret ARN>"
export TF_STATE_BUCKET="<existing S3 state bucket>"
```

Initialize Terraform with the remote state backend, then review and apply:

```sh
terraform init \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=terraform-ansible/dev/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

The configured AMI must be a valid Ubuntu AMI in `aws_region`. After apply,
Terraform outputs the control public IP and the managed instances' public and
private IPs.

## Run Ansible

From this directory, copy the Ansible project to the control instance:

```sh
scp -i terra-ansible -r ../ansible \
  "ubuntu@$(terraform output -raw control_public_ip):/home/ubuntu/"
ssh -i terra-ansible \
  "ubuntu@$(terraform output -raw control_public_ip)"
```

On the control instance, run:

```sh
cd ~/ansible
ansible-inventory --graph
ansible-playbook site.yml
```

The inventory script uses the EC2 instance role to find running instances
tagged `Role=ansible-managed`. The control instance uses the private key it
retrieved from Secrets Manager to connect to their private IPs. If you change
the AWS region, update the inventory script's default region to match.

## Remove the infrastructure

Review and confirm resource removal when finished:

```sh
terraform plan -destroy
terraform destroy
```

Destroying the Terraform-managed infrastructure does not delete the separately
managed Secrets Manager secret or the S3 state bucket.
