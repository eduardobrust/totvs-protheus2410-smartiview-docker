FROM oraclelinux:9-slim

LABEL version="oraclelinux:9-slim" \
      description="Totvs DbAccess" \
      maintainer="Eduardo Brust <eduardobrust@gmail.com>"

# Instala apenas o necessário e limpa cache em uma única camada
RUN microdnf install -y gzip tar && \
    microdnf clean all && \
    rm -rf /var/cache/yum

# Cria diretório e extrai o dbaccess em uma única etapa
COPY dbaccess.tgz /tmp/
RUN mkdir -p /totvs && \
    tar -xzf /tmp/dbaccess.tgz -C /totvs && \
    rm /tmp/dbaccess.tgz && \
    chmod +x /totvs/dbaccess/multi/dbaccess64 && \
    chmod 664 /totvs/dbaccess/multi/dbaccess.ini

# Define permissões mínimas necessárias para funcionamento
RUN chmod -R 755 /totvs && \
    chmod 775 /totvs/dbaccess && \
    chmod 755 /totvs/dbaccess/multi

# Define diretório de trabalho
WORKDIR /totvs/dbaccess/multi/

# Copia e aplica permissão ao entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define o entrypoint
ENTRYPOINT ["/entrypoint.sh"]
