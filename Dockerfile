# RHEL9 UBI-init base with systemd support
FROM registry.access.redhat.com/ubi9/ubi-init:latest

ENV TZ=UTC

# Install testssl.sh package, cron, and other dependencies
RUN yum update -y && \
    yum install -y \
    testssl.sh \
    cronie \
    cronie-noanacron \
    ca-certificates \
    ssmtp \
    vim \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && yum clean all \
    && rm -rf /var/cache/yum/*

# Create working directory for logs and input files
WORKDIR /data

# Copy the runner and entrypoint scripts
COPY runner.sh /usr/local/bin/runner.sh
COPY entrypoint.sh /entrypoint.sh

# Copy systemd service file for crond
COPY crond.service /etc/systemd/system/crond.service

# Set executable permissions
RUN chmod +x /usr/local/bin/runner.sh /entrypoint.sh

# Enable crond service to start automatically
RUN systemctl enable crond.service

# Start the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
