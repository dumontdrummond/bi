#!/bin/bash
# OSINT de número de telefone usando phoneinfoga e fontes públicas

NUMBER="$1"

if [ -z "$NUMBER" ]; then
    echo "Uso: $0 +5586999999999"
    echo "Exemplo: $0 +5586954289725"
    exit 1
fi

echo "=============================="
echo " PHONE OSINT: $NUMBER"
echo "=============================="
echo ""

# 1. Informações básicas via API pública
echo "[*] Informações básicas (NumVerify/público)..."
curl -s "https://phonevalidation.abstractapi.com/v1/?api_key=&phone=$NUMBER" 2>/dev/null | python3 -m json.tool 2>/dev/null || true

# 2. phoneinfoga scan
if command -v phoneinfoga > /dev/null 2>&1; then
    echo ""
    echo "[*] Scan completo com phoneinfoga..."
    phoneinfoga scan -n "$NUMBER"
else
    echo "[!] phoneinfoga não instalado. Instale com:"
    echo "    curl -L https://github.com/sundowndev/phoneinfoga/releases/latest/download/phoneinfoga_Linux_arm64.tar.gz -o ~/pif.tar.gz && tar xzf ~/pif.tar.gz -C \$PREFIX/bin/ && rm ~/pif.tar.gz"
fi

echo ""
echo "[*] Busca em fontes públicas..."
CLEAN=$(echo "$NUMBER" | tr -d '+- ()')
curl -s "https://api.numlookupapi.com/v1/info/$CLEAN" 2>/dev/null | python3 -m json.tool 2>/dev/null || true

echo ""
echo "=============================="
echo " FIM DO RELATÓRIO"
echo "=============================="
