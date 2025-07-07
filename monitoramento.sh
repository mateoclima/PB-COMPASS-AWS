#!/bin/bash

# Script para monitorar a disponibilidade de um site web e enviar alertas para o Discord.

# --- INCLUSÃO DO ARQUIVO DE CONFIGURAÇÃO SECRETO ---
# Define o caminho para o arquivo de configuração.
CONFIG_FILE="/caminho/para/config.sh" # Lembre-se de ajustar este caminho se seu config.sh estiver em outro lugar

# Verifica se o arquivo de configuração existe e o "inclui".
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Se o arquivo de configuração não for encontrado, exibe um erro e sai.
    echo "ERRO: Arquivo de configuração $CONFIG_FILE não encontrado ou não acessível!" >&2
    exit 1
fi

# --- CONFIGURAÇÃO PRINCIPAL ---
# Nome amigável para o site que será usado nas mensagens de log e alertas.
SITE_NAME="Meu Servidor Web Principal"

# --- FUNÇÕES ---

# Função para registrar mensagens no arquivo de log.
# Recebe o tipo da mensagem (ex: INFO, ALERTA) e o conteúdo da mensagem.
log_message() {
    local TYPE=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S") # Obtém a data e hora atual.
    # Escreve a mensagem formatada no LOG_FILE. 'sudo tee -a' adiciona ao final do arquivo como root.
    echo "[$TIMESTAMP] [$TYPE] $MESSAGE" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Função para enviar notificações para o Discord via webhook.
# Recebe a mensagem a ser enviada.
send_discord_notification() {
    local MESSAGE=$1
    # Verifica se a URL do webhook do Discord está configurada.
    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        log_message "ERRO" "URL do Discord Webhook não configurada no config.sh. Não foi possível enviar a notificação."
        return 1 # Sai da função com erro.
    fi

    # Usa curl para enviar a mensagem formatada como JSON para o Discord.
    curl -s -X POST -H "Content-Type: application/json" \
         -d '{
            "username": "Monitor de Site - '"$SITE_NAME"'",
            "content": "'"$MESSAGE"'"
         }' "$DISCORD_WEBHOOK_URL"
}

# --- LÓGICA PRINCIPAL DO MONITORAMENTO ---

# Usa curl para verificar o código de status HTTP do SITE_URL.
# -o /dev/null: descarta a saída do corpo da página.
# -s: modo silencioso (não mostra o progresso do curl).
# -w "%{http_code}": imprime apenas o código de status HTTP.
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$SITE_URL")

# Verifica se o site está online (código de status 200).
if [ "$HTTP_STATUS" -eq 200 ]; then
    # Se online, registra uma mensagem de INFO no log.
    log_message "INFO" "SITE ONLINE - $SITE_NAME ($SITE_URL) - Status HTTP: $HTTP_STATUS"
else
    # Se offline (código diferente de 200), registra um ALERTA no log.
    log_message "ALERTA" "SITE OFFLINE - $SITE_NAME ($SITE_URL) - Status HTTP: $HTTP_STATUS"

    # Formata a mensagem para ser enviada ao Discord.
    NOTIFICATION_MESSAGE="O site $SITE_NAME ($SITE_URL) está fora do ar! (Código HTTP: '$HTTP_STATUS')."
    # Envia a notificação de alerta para o Discord.
    send_discord_notification "$NOTIFICATION_MESSAGE"
fi
