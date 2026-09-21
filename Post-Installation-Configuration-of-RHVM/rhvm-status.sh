#!/bin/bash
echo "=== RHVM System Status Check ==="
echo "Date: $(date)"
echo "Server: $(hostname -f)"
echo ""

echo "1. Service Status:"
services=("ovirt-engine" "postgresql" "httpd")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "   ✓ $service: Running"
    else
        echo "   ✗ $service: Not Running"
    fi
done

echo ""
echo "2. Network Connectivity:"
if ss -tlnp | grep -q ":443"; then
    echo "   ✓ HTTPS port 443: Listening"
else
    echo "   ✗ HTTPS port 443: Not Listening"
fi

echo ""
echo "3. Disk Space:"
df -h / | tail -1 | awk '{print "   Root filesystem: " $5 " used"}'

echo ""
echo "4. Memory Usage:"
free -h | grep Mem | awk '{print "   Memory: " $3 "/" $2 " used"}'

echo ""
echo "5. Load Average:"
uptime | awk -F'load average:' '{print "   Load:" $2}'
