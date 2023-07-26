ARG UBUNTU_VERSION=latest
FROM ubuntu:${UBUNTU_VERSION}

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    python3 \
    python3-pip \
    dotnet-sdk-7.0


ENV NODE_VERSION 18.17.0
# The node version on the ubuntu repo is too old. So here is a manual install
# Copied this snippet from node's docker file
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
      amd64) ARCH='x64';; \
      ppc64el) ARCH='ppc64le';; \
      s390x) ARCH='s390x';; \
      arm64) ARCH='arm64';; \
      armhf) ARCH='armv7l';; \
      i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # smoke tests
    && node --version \
    && npm --version

# The golang version on the ubuntu repo is too old. So here is a manual install
ENV GO_VERSION 1.20.6
RUN ARCH=$(dpkg --print-architecture) \
    && wget https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz

ENV PATH="${PATH}:/usr/local/go/bin"

RUN npm install -g yarn typescript

RUN mkdir /provider
RUN useradd -ms /bin/bash cookiecutter
RUN chown -R cookiecutter:cookiecutter /provider

USER cookiecutter
ENV PATH="${PATH}:/home/cookiecutter/.local/bin"
RUN python3 -m pip install cookiecutter packaging

COPY --chown=cookiecutter:cookiecutter . /home/cookiecutter
WORKDIR /provider
ENTRYPOINT ["/home/cookiecutter/entrypoint.sh"]