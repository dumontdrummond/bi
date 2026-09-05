# Android Security Toolkit — ~/.bashrc additions
# Add to your ~/.bashrc or ~/.zshrc: source ~/android-security-toolkit/configs/bashrc_additions.sh

# Termux environment
export TERMUX=true
export PREFIX=/data/data/com.termux/files/usr
export HOME=/data/data/com.termux/files/home
export PATH=$PREFIX/bin:$HOME/.local/bin:$HOME/go/bin:$PATH
export PYTHONPATH=$HOME/.local/lib/python3.*/site-packages
export GOPATH=$HOME/go

# API keys — fill in your own values
# export ANTHROPIC_API_KEY="your-key-here"
# export SHODAN_API_KEY="your-key-here"
# export GITHUB_TOKEN="your-token-here"

# Toolkit paths
export SECLISTS="$HOME/tools/SecLists"
export PAYLOADS="$HOME/tools/PayloadsAllTheThings"
export TOOLS="$HOME/tools"
export SCRIPTS="$HOME/scripts"

# Convenience aliases
alias nmap-quick='nmap -T2 -sV --top-ports 1000'
alias nmap-full='nmap -sV -sC -O -p-'
alias nmap-scripts='nmap --script vuln'
alias tor-check='curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip'
alias myip='curl -s https://icanhazip.com'
alias myip-tor='proxychains4 curl -s https://icanhazip.com'
alias harvester='python3 $TOOLS/theHarvester/theHarvester.py'
alias sherlock='python3 $TOOLS/sherlock/sherlock'
alias spiderfoot='python3 $TOOLS/spiderfoot/sf.py'
alias nikto='perl $TOOLS/nikto/program/nikto.pl'

# Session logging
alias start-session='script -a $HOME/logs/session_$(date +%Y%m%d_%H%M%S).log'
