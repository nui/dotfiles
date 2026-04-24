# Create a new sealed secret file 
 echo -n "secret" | kubectl -n ci create secret generic harbor-seal --dry-run=client --from-file=secretKey=/dev/stdin -o json | kubeseal | tee secret.sealed.json

# Apply secret
kubectl apply -f secret.sealed.json

# Edit existing secret
nmk ss edit secret.sealed.json -e
