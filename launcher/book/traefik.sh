# Access dashboard
# Run
kubectl -n kube-system port-forward daemonsets/rke2-traefik --address 127.0.0.2 8080:8080
# Then access via http://127.0.0.2:8080/dashboard/
