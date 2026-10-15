# Docker role

Installs the Ubuntu `docker.io` package, adds the configured users to the
`docker` group, and ensures the Docker service is enabled and running.

The `docker_users` variable is defined in `vars/main.yml` and currently
contains `ubuntu`. Run the role through `site.yml` from the `ansible` directory
on the Terraform-created control instance:

```sh
ansible-playbook site.yml
```
