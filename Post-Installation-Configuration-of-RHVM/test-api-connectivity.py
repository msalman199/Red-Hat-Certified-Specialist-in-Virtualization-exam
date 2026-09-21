#!/usr/bin/env python3

import ovirtsdk4 as sdk
import ovirtsdk4.types as types
import sys
import os

# Get server details from environment
server_url = os.environ.get('RHVM_URL', 'https://localhost:443/ovirt-engine')
username = os.environ.get('RHVM_ADMIN_USER', 'admin@internal')

print(f"Testing RHVM API connectivity...")
print(f"Server URL: {server_url}")
print(f"Username: {username}")

try:
    # Note: In a real environment, you would use proper authentication
    # For this lab, we'll test the connection endpoint
    print("Attempting to connect to RHVM API...")
    
    # Create connection (this will prompt for password in real scenario)
    connection = sdk.Connection(
        url=f"{server_url}/api",
        username=username,
        # password='your_password',  # In production, use secure password handling
        insecure=True,  # Only for lab environment
    )
    
    # Test the connection by getting system information
    system_service = connection.system_service()
    api_info = system_service.get()
    
    print(f"✓ Successfully connected to RHVM API")
    print(f"Product: {api_info.product_info.name}")
    print(f"Version: {api_info.product_info.version.full_version}")
    
    # Close the connection
    connection.close()
    
except Exception as e:
    print(f"✗ Failed to connect to RHVM API: {str(e)}")
    print("This is expected in the lab environment without proper credentials")
    sys.exit(1)
