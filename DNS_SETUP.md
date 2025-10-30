# DNS Setup for media.uzyol.uz

This guide shows how to configure DNS for Storm-Breaker deployment.

---

## DNS Configuration Required

**Subdomain**: `media.uzyol.uz`
**Record Type**: A (IPv4) or AAAA (IPv6)
**Points to**: Your server IP address

---

## Step-by-Step DNS Setup

### Step 1: Get Your Server IP

```bash
# From your server, run:
curl ifconfig.me

# Or:
hostname -I | awk '{print $1}'
```

**Example output:** `185.123.456.789`

---

### Step 2: Add DNS Record

Login to your DNS provider (where you registered uzyol.uz) and add:

```
Type:  A
Name:  media
Value: 185.123.456.789  (your server IP)
TTL:   300 (or Auto/Default)
```

**Common DNS Providers:**

#### **Cloudflare**
1. Login to Cloudflare dashboard
2. Select domain: `uzyol.uz`
3. Go to **DNS** tab
4. Click **Add record**
5. Fill in:
   - Type: `A`
   - Name: `media`
   - IPv4 address: `YOUR_SERVER_IP`
   - Proxy status: **DNS only** (gray cloud, not proxied)
   - TTL: Auto
6. Click **Save**

#### **Namecheap**
1. Login to Namecheap
2. Go to **Domain List** → Manage `uzyol.uz`
3. Click **Advanced DNS**
4. Click **Add New Record**
5. Fill in:
   - Type: `A Record`
   - Host: `media`
   - Value: `YOUR_SERVER_IP`
   - TTL: Automatic
6. Click **Save**

#### **GoDaddy**
1. Login to GoDaddy
2. Go to **My Products** → DNS
3. Select domain `uzyol.uz`
4. Click **Add** under Records
5. Fill in:
   - Type: `A`
   - Name: `media`
   - Value: `YOUR_SERVER_IP`
   - TTL: 1 Hour
6. Click **Save**

#### **Google Domains / Cloud DNS**
1. Login to Google Domains
2. Select `uzyol.uz`
3. Go to **DNS** settings
4. Click **Manage custom records**
5. Click **Create new record**
6. Fill in:
   - Host name: `media`
   - Type: `A`
   - TTL: 300
   - Data: `YOUR_SERVER_IP`
7. Click **Save**

#### **Amazon Route 53**
1. Open Route 53 console
2. Select hosted zone: `uzyol.uz`
3. Click **Create record**
4. Fill in:
   - Record name: `media`
   - Record type: `A`
   - Value: `YOUR_SERVER_IP`
   - TTL: 300
   - Routing policy: Simple
5. Click **Create records**

---

### Step 3: Verify DNS Propagation

DNS changes can take 5 minutes to 48 hours to propagate globally.

**Check propagation:**

```bash
# Method 1: Using nslookup
nslookup media.uzyol.uz
# Should return your server IP

# Method 2: Using dig
dig media.uzyol.uz +short
# Should return your server IP

# Method 3: Using host
host media.uzyol.uz
# Should show: media.uzyol.uz has address YOUR_SERVER_IP
```

**Online checker:**
- https://dnschecker.org
- Enter: `media.uzyol.uz`
- Type: `A`
- Check multiple locations worldwide

---

## DNS Record Examples

### Basic A Record (IPv4)
```
Type:  A
Name:  media
Value: 185.123.456.789
TTL:   300
```

### AAAA Record (IPv6) - Optional
```
Type:  AAAA
Name:  media
Value: 2001:db8::1
TTL:   300
```

### CNAME Record (Alternative) - NOT Recommended
```
Type:  CNAME
Name:  media
Value: uzyol.uz
TTL:   300
```
**Note:** A record is preferred over CNAME for root-level subdomains.

---

## Wildcard SSL Certificate Setup

If you use a wildcard certificate `*.uzyol.uz`, it will automatically cover `media.uzyol.uz`.

**Check if you have wildcard certificate:**
```bash
sudo certbot certificates | grep "*.uzyol.uz"
```

**If you have wildcard certificate:**
- ✅ `media.uzyol.uz` is already covered
- ✅ No additional SSL setup needed
- ✅ Nginx config already uses the wildcard cert

**If you DON'T have wildcard certificate:**

### Option 1: Obtain wildcard certificate
```bash
sudo certbot certonly --manual \
  --preferred-challenges dns \
  -d "*.uzyol.uz" \
  -d "uzyol.uz"

# Follow instructions to add TXT record to DNS
```

### Option 2: Obtain certificate for media.uzyol.uz only
```bash
sudo certbot certonly --nginx -d media.uzyol.uz
```

Then update nginx config to use:
```nginx
ssl_certificate /etc/letsencrypt/live/media.uzyol.uz/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/media.uzyol.uz/privkey.pem;
```

---

## DNS Troubleshooting

### Issue: "nslookup returns NXDOMAIN"

**Cause:** DNS record not created or not propagated yet

**Solution:**
1. Double-check DNS record was saved
2. Wait 5-15 minutes for propagation
3. Clear local DNS cache:
   ```bash
   # Linux
   sudo systemd-resolve --flush-caches

   # macOS
   sudo dscacheutil -flushcache

   # Windows
   ipconfig /flushdns
   ```

---

### Issue: "DNS resolves to wrong IP"

**Cause:** Old DNS cache or wrong A record value

**Solution:**
1. Verify A record points to correct IP
2. Check TTL hasn't cached old value
3. Wait for TTL to expire
4. Use lower TTL (300 seconds) during testing

---

### Issue: "Wildcard SSL doesn't cover media.uzyol.uz"

**Cause:** SSL cert is for specific subdomains, not wildcard

**Solution:**
```bash
# Check what domains are covered
sudo certbot certificates

# If no wildcard, add media.uzyol.uz to certificate
sudo certbot certonly --nginx -d media.uzyol.uz --expand
```

---

## Cloudflare Specific Settings

If using Cloudflare:

### 1. Set Proxy Status
- **Development/Testing**: DNS only (gray cloud) ☁️
- **Production**: Proxied (orange cloud) 🟠 (optional)

### 2. SSL/TLS Settings
- Go to **SSL/TLS** → **Overview**
- Set to: **Full (strict)** (not Flexible)

### 3. Page Rules (Optional)
Create page rule for `media.uzyol.uz`:
- Cache Level: Bypass
- Disable Apps
- Disable Performance

This ensures Storm-Breaker functions correctly without Cloudflare interference.

---

## DNS Security (DNSSEC)

If your domain has DNSSEC enabled, ensure:

1. **Wait for propagation** - DNSSEC can take longer (up to 48h)
2. **Verify DNSSEC chain**:
   ```bash
   dig media.uzyol.uz +dnssec
   ```
3. **If issues**, temporarily disable DNSSEC while testing

---

## Complete DNS Configuration Example

Assuming you have these existing records:

```
# Existing records
uzyol.uz              A       185.123.456.789
admin.uzyol.uz        A       185.123.456.789
bot.uzyol.uz          A       185.123.456.789
api.uzyol.uz          A       185.123.456.789

# Add this new record
media.uzyol.uz        A       185.123.456.789
```

All pointing to the same server IP (different apps handled by Nginx).

---

## Next Steps

After DNS is configured and propagated:

1. ✅ Verify DNS: `nslookup media.uzyol.uz`
2. ✅ Deploy Docker: `docker-compose up -d`
3. ✅ Configure Nginx: Add config snippet
4. ✅ Test HTTPS: `curl -I https://media.uzyol.uz`

See [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md) for full deployment steps.

---

## DNS Record Cheat Sheet

```bash
# Check DNS A record
dig media.uzyol.uz A +short

# Check DNS propagation globally
dig @8.8.8.8 media.uzyol.uz +short  # Google DNS
dig @1.1.1.1 media.uzyol.uz +short  # Cloudflare DNS

# Trace DNS resolution path
dig media.uzyol.uz +trace

# Check TTL
dig media.uzyol.uz | grep "^media"

# Reverse DNS lookup
dig -x YOUR_SERVER_IP +short
```

---

**DNS configured correctly?** → Continue to [QUICKSTART_INTEGRATED.md](QUICKSTART_INTEGRATED.md)
