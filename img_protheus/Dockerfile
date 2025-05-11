FROM opensuse/leap:15.6

LABEL version="opensuse-leap:15.6" \
      description="Totvs Protheus Release 2410" \
      maintainer="Eduardo Brust <eduardobrust@gmail.com>"

# Instala pacotes necessários e limpa cache em uma única camada
RUN zypper --non-interactive install --no-recommends gzip tar && \
    zypper clean -a && \
    rm -rf /var/cache/zypp

# Cria diretório e copia arquivos
WORKDIR /totvs
COPY protheus.tgz protheus_data.tgz ./

# Extrai os arquivos e remove os tgz, ajusta permissões em uma única camada
RUN tar -xzf protheus.tgz && rm protheus.tgz && \
    tar -xzf protheus_data.tgz && rm protheus_data.tgz && \
	chmod +x /totvs/protheus/bin/appsec01/appsrvlinux && \
	chmod 664 /totvs/protheus/bin/appsec01/appserver.ini && \
    chmod +x /totvs/protheus/bin/apprest/appsrvlinux && \
    chmod 664 /totvs/protheus/bin/apprest/appserver.ini && \
    chmod -R 775 /totvs/protheus_data/ && \
    chmod -R 775 /totvs

# Copia o script de entrada e dá permissão
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define diretório padrão
WORKDIR /totvs

# Define o entrypoint
ENTRYPOINT ["/entrypoint.sh"]
