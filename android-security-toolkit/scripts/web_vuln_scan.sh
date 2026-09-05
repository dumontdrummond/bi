#!/bin/bash
# web_vuln_scan.sh — Web application vulnerability scan pipeline
# Usage: ./web_vuln_scan.sh <URL> [IP] [--no-ai]
# Requires: nmap, nikto, sqlmap, gobuster, claude

ALVO="${1:?Usage: $0 <URL> [IP] [--no-ai]}"
IP="${2:-}"
USE_AI=true
[ "$3" = "--no-ai" ] || [ "$2" = "--no-ai" ] && USE_AI=false

HOSTNAME=$(echo "$ALVO" | sed 's|https\?://||;s|/.*||')
SAIDA="$HOME/recon/web_${HOSTNAME}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SAIDA"

echo "[*] Target: $ALVO"
[ -n "$IP" ] && echo "[*] IP: $IP"
echo "[*] Output: $SAIDA"
echo ""

# 1. Port scan
if [ -n "$IP" ] && command -v nmap &>/dev/null; then
  echo "[1/4] Port scanning $IP..."
  nmap -sV -T2 --top-ports 100 "$IP" -oN "$SAIDA/nmap.txt" 2>/dev/null
  echo "[+] Port scan complete"
else
  echo "[1/4] Skipping port scan (no IP provided or nmap missing)"
fi

# 2. Nikto web scan
if [ -f "$HOME/tools/nikto/program/nikto.pl" ]; then
  echo "[2/4] Running Nikto web scan..."
  perl "$HOME/tools/nikto/program/nikto.pl" \
    -h "$ALVO" -nointeractive -maxtime 300 \
    2>/dev/null > "$SAIDA/nikto.txt"
  echo "[+] Nikto scan complete"
fi

# 3. SQLi test
if command -v sqlmap &>/dev/null; then
  echo "[3/4] Testing for SQL injection..."
  sqlmap -u "${ALVO}/?id=1" \
    --batch --level=2 --risk=2 \
    --threads=2 --delay=1 \
    --output-dir="$SAIDA/sqlmap" \
    2>/dev/null | tail -20 > "$SAIDA/sqli.txt"
  echo "[+] SQLi test complete"
fi

# 4. Directory enumeration
if command -v gobuster &>/dev/null && [ -f "$HOME/tools/SecLists/Discovery/Web-Content/common.txt" ]; then
  echo "[4/4] Directory enumeration..."
  gobuster dir -u "$ALVO" \
    -w "$HOME/tools/SecLists/Discovery/Web-Content/common.txt" \
    -t 10 -q -x php,asp,aspx,jsp,html,txt,bak \
    -o "$SAIDA/dirs.txt" 2>/dev/null
  echo "[+] $(wc -l < "$SAIDA/dirs.txt") paths found"
fi

# AI analysis
if $USE_AI && command -v claude &>/dev/null; then
  echo "[*] Generating AI report..."
  {
    [ -f "$SAIDA/nmap.txt" ] && { echo "=== NMAP ==="; cat "$SAIDA/nmap.txt"; }
    [ -f "$SAIDA/nikto.txt" ] && { echo "=== NIKTO ==="; cat "$SAIDA/nikto.txt"; }
    [ -f "$SAIDA/sqli.txt" ] && { echo "=== SQLI ==="; cat "$SAIDA/sqli.txt"; }
    [ -f "$SAIDA/dirs.txt" ] && { echo "=== DIRECTORIES ==="; cat "$SAIDA/dirs.txt"; }
  } | claude --print "Gere relatório executivo de vulnerabilidades encontradas em $ALVO.
Classifique por criticidade (Crítico/Alto/Médio/Baixo).
Para cada vulnerabilidade inclua: descrição, impacto e recomendação de remediação.
Formato em português, estruturado e técnico." \
  > "$SAIDA/relatorio_ia.md" 2>/dev/null
  echo "[+] AI report: $SAIDA/relatorio_ia.md"
fi

echo ""
echo "[+] Scan complete. Results in: $SAIDA/"
ls -lh "$SAIDA/"
