#!/bin/bash

COMPOSE_FILE="docker-compose.yml"
OVERRIDE_FILE="docker-compose.override.yml"
SERVICE_NAME="dbaccess"

# Verifica se o arquivo docker-compose.override.yml existe
if [ -f "$OVERRIDE_FILE" ]; then
  COMPOSE_OPTIONS="-f $COMPOSE_FILE -f $OVERRIDE_FILE"
else
  COMPOSE_OPTIONS="-f $COMPOSE_FILE"
fi

function build() {
  echo "🛑 Brust - Totvs DbAcess - Parando o serviço antigo (se existir)..."
  docker-compose $COMPOSE_OPTIONS stop $SERVICE_NAME 2>/dev/null || true

  echo "🔨 Brust - Totvs DbAcess - Removendo serviço antigo (se existir)..."
  docker-compose $COMPOSE_OPTIONS rm -f $SERVICE_NAME 2>/dev/null || true

  echo "🔨 Brust - Totvs DbAcess - Buildando imagem Docker..."
  docker-compose $COMPOSE_OPTIONS build $SERVICE_NAME
}

function run() {
  # Verifica se o serviço já está rodando
  if docker-compose $COMPOSE_OPTIONS ps --services --filter "status=running" | grep -w $SERVICE_NAME > /dev/null; then
    echo "⚠️ Brust - O serviço $SERVICE_NAME já está rodando. Parando e removendo..."
    stop
  fi

  # Limpando volumes não usados
  clean

  # Verifica se deve buildar a imagem
  BUILD=true
  for arg in "$@"; do
    if [ "$arg" == "--no-build" ]; then
      BUILD=false
    fi
  done

  if $BUILD; then
    echo "🚀 Brust - Totvs DbAcess - Fazendo novo Build ..."
    build
  fi

  # Subindo o serviço com docker-compose
  echo "🚀 Brust - Subindo o Totvs DbAcess..."
  docker-compose $COMPOSE_OPTIONS up -d $SERVICE_NAME
}

function stop() {
  echo "🛑 Brust - Totvs DbAcess - Parando e removendo serviço (se existir)..."
  docker-compose $COMPOSE_OPTIONS rm -f $SERVICE_NAME 2>/dev/null || true
}

function clean() {
  echo "🧹 Brust - Totvs DbAcess - Limpando volumes não usados..."
  docker volume prune -f
}

function logs() {
  echo "📋 Brust - Totvs DbAcess - Logs do serviço:"
  docker-compose $COMPOSE_OPTIONS logs -f $SERVICE_NAME
}

function help() {
  echo "Brust - Totvs DbAcess - Uso: $0 [comando]"
  echo ""
  echo "Comandos disponíveis:"
  echo "  build   → Builda a imagem do serviço"
  echo "  run     → Para, limpa, builda e sobe o serviço"
  echo "  run --no-build     → Para, limpa, sem buildar e sobe o serviço"
  echo "  stop    → Para e remove o serviço"
  echo "  clean   → Remove volumes não usados"
  echo "  logs    → Mostra logs do serviço"
  echo "  help    → Exibe esta ajuda"
}

# Executa o comando passado
case "$1" in
  build) build ;;
  run) run "$@" ;;
  stop) stop ;;
  clean) clean ;;
  logs) logs ;;
  help|*) help ;;
esac
