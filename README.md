# RDBMS_HA_cluster_debug
This script combines monitoring functionalities for HA clusters while identifying the host's role and managing the operational challenges efficiently. Features 1. Host Role Detection 2. Node Health 3. Split-Brain Monitoring 4. Network Partition Checks 5. Replication Lag Monitoring 6. Quorum Status 7. Shared Storage 8. Load Balancing 9. Performance

Dependencies  needed for runing:"
1. git 
2. pcs
   
use - $sudo apt install -y "package name"

How to Use:

1. Save the script: Save it as ha_cluster_monitor.sh.

2. Make it executable: Run chmod +x ha_cluster_monitor.sh.

3. Run the script: Execute with ./ha_cluster_monitor.sh or sudo ./ha_cluster_monitor.sh (recommended for better functionality).

4. Stop the script: Press [CTRL+C].


* Supported Features:

* Host Role Detection: Determines whether the host is Master or Slave.
* Node Health: Uses pcs to fetch node health information.
* Split-Brain Monitoring: Detects split-brain situations in the cluster.
* Network Partition Checks: Validates node connectivity via ping.
* Replication Lag Monitoring: Checks replication status and lag for MySQL.
* Quorum Status: Ensures quorum is active and sufficient.
* Shared Storage: Validates shared storage accessibility.
* Load Balancing: Ensures proper resource distribution.
* Performance Bottleneck Monitoring: Provides top resource usage.
* Upgrade Issues: Scans logs for upgrade-related errors

