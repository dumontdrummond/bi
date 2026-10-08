#!/bin/bash
# Menu dinâmico do toolkit OSINT/Segurança
# Detecta automaticamente o que está instalado e monta o menu

# ── Cores ──────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
B='\033[0;34m'; M='\033[0;35m'; C='\033[0;36m'
W='\033[1;37m'; DIM='\033[0;37m'; NC='\033[0m'; BOLD='\033[1m'

SCRIPTS="$HOME/bi/android-security-toolkit/scripts"

# ── Helpers ────────────────────────────────────────────
has()        { command -v "$1" >/dev/null 2>&1; }
has_script() { [ -f "$SCRIPTS/$1" ]; }
has_py_mod() { python3 -c "import $1" 2>/dev/null; }

prompt_input() {
  echo -e "${Y}$1${NC}"
  read -r -p "→ " VAL
  echo "$VAL"
}

pause() {
  echo ""
  read -r -p "$(echo -e "${DIM}Pressione Enter para voltar ao menu...${NC}")"
}

# ── Construção dinâmica do menu ────────────────────────
ITEMS=()   # rótulo exibido
KEYS=()    # chave de ação
CATS=()    # categoria (para header)
LAST_CAT=""

add() {
  local label="$1" cat="$2" key="$3"
  ITEMS+=("$label"); CATS+=("$cat"); KEYS+=("$key")
}

# ── Detectar e registrar itens ─────────────────────────

# TELEFONE
has phoneinfoga      && add "PhoneInfoga  — scan completo do número"           "TELEFONE" "phoneinfoga_scan"
has phoneintel       && add "PhoneIntel   — operadora, país, fuso"             "TELEFONE" "phoneintel_info"
has phoneintel       && add "PhoneIntel   — dorks Google para número"          "TELEFONE" "phoneintel_dorks"
has phoneintel       && add "PhoneIntel   — buscar número em arquivo/texto"    "TELEFONE" "phoneintel_search"
has_py_mod phonenumbers && add "phonenumbers — validar offline (Python)"       "TELEFONE" "py_phonenumbers"
has_script phone_osint.sh && add "phone_osint.sh — pipeline multi-fonte"      "TELEFONE" "script_phone"

# USERNAME / OSINT
has sherlock   && add "Sherlock      — username em 400+ redes sociais"         "OSINT" "sherlock_search"
has h8mail     && add "h8mail        — email em vazamentos de dados"           "OSINT" "h8mail_check"
has_script osint_person.sh && add "osint_person.sh — OSINT completo de pessoa" "OSINT" "script_osint_person"

# REDE / IP
has_script ip_lookup.sh && add "ip_lookup.sh  — geolocalização + WHOIS + portas" "REDE" "script_ip_lookup"
has nexttrace  && add "nexttrace     — rota de rede com geolocalização"        "REDE" "nexttrace_run"
has whois      && add "whois         — registro de domínio ou IP"              "REDE" "whois_run"
has nmap       && add "nmap          — escanear IP / domínio"                  "REDE" "nmap_host"
has nmap       && add "nmap          — descobrir dispositivos na rede Wi-Fi"   "REDE" "nmap_net"
has nmap       && add "nmap          — escanear portas + detectar versões"     "REDE" "nmap_full"

# WEB
has nikto      && add "nikto         — vulnerabilidades em site"               "WEB" "nikto_scan"
has sqlmap     && add "sqlmap        — injeção SQL em formulário"              "WEB" "sqlmap_scan"
has_script web_vuln_scan.sh  && add "web_vuln_scan.sh — scan completo (nmap+nikto+sqlmap)" "WEB" "script_web_vuln"
has_script auto_recon.sh     && add "auto_recon.sh    — reconhecimento de domínio"          "WEB" "script_auto_recon"

# APK
has_script apk_analyze.sh && add "apk_analyze.sh — analisar APK Android"      "APK" "script_apk"

# SISTEMA
add "Verificar ferramentas instaladas"   "SISTEMA" "sys_check"
add "Atualizar scripts (git pull)"       "SISTEMA" "sys_update"
add "Sair"                               "SISTEMA" "sys_exit"

# ── Exibir menu ────────────────────────────────────────
show_menu() {
  clear
  echo -e "${BOLD}${C}"
  echo " ╔══════════════════════════════════════╗"
  echo " ║    🛡  TOOLKIT OSINT & SEGURANÇA     ║"
  echo " ║         Termux — menu dinâmico        ║"
  echo " ╚══════════════════════════════════════╝${NC}"
  echo ""

  local i=0 last_cat=""
  for label in "${ITEMS[@]}"; do
    local cat="${CATS[$i]}"
    if [ "$cat" != "$last_cat" ]; then
      echo ""
      case "$cat" in
        TELEFONE) echo -e "  ${G}📞 TELEFONE${NC}" ;;
        OSINT)    echo -e "  ${M}👤 USERNAME / OSINT${NC}" ;;
        REDE)     echo -e "  ${B}🌐 REDE / IP${NC}" ;;
        WEB)      echo -e "  ${Y}🌍 WEB${NC}" ;;
        APK)      echo -e "  ${R}📱 APK / ANDROID${NC}" ;;
        SISTEMA)  echo -e "  ${DIM}🔧 SISTEMA${NC}" ;;
      esac
      last_cat="$cat"
    fi
    printf "  ${W}%2d)${NC} %s\n" "$((i+1))" "$label"
    i=$((i+1))
  done

  echo ""
  echo -e "${DIM}  $(( ${#ITEMS[@]} - 2 )) ferramentas detectadas${NC}"
  echo ""
}

# ── Executar ação ──────────────────────────────────────
run_action() {
  local key="$1"
  echo ""
  case "$key" in

    # ─── TELEFONE ──────────────────────────────────────

    phoneinfoga_scan)
      NUM=$(prompt_input "Número (ex: +5586999999999):")
      [ -z "$NUM" ] && return
      echo -e "${C}[*] Executando PhoneInfoga...${NC}\n"
      phoneinfoga scan -n "$NUM"
      pause ;;

    phoneintel_info)
      NUM=$(prompt_input "Número (ex: +5586999999999):")
      [ -z "$NUM" ] && return
      echo -e "${C}[*] PhoneIntel — informações...${NC}\n"
      phoneintel --info "$NUM"
      pause ;;

    phoneintel_dorks)
      NUM=$(prompt_input "Número (ex: +5586999999999):")
      [ -z "$NUM" ] && return
      echo -e "${C}[*] PhoneIntel — gerando dorks Google...${NC}\n"
      phoneintel "$NUM" --dorks --type social_networks
      pause ;;

    phoneintel_search)
      echo -e "${Y}Buscar número em: ${W}1) texto  2) arquivo${NC}"
      read -r -p "→ " OPT
      if [ "$OPT" = "1" ]; then
        TXT=$(prompt_input "Cole o texto:")
        phoneintel --search --string "$TXT"
      else
        ARQ=$(prompt_input "Caminho do arquivo (ex: ~/lista.txt):")
        phoneintel --search --input "$ARQ"
      fi
      pause ;;

    py_phonenumbers)
      NUM=$(prompt_input "Número (ex: +5586999999999):")
      [ -z "$NUM" ] && return
      echo -e "${C}[*] phonenumbers (offline)...${NC}\n"
      python3 -c "
import phonenumbers
from phonenumbers import geocoder, carrier, timezone
try:
    n = phonenumbers.parse('$NUM')
    print('Válido:    ', phonenumbers.is_valid_number(n))
    print('País:      ', geocoder.description_for_number(n, 'pt'))
    print('Operadora: ', carrier.name_for_number(n, 'pt'))
    print('Fuso:      ', list(timezone.time_zones_for_number(n)))
    print('Tipo:      ', phonenumbers.number_type(n))
except Exception as e:
    print('Erro:', e)
"
      pause ;;

    script_phone)
      NUM=$(prompt_input "Número (ex: +5586999999999):")
      [ -z "$NUM" ] && return
      echo -e "${C}[*] Pipeline phone_osint.sh...${NC}\n"
      bash "$SCRIPTS/phone_osint.sh" "$NUM"
      pause ;;

    # ─── OSINT ─────────────────────────────────────────

    sherlock_search)
      USR=$(prompt_input "Username a pesquisar:")
      [ -z "$USR" ] && return
      echo -e "${C}[*] Sherlock buscando '$USR'...${NC}\n"
      \sherlock "$USR" --print-found --timeout 10
      pause ;;

    h8mail_check)
      EMAIL=$(prompt_input "Email a verificar:")
      [ -z "$EMAIL" ] && return
      echo -e "${C}[*] h8mail verificando '$EMAIL'...${NC}\n"
      h8mail -t "$EMAIL"
      pause ;;

    script_osint_person)
      USR=$(prompt_input "Username / nome para pesquisar:")
      [ -z "$USR" ] && return
      echo -e "${C}[*] osint_person.sh '$USR'...${NC}\n"
      bash "$SCRIPTS/osint_person.sh" --no-ai "$USR"
      pause ;;

    # ─── REDE ──────────────────────────────────────────

    script_ip_lookup)
      ALVO=$(prompt_input "IP ou domínio (ex: 8.8.8.8 ou google.com):")
      [ -z "$ALVO" ] && return
      echo -e "${C}[*] ip_lookup.sh '$ALVO'...${NC}\n"
      bash "$SCRIPTS/ip_lookup.sh" "$ALVO"
      pause ;;

    nexttrace_run)
      ALVO=$(prompt_input "IP ou domínio:")
      [ -z "$ALVO" ] && return
      echo -e "${C}[*] nexttrace '$ALVO'...${NC}\n"
      nexttrace "$ALVO"
      pause ;;

    whois_run)
      ALVO=$(prompt_input "Domínio ou IP:")
      [ -z "$ALVO" ] && return
      echo -e "${C}[*] whois '$ALVO'...${NC}\n"
      whois "$ALVO" | head -60
      pause ;;

    nmap_host)
      ALVO=$(prompt_input "IP ou domínio:")
      [ -z "$ALVO" ] && return
      echo -e "${C}[*] nmap '$ALVO' (top 20 portas)...${NC}\n"
      nmap -T4 --top-ports 20 "$ALVO"
      pause ;;

    nmap_net)
      echo -e "${DIM}Seu IP na rede:${NC}"
      ip route | grep src | awk '{print $NF}' | head -1
      REDE=$(prompt_input "Faixa da rede (ex: 192.168.1.0/24):")
      [ -z "$REDE" ] && return
      echo -e "${C}[*] nmap rede '$REDE'...${NC}\n"
      nmap -T4 -sn "$REDE"
      pause ;;

    nmap_full)
      ALVO=$(prompt_input "IP ou domínio:")
      PORTAS=$(prompt_input "Portas (ex: 80,443,22 ou deixe vazio para padrão):")
      [ -z "$ALVO" ] && return
      echo -e "${C}[*] nmap com detecção de versão...${NC}\n"
      if [ -z "$PORTAS" ]; then
        nmap -sV "$ALVO"
      else
        nmap -sV -p "$PORTAS" "$ALVO"
      fi
      pause ;;

    # ─── WEB ───────────────────────────────────────────

    nikto_scan)
      URL=$(prompt_input "URL do site (ex: http://site.com):")
      [ -z "$URL" ] && return
      echo -e "${C}[*] nikto '$URL'...${NC}\n"
      nikto -h "$URL"
      pause ;;

    sqlmap_scan)
      URL=$(prompt_input "URL com parâmetro (ex: http://site.com/page?id=1):")
      [ -z "$URL" ] && return
      echo -e "${C}[*] sqlmap '$URL'...${NC}\n"
      sqlmap -u "$URL" --dbs --batch
      pause ;;

    script_web_vuln)
      URL=$(prompt_input "URL do site (ex: http://site.com):")
      [ -z "$URL" ] && return
      echo -e "${C}[*] web_vuln_scan.sh '$URL'...${NC}\n"
      bash "$SCRIPTS/web_vuln_scan.sh" --no-ai "$URL"
      pause ;;

    script_auto_recon)
      DOMINIO=$(prompt_input "Domínio (ex: exemplo.com.br):")
      [ -z "$DOMINIO" ] && return
      echo -e "${C}[*] auto_recon.sh '$DOMINIO'...${NC}\n"
      bash "$SCRIPTS/auto_recon.sh" --no-ai "$DOMINIO"
      pause ;;

    # ─── APK ───────────────────────────────────────────

    script_apk)
      APK=$(prompt_input "Caminho do APK (ex: ~/Downloads/app.apk):")
      [ -z "$APK" ] && return
      echo -e "${C}[*] apk_analyze.sh '$APK'...${NC}\n"
      bash "$SCRIPTS/apk_analyze.sh" "$APK"
      pause ;;

    # ─── SISTEMA ───────────────────────────────────────

    sys_check)
      echo -e "${BOLD}Ferramentas detectadas:${NC}\n"
      TOOLS="nmap sqlmap nikto curl python3 phoneinfoga nexttrace phoneintel sherlock h8mail whois dig"
      for t in $TOOLS; do
        if has "$t"; then
          VER=$(command -v "$t")
          echo -e "  ${G}✓${NC} $t  ${DIM}($VER)${NC}"
        else
          echo -e "  ${R}✗${NC} $t"
        fi
      done
      echo ""
      echo -e "${BOLD}Scripts em $SCRIPTS:${NC}\n"
      for s in "$SCRIPTS"/*.sh; do
        name=$(basename "$s")
        echo -e "  ${G}✓${NC} $name"
      done
      echo ""
      echo -e "${BOLD}Módulos Python úteis:${NC}\n"
      for m in phonenumbers requests; do
        if has_py_mod "$m"; then
          echo -e "  ${G}✓${NC} $m"
        else
          echo -e "  ${R}✗${NC} $m"
        fi
      done
      pause ;;

    sys_update)
      echo -e "${C}[*] Atualizando repositório...${NC}\n"
      cd "$HOME/bi" && git pull
      pause ;;

    sys_exit)
      echo -e "\n${DIM}Saindo...${NC}\n"
      exit 0 ;;
  esac
}

# ── Loop principal ─────────────────────────────────────
while true; do
  show_menu
  read -r -p "$(echo -e "${W}Escolha uma opção: ${NC}")" CHOICE

  # Validar entrada
  if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
    continue
  fi

  IDX=$((CHOICE - 1))
  if [ "$IDX" -lt 0 ] || [ "$IDX" -ge "${#ITEMS[@]}" ]; then
    echo -e "\n${R}Opção inválida.${NC}"
    sleep 1
    continue
  fi

  run_action "${KEYS[$IDX]}"
done
