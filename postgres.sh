#!/bin/bash

COMPOSE_FILE="docker-compose.yml"
OVERRIDE_FILE="docker-compose.override.yml"
SERVICE_NAME="database"

function build() {
  echo "🛑 Brust - Postgres 16 - Parando o serviço antigo (se existir)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE stop $SERVICE_NAME 2>/dev/null || true

  echo "🔨 Brust - Postgres 16 - Removendo serviço antigo (se existir)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE rm -f $SERVICE_NAME 2>/dev/null || true

  echo "🔨 Brust - Postgres 16 - Buildando imagem Docker..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE build $SERVICE_NAME
}

function run() {
  # Verifica se o serviço já está rodando
  if docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE ps --services --filter "status=running" | grep -w $SERVICE_NAME > /dev/null; then
    echo "⚠️ Brust - Postgres 16 - O serviço $SERVICE_NAME já está rodando. Parando e removendo..."
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
    build
  fi

  # Subindo o serviço com docker-compose
  echo "🚀 Brust - Postgres 16 - Subindo serviço PostgreSQL..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE up -d $SERVICE_NAME
}

function stop() {
  echo "🛑 Brust - Postgres 16 - Parando e removendo serviço (se existir)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE rm -f $SERVICE_NAME 2>/dev/null || true
}

function clean() {
  echo "🧹 Brust - Postgres 16 - Limpando volumes não usados..."
  docker volume prune -f
}

function logs() {
  echo "📋 Brust - Postgres 16 - Logs do serviço:"
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE logs -f $SERVICE_NAME
}

function help() {
  echo "Brust - Postgres 16 - Uso: $0 [comando]"
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