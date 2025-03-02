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
xzfile=nmk-x86_64-unknown-linux-musl.xz
curl -sSL -o $xzfile https://github.com/nuimk/nmk-releases/releases/download/v2025.03.01/$xzfile
if echo "f9222b7add8c245dd76a715f668c01114632ada60cb190e71d0048f1ef39dd9f *$xzfile" | sha256sum -c -; then
    unxz --stdout $xzfile > nmk
    install nmk /usr/local/bin/nmk
    rm nmk
fi
rm -rf $staging_dir
EOF

ENTRYPOINT ["/bin/bash"]
