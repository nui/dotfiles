# Start k8s proxy for getting metrics
kubectl proxy -p 8024 --accept-paths='^/api/v1/nodes/[a-z]([-a-z0-9]*[a-z0-9])?/proxy/metrics.*'
# Get metrics
curl http://localhost:8024/api/v1/nodes/tempest/proxy/metrics/cadvisor

