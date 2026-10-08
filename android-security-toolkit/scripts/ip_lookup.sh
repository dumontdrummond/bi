#!/bin/bash
# Lookup de IP com geolocalização e informações de rede

IP="$1"

if [ -z "$IP" ]; then
    echo "Uso: $0 <IP ou domínio>"
    echo "Exemplo: $0 8.8.8.8"
    echo "Exemplo: $0 google.com"
    exit 1
fi

# Resolver domínio para IP se necessário
RESOLVED=$(dig +short "$IP" 2>/dev/null | head -1)
if [[ "$RESOLVED" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    TARGET="$RESOLVED"
    echo "[*] Domínio $IP → IP: $TARGET"
else
    TARGET="$IP"
fi

echo "=============================="
echo " IP LOOKUP: $TARGET"
echo "=============================="
echo ""

# 1. Geolocalização via ip-api.com (gratuito, sem API key)
echo "[*] Geolocalização..."
curl -s "http://ip-api.com/json/$TARGET?fields=status,message,country,regionName,city,zip,lat,lon,isp,org,as,query,mobile,proxy,hosting" | python3 -m json.tool

echo ""

# 2. Informações WHOIS
echo "[*] WHOIS..."
whois "$TARGET" 2>/dev/null | grep -iE "netname|country|orgname|cidr|inetnum|abuse|owner" | head -20

echo ""

# 3. Verificar portas abertas (rápido)
if command -v nmap > /dev/null 2>&1; then
    echo "[*] Portas abertas (top 20)..."
    nmap -T4 --top-ports 20 "$TARGET" 2>/dev/null | grep -E "open|closed|PORT"
fi

echo ""

# 4. GeoIP local (se instalado)
if command -v geoiplookup > /dev/null 2>&1; then
    echo "[*] GeoIP database local..."
    geoiplookup "$TARGET"
fi

echo ""
echo "=============================="
echo " FIM DO RELATÓRIO"
echo "=============================="
