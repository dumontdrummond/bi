# Android Security Toolkit

Security testing toolkit for Termux on Android (GrapheneOS / LineageOS / Stock).

## Requirements

- Android with Termux installed (F-Droid recommended)
- Optional: Termux:API, PCAPdroid (both on F-Droid)
- ANTHROPIC_API_KEY for AI-powered analysis

## Quick Start

```bash
# 1. Clone
git clone <repo> && cd android-security-toolkit

# 2. Run initial setup
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. Add environment config to shell
echo "source $(pwd)/configs/bashrc_additions.sh" >> ~/.bashrc
source ~/.bashrc

# 4. Set your API key
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.bashrc
```

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/setup.sh` | One-time environment setup — installs all tools |
| `scripts/auto_recon.sh <domain>` | Domain recon: subdomains → HTTP probe → OSINT → AI report |
| `scripts/apk_analyze.sh <app.apk>` | APK static analysis → secrets hunt → AI risk assessment |
| `scripts/web_vuln_scan.sh <URL> [IP]` | Web pipeline: nmap → nikto → sqlmap → gobuster → AI report |
| `scripts/osint_person.sh <domain> <user>` | OSINT: WHOIS → theHarvester → Sherlock → AI consolidation |

All scripts accept `--no-ai` to skip Claude Code analysis.

## Tool Categories

| Category | Tools |
|----------|-------|
| OSINT / Recon | subfinder, httpx, theHarvester, Sherlock, h8mail, dnsx, amass |
| Web Testing | sqlmap, nikto, gobuster, httpx, WPScan |
| Network | nmap, netcat, tshark, masscan (via proot) |
| Credential | hydra, hashcat, john |
| APK Analysis | apktool, jadx |
| Anonymity | Tor, proxychains, WireGuard, SSH tunnels |
| AI Analysis | Claude Code (anthropic) |

## Docs

- [Quick Reference](docs/quick-reference.md) — commands, one-liners, workflows

## Notes

- All tools are open-source and publicly available
- Designed for authorized penetration testing and security research
- Always verify written authorization before testing any target
- Resource-limited defaults (low thread counts, delays) preserve mobile battery
