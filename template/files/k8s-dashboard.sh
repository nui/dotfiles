# Create admin access token
kubectl -n kubernetes-dashboard create token admin-user --duration $((7*24))h
