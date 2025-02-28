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
curl -sSL -o $xzfile https://storage.googleapis.com/nmk.nuimk.com/releases/2025-02-28/$xzfile
if echo "c474a4d55f72af6cd9b325bc2c608eda3bd86ba339afc7031326a829ef0d567f *$xzfile" | sha256sum -c -; then
    unxz --stdout $xzfile > nmk
    install nmk /usr/local/bin/nmk
    rm nmk
fi
rm -rf $staging_dir
EOF

ENTRYPOINT ["/bin/bash"]
