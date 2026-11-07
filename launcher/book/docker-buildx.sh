# Create context for rootless docker
docker context create user --docker host=unix://${XDG_RUNTIME_DIR:-/run/user/$UID}/docker.sock
docker context use user


# Create a new buildx builder
docker buildx create --name builder --driver docker-container --use

# Create a new remote builder
docker buildx create --name=remote --driver=remote

