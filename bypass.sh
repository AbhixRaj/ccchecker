#!/bin/bash

echo "[+] Starting firewall bypass setup..."

# Step 1: Create a new network namespace
sudo ip netns add bypass

# Step 2: Create a virtual Ethernet link between the namespaces
sudo ip link add veth0 type veth peer name veth1 netns bypass

# Step 3: Bring up the interfaces
sudo ip link set veth0 up
sudo ip netns exec bypass ip link set veth1 up
sudo ip netns exec bypass ip addr add 192.168.1.2/24 dev veth1

# Step 4: Enable IP forwarding and configure NAT masquerading
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Step 5: Set up a default route for the namespace
sudo ip netns exec bypass ip route add default via 192.168.1.1

echo "[+] Network namespace and NAT setup complete!"

# Step 6: Run your Go UDP script within the namespace
sudo ip netns exec bypass go run UDP.go "$@"
