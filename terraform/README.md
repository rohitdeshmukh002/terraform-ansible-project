# Terraform remote state

The S3 state bucket is part of this Terraform configuration, so it must be
created with local state before Terraform can switch to the S3 backend. The
bootstrap targets below create only the bucket and its security settings; they
leave the application infrastructure untouched.

From this directory, temporarily disable the S3 backend and initialize the
local backend:

```sh
mv backend.tf backend.tf.disabled
terraform init -reconfigure
```

Create the state bucket and its protections:

```sh
terraform apply \
  -target=aws_s3_bucket.terraform_state \
  -target=aws_s3_bucket_versioning.terraform_state \
  -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state \
  -target=aws_s3_bucket_public_access_block.terraform_state
```

Restore the backend configuration and migrate the current local state:

```sh
mv backend.tf.disabled backend.tf
terraform init -migrate-state \
  -backend-config="bucket=$(terraform output -raw state_bucket_name)" \
  -backend-config="key=terraform-ansible/dev/terraform.tfstate" \
  -backend-config="region=$(terraform output -raw state_bucket_region)" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"
```

Terraform uses an S3 lock file (`.tflock`) to prevent concurrent state
changes. The AWS identity used by Terraform needs permission to read and write
the state object and read, write, and delete the lock object.

The bucket has versioning, server-side encryption, public-access blocking, and
Terraform destroy protection enabled. After migration, run normal `terraform
plan` and `terraform apply` commands from this directory. Keep the local state
and any backup state files private.

## GitHub Actions

The Terraform workflow runs formatting and validation for pull requests without
AWS credentials. On pushes to `main` (and manual runs), it also authenticates
with AWS using OIDC and creates a Terraform plan. Configure these repository
variables:

- `AWS_ROLE_ARN`: IAM role trusted for GitHub Actions OIDC and permitted to
  read the Terraform-managed infrastructure and access the state bucket.
- `TF_STATE_BUCKET`: the name of the S3 state bucket.
- `SSH_PUBLIC_KEY`: the public SSH key text registered by the EC2 key-pair
  resource.

The role needs the S3 state and `.tflock` object permissions documented above.
Configure its OIDC trust policy for audience `sts.amazonaws.com` and restrict
the subject to `repo:rohitdeshmukh002/terraform-ansible-project:ref:refs/heads/main`.
Do not grant this role to `pull_request` events. The workflow does not apply
infrastructure changes.
