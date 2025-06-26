# Create a new buildx builder
docker buildx create --name builder --driver docker-container --use

# Create docker context for rootless docker on linux
docker context create rootless --docker host=unix://$XDG_RUNTIME_DIR/docker.sock

