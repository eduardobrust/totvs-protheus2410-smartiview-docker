#!/bin/bash
set -euo pipefail

echo "🔨 Brust - Ajustando ulimit..."

echo "🔨 Brust - [INFO] nofile após ulimit: $(ulimit -n)"

INI_FILE="/totvs/licenseserver/bin/appserver/appserver.ini"

if [[ ! -f "$INI_FILE" ]]; then
  echo "🔨 Brust -[ERRO] Arquivo appserver.ini não encontrado em: $INI_FILE"
  exit 1
fi

echo "🔨 Brust - Configurando portas no appserver.ini..."

# Verifica se variáveis estão definidas
: "${TCP_PORT:?Variável TCP_PORT não definida}"
: "${LICENSESERVER_PORT:?Variável LICENSESERVER_PORT não definida}"
: "${WEBAPP_PORT:?Variável WEBAPP_PORT não definida}"

# Substitui os placeholders pelas variáveis de ambiente
sed -i "s/TCP_PORT/${TCP_PORT}/g" "$INI_FILE"
sed -i "s/LICENSESERVER_PORT/${LICENSESERVER_PORT}/g" "$INI_FILE"
sed -i "s/WEBAPP_PORT/${WEBAPP_PORT}/g" "$INI_FILE"

echo "🔨 Brust - Configuração concluída. Iniciando License Server..."

exec /totvs/licenseserver/bin/appserver/appsrvlinux
