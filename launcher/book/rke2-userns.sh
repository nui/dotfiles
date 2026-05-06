# rke2 user namespace configuration
# 
# We only need this configuration if we want more than 65536 ids per pods

# STEP 1, add kubelet user
# add new group and user
addgroup --gid 2000 kubelet
adduser  --gid 2000 --uid 2000 \
    --shell /usr/sbin/nologin \
    --no-create-home \
    --disabled-password \
    --disabled-login \
    --gecos '' kubelet

# STEP 2 Fix /etc/subuid and /etc/subgid
ID_PER_PODS=$(( 100 * 65536 ))
START_ID=$ID_PER_PODS # START_ID must be multiple of ID_PER_PODS
MAX_PODS=250
TOTAL_IDS=$(( ID_PER_PODS * MAX_PODS ))

# fix /etc/subuid /etc/subgid
fix_kubelet_ids() {
    local new_config
    local updated
    new_config=kubelet:$START_ID:$TOTAL_IDS
    updated=$(awk -v new_config="$new_config" '/^kubelet:/ { print new_config; next } 1' "$1")
    echo "$updated" > "$1"
}

fix_kubelet_ids /etc/subuid /etc/subgid

# STEP 3 Update kubelet config
# Assuming kubelet config is at /etc/rancher/rke2/kubelet-config.yaml
# And the configuration doesn't exist
cat >> /etc/rancher/rke2/kubelet-config.yaml <EOF
userNamespaces:
  idsPerPod: $ID_PER_PODS
EOF

# STEP 4 apply config and check log
systemctl restart rke2-agent
tail -f /var/lib/rancher/rke2/agent/logs/kubelet.log

