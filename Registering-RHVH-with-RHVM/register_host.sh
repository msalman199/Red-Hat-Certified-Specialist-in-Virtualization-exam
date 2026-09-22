#!/bin/bash

# RHVM connection details
RHVM_URL="https://localhost/ovirt-engine/api"
RHVM_USER="admin@internal"
RHVM_PASS="your_admin_password"

# Host details
HOST_NAME="rhvh-host-01"
HOST_ADDRESS="rhvh-host-ip"
HOST_PASSWORD="rhvh_root_password"
CLUSTER_NAME="Default"

# Register the host
ovirt-shell -c -u "$RHVM_USER" -p "$RHVM_PASS" -U "$RHVM_URL" << SHELL_EOF
add host --name "$HOST_NAME" --address "$HOST_ADDRESS" --root_password "$HOST_PASSWORD" --cluster-name "$CLUSTER_NAME"
SHELL_EOF

echo "Host registration initiated for $HOST_NAME"
