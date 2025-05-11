#!/bin/bash

set -e # Faz o script parar se algum comando falhar

# Ajusta o tamanho da stack para 8 MB
ulimit -s 8192

#exportando biblioteca
echo "🔨 Brust - Dbaccess - /totvs/dbaccess/library ..exportando biblioteca"
echo "/totvs/dbaccess/library" > /etc/ld.so.conf.d/dbaccess.conf
ldconfig

echo "🔨 Brust - Dbaccess - Instalando dependências do ODBC"

# Atualizando o sistema com dnf
microdnf update -y

# Instalando as dependências ODBC
microdnf install -y unixODBC postgresql-odbc

echo "🔨 Brust - Dbaccess - Criando arquivos de configuração do ODBC"

# Criando o /etc/odbcinst.ini
cat <<EOF > /etc/odbcinst.ini
[PostgreSQL]
Description=ODBC para PostgreSQL
Driver=/usr/lib64/psqlodbcw.so
Setup=/usr/lib64/psqlodbc.so
FileUsage=1
EOF

cat /etc/odbcinst.ini

echo "🔨 Brust - Dbaccess - Criando configuracao de ODBC para o banco dbprotheus"
# Criando o /etc/odbc.ini com variáveis de ambiente
cat <<EOF > /etc/odbc.ini
[${DB_ENVIRONMENTS:-dbprotheus}]
Description = Protheus Database
Driver = PostgreSQL
Servername = ${DB_SERVER_NAME:-localhost}
Port = ${DB_SERVER_PORT:-5432}
Database = ${DB_ENVIRONMENTS:-dbprotheus}
User = ${DB_USER:-userprotheus}
Password = ${DB_PASSWORD:-a12345}
Protocol = TCP
EOF

cat /etc/odbc.ini

echo "🔨 Brust - Dbaccess - Localizando arquivo dbaccess.ini"

set -e  # Faz o script parar se algum comando falhar

INI_FILE="/totvs/dbaccess/multi/dbaccess.ini"

echo "🔨 Brust - Configurando portas no dbaccess.ini..."

# Substitui os placeholders pelas variáveis de ambiente
sed -i "s/DB_PORT/${DB_PORT}/g" "$INI_FILE"
sed -i "s/LICENSE_SERVER/${LICENSE_SERVER}/g" "$INI_FILE"
sed -i "s/LICENSESERVER_PORT/${LICENSESERVER_PORT}/g" "$INI_FILE"
sed -i "s/DB_USER/${DB_USER}/g" "$INI_FILE"
sed -i "s/DB_ENVIRONMENTS/${DB_ENVIRONMENTS}/g" "$INI_FILE"
sed -i "s/CODEPAGE/${CODEPAGE}/g" "$INI_FILE"

echo "🔨 Brust - Configuração concluída. Iniciando Totvs DbAcess..."

# Executa o binário principal do Totvs DbAcess Server
exec /totvs/dbaccess/multi/dbaccess64
