#!/bin/bash
# apk_analyze.sh — Static APK analysis with AI review
# Usage: ./apk_analyze.sh <app.apk> [--no-ai]
# Requires: apktool, claude (optional)

APK="${1:?Usage: $0 <app.apk>}"
USE_AI=true
[ "$2" = "--no-ai" ] && USE_AI=false

[ -f "$APK" ] || { echo "[!] File not found: $APK"; exit 1; }

NOME=$(basename "$APK" .apk)
SAIDA="$HOME/apk_analysis/$NOME"
mkdir -p "$SAIDA"

echo "[*] Analyzing: $APK"
echo "[*] Output: $SAIDA"

# 1. Decompile
echo "[1/5] Decompiling with apktool..."
apktool d "$APK" -o "$SAIDA/decompiled" -f 2>/dev/null
echo "[+] Decompilation done"

# 2. Sensitive strings
echo "[2/5] Searching for sensitive strings..."
grep -rEi \
  "api[_-]?key|api[_-]?secret|access[_-]?token|secret[_-]?key|\
  password\s*=|passwd\s*=|pwd\s*=|firebase|AKIA[0-9A-Z]{16}|\
  BEGIN PRIVATE KEY|BEGIN RSA PRIVATE KEY|aws_secret|client_secret" \
  "$SAIDA/decompiled/" \
  --include="*.xml" --include="*.java" \
  --include="*.smali" --include="*.properties" \
  --include="*.json" --include="*.gradle" \
  -l 2>/dev/null > "$SAIDA/files_with_secrets.txt"

grep -rEi \
  "api[_-]?key|password|secret|token|AKIA|BEGIN PRIVATE" \
  "$SAIDA/decompiled/" \
  --include="*.xml" --include="*.java" \
  --include="*.smali" --include="*.properties" \
  2>/dev/null > "$SAIDA/strings_sensiveis.txt"
echo "[+] $(wc -l < "$SAIDA/strings_sensiveis.txt") sensitive string occurrences"

# 3. Extract endpoints
echo "[3/5] Extracting API endpoints..."
grep -rEoh "https?://[a-zA-Z0-9./?=_%&:@#-]+" "$SAIDA/decompiled/" 2>/dev/null \
  | grep -v "schemas.android.com\|w3.org\|xmlns\|example.com" \
  | sort -u > "$SAIDA/endpoints.txt"
echo "[+] $(wc -l < "$SAIDA/endpoints.txt") unique endpoints found"

# 4. Permissions
echo "[4/5] Extracting permissions..."
if [ -f "$SAIDA/decompiled/AndroidManifest.xml" ]; then
  grep "uses-permission" "$SAIDA/decompiled/AndroidManifest.xml" > "$SAIDA/permissoes.txt"
  grep "android.permission.CAMERA\|android.permission.RECORD_AUDIO\|\
android.permission.ACCESS_FINE_LOCATION\|android.permission.READ_CONTACTS\|\
android.permission.READ_SMS\|android.permission.SEND_SMS\|\
android.permission.RECEIVE_SMS\|android.permission.CALL_PHONE" \
    "$SAIDA/permissoes.txt" > "$SAIDA/permissoes_perigosas.txt" 2>/dev/null || true
  echo "[+] $(wc -l < "$SAIDA/permissoes.txt") permissions, $(wc -l < "$SAIDA/permissoes_perigosas.txt") dangerous"
fi

# 5. AI analysis
if $USE_AI && command -v claude &>/dev/null; then
  echo "[5/5] AI analysis with Claude Code..."
  {
    echo "=== SENSITIVE STRINGS ==="
    head -100 "$SAIDA/strings_sensiveis.txt"
    echo "=== ENDPOINTS ==="
    cat "$SAIDA/endpoints.txt"
    echo "=== PERMISSIONS ==="
    cat "$SAIDA/permissoes.txt"
    echo "=== DANGEROUS PERMISSIONS ==="
    cat "$SAIDA/permissoes_perigosas.txt"
  } | claude --print "Analise os dados extraídos deste APK Android.
Identifique:
1. Credenciais ou chaves hardcoded (listar cada uma)
2. Endpoints de API críticos ou suspeitos
3. Permissões perigosas e seu risco
4. Vulnerabilidades potenciais
5. Classificação de risco geral: Baixo/Médio/Alto/Crítico
Seja direto e técnico. Formato em português." \
  > "$SAIDA/relatorio_ia.md" 2>/dev/null
  echo "[+] AI report: $SAIDA/relatorio_ia.md"
fi

echo ""
echo "[+] Analysis complete. Files:"
ls -lh "$SAIDA/"
