#!/bin/bash

# Initialize variables with default values
interface=""
gateway_ip=""
url=""
ip_type=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --iptype)
        ip_type="$2"
        shift # past argument
        shift # past value
        ;;
        -i|--interface)
        interface="$2"
        shift # past argument
        shift # past value
        ;;
        -g|--gateway)
        gateway_ip="$2"
        shift # past argument
        shift # past value
        ;;
        -u|--url)
        url="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        shift # past argument
        ;;
    esac
done

# Verify required parameters
if [[ -z "$interface" || -z "$gateway_ip" || -z "$url" || -z "$ip_type" ]]; then
    echo "Usage: $0 --iptype <ipv4|ipv6> -i <interface> -g <gateway_ip> -u <url>"
    exit 1
fi

# Verify that the specified interface is active
if ! ip addr show "$interface" > /dev/null 2>&1; then
    echo "The interface $interface is not available."
    exit 1
fi

# Use curl to retrieve the list of IP addresses
ip_list=$(curl -s "$url" | tr -d '\r')

# Check if the list of IP addresses was retrieved successfully
if [ -z "$ip_list" ]; then
    echo "Unable to retrieve the list of IP addresses."
    exit 1
fi

# Filter the IP addresses based on the specified type
if [ "$ip_type" == "ipv4" ]; then
    filtered_ip_list=$(echo "$ip_list" | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
elif [ "$ip_type" == "ipv6" ]; then
    filtered_ip_list=$(echo "$ip_list" | grep -E "([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}")
else
    echo "Unsupported IP address type."
    exit 1
fi

# Check if filtered IP list is empty
if [ -z "$filtered_ip_list" ]; then
    echo "No IP addresses found for the specified type."
    exit 1
fi

# Iterate over each filtered IP address and add a route for each address
while IFS= read -r ip_address; do
    # Add the route for the IP address via the specified interface
    sudo ip route add "$ip_address" via "$gateway_ip" dev "$interface"
    if [ $? -eq 0 ]; then
        echo "Route added for $ip_address via $interface."
    else
        echo "Failed to add route for $ip_address."
    fi
done <<< "$filtered_ip_list"

