#!/bin/bash
#Feito Por Daniel Amorim
#Script de automação de escaneamento e pentest em Sites
#Várias ferramentas de uma só vez.
#Use com consciência

#Atualiza e instala os pacotes necessários e limpa a tela
apt update
apt install net-tools whois dirb gobuster nikto whatweb nmap
clear

PORTS=80,8080,443

# Log do Programa
LOG_FILE=pentest_log.txt
echo "Digite o host alvo, exemplo = www.site.com" 
read host_alvo

# Exibe o valor digitado
echo "O host alvo selecionado é: $host_alvo" 
echo "O log está indo para o arquivo $LOG_FILE e é atualizado em tempo real"
echo "--- Iniciando o pentest em $host_alvo ---" >> "$LOG_FILE"
echo "--- Data/Hora: $(date) ---"  >> "$LOG_FILE"

# Fase 1: Ping
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 1: Verificando conectividade com Ping..." 
echo ">> Fase 1: Verificando conectividade com Ping...."  >> "$LOG_FILE"
ping -c 4 $host_alvo >> "$LOG_FILE"

# Fase 2: Whois
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 2: WHOIS..."
echo ">> Fase 2: WHOIS..." >> "$LOG_FILE"
whois $host_alvo  >>  "$LOG_FILE" 

# Fase 3: Nslookup 
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 3: Nslookup..."
echo ">> Fase 3: Nslookup..."   >>  "$LOG_FILE" 
echo ">>"  >> "$LOG_FILE"

echo ">> Consulta Nslookup MX..."   >>  "$LOG_FILE" 
echo ">>"  >> "$LOG_FILE"
nslookup -type=MX  $host_alvo  >>  "$LOG_FILE" 

echo ">>"  >> "$LOG_FILE"
echo ">> Consulta Nslookup AAAA..."   >>  "$LOG_FILE" 
echo ">>"  >> "$LOG_FILE"

nslookup -type=AAAA  $host_alvo >>  "$LOG_FILE"

echo ">>"  >> "$LOG_FILE"
echo ">> Consulta Nslookup CNAME..."   >>  "$LOG_FILE" 
echo ">>"  >> "$LOG_FILE"
nslookup -type=AAAA -type=CNAME $host_alvo  >>  "$LOG_FILE"

# Fase 4: Dirb 
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 4: Dirb..." 
echo ">> Fase 4: Dirb..."  >> "$LOG_FILE"
echo ">>"  >> "$LOG_FILE"
echo ">> Dirb HTTP..."  >> "$LOG_FILE"
dirb http://$host_alvo -S -z 100 -o pentest_dirb.txt -t 50 >> "$LOG_FILE"
echo ">>"  >> "$LOG_FILE"
echo ">> Dirb HTTPS..."  >> "$LOG_FILE"
dirb https://$host_alvo -S -z 100 -o pentest_dirb_ssl.txt -t 50 >> "$LOG_FILE"

# Fase 5: Gobuster 
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 5: Gobuster..."
echo ">> Fase 5: Gobuster..." >> "$LOG_FILE"
gobuster -t 30 -o pentest_gobuster.txt  dns -d "$host_alvo" -w /usr/share/dirb/wordlists/common.txt >> "$LOG_FILE"

# Fase 6: Nikto
echo ">>"  >> "$LOG_FILE"
echo ">>"
echo ">> Fase 6: Nikto"
echo ">> Fase 6: Nikto" >> "$LOG_FILE"
nikto -o pentest_nikto.txt -p "$PORTS" -h "$host_alvo" >> "$LOG_FILE"

# Fase 7: nmap 
echo ">>"  >> "$LOG_FILE"
echo ">> Fase 7: Nmap - Descobrindo Vulnerabilidades" 
echo ">> Fase 7: Nmap - Descobrindo Vulnerabilidades" >> "$LOG_FILE"
nmap -sV -O --script vuln -p "$PORTS" "$host_alvo" -oA pentest_nmap_vuln --min-hostgroup 10000 --min-rate 10000  >> "$LOG_FILE"

#Isso daqui eu ainda vou corrigir
#Tem causado problema na finalização de execução do codigo.
#cat pentest_nmap_vuln.gnmap | grep open | cut -d " " -f2 > pentest_nmap_ips_alvo.txt
#cat pentest_nmap_vuln.gnmap | grep open | awk '{ip=$2; ports=" "; for (i=6; i<=NF; i++) {if ($i ~ /open/) {split($i, a, "/"); ports=ports a[1]","}} print ip, ports}' | sed 's/,$//' > pentest_ip_open_ports.txt

# Fase 8: Whatweb
echo ">>"  >> "$LOG_FILE"
echo ">>" 
echo ">> Fase 8: WhatWeb" 
echo ">> Fase 8: WhatWeb" >> "$LOG_FILE"
whatweb -a 3 $host_alvo >> "$LOG_FILE"

echo ">>" 
echo ">>"  >> "$LOG_FILE"
echo "--- Data/Hora DA FINALIZAÇÃO DO ESCANEAMENTO: $(date) ---"  >> "$LOG_FILE"

echo ">> FINALIZADO - VERIFIQUE O ARQUIVO DE LOG $LOG_FILE" 
echo ">> FINALIZADO - VERIFIQUE O ARQUIVO DE LOG $LOG_FILE" >> "$LOG_FILE"
