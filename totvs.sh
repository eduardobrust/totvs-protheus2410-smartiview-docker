#!/bin/bash

# Script centralizador para gerenciar todos os serviços TOTVS

COMPOSE_FILE="docker-compose.yml"
OVERRIDE_FILE="docker-compose.override.yml"

function build() {
  echo "🛑 Brust - TOTVS - Parando todos os serviços antigos (se existirem)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE stop 2>/dev/null || true

  echo "🔨 Brust - TOTVS - Removendo todos os serviços antigos (se existirem)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE rm -f 2>/dev/null || true

  echo "🔨 Brust - TOTVS - Iniciando build de todas as imagens..."
  ./postgres.sh build
  ./license.sh build
  ./dbaccess.sh build
  ./protheus.sh build
  ./smartview.sh build
}

function run() {
  if docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE ps --services --filter "status=running" | grep -q .; then
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
  ./postgres.sh run "$@"
  ./license.sh run "$@"
  ./dbaccess.sh run "$@"
  ./protheus.sh run "$@"
  ./smartview.sh run "$@"
}

function stop() {
  echo "🛑 Brust - TOTVS - Parando e removendo todos os serviços (se existirem)..."
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE rm -f 2>/dev/null || true
}

function clean() {
  echo "🧹 Brust - TOTVS - Limpando volumes não usados..."
  docker volume prune -f
}

function logs() {
  echo "📋 Brust - TOTVS - Logs de todos os serviços:"
  docker-compose -f $COMPOSE_FILE -f $OVERRIDE_FILE logs -f
}

function help() {
  echo "Brust - TOTVS - Uso: $0 [comando]"
  echo ""
  echo "Comandos disponíveis:"
  echo "  build   → Builda as imagens de todos os serviços"
  echo "  run     → Para, limpa, builda e sobe todos os serviços na ordem"
  echo "  run --no-build     → Para, limpa, sem buildar e sobe todos os serviços"
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