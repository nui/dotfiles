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
curl -sSL -o $file https://github.com/nuimk/nmk-releases/releases/download/v2025.03.03/$file
if echo "eea2efb83f05bea0255c2a615eef22271cb51047772ea76ec69f511152a91831 *$file" | sha256sum -c -; then
    install $file /usr/local/bin/nmk
fi
rm -rf $staging_dir
EOF

ENTRYPOINT ["/bin/bash"]
