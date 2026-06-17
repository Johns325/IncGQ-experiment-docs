FROM maven:3.9-eclipse-temurin-11-jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV NLTK_DATA=/usr/local/share/nltk_data

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        bzip2 \
        postgresql-client \
        python3-pip \
        unzip \
        wget \
        zstd \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
        gdown \
        nltk \
        numpy \
        pandas \
    && mkdir -p "${NLTK_DATA}"

RUN wget -q -O /tmp/z3-4.8.7-x64-ubuntu-16.04.zip \
        https://github.com/Z3Prover/z3/releases/download/z3-4.8.7/z3-4.8.7-x64-ubuntu-16.04.zip \
    && unzip -q /tmp/z3-4.8.7-x64-ubuntu-16.04.zip -d /tmp \
    && mvn -q install:install-file \
        -Dfile=/tmp/z3-4.8.7-x64-ubuntu-16.04/bin/com.microsoft.z3.jar \
        -DgroupId=com.microsoft \
        -DartifactId=z3 \
        -Dversion=4.8.7 \
        -Dpackaging=jar \
        -DgeneratePom=true \
    && rm -rf /tmp/z3-4.8.7-x64-ubuntu-16.04 /tmp/z3-4.8.7-x64-ubuntu-16.04.zip

WORKDIR /workspace/pg-view
