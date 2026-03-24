# Fix 100% CPU on kubelet process
#
# kubelet can't remove pod because it fail to remove openebs volume (which is no longer exist)
#
# We have to delete all pods on that node and rejoin the cluster


# Step 1: drain all pod from node
kubectl drain --ignore-daemonsets --delete-emptydir-data tempest

# Step 2: stop rke2-agent on target node and reboot
systemctl disable rke2-agent
reboot
# after reboot
rm -rf /var/lib/kubelet/pods/*
systemctl enable --now rke2-agent

# Step 3: reassign node labels
kubectl label node tempest node-role.kubernetes.io/ingress=true
kubectl label node tempest node-role.kubernetes.io/worker=true

