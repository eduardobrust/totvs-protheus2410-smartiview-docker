#!/bin/bash

# Script centralizador para gerenciar todos os serviços TOTVS

COMPOSE_FILE="docker-compose.yml"
OVERRIDE_FILE="docker-compose.override.yml"

# Verifica o arquivo docker-compose.override.yml
if [ -f "$OVERRIDE_FILE" ]; then
  COMPOSE_OPTIONS="-f $COMPOSE_FILE -f $OVERRIDE_FILE"
else
  COMPOSE_OPTIONS="-f $COMPOSE_FILE"
fi

# Função para build das imagens
function build() {
  echo "🛑 Brust - TOTVS - Parando todos os serviços antigos (se existirem)..."
  docker-compose $COMPOSE_OPTIONS stop 2>/dev/null || true

  echo "🔨 Brust - TOTVS - Removendo todos os serviços antigos (se existirem)..."
  docker-compose $COMPOSE_OPTIONS rm -f 2>/dev/null || true

  echo "🔨 Brust - TOTVS - Iniciando build de todas as imagens..."
  ./1_postgres_image.sh build
  ./2_license_server_image.sh build
  ./3_dbaccess_image.sh build
  ./4_protheus_image.sh build
  ./5_smartview_image.sh build
}

# Função para rodar os containers
function run() {

  if docker-compose $COMPOSE_OPTIONS ps --services --filter "status=running" | grep -q .; then
    echo "⚠️ Brust - TOTVS - Alguns serviços já estão rodando. Parando e removendo todos..."
    stop
  fi

  clean

  BUILD=true
  for arg in "$@"; do
    if [ "$arg" == "--no-build" ]; then
      BUILD=false
    fi
  done

  if $BUILD; then
    build
  fi

  echo "🚀 Brust - TOTVS - Subindo todos os serviços na ordem: postgres, license, dbaccess, protheus, smartview..."
  ./1_postgres_image.sh run "$@"
  ./2_license_server_image.sh run "$@"
  ./3_dbaccess_image.sh run "$@"
  ./4_protheus_image.sh run "$@"
  ./5_smartview_image.sh run "$@"
}

# Função para parar e remover os containers
function stop() {
  echo "🛑 Brust - TOTVS - Parando e removendo todos os serviços (se existirem)..."
  docker-compose $COMPOSE_OPTIONS rm -f 2>/dev/null || true
}

# Função para limpar volumes não utilizados
function clean() {
  echo "🧹 Brust - TOTVS - Limpando volumes não usados..."
  docker volume prune -f
}

# Função para exibir logs de todos os serviços
function logs() {
  echo "📋 Brust - TOTVS - Logs de todos os serviços:"
  docker-compose $COMPOSE_OPTIONS logs -f
}

# Função de ajuda
function help() {
  echo "Brust - TOTVS - Uso: $0 [comando]"
  echo ""
  echo "Comandos disponíveis:"
  echo "  build   → Builda as imagens de todos os serviços"
  echo "  run     → Para, limpa, builda e sobe todos os serviços na ordem"
  echo "  run --no-build     → Para, limpa, sem buildar e sobe todos os serviços na ordem"
  echo "  stop    → Para e remove todos os serviços"
  echo "  clean   → Remove volumes não usados"
  echo "  logs    → Mostra logs de todos os serviços"
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
