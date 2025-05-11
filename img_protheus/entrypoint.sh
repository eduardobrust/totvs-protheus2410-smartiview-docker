#!/bin/bash

set -e # Faz o script parar se algum comando falhar

# Exportando biblioteca para apprest
echo "🔨 Brust - Totvs Protheus Services - /totvs/Totvs Protheus Services/library ..exportando biblioteca"
echo "/totvs/protheus/bin/apprest" > /etc/ld.so.conf.d/protheus_apprest.conf
ldconfig

# Exportando biblioteca para appsec01
echo "🔨 Brust - Totvs Protheus Services - /totvs/Totvs Protheus Services/library ..exportando biblioteca"
echo "/totvs/protheus/bin/appsec01" > /etc/ld.so.conf.d/protheus_appsec01.conf
ldconfig

# Configurando appserver.ini para REST
echo "🔨 Brust - Totvs Protheus Services - Editando arquivo appserver.ini - REST"
INI_FILE="/totvs/protheus/bin/apprest/appserver.ini"
echo "🔨 Brust - Configurando portas no Totvs Protheus appserver.ini REST..."
cd /totvs/protheus/bin/apprest/
ls -l appserver.ini
sed -i "s/TCP_PORT_REST/${TCP_PORT_REST}/g" "$INI_FILE"
sed -i "s/DBACCESS_DATABASE/${DBACCESS_DATABASE}/g" "$INI_FILE"
sed -i "s/DBACCESS_SERVER/${DBACCESS_SERVER}/g" "$INI_FILE"
sed -i "s/DBACCESS_PORT/${DBACCESS_PORT}/g" "$INI_FILE"
sed -i "s/DBACCESS_ALIAS/${DBACCESS_ALIAS}/g" "$INI_FILE"
sed -i "s/LICENSE_SERVER/${LICENSE_SERVER}/g" "$INI_FILE"
sed -i "s/LICENSE_PORT/${LICENSE_PORT}/g" "$INI_FILE"
sed -i "s/HTTP_PORT_REST/${HTTP_PORT_REST}/g" "$INI_FILE"
sed -i "s/TOTVS_CERTIFICATE/${TOTVS_CERTIFICATE}/g" "$INI_FILE"
sed -i "s/TOTVS_KEY/${TOTVS_KEY}/g" "$INI_FILE"
echo "🔨 Brust - Configuração concluída do appserver.ini REST."

# Configurando appserver.ini para APPSERVER
INI_FILE="/totvs/protheus/bin/appsec01/appserver.ini"
echo "🔨 Brust - Configurando portas no Totvs Protheus appserver.ini APPSERVER..."
cd /totvs/protheus/bin/appsec01/
ls -l appserver.ini
sed -i "s/TCP_PORT_APP/${TCP_PORT_APP}/g" "$INI_FILE"
sed -i "s/DBACCESS_DATABASE/${DBACCESS_DATABASE}/g" "$INI_FILE"
sed -i "s/DBACCESS_SERVER/${DBACCESS_SERVER}/g" "$INI_FILE"
sed -i "s/DBACCESS_PORT/${DBACCESS_PORT}/g" "$INI_FILE"
sed -i "s/DBACCESS_ALIAS/${DBACCESS_ALIAS}/g" "$INI_FILE"
sed -i "s/LICENSE_SERVER/${LICENSE_SERVER}/g" "$INI_FILE"
sed -i "s/LICENSE_PORT/${LICENSE_PORT}/g" "$INI_FILE"
sed -i "s/WEBAPP_PORT/${WEBAPP_PORT}/g" "$INI_FILE"
sed -i "s/AGENT_PORT/${AGENT_PORT}/g" "$INI_FILE"
echo "🔨 Brust - Configuração concluída do appserver.ini APPSERVER."

echo "🔨 Brust - Subindo o APPSERVER ...."
/totvs/protheus/bin/appsec01/appsrvlinux &

sleep 10 # Aguarda inicialização do primeiro serviço

# Subindo os serviços em background
echo "🔨 Brust - Subindo o REST ...."
/totvs/protheus/bin/apprest/appsrvlinux &

echo "🔨 Brust - Totvs Protheus Release 2410 disponível ...."

# Mantém o container rodando
tail -f /dev/null