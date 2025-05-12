FROM python:3-slim

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -yq update \
    && apt-get -yq upgrade \
    && apt-get -yq --no-install-recommends install \
        curl \
        git \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN <<EOF
set -ex
staging_dir=$(mktemp -d)
cd $staging_dir
file=nmk-x86_64-unknown-linux-musl
curl -sSL -o $file https://github.com/nuimk/nmk-releases/releases/download/v2025.5.1/$file
if echo "20b5b49292332075ce789e145f99b31384e3d538612a9b562d871110d9561e39 *$file" | sha256sum -c -; then
    install $file /usr/local/bin/nmk
fi
rm -rf $staging_dir
EOF

ENTRYPOINT ["/bin/bash"]
