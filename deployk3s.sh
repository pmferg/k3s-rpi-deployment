#!/bin/bash

# Load Configuration from a Separate File
if [ ! -f ./config.env ]; then
    echo "Configuration file (config.env) not found!"
    exit 1
fi

source ./config.env

# Function to enable memory cgroups on a Raspberry Pi
enable_cgroups() {
    local NODE_IP=$1
    echo "Enabling cgroups on $NODE_IP..."
    ssh "$SSH_USER@$NODE_IP" <<EOF
sudo sed -i 's/\$/ cgroup_enable=memory cgroup_memory=1/' /boot/cmdline.txt
sudo reboot
EOF
    echo "Rebooting $NODE_IP to apply cgroup changes..."
    # Wait for the node to reboot
    sleep $REBOOT_WAIT_TIME
}

# Function to install K3s on the server
install_server() {
    echo "Installing K3s server on $SERVER_IP..."
    ssh "$SSH_USER@$SERVER_IP" <<EOF
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -
EOF

    echo "Fetching K3s server token..."
    SERVER_TOKEN=$(ssh "$SSH_USER@$SERVER_IP" "sudo cat /var/lib/rancher/k3s/server/node-token")
    echo "K3s server token fetched: $SERVER_TOKEN"
}

# Function to install K3s on an agent
install_agent() {
    local AGENT_IP=$1
    echo "Installing K3s agent on $AGENT_IP..."
    ssh "$SSH_USER@$AGENT_IP" <<EOF
curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=$SERVER_TOKEN INSTALL_K3S_VERSION=$K3S_VERSION sh -
EOF
    echo "K3s agent installed on $AGENT_IP."
}

# Main Script Execution
echo "Starting K3s deployment..."

# Enable cgroups on all nodes (server and agents)
enable_cgroups "$SERVER_IP"
for AGENT_IP in "${AGENT_IPS[@]}"; do
    enable_cgroups "$AGENT_IP"
done

# Install K3s server
install_server

# Install K3s agents
for AGENT_IP in "${AGENT_IPS[@]}"; do
    install_agent "$AGENT_IP"
done

echo "K3s cluster setup complete."

# Verify the cluster status
echo "Verifying cluster status..."
ssh "$SSH_USER@$SERVER_IP" "sudo kubectl get nodes"
