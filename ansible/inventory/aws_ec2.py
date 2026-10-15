#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def main():
    result = subprocess.run(
        [
            "aws",
            "ec2",
            "describe-instances",
            "--region",
            os.environ.get("AWS_DEFAULT_REGION", "ap-south-1"),
            "--filters",
            "Name=tag:Role,Values=ansible-managed",
            "Name=instance-state-name,Values=running",
            "--query",
            "Reservations[].Instances[].PrivateIpAddress",
            "--output",
            "json",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    hosts = json.loads(result.stdout)
    inventory = {
        "managed": {
            "hosts": hosts,
            "vars": {
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "/home/ubuntu/.ssh/ansible-workers",
            },
        },
        "_meta": {"hostvars": {host: {"ansible_host": host} for host in hosts}},
    }
    json.dump(inventory, sys.stdout)


if __name__ == "__main__":
    main()
