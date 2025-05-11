FROM opensuse/leap:15.6

LABEL version="opensuse/leap:15.6" \
      description="Totvs License Server" \
      creator="Eduardo Brust <eduardobrust@gmail.com>"

# Instala pacotes necessários e cria o diretório
RUN zypper refresh && \
    zypper install -y gzip tar && \
    zypper clean && \
    mkdir -p /totvs

# Copia o arquivo compactado para o diretório /totvs
COPY licenseserver.tgz /totvs/

# Extrai o conteúdo do arquivo .tar.gz, remove o arquivo .tgz e ajusta permissões
RUN tar -xzf /totvs/licenseserver.tgz -C /totvs && \
    rm /totvs/licenseserver.tgz && \
    chmod -R 777 /totvs/licenseserver/ && \
    chmod +x /totvs/licenseserver/bin/appserver/appsrvlinux && \
    chmod 664 /totvs/licenseserver/bin/appserver/appserver.ini

# Define o diretório de trabalho como o diretório onde o binário está localizado
WORKDIR /totvs/licenseserver/bin/appserver

# Copia o entrypoint.sh e dá permissão de execução
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

# Define o entrypoint para rodar o script
ENTRYPOINT ["/entrypoint.sh"]