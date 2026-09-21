#!/bin/bash
echo "=== RHVM Log Monitor ==="
echo "Monitoring RHVM engine logs (Press Ctrl+C to stop)"
echo ""

# Function to display colored output
print_log_line() {
    local line="$1"
    if echo "$line" | grep -qi error; then
        echo -e "\033[31m$line\033[0m"  # Red for errors
    elif echo "$line" | grep -qi warn; then
        echo -e "\033[33m$line\033[0m"  # Yellow for warnings
    elif echo "$line" | grep -qi info; then
        echo -e "\033[32m$line\033[0m"  # Green for info
    else
        echo "$line"
    fi
}

# Monitor the main engine log
tail -f /var/log/ovirt-engine/engine.log | while read line; do
    print_log_line "$line"
done
