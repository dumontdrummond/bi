# Android Security Toolkit — Quick Reference

## Environment Detection

```bash
echo $PREFIX          # /data/data/com.termux/files/usr (Termux)
uname -a              # Android kernel info
free -h               # RAM available
termux-battery-status | jq '.percentage'
```

## Reconnaissance

```bash
# Subdomain enumeration
subfinder -d target.com -o subdomains.txt -silent

# Live endpoint probe
httpx -l subdomains.txt -status-code -title -o alive.txt

# DNS enumeration
dig target.com ANY
subfinder -d target.com | dnsx -a -resp

# Email/IP harvesting
harvester -d target.com -b google,bing,shodan

# Username hunt across platforms
sherlock username --timeout 10

# WHOIS
whois target.com
```

## Web Application Testing

```bash
# SQL injection
sqlmap -u "http://target.com/?id=1" --dbs --threads=2

# Directory brute-force
gobuster dir -u http://target.com -w $SECLISTS/Discovery/Web-Content/common.txt -t 10

# Web vulnerability scan
nikto -h http://target.com -nointeractive

# WordPress
wpscan --url http://target.com -e u,vp
```

## Network Scanning

```bash
# Host discovery
nmap -sn 192.168.1.0/24

# Port + service scan (battery-friendly)
nmap -T2 -sV --top-ports 1000 192.168.1.1

# Full scan with scripts
nmap -sV -sC --script vuln 192.168.1.1

# Banner grab
echo "" | nc -w1 192.168.1.1 80
```

## Credential Attacks

```bash
# SSH brute-force
hydra -l admin -P $SECLISTS/Passwords/Common-Credentials/10-million-password-list-top-10000.txt \
  -t 4 ssh://192.168.1.1

# HTTP form brute-force
hydra -l admin -P wordlist.txt 192.168.1.1 \
  http-post-form "/login:user=^USER^&pass=^PASS^:F=Invalid"

# Hash cracking (MD5)
hashcat -m 0 hash.txt wordlist.txt
```

## APK Analysis

```bash
# Decompile
apktool d app.apk -o output/

# Find secrets
grep -rEi "api_key|password|secret|token" output/ --include="*.xml" --include="*.smali"

# Extract endpoints
grep -rEoh "https?://[a-zA-Z0-9./?=_%&-]+" output/ | sort -u

# Check permissions
grep "uses-permission" output/AndroidManifest.xml
```

## Anonymity & OPSEC

```bash
# Start Tor
tor &
tor-check   # verify Tor connection

# Route tool through Tor
proxychains4 curl https://icanhazip.com
proxychains4 python3 $TOOLS/sherlock/sherlock username

# SSH tunnel (expose local port to internet)
ssh -R 8080:localhost:5001 user@server.com

# SSH tunnel (access remote service locally)
ssh -L 3306:internal-db:3306 user@server.com
```

## Useful One-Liners

```bash
# HTTP headers
curl -sI https://target.com

# SSL certificate info
openssl s_client -connect target.com:443 </dev/null 2>/dev/null | openssl x509 -noout -text

# Extract emails from page
curl -s https://target.com | grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"

# Extract all links from page
curl -s https://target.com | grep -Eo '(href|src)="[^"]*"' | cut -d'"' -f2

# Ping sweep
for i in $(seq 1 254); do (ping -c1 -W1 192.168.1.$i &>/dev/null && echo "192.168.1.$i UP") & done; wait

# Base64 encode/decode
echo "text" | base64
echo "dGV4dA==" | base64 -d

# URL encode
python3 -c "import urllib.parse; print(urllib.parse.quote('payload here'))"

# Generate hash
echo -n "password" | sha256sum
```

## Mobile Resource Management

```bash
# Check before heavy operations
free -h                                  # RAM
termux-battery-status | jq '.percentage' # Battery
df -h $HOME                             # Storage

# Resource-limited flags
nmap:      -T2 --max-parallelism 5
hydra:     -t 4 -w 3
gobuster:  -t 10
sqlmap:    --threads 2 --delay 1
```

## Pre-Operation Checklist

- [ ] Explicit authorization for this target?
- [ ] Scope defined and documented?
- [ ] Operating in isolated test environment or with written permission?
- [ ] VPN/Tor active if anonymity required?
- [ ] Session logging enabled (`start-session`)?

## Automated Scripts

| Script | Usage |
|--------|-------|
| `setup.sh` | Initial Termux environment setup |
| `auto_recon.sh <domain>` | Full domain recon with AI analysis |
| `apk_analyze.sh <app.apk>` | Static APK analysis with AI review |
| `web_vuln_scan.sh <URL> [IP]` | Web vuln scan pipeline |
| `osint_person.sh <domain> <username>` | OSINT for person/company |
