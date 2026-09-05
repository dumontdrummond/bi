#!/bin/bash
# Android Security Toolkit — Termux Initial Setup
# Run once after installing Termux

set -e

echo "[*] Updating package repositories..."
pkg update && pkg upgrade -y

echo "[*] Installing core dependencies..."
pkg install -y \
  python git nodejs curl wget \
  openssh nmap netcat-openbsd \
  ruby golang rust \
  libxml2 libxslt \
  openssl libjpeg-turbo \
  termux-api proot \
  zsh vim nano \
  jq xmlstarlet \
  hydra sqlmap \
  whois dnsutils \
  build-essential \
  apktool \
  tshark \
  tor \
  proxychains-ng \
  hashcat \
  openjdk-17

echo "[*] Upgrading pip..."
pip install --upgrade pip setuptools wheel

echo "[*] Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo "[*] Creating directory structure..."
mkdir -p \
  "$HOME/tools" \
  "$HOME/scripts" \
  "$HOME/logs" \
  "$HOME/recon" \
  "$HOME/apk_analysis"

echo "[*] Cloning essential wordlists..."
mkdir -p "$HOME/tools/SecLists"
cd "$HOME/tools/SecLists"
for url in \
  "Discovery/Web-Content/common.txt" \
  "Discovery/Web-Content/big.txt" \
  "Passwords/Common-Credentials/10-million-password-list-top-10000.txt" \
  "Usernames/top-usernames-shortlist.txt" \
  "Discovery/DNS/subdomains-top1million-5000.txt" \
  "Fuzzing/SQLi/Generic-SQLi.txt" \
  "Fuzzing/XSS/XSS-Jhaddix.txt"; do
  dir=$(dirname "$url")
  mkdir -p "$dir"
  curl -sO "https://raw.githubusercontent.com/danielmiessler/SecLists/master/$url" \
    --output-dir "$dir" || true
done

echo "[*] Cloning security tools..."
repos=(
  "https://github.com/laramies/theHarvester $HOME/tools/theHarvester"
  "https://github.com/sherlock-project/sherlock $HOME/tools/sherlock"
  "https://github.com/smicallef/spiderfoot $HOME/tools/spiderfoot"
  "https://github.com/sullo/nikto $HOME/tools/nikto"
  "https://github.com/swisskyrepo/PayloadsAllTheThings $HOME/tools/PayloadsAllTheThings"
)

for entry in "${repos[@]}"; do
  url=$(echo "$entry" | awk '{print $1}')
  dest=$(echo "$entry" | awk '{print $2}')
  if [ ! -d "$dest" ]; then
    git clone "$url" "$dest" --depth=1 2>/dev/null || echo "[!] Failed to clone $url"
  fi
done

echo "[*] Installing Python tool requirements..."
for req in \
  "$HOME/tools/theHarvester/requirements/base.txt" \
  "$HOME/tools/sherlock/requirements.txt" \
  "$HOME/tools/spiderfoot/requirements.txt"; do
  [ -f "$req" ] && pip install -r "$req" --quiet || true
done

pip install h8mail shodan --quiet

echo "[*] Installing Go tools..."
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null || true
go install github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null || true
go install github.com/OJ/gobuster/v3@latest 2>/dev/null || true
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest 2>/dev/null || true

echo "[*] Installing Ruby tools..."
gem install wpscan --no-document 2>/dev/null || true

echo "[*] Configuring tmux..."
cat > "$HOME/.tmux.conf" << 'TMUXEOF'
set -g mouse on
set -g history-limit 10000
bind | split-window -h
bind - split-window -v
set -g status-style bg=black,fg=green
TMUXEOF

echo "[*] Configuring proxychains for Tor..."
cat > "$PREFIX/etc/proxychains.conf" << 'PCEOF'
strict_chain
proxy_dns
[ProxyList]
socks5 127.0.0.1 9050
PCEOF

echo ""
echo "[+] Setup complete. Next steps:"
echo "    1. Set ANTHROPIC_API_KEY in ~/.bashrc"
echo "    2. Install Termux:API from F-Droid"
echo "    3. Install PCAPdroid from F-Droid for traffic capture"
echo "    4. Configure WireGuard if needed"
echo "    5. Run: source ~/.bashrc"
