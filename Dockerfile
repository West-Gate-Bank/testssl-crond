# RHEL9 UBI-init base with systemd support
FROM registry.access.redhat.com/ubi9/ubi-init:latest

ENV TZ=UTC
ARG BUILD_VERSION=3.2
ARG URL=https://github.com/testssl/testssl.sh.git

# Install testssl.sh package, cron, and other dependencies
RUN yum update -y && \
    yum install -y --allowerasing \
    cronie \
    cronie-noanacron \
    ca-certificates \
    postfix \
    vim \
    tzdata \
    wget \
    openssl \
    grep \
    gawk \
    sed \
    procps \
    git \
    coreutils \
    shadow-utils \
    bind-utils \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && yum clean all \
    && rm -rf /var/cache/yum/* 
    
RUN git clone --depth 1 -b ${BUILD_VERSION} $URL /home/testssl 

RUN groupadd testssl \
    && useradd -g testssl -c "testssl" -s /bin/bash -m -d /home/testssl testssl \
    && ln -s /home/testssl/testssl.sh /usr/local/bin/ \
    && chmod +x /usr/local/bin/testssl.sh

# Create working directory for logs and input files
WORKDIR /data

# Copy the runner and entrypoint scripts
COPY runner.sh /usr/local/bin/runner.sh
COPY setup-cron.sh /usr/local/bin/setup-cron.sh
RUN chmod +x /usr/local/bin/runner.sh /usr/local/bin/setup-cron.sh

# Copy systemd service file for crond
COPY setup-crond.service /etc/systemd/system/setup-crond.service
COPY crond.service /etc/systemd/system/crond.service
RUN systemctl enable setup-crond
RUN systemctl enable crond
RUN systemctl enable postfix
