#!/bin/bash
#Feito Por Daniel Amorim
#Script de automação de escaneamento e pentest em Sites
#Várias ferramentas de uma só vez.
#Use com consciência

#Atualiza e instala os pacotes necessários e limpa a tela
apt update
apt install net-tools whois dirb gobuster nikto whatweb nmap
clear

# Valor padrão inicial para o caso do usuário não digitar nada.
DEFAULT_PORTS="80,8080,443"

# Log do Script
LOG_FILE=pentest_log.txt
# Limpa o arquivo de log anterior ou cria um novo
> $LOG_FILE

echo "Script - AutoTeste_WEB, por Daniel Amorim - versão 2.0 - 09/2025" | tee -a $LOG_FILE
echo "Digite o host alvo, Exemplo = www.site.com" | tee -a $LOG_FILE
read host_alvo

echo "Digite as Portas Alvo, padrão é $DEFAULT_PORTS, Exemplo = 80,8080,443"  | tee -a $LOG_FILE
read PORTS_INPUT

# Se PORTS_INPUT estiver vazio, use o valor de DEFAULT_PORTS.
PORTS=${PORTS_INPUT:-$DEFAULT_PORTS}

# Exibe o valor digitado
echo "O host alvo selecionado é: $host_alvo" | tee -a $LOG_FILE
echo "As Portas alvo selecionadas são: $PORTS" | tee -a $LOG_FILE
#echo "O host alvo selecionado é: $host_alvo" | tee -a $LOG_FILE
#echo "As Portas alvo selecionadas são: $PORTS" | tee -a $LOG_FILE
echo "O log está indo para o arquivo $LOG_FILE e é atualizado em tempo real" | tee -a $LOG_FILE


echo "--- Iniciando o pentest em $host_alvo ---" | tee -a $LOG_FILE
echo "--- Data/Hora: $(date) ---"  | tee -a $LOG_FILE

# Fase 1: Ping
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 1: Verificando conectividade com Ping...."  | tee -a $LOG_FILE
ping -c 4 $host_alvo > /dev/null 2>&1 | tee -a $LOG_FILE

if [ $? -ne 0 ]; then
    # O código de saída NÃO é zero, ou seja, houve um erro no ping
    echo "" | tee -a $LOG_FILE
    echo "🚨 ERRO DE CONECTIVIDADE!" | tee -a $LOG_FILE
    echo "O host '$host_alvo' não respondeu ao ping ou não foi encontrado." | tee -a $LOG_FILE
    echo "Cancelando o restante dos testes." | tee -a $LOG_FILE
    exit 1 # Encerra o script com um código de erro (1)
else
    # O código de saída é zero, o ping foi bem-sucedido
    echo "" | tee -a $LOG_FILE
    echo "✅ Conectividade básica OK." | tee -a $LOG_FILE
fi

echo "Continuando com os demais testes..."

# Fase 2: Whois
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 2: WHOIS..." | tee -a $LOG_FILE
whois $host_alvo  >> $LOG_FILE 
echo "" | tee -a $LOG_FILE

# Fase 3: Nslookup 
echo ">>"  >> $LOG_FILE 
echo "✅ Fase 3: Nslookup..."   >> $LOG_FILE 
echo ">>"  >> $LOG_FILE 
echo ">> Consulta Nslookup MX..."   >> $LOG_FILE 
echo ">>"   >> $LOG_FILE 
nslookup -type=MX  $host_alvo  >> $LOG_FILE 

echo ">>"   >> $LOG_FILE 
echo ">> Consulta Nslookup A..."   >> $LOG_FILE 
echo ">>"  >> $LOG_FILE 
nslookup -type=A  $host_alvo >>  $LOG_FILE

echo ">>"   >> $LOG_FILE 
echo ">> Consulta Nslookup AAAA..."   >> $LOG_FILE 
echo ">>"   >> $LOG_FILE 
nslookup -type=AAAA  $host_alvo >>  $LOG_FILE

echo ">>"   >> $LOG_FILE 
echo ">> Consulta Nslookup CNAME..."   >> $LOG_FILE 
echo ">>"  >> $LOG_FILE 
nslookup -type=CNAME -type=CNAME $host_alvo  >>  $LOG_FILE

# Fase 4: Dirb 
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 4: Dirb - Modo de Enumeração de DNS..."  | tee -a $LOG_FILE
echo ">>"  | tee -a $LOG_FILE
echo ">> Dirb HTTP..."   >> $LOG_FILE 
dirb http://$host_alvo -S -z 100 -o pentest_dirb.txt -t 50 >> $LOG_FILE 
echo ">>"   >> $LOG_FILE 
echo ">> Dirb HTTPS..."  | >> $LOG_FILE 
dirb https://$host_alvo -S -z 100 -o pentest_dirb_ssl.txt -t 50 >> $LOG_FILE 

# Fase 5: Gobuster 
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 5: Gobuster..." | tee -a $LOG_FILE
gobuster -t 30 -o pentest_gobuster.txt  dns -d "$host_alvo" -w /usr/share/dirb/wordlists/common.txt >> $LOG_FILE 

# Fase 6: Nikto
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 6: Nikto" | tee -a $LOG_FILE
nikto -o pentest_nikto.txt -p "$PORTS" -h "$host_alvo" >> $LOG_FILE 

# Fase 7: nmap 
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 7: Nmap - Descobrindo Vulnerabilidades" | tee -a $LOG_FILE
nmap -sV -O --script vuln -p "$PORTS" "$host_alvo" -oA pentest_nmap_vuln --min-hostgroup 10000 --min-rate 10000  >> $LOG_FILE 

# Fase 8: Whatweb
echo ">>"  | tee -a $LOG_FILE
echo "✅ Fase 8: WhatWeb" | tee -a $LOG_FILE
whatweb -a 3 $host_alvo >> $LOG_FILE 

echo "" | tee -a $LOG_FILE
echo "✅ Finalizando..."  | tee -a $LOG_FILE
echo "Fazendo a sanitização dos Dados Coletados pelo NMAP... Aguarde"| tee -a $LOG_FILE
cat pentest_nmap_vuln.gnmap | grep open | cut -d " " -f2 > pentest_nmap_ips_alvo.txt
cat pentest_nmap_vuln.gnmap | grep open | awk '{ip=$2; ports=" "; for (i=5; i<=NF; i++) {if ($i ~ /open/) {split($i, a, "/"); ports=ports a[1]","}} print ip, ports}' | sed 's/,$//' > pentest_ip_open_ports.txt

echo "Cheque os arquivos - pentest_ip_open_ports.txt e pentest_nmap_ips_alvo.txt"

echo ">> Cheque os arquivos - pentest_ip_open_ports.txt e pentest_nmap_ips_alvo.txt"  | tee -a $LOG_FILE

echo ">>"  | tee -a $LOG_FILE
echo "--- Data/Hora DA FINALIZAÇÃO DO ESCANEAMENTO: $(date) ---"  | tee -a $LOG_FILE
echo ">> FINALIZADO - VERIFIQUE O ARQUIVO DE LOG $LOG_FILE" 
echo ">> FINALIZADO" | tee -a $LOG_FILE

