#!/bin/bash
# auto_recon.sh — Automated domain reconnaissance with AI analysis
# Usage: ./auto_recon.sh <domain> [--no-ai]
# Requires: subfinder, httpx, theHarvester, whois, dnsutils, claude

ALVO="${1:?Usage: $0 <domain>}"
USE_AI=true
[ "$2" = "--no-ai" ] && USE_AI=false

SAIDA="$HOME/recon/$ALVO"
mkdir -p "$SAIDA"

check_tool() {
  command -v "$1" &>/dev/null || { echo "[!] $1 not found — skipping"; return 1; }
}

echo "[*] Starting recon on $ALVO"
echo "[*] Output directory: $SAIDA"
echo ""

# 1. Subdomains
if check_tool subfinder; then
  echo "[1/6] Collecting subdomains..."
  subfinder -d "$ALVO" -o "$SAIDA/subdomains.txt" -silent 2>/dev/null
  echo "[+] $(wc -l < "$SAIDA/subdomains.txt") subdomains found"
fi

# 2. HTTP probing
if check_tool httpx && [ -f "$SAIDA/subdomains.txt" ]; then
  echo "[2/6] Probing HTTP endpoints..."
  httpx -l "$SAIDA/subdomains.txt" -status-code -title -o "$SAIDA/http_alive.txt" -silent 2>/dev/null
  echo "[+] $(wc -l < "$SAIDA/http_alive.txt") live endpoints"
fi

# 3. theHarvester
if [ -d "$HOME/tools/theHarvester" ]; then
  echo "[3/6] Collecting emails and IPs (theHarvester)..."
  python3 "$HOME/tools/theHarvester/theHarvester.py" \
    -d "$ALVO" -b google,bing -f "$SAIDA/harvester" 2>/dev/null
fi

# 4. WHOIS
if check_tool whois; then
  echo "[4/6] WHOIS lookup..."
  whois "$ALVO" > "$SAIDA/whois.txt" 2>/dev/null
fi

# 5. DNS enumeration
if check_tool dig; then
  echo "[5/6] DNS enumeration..."
  {
    echo "=== A RECORD ==="
    dig "$ALVO" A +short
    echo "=== MX RECORD ==="
    dig "$ALVO" MX +short
    echo "=== TXT RECORD ==="
    dig "$ALVO" TXT +short
    echo "=== NS RECORD ==="
    dig "$ALVO" NS +short
    echo "=== ALL ==="
    dig "$ALVO" ANY
  } > "$SAIDA/dns.txt" 2>/dev/null
fi

# 6. AI analysis
if $USE_AI && check_tool claude; then
  echo "[6/6] Sending data to Claude Code for analysis..."
  {
    [ -f "$SAIDA/http_alive.txt" ] && cat "$SAIDA/http_alive.txt"
    [ -f "$SAIDA/harvester.json" ] && cat "$SAIDA/harvester.json"
    [ -f "$SAIDA/dns.txt" ] && cat "$SAIDA/dns.txt"
    [ -f "$SAIDA/whois.txt" ] && cat "$SAIDA/whois.txt"
  } | claude --print "Analise esses dados de reconhecimento OSINT do domínio $ALVO.
Identifique:
1. Superfície de ataque
2. Alvos prioritários
3. Possíveis vetores de entrada
4. Próximos passos recomendados
Formato: relatório estruturado de inteligência em português." \
  > "$SAIDA/analise_ia.md" 2>/dev/null
  echo "[+] AI analysis saved: $SAIDA/analise_ia.md"
fi

echo ""
echo "[+] Recon complete. All results in: $SAIDA/"
ls -lh "$SAIDA/"
