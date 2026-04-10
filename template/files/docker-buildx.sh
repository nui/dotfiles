# Create a new buildx builder
docker buildx create --name builder --driver docker-container --use

# Create a new remote builder
docker buildx create --name=remote --driver=remote

# Create docker context for rootless docker on linux
docker context create rootless --docker host=unix://$XDG_RUNTIME_DIR/docker.sock

