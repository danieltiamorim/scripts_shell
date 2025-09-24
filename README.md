# scripts_shell

**autoteste_web.sh**

Script de Automação em Pentest WEB.

**Como usar o Script Autoteste - Web:**

	git clone "https://github.com/danieltiamorim/scripts_shell.git"
	cd scripts_shell/
	sudo chmod +x autoteste_web.sh 
	sudo ./autoteste_web.sh

  **Descrição**
  Um combo com 8 Ferramentas de Pentest:
  - Ping 
  - Whois
  - Nslookup
  - Dirb
  - Gobuster
  - Whatweb
  - Nmap

Cada um com sua função específica.

Esse script automatiza o trabalho do pentester fazendo em poucos minutos uma varredura no ambiente remoto por informações que demorariam pouco mais de uma hora para juntar.

O arquivo de log, pentest_log.txt ajuda o pentester a não perder o fio da documentação necessária para o próximo passo, a exploração de vulnerabilidades, e já adiantando, algumas ferramentas acima já fazem esse trabalho, como o Dirb, Whatweb e o Nmap.

Algumas ferramentas também terão seus próprios arquivos de Documentação, entregando os logs em formatos variados para que possam ser utilizados em outras ferramentas como o caso do NMAP e o arquivo de log .gnmap e o .xml.


Mais detalhes sobre o script estão no link:
https://deepwiki.com/danieltiamorim/scripts_shell/2-autoteste_web.sh-script
