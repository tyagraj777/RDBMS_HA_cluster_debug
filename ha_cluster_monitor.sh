#Here is an enhanced script that incorporates monitoring the host's role (Master/Slave) along with all the earlier issues.
#It runs continuously, displays results on standard output, and can be stopped manually with [CTRL+C].

#for detail usage refer README file


#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Note: Some checks may require root privileges for complete results."
fi

# Function to determine if the host is Master or Slave
check_host_role() {
    echo "Determining Host Role..."
    role=$(mysql -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master" > /dev/null && echo "Slave" || echo "Master")
    echo "Host Role: $role"
    echo ""
}

# Function to check cluster node health
check_node_health() {
    echo "Checking Cluster Node Health..."
    pcs status nodes || echo "Unable to fetch node status. Ensure 'pcs' is installed."
    echo ""
}

# Function to check split-brain scenarios
check_split_brain() {
    echo "Checking for Split-Brain Scenarios..."
    crm_mon -1 | grep -i "partition" && echo "Warning: Possible split-brain detected!" || echo "No split-brain issues found."
    echo ""
}

# Function to check network partitioning
check_network_partition() {
    echo "Checking Network Partitioning..."
# Extract online nodes from pcs status
online_nodes=$(pcs status | grep -E "Online: \[" | grep -oP "(?<=\[).*(?=\])" | tr ',' ' ')

if [ -z "$online_nodes" ]; then
    echo "No online nodes found in pcs status output."
    exit 1
fi

# echo "Detected online nodes: $online_nodes"
# echo "Starting ping tests..."

# Loop through each online node and perform ping test
for node in $online_nodes; do
    echo "Pinging node: $node..."
    if ping -c 3 "$node" &> /dev/null; then
        echo "Node $node is reachable."
    else
        echo "Node $node is NOT reachable."
    fi
done
}

# Function to check replication lag
check_replication_lag() {
    echo "Checking Replication Lag..."
    lag=$(mysql -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master" | awk '{print $2}')
    if [ -z "$lag" ]; then
        echo "Replication is not active or lag is unavailable!"
    else
        echo "Replication Lag: $lag seconds."
    fi
    echo ""
}

# Function to check quorum status
check_quorum() {
    echo "Checking Quorum Status..."
    corosync-cfgtool -s | grep -i "quorum" && echo "Quorum is OK." || echo "Quorum is lost! Check cluster status."
    echo ""
}

# Function to check shared storage availability
check_shared_storage() {
    echo "Checking Shared Storage..."
    df -h | grep "/mnt/shared" && echo "Shared storage is available." || echo "Shared storage is not accessible!"
    echo ""
}

# Function to check load balancing
check_load_balancing() {
    echo "Checking Load Balancing..."
    pcs resource | grep -i "distribution" && echo "Load balancing appears configured." || echo "Load balancing not properly configured!"
    echo ""
}

# Function to monitor performance bottlenecks
check_performance_bottlenecks() {
    echo "Monitoring Performance Bottlenecks..."
    top -bn1 | head -15
    echo ""
}

# Function to check for upgrade-related issues
check_upgrade_issues() {
    echo "Checking for Upgrade-Related Issues..."
    grep "upgrade" /var/log/messages && echo "Upgrade issues detected!" || echo "No recent upgrade issues found."
    echo ""
}

# Display instructions
echo "Linux RDBMS HA Cluster Monitoring Script with Host Role Detection"
echo "Press [CTRL+C] to stop monitoring."
echo "Ensure required tools (pcs, corosync, mysql) are installed and properly configured."
echo "---------------------------------------------------------------"
echo ""

# Continuous monitoring loop
while true; do
    check_host_role
    check_node_health
    check_split_brain
    check_network_partition
    check_replication_lag
    check_quorum
    check_shared_storage
    check_load_balancing
    check_performance_bottlenecks
    check_upgrade_issues
    sleep 15
done
