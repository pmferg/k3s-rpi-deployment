
# K3s Deployment Script for Raspberry Pi Cluster

This repository contains a script to deploy K3s on a Raspberry Pi cluster. It automates the configuration of cgroups, installation of K3s on a server node, and addition of agent nodes to form a complete cluster. 

The script is parameterized for reusability and reads its configuration from a separate file (`config.env`).

---

## Features
- Automatically enables memory cgroups required for K3s.
- Deploys K3s server on a specified Raspberry Pi.
- Adds agent nodes to the K3s cluster.
- Parameterized configuration for easy reuse.
- Verifies the cluster setup post-installation.

---

## Requirements
- **Raspberry Pi Cluster**: A set of Raspberry Pis with static IP addresses or DNS names.
- **SSH Access**: SSH must be enabled, and the script user should have passwordless sudo access on all nodes.
- **Linux/MacOS**: A system with Bash shell to execute the script.

---

## Usage

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone <repository-url>
cd <repository-folder>
```

### 2. Configure Parameters
Edit the `config.env` file to specify your Raspberry Pi cluster details:
```bash
nano config.env
```

#### Example `config.env`:
```bash
# Configuration for deploy_k3s_with_cgroups.sh

# K3s version to install
K3S_VERSION="v1.25.10+k3s1"

# Server node IP
SERVER_IP="192.168.1.100"

# Agent node IPs (comma-separated)
AGENT_IPS=("192.168.1.101" "192.168.1.102")

# SSH user for all nodes
SSH_USER="pi"

# Wait time after reboot (in seconds)
REBOOT_WAIT_TIME=60
```

### 3. Run the Script
Make the script executable and run it:
```bash
chmod +x deploy_k3s_with_cgroups.sh
./deploy_k3s_with_cgroups.sh
```

### 4. Verify the Cluster
Once the script completes, verify the cluster status:
```bash
ssh pi@<SERVER_IP> "sudo kubectl get nodes"
```

---

## What the Script Does
1. Updates `/boot/firmware/cmdline.txt` to enable memory cgroups on all nodes.
2. Reboots the nodes to apply cgroup changes.
3. Installs K3s on the server node.
4. Installs K3s agents and joins them to the server.
5. Displays the cluster status.

---

## Troubleshooting
### Memory Cgroup Error
If K3s fails with `failed to find memory cgroup`, ensure:
1. The `/boot/firmware/cmdline.txt` includes `cgroup_enable=memory cgroup_memory=1`.
2. Nodes are rebooted after modifying the file.

### Port Conflicts
Ensure required ports are free:
- `6443`: Kubernetes API server
- `2379-2380`: etcd
- `10250-10252`: Kubelet, controller, scheduler

Check active ports with:
```bash
sudo netstat -tuln | grep LISTEN
```

### Logs
Check K3s logs for errors:
```bash
sudo journalctl -u k3s
```

---

## License
This script is licensed under the MIT License. Feel free to use and modify it.

---

## Contributing
Feel free to submit issues or pull requests for improvements.
