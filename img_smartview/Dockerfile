FROM oraclelinux:9-slim

LABEL version="oraclelinux:9-slim" \
      description="Totvs SmartView 3.8" \
      creator="Eduardo Brust <eduardobrust@gmail.com>"

# Instala pacotes necessários e cria o diretório
RUN microdnf update -y && \
    microdnf install -y tar gzip && \
	microdnf install -y libicu && \
    microdnf clean all && \
    mkdir -p /totvs

# Copia o arquivo compactado para o diretório /totvs
COPY smartview.tgz /totvs/

# Extrai o conteúdo e ajusta permissões
RUN tar -xzf /totvs/smartview.tgz -C /totvs && \
    rm /totvs/smartview.tgz && \
    chmod -R 777 /totvs/smartview/ && \
    chmod +x /totvs/smartview/TReports.Agent

# Define o diretório de trabalho
WORKDIR /totvs/smartview/

# Define o binário como processo principal do container
ENTRYPOINT ["./TReports.Agent"]
