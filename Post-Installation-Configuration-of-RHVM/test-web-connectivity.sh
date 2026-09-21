#!/bin/bash
echo "Testing RHVM Web Console Connectivity..."
echo "Server: $(hostname -f)"
echo "Testing HTTPS connection..."

if curl -k -s --connect-timeout 10 https://$(hostname -f):443/ovirt-engine/ > /dev/null; then
    echo "✓ Web console is accessible"
    echo "Access URL: https://$(hostname -f):443/ovirt-engine/"
else
    echo "✗ Web console is not accessible"
    echo "Check firewall and service status"
fi
