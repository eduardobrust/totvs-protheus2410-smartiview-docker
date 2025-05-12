FROM postgres:16.9

LABEL version="postgres:16.9" \
      description="PostgreSQL com WIN1252" \
      creator="Eduardo Brust <eduardobrust@gmail.com>"

# Agrupa a remoção do gosu antigo, atualização de pacotes, configuração de locales, instalação do Go, compilação do gosu e limpeza
RUN set -eux; \
    # Remove a versão antiga do gosu antes de qualquer outra operação
    if [ -f /usr/local/bin/gosu ]; then rm /usr/local/bin/gosu; fi && \
    # Adiciona o repositório bookworm-security para atualizações de segurança
    echo "deb http://deb.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    # Atualiza pacotes e instala dependências
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y locales wget git ca-certificates && \
    # Configura locales
    echo "en_US WIN1252" >> /etc/locale.gen && \
    echo "pt_BR WIN1252" >> /etc/locale.gen && \
    locale-gen && \
    # Instala o Go 1.23.8 (versão mais recente que corrige todas as vulnerabilidades)
    wget -O go.tar.gz https://go.dev/dl/go1.23.8.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    # Compila o gosu com Go 1.23.8
    export PATH=$PATH:/usr/local/go/bin && \
    git clone https://github.com/tianon/gosu.git /tmp/gosu && \
    cd /tmp/gosu && \
    git checkout 1.17 && \
    go build -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    gosu --version && \
    # Limpeza
    rm -rf /tmp/gosu /usr/local/go && \
    apt-get purge -y --auto-remove git ca-certificates wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Combina todas as variáveis de ambiente em uma única instrução
ENV LANG=pt_BR.WIN1252 \
    LANGUAGE=pt_BR:pt \
    LC_ALL=pt_BR.WIN1252

# Copia os scripts de inicialização
COPY initdb/init.sh /docker-entrypoint-initdb.d/init.sh
COPY initdb/init.sql /docker-entrypoint-initdb.d/init.sql

# Define permissões para o script
RUN chmod +x /docker-entrypoint-initdb.d/init.sh