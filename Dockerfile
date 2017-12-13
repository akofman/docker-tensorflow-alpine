FROM  alexiskofman/bazel-alpine:1.0
LABEL maintainer="Alexis Kofman <alexis.kofman@gmail.com>"

ENV TENSORFLOW_VERSION="df9189cc4671facfecd3e8249c9e8b01b11c0df5" \
    TENSORFLOW_SHA256SUM="956f17c180c1f03150de5b99e5244b3785de1127b84eac796804881d57241bc7  df9189cc4671facfecd3e8249c9e8b01b11c0df5.tar.gz"

RUN apk update && apk upgrade && \
    apk add --no-cache --virtual build-dependencies bash curl coreutils g++ musl-dev linux-headers patch tar && \
    DIR=$(mktemp -d) && cd ${DIR} && \
    pip3 install numpy && \
    curl -sLO https://github.com/tensorflow/tensorflow/archive/${TENSORFLOW_VERSION}.tar.gz && \
    echo ${TENSORFLOW_SHA256SUM} | sha256sum --check && \    
    tar -zx --strip-components=1 -f ${TENSORFLOW_VERSION}.tar.gz && \
    # musl-libc does not have "secure_getenv" function
    sed -i -e '/JEMALLOC_HAVE_SECURE_GETENV/d' third_party/jemalloc.BUILD && \
    ./configure && \
    bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg && \
    pip3 install /tmp/tensorflow_pkg/tensorflow-* && \
    rm -rf ${DIR} && \
    apk del build-dependencies