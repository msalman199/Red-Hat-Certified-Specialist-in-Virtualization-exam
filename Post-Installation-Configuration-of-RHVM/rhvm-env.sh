#!/bin/bash
# RHVM Environment Configuration

# RHVM Server Details
export RHVM_SERVER=$(hostname -f)
export RHVM_PORT=443
export RHVM_URL="https://${RHVM_SERVER}:${RHVM_PORT}/ovirt-engine"

# Administrative Credentials
export RHVM_ADMIN_USER="admin@internal"
export RHVM_ADMIN_DOMAIN="internal"

# API Configuration
export RHVM_API_URL="${RHVM_URL}/api"
export RHVM_CA_FILE="/etc/pki/ovirt-engine/ca.pem"

# Default Settings
export RHVM_DEFAULT_DC="Default"
export RHVM_DEFAULT_CLUSTER="Default"

# Display current configuration
echo "RHVM Environment Variables Set:"
echo "Server: $RHVM_SERVER"
echo "URL: $RHVM_URL"
echo "API URL: $RHVM_API_URL"
echo "Admin User: $RHVM_ADMIN_USER"
