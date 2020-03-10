FROM alpine AS v1
ARG AWS_VERSION=1.18.17
RUN set -eux \
    && apk upgrade \
    && apk add --no-cache python3 \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir --no-compile "awscli==${AWS_VERSION}" \
    && find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
    && find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

VOLUME /code
WORKDIR /code

ENTRYPOINT ["/usr/bin/aws"]

FROM python:slim-buster AS v2

RUN apt-get -qy update \
    && apt-get -qy upgrade \
    && apt-get -qy install curl unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && apt-get -qy purge curl unzip \
    && apt-get -qy autoremove \
    && rm -rf /aws awscliv2.zip \
    && rm -rf /var/lib/apt/lists/*

VOLUME /code
WORKDIR /code

ENTRYPOINT ["/usr/local/bin/aws"]
