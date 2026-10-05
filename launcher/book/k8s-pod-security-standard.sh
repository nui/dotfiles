# K8S Pod Security standard commands

# To apply
kubectl label ns dev pod-security.kubernetes.io/enforce=baseline
kubectl label ns dev pod-security.kubernetes.io/enforce-version=v1.36

# To remove
kubectl label ns dev pod-security.kubernetes.io/enforce-
kubectl label ns dev pod-security.kubernetes.io/enforce-version-

