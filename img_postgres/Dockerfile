FROM postgres:16

LABEL version="postgres:16" \
      description="PostgreSQL com WIN1252" \
      creator="Eduardo Brust <eduardobrust@gmail.com>"

# Instala suporte a locales e define o ambiente
RUN apt-get update && \
    apt-get install -y locales && \
    echo "en_US WIN1252" >> /etc/locale.gen && \
    echo "pt_BR WIN1252" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=pt_BR.WIN1252
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.WIN1252

# Copia os scripts de inicialização
COPY initdb/init.sh /docker-entrypoint-initdb.d/init.sh
COPY initdb/init.sql /docker-entrypoint-initdb.d/init.sql
RUN chmod +x /docker-entrypoint-initdb.d/init.sh