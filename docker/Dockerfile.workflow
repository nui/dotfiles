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
curl -sSL -o $file https://github.com/nuimk/nmk-releases/releases/download/v2025.07.01/$file
if echo "f1333e0f3c4ac41d36b1f2e1fab390d13e205b20ce128a7fe8d24060af5936ec *$file" | sha256sum -c -; then
    install $file /usr/local/bin/nmk
fi
rm -rf $staging_dir
EOF

ENTRYPOINT ["/bin/bash"]
