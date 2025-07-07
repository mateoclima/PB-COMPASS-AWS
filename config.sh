#!/bin/bash
# Este arquivo contém variáveis de configuração para o script de monitoramento.
# Mantenha este arquivo seguro, com permissões restritas (ex: chmod 600).

# URL do Webhook do Discord para onde os alertas serão enviados.
# Substitua "SUA_URL_DO_WEBHOOK_DISCORD" pela URL real do seu webhook.
DISCORD_WEBHOOK_URL="SUA_URL_DO_WEBHOOK_DISCORD"

# Caminho completo para o arquivo de log onde o script registrará suas ações e status.
# Este arquivo será criado ou atualizado pelo script.
LOG_FILE="/var/log/monitoramento.log"

# URL do site que será monitorado.
# Substitua "http://SEU_IP_PUBLICO_DA_INSTANCIA_EC2" pelo IP público da sua EC2 ou domínio do site.
SITE_URL="http://SEU_IP_PUBLICO_DA_INSTANCIA_EC2"
