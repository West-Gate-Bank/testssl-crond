# testssl-crond

Automated SSL/TLS grading and reporting using `testssl.sh`, `cron`, and `ssmtp`. [cite_start]This project is built on **Debian 13 (Trixie)** [cite: 1] [cite_start]and uses **Supervisor** to manage background processes and log redirection[cite: 1, 2].

---

## 🚀 Features

* [cite_start]**Automated Audits**: Schedule SSL/TLS checks using standard Cron syntax via the `mycron` configuration[cite: 6, 7].
* **SSL Grading**: Extracts the "Overall Grade" from `testssl.sh` results for a high-level security overview.
* [cite_start]**Email Reporting**: Sends aggregated scan results to specified recipients using `ssmtp`[cite: 1].
* [cite_start]**Timezone Support**: Customizable container timezone via the `TZ` environment variable[cite: 1, 2].

---

## 📋 Configuration Files

[cite_start]The system requires several configuration files to be mounted as volumes:

| File | Purpose |
| :--- | :--- |
| `domains.txt` | [cite_start]A list of FQDNs or IP addresses to scan (one per line)[cite: 3]. |
| `email.txt` | [cite_start]Email header template containing To, From, and Subject fields[cite: 4]. |
| `emailaddress.txt` | [cite_start]A comma-separated list of raw recipient email addresses[cite: 5]. |
| `mycron` | [cite_start]The cron schedule definition (Must end with an empty line)[cite: 6, 7]. |

---

## ⚙️ Usage

### Docker Compose
[cite_start]Configure your mail relay and volume paths in your `docker-compose.yml`:

```yaml
services:
  testssl-crond:
    image: testssl-crond
    container_name: testssl
    restart: always
    environment:
      - EMAIL_SERVER=1.2.3.4:25        # SMTP server IP and port 
      - EMAIL_DOMAIN=youremaildomain.com # Rewrite domain for sender 
      - TZ=America/Chicago             # Local timezone 
    volumes:
      - /configs/testssl.sh/email.txt:/data/email.txt:ro
      - /configs/testssl.sh/domains.txt:/data/domains.txt:ro
      - /configs/testssl.sh/emailaddress.txt:/data/emailaddress.txt
      - /configs/testssl.sh/mycron:/etc/cron.d/mycron
