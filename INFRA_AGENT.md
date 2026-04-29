# 🛡️ Infra-Agent (v2)

`infra-agent` is a high-performance, production-grade infrastructure security and diagnostics tool. Designed to comprehensively scan Linux web environments (specifically `/home` and `/var/www`), it detects vulnerabilities, identifies malicious activities, and can autonomously remediate critical issues.

## 🚀 Features

- **Parallel Malware Scanning**: Uses multi-threading (`xargs -P 4`) to rapidly scan `.php` files for base64 injected malware.
- **Auto-Fix Mode**: Autonomously remediates `777` permissions, deletes detected malware, and blocks heavy attacking IPs via `ufw`.
- **Advanced Environment Parsing**: Safely parses `.env` files across all web apps to detect misconfigurations, exposed debug modes, and test database connections.
- **Performance Diagnostics**: Analyzes CPU usage, memory limits, disk space thresholds, and PHP-FPM memory consumption.
- **Attack Analysis**: Parses web server access logs (Nginx, Apache, LiteSpeed) to detect suspicious payloads (e.g., `phpunit`, `_ignition`, `eval`) and identify high-volume attackers.
- **Pipeline Integration**: Outputs cleanly formatted JSON and supports Webhook integration for centralized monitoring platforms.

## 📦 Installation

If you used the `.deb` package or the standard `install.sh`, the command is available globally as `infra-agent`.

Alternatively, you can run the script directly:

```bash
chmod +x infra-agent.sh
./infra-agent.sh
```

## 🛠️ Usage

### Basic Scan

Run a standard diagnostic scan that prints colorful output to the terminal:

```bash
infra-agent scan
```

### Auto-Fix Mode

Run the scan and allow the agent to automatically fix `777` permissions, delete identified malware files, and block attacking IPs:

```bash
infra-agent scan --auto-fix
```

### CI/CD Pipeline & Monitoring Mode

Run the scan, outputting the results as structured JSON objects instead of plain text. Ideal for consumption by monitoring dashboards:

```bash
infra-agent scan --json
```

### Webhook Alerts

Send the final risk score and malware summary to a Slack/Discord or custom API webhook:

```bash
infra-agent scan --webhook "https://your-pipeline.com/webhook/endpoint"
```

> [!TIP]
> You can combine `--json`, `--auto-fix`, and `--webhook` for a fully autonomous, self-reporting, self-healing pipeline!

### Self-Update

Securely fetch and install the latest version directly from GitHub:

```bash
infra-agent --update
```

## 📊 Security Checks Performed

1. **Web & Stack**: Detects Nginx, Apache, LiteSpeed, PHP CLI/FPM extensions, and MySQL status.
2. **Frameworks**: Laravel & Node.js discovery (Storage permissions, Env variables, Queue workers, Cron schedules).
3. **Malware**: Parallel Base64 payload detection across all PHP files.
4. **Vulnerabilities**: Identification of `777` directories and exposed `.sql`/`.zip` backup files in the webroot.
5. **DNS & Routing**: Wildcard domain routing verification and Cloudflare proxy detection.
6. **Log Parsing**: Aggregation of top requesting IPs and malicious payload patterns.
