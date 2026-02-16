#!/bin/bash

# Arquivo de configuração do Niri
CONFIG_FILE="$HOME/.config/niri/config.kdl"

# 1. Verifica dependências
if ! command -v jq &> /dev/null; then
    notify-send "Erro Niri Script" "O utilitário 'jq' não está instalado."
    exit 1
fi

# 2. Pega informações da janela (ADICIONADO A FLAG -j)
WINDOW_INFO=$(niri msg -j focused-window)

# Verifica se o comando retornou algo válido
if [ -z "$WINDOW_INFO" ] || [ "$WINDOW_INFO" == "null" ]; then
    notify-send "Erro Niri Script" "Nenhuma janela focada encontrada."
    exit 1
fi

# Extrai os dados
APP_ID=$(echo "$WINDOW_INFO" | jq -r '.app_id')
TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')

# 3. Lógica de decisão (App ID vs Title)
MATCH_RULE=""
IDENTIFIER=""

if [ "$APP_ID" != "null" ] && [ -n "$APP_ID" ]; then
    MATCH_RULE="app-id=\"$APP_ID\""
    IDENTIFIER="$APP_ID"
elif [ "$TITLE" != "null" ] && [ -n "$TITLE" ]; then
    # Fallback para XWayland ou janelas sem App ID
    MATCH_RULE="title=\"$TITLE\""
    IDENTIFIER="$TITLE"
fi

# 4. Trava de segurança: Se a regra ainda estiver vazia, não faz nada
if [ -z "$MATCH_RULE" ]; then
    notify-send "Erro Niri Script" "Não foi possível identificar App ID ou Título."
    exit 1
fi

# Cria a nova regra de janela
NEW_RULE="
window-rule {
    match $MATCH_RULE
    open-floating true
}
"

# 5. Backup e Gravação
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Adiciona uma quebra de linha antes para garantir separação
echo -e "\n$NEW_RULE" >> "$CONFIG_FILE"

# Notifica sucesso
notify-send "Niri Config" "Regra Floating salva para: $IDENTIFIER"
