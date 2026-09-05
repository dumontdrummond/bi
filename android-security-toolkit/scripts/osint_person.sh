#!/bin/bash
# osint_person.sh — OSINT pipeline for person/company research
# Usage: ./osint_person.sh <domain> <username> [--no-ai]

ALVO="${1:?Usage: $0 <domain> <username> [--no-ai]}"
PESSOA="${2:?Usage: $0 <domain> <username> [--no-ai]}"
USE_AI=true
[ "$3" = "--no-ai" ] && USE_AI=false

SAIDA="$HOME/recon/osint_${ALVO}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SAIDA"

echo "[*] Domain: $ALVO | Username: $PESSOA"
echo "[*] Output: $SAIDA"

# 1. WHOIS
if command -v whois &>/dev/null; then
  echo "[1/4] WHOIS lookup..."
  whois "$ALVO" > "$SAIDA/whois.txt" 2>/dev/null
fi

# 2. theHarvester
if [ -d "$HOME/tools/theHarvester" ]; then
  echo "[2/4] Email/IP harvesting..."
  python3 "$HOME/tools/theHarvester/theHarvester.py" \
    -d "$ALVO" -b google,bing -q \
    2>/dev/null > "$SAIDA/harvester.txt"
fi

# 3. Sherlock username hunt
if [ -d "$HOME/tools/sherlock" ]; then
  echo "[3/4] Username hunting across platforms..."
  python3 "$HOME/tools/sherlock/sherlock" "$PESSOA" \
    --print-found --timeout 10 \
    --output "$SAIDA/sherlock_${PESSOA}.txt" \
    2>/dev/null
fi

# 4. DNS
if command -v dig &>/dev/null; then
  echo "[4/4] DNS records..."
  {
    echo "=== A ===" && dig "$ALVO" A +short
    echo "=== MX ===" && dig "$ALVO" MX +short
    echo "=== TXT ===" && dig "$ALVO" TXT +short
    echo "=== NS ===" && dig "$ALVO" NS +short
  } > "$SAIDA/dns.txt" 2>/dev/null
fi

# AI consolidation
if $USE_AI && command -v claude &>/dev/null; then
  echo "[*] AI intelligence consolidation..."
  {
    [ -f "$SAIDA/whois.txt" ] && { echo "=== WHOIS ==="; cat "$SAIDA/whois.txt"; }
    [ -f "$SAIDA/harvester.txt" ] && { echo "=== HARVESTER ==="; cat "$SAIDA/harvester.txt"; }
    [ -f "$SAIDA/sherlock_${PESSOA}.txt" ] && { echo "=== SHERLOCK ==="; cat "$SAIDA/sherlock_${PESSOA}.txt"; }
    [ -f "$SAIDA/dns.txt" ] && { echo "=== DNS ==="; cat "$SAIDA/dns.txt"; }
  } | claude --print "Consolide em relatório de inteligência OSINT sobre o alvo $ALVO / usuário $PESSOA.
Identifique:
1. Perfil do alvo e presença digital
2. Exposição de dados e riscos de privacidade
3. Infraestrutura e tecnologias utilizadas
4. Pontos de atenção e vulnerabilidades de OSINT
5. Recomendações para o próximo passo
Formato em português, estruturado como relatório de inteligência." \
  > "$SAIDA/relatorio_ia.md" 2>/dev/null
  echo "[+] AI intelligence report: $SAIDA/relatorio_ia.md"
fi

echo ""
echo "[+] OSINT complete. Results in: $SAIDA/"
ls -lh "$SAIDA/"
