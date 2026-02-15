# Debian 13 (Trixie) base
FROM debian:trixie-slim

ENV TZ=UTC

# Install testssl.sh package and cron
RUN apt-get update && apt-get install -y --no-install-recommends \
    testssl.sh \
    cron \
    ca-certificates \
    ssmtp \
    vim \
    supervisor \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Create working directory for logs and input files
WORKDIR /data

# Copy the runner and entrypoint scripts
COPY runner.sh /usr/local/bin/runner.sh
COPY supervisor.conf /data/supervisor.conf
COPY entrypoint.sh /entrypoint.sh
# COPY mycron /etc/cron.d/mycron
RUN chmod +x /usr/local/bin/runner.sh /entrypoint.sh
# RUN chmod 0644 /etc/cron.d/mycron
# RUN chown root:root /etc/cron.d/mycron

# Start the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
