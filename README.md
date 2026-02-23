# testssl-crond

A Docker-based SSL/TLS certificate security auditing tool that runs scheduled security scans on specified domains and sends email reports.

## Overview

**testssl-crond** is a containerized solution that automates SSL/TLS certificate testing using [testssl.sh](https://github.com/drwetter/testssl.sh). It leverages cron scheduling to run periodic security assessments on your domains and automatically emails the results.

## Features

- 🔒 **Automated SSL/TLS Testing** - Run security assessments on multiple domains
- 📧 **Email Reporting** - Automatic email delivery of test results
- 🐳 **Docker Containerized** - Easy deployment and portability
- ⏰ **Cron Scheduling** - Flexible scheduling using standard cron expressions
- 🌍 **Multi-Domain Support** - Test multiple domains in a single run
- 📋 **Detailed Logging** - Comprehensive scan history and results tracking

## Prerequisites

- Docker
- Docker Compose (optional)
- SMTP server access for email notifications

## Quick Start

### Using Docker Compose

1. Clone this repository:
```bash
git clone https://github.com/West-Gate-Bank/testssl-crond.git
cd testssl-crond
```

2. Configure your settings:
   - Create/modify `domains.txt` with your domains (one per line)
   - Create/modify `email.txt` with email headers and body template
   - Create/modify `emailaddress.txt` with recipient email address
   - Create/modify `mycron` with your cron schedule

3. Update `docker-compose.yml` with your environment:
```yaml
environment:
  - EMAIL_SERVER=smtp.example.com:25
  - EMAIL_DOMAIN=yourdomain.com
  - TZ=America/Chicago
```

4. Build and run:
```bash
docker-compose up -d
```

### Using Docker CLI

```bash
docker build -t testssl-crond .

docker run -d \
  --name testssl \
  --restart always \
  -e EMAIL_SERVER=smtp.example.com:25 \
  -e EMAIL_DOMAIN=yourdomain.com \
  -e TZ=America/Chicago \
  -v /path/to/domains.txt:/data/domains.txt:ro \
  -v /path/to/email.txt:/data/email.txt:ro \
  -v /path/to/emailaddress.txt:/data/emailaddress.txt \
  -v /path/to/mycron:/etc/cron.d/mycron \
  testssl-crond
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `EMAIL_SERVER` | SMTP server address and port (format: `host:port`) | Required |
| `EMAIL_DOMAIN` | Email rewrite domain (sender domain) | Required |
| `TZ` | Timezone for cron scheduling | UTC |

### Configuration Files

#### `domains.txt`
List of domains to scan, one per line:
```
example.com
api.example.com
www.example.com
```

#### `emailaddress.txt`
Email address(es) to send reports to:
```
admin@example.com
```

#### `email.txt`
Email header and body template:
```
Subject: SSL/TLS Security Audit Report
To: recipient@example.com

---
SSL/TLS Grade Report:

```

#### `mycron`
Cron schedule definition. Default runs on the 1st of each month at midnight:
```
SHELL=/bin/bash
0 0 1 * * root . /etc/container.env; /usr/local/bin/runner.sh >> /var/log/cron.log 2>&1
```

Common cron patterns:
- `0 0 * * *` - Daily at midnight
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 0` - Weekly on Sunday at midnight
- `0 0 1 * *` - Monthly on the 1st at midnight

**Important:** The `mycron` file must end with an empty line.

## How It Works

1. **Entrypoint** (`entrypoint.sh`) - Initializes the container:
   - Sets up timezone
   - Exports environment variables to `/etc/container.env`
   - Configures SSMTP for email delivery
   - Starts supervisord to manage the cron service

2. **Runner Script** (`runner.sh`) - Executes scheduled tasks:
   - Reads domains from `domains.txt`
   - Runs `testssl.sh` on each domain
   - Extracts SSL/TLS grade information
   - Logs results to `grade.log`
   - Combines email template with results
   - Sends email via SSMTP

3. **Supervisor** (`supervisor.conf`) - Process management:
   - Manages cron daemon lifecycle
   - Ensures cron continues running
   - Handles logging

## Output Files

The container generates the following log files in `/data`:

- `grade.log` - Test results with SSL/TLS grades for each domain
- `cron_history.log` - Timestamp log of all completed scans
- `emailout.log` - Complete email sent to recipients

## Architecture

**Base Image:** Debian 13 (Trixie) slim

**Key Components:**
- `testssl.sh` - SSL/TLS security testing tool
- `cron` - Task scheduler
- `ssmtp` - Email delivery agent
- `supervisor` - Process manager

## Troubleshooting

### Email Not Sending
- Verify `EMAIL_SERVER` is accessible from container
- Check SMTP server allows anonymous connections
- Review logs: `docker logs testssl`
- Inspect `/data/emailout.log` for email content

### Cron Not Executing
- Verify `mycron` file ends with empty line
- Check timezone with: `docker exec testssl date`
- Review `docker logs testssl` for supervisor output
- Verify cron schedule syntax at [crontab.guru](https://crontab.guru)

### Testssl.sh Errors
- Ensure domains are valid and reachable from container
- Check domain connectivity: `docker exec testssl curl -I https://domain.com`
- Review detailed logs in `/data/cron_history.log`

## Building the Image

```bash
docker build -t testssl-crond:latest .
```

## License

This project is licensed under the GNU General Public License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please open an issue on the [GitHub repository](https://github.com/West-Gate-Bank/testssl-crond).