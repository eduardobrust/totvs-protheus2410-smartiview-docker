#!/bin/bash
# description: Este script é usado para gerenciar serviços do Protheus, permitindo
# iniciar, parar, reiniciar, matar, verificar o status, exibir informações detalhadas,
# exportar logs e configurações, e monitorar logs em tempo real.
# Use as opções start, stop, kill, restart, status, describe, export, ou log para realizar
# operações comuns de serviço de maneira fácil e eficiente.

#########################################
#   CONFIGURACAO DO SERVICO     #
#########################################
# Nome do container (ajuste conforme necessário ou passe como argumento)
CONTAINER_NAME=${CONTAINER_NAME:-"protheus_services"}

# Inserir o nome do executavel
prog="appsrvlinux"

# Inserir o caminho do diretorio do executavel dentro do container
pathbin="/totvs/protheus/bin/appsec01"

alias=$(basename "${pathbin}")

progbin="${pathbin}/${prog}"
pidfile="/var/run/${alias}.pid"
lockfile="/var/lock/subsys/${alias}"

config_filename=appserver.ini
log_filename=console.log
#################################################################
# Configuracao de ULIMIT
#################################################################
# open files - (-n)
openFiles=65536
# stack size - (kbytes, -s)
stackSize=1024
# core file size - (blocks, -c)
coreFileSize=unlimited
# file size - (blocks, -f)
fileSize=unlimited
# cpu time - (seconds, -t)
cpuTime=unlimited
# virtual memory - (-v)
virtualMemory=unlimited

#################################
#   FIM DA CONFIGURACAO #
#################################

RETVAL=0

## Verifica se o container existe
docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$" || {
    echo "Container ${CONTAINER_NAME} not found!"
    exit 5
}

# Variaveis de Output
red="\033[31m"
green='\033[32m'
reset='\033[m'

SCRIPT_NAME=$(basename "$0")

## Função auxiliar para obter o PID do processo usando ps e filtrar pelo caminho
get_pid() {
    # Obtém todos os PIDs correspondentes a appsrvlinux
    pids=$(docker exec ${CONTAINER_NAME} ps -aux | grep "[${prog:0:1}]${prog:1}" | grep -v grep | awk '{print $2}' 2>/dev/null)
    
    # Se não houver PIDs, retorna vazio
    if [ -z "$pids" ]; then
        echo ""
        return 0
    fi

    # Itera sobre os PIDs e verifica o caminho do executável
    for pid in $pids; do
        # Obtém o caminho real do executável usando /proc/<pid>/exe
        exe_path=$(docker exec ${CONTAINER_NAME} readlink /proc/$pid/exe 2>/dev/null)
        if [ "$exe_path" = "$progbin" ]; then
            echo "$pid"
            return 0
        fi
    done

    # Se nenhum PID corresponder ao caminho correto, retorna vazio
    echo ""
}

## Start_service: função que inicia o serviço.
start_service() {
    pid=$(get_pid)
    if [ -z "$pid" ]; then
        echo "Starting Appserver $prog... "
        # Inicia o serviço no container
        docker exec ${CONTAINER_NAME} /bin/bash -c "cd ${pathbin} && ${progbin} -daemon >/dev/null &"
        RETVAL=$?
        if [ ${RETVAL} -eq 0 ]; then
            sleep 1
            docker exec ${CONTAINER_NAME} touch ${lockfile} 2>/dev/null
            docker exec ${CONTAINER_NAME} touch ${pidfile} 2>/dev/null
            # Obtém o PID após iniciar
            pid=$(get_pid)
            if [ -n "$pid" ]; then
                echo "$pid" | docker exec ${CONTAINER_NAME} tee ${pidfile} >/dev/null 2>/dev/null
                echo "PID : $pid"
                echo -e "${prog} Appserver running :   ${green}[ OK ]${reset}"
            else
                echo -e "Failed to get PID for Appserver ${prog} : ${red}[ Failure ]${reset}"
            fi
        else
            echo -e "Failed to start Appserver ${prog} :         ${red}[ Failure ]${reset}"
        fi
        echo
    else
        echo -e "$prog Appserver is ${green}Started${reset} pid $pid"
    fi
}

## Stop_service: função que encerra o serviço.
stop_service() {
    pid=$(get_pid)
    if [ -z "$pid" ]; then
        echo -e "${prog} Appserver is not running ${red}[ Stopped ]${reset}"
        return 0
    fi
    # Verifica se o PID corresponde a appsrvlinux antes de enviar o sinal
    process_name=$(docker exec ${CONTAINER_NAME} ps -p $pid -o comm= 2>/dev/null || echo "unknown")
    if [ -z "$process_name" ] || [ "$process_name" != "$prog" ]; then
        echo -e "${red}Warning: PID $pid does not match $prog (found $process_name)${reset}"
        return 1
    fi
    # Envia o sinal SIGTERM
    if ! docker exec ${CONTAINER_NAME} kill -s SIGTERM $pid 2>/dev/null; then
        echo -e "${red}Warning: Failed to send SIGTERM to $pid${reset}"
        return 1
    fi
    echo
    docker exec ${CONTAINER_NAME} rm -f ${lockfile} 2>/dev/null
    docker exec ${CONTAINER_NAME} rm -f ${pidfile} 2>/dev/null
    echo -n "Stopping Appserver $prog..."
    # Aguarda o término do processo
    while [ ! -z "$(docker exec ${CONTAINER_NAME} ps -p $pid -o pid= 2>/dev/null)" ]; do
        echo -n "."
        sleep 1
    done
    echo
    echo -e "$prog Appserver is Stopped     ${red}[ Stopped ]${reset}"
}

## Kill_service: função que interrompe o serviço.
kill_service() {
    pid=$(get_pid)
    if [ -z "$pid" ]; then
        echo -e "${prog} Appserver is not running ${red}[ Stopped ]${reset}"
        return 0
    fi
    # Verifica se o PID corresponde a appsrvlinux antes de enviar o sinal
    process_name=$(docker exec ${CONTAINER_NAME} ps -p $pid -o comm= 2>/dev/null || echo "unknown")
    if [ -z "$process_name" ] || [ "$process_name" != "$prog" ]; then
        echo -e "${red}Warning: PID $pid does not match $prog (found $process_name)${reset}"
        return 1
    fi
    # Envia o sinal SIGKILL
    if ! docker exec ${CONTAINER_NAME} kill -s SIGKILL $pid 2>/dev/null; then
        echo -e "${red}Warning: Failed to send SIGKILL to $pid${reset}"
        return 1
    fi
    echo
    docker exec ${CONTAINER_NAME} rm -f ${lockfile} 2>/dev/null
    docker exec ${CONTAINER_NAME} rm -f ${pidfile} 2>/dev/null
    echo -n "Stopping Appserver $prog..."
    # Aguarda o término do processo
    while [ ! -z "$(docker exec ${CONTAINER_NAME} ps -p $pid -o pid= 2>/dev/null)" ]; do
        echo -n "."
        sleep 1
    done
    echo
    echo -e "$prog Appserver is Killed     ${red}[ Killed ]${reset}"
}

## get_stats: função que coleta os dados do serviço e exporta no contexto atual.
get_stats() {
    date
    echo
    pid=$(get_pid)
    if [ -n "$pid" ]; then
        export progport=$(docker exec ${CONTAINER_NAME} lsof -Pp ${pid} | grep '(LISTEN)' | awk '{ print $9}' | cut -d: -f2 | xargs | tr ' ' ',' 2>/dev/null || echo "N/A")
        export list=$(docker exec ${CONTAINER_NAME} ps -eo pid,start_time,cputime,pcpu,pmem,stat,size,nlwp,comm | grep ${pid} 2>/dev/null || echo "")
        if [ -n "$list" ]; then
            export start_time=$(echo -e "$list" | awk '{ print $2 }' || echo "N/A")
            export cputime=$(echo -e "$list" | awk '{ print $3 }' || echo "N/A")
            export pcpu=$(echo -e "$list" | awk '{ print $4 }' || echo "N/A")
            export pmem=$(echo -e "$list" | awk '{ print $5 }' || echo "N/A")
            export stat=$(echo -e "$list" | awk '{ print $6 }' || echo "N/A")
            export size=$(echo -e "$list" | awk '{ print $7 }' || echo "N/A")
            export nlwp=$(echo -e "$list" | awk '{ print $8 }' || echo "N/A")
            export comm=$(echo -e "$list" | awk '{ print $9 }' || echo "N/A")
            export size=$(echo -e "$(bc <<< "scale=2;$size/1024")MB" 2>/dev/null || echo "N/A")
        else
            export start_time="N/A"
            export cputime="N/A"
            export pcpu="N/A"
            export pmem="N/A"
            export stat="N/A"
            export size="N/A"
            export nlwp="N/A"
            export comm="N/A"
        fi
    else
        echo -e "Status process: ${red} [ Stopped ] ${reset} "
        echo -e "${red}- Program $prog Appserver is not running! ${reset}"
    fi
}

## Status: função que exibe o estado atual do serviço em formato de tabela.
status() {
    get_stats
    if [ -z "$pid" ]; then
        echo -e "Status process: ${red} [ Stopped ] ${reset} "
        echo -e "${red}- Program $prog Appserver is not running! ${reset}"
    else
        output=$(cat << EOF
ALIAS PROCESS PORT PID CPU_TIME %CPU %MEM MEMORY THREADS STATUS PATH
${alias} ${comm} ${progport} ${pid} ${cputime} ${pcpu} ${pmem} ${size} ${nlwp} ${green}[running]${reset} ${progbin}
EOF
)
        echo -e "$output" | column -t
    fi
}

get_log() {
    consolelog=$(docker exec ${CONTAINER_NAME} grep -i '^\s*consolefile\s*=' "${pathbin}/${config_filename}" | awk -F= '{print $2}' | tr -d ' ' 2>/dev/null)
    if [ ! -n "$consolelog" ]; then
        if [ -n "$(docker exec ${CONTAINER_NAME} test -f ${pathbin}/${log_filename} && echo true 2>/dev/null)" ]; then
            consolelog="${pathbin}/${log_filename}"
        else
            echo "${red}Logfile not found!${reset} : \"${pathbin}/${log_filename}\""
            echo "Config File: ${pathbin}/${config_filename}"
            echo "Add parameter: consolefile=${pathbin}/${log_filename}"
        fi
    fi
    echo ${consolelog}
}

## Describe: função que exibe as configurações do ambiente onde o servico está rodando.
describe() {
    get_stats
    if [ -n "$pid" ]; then
        output=$(cat << EOF
AlIAS ${alias}
PROCESS ${comm}
PATH ${progbin}
PORT ${progport}
PID ${pid}
STARTED ${start_time}
TIME ${cputime}
%CPU ${pcpu}
%MEM ${pmem}
MEMORY ${size}
STATUS [Running]
THREADS ${nlwp}
EOF
)
        echo -e "$output" | column -t
        echo
    fi
    echo "### LIBRARY ####"
    docker exec ${CONTAINER_NAME} ldd ${progbin} 2>/dev/null || echo "Cannot execute ldd"
    echo ""
    echo "### INI ###"
    if [ -n "$(docker exec ${CONTAINER_NAME} test -f ${pathbin}/${config_filename} && echo true 2>/dev/null)" ]; then
        echo ""
        echo -e "${config_filename} : ${green} ${pathbin}/${config_filename} ${reset}"
        echo ""
        docker exec ${CONTAINER_NAME} cat ${pathbin}/${config_filename} 2>/dev/null || echo "Cannot read ${config_filename}"
    else
        echo "O appserver não foi localizado."
    fi
    echo ""
    echo "### LOGFILE ###"
    consolelog=$(get_log)
    if [ -n "$consolelog" ]; then
        echo ""
        echo -e "console.log : ${green} ${consolelog} ${reset}"
        echo ""
        docker exec ${CONTAINER_NAME} head -n 15 "$consolelog" 2>/dev/null || echo "Cannot read log"
        echo ...
        docker exec ${CONTAINER_NAME} tail -n 15 "$consolelog" 2>/dev/null || echo "Cannot read log"
    else
        echo "Chave 'consolefile' não encontrada no arquivo ${pathbin}/${config_filename}."
    fi
}

## Tail_log: Executa o comando tail -f no arquivo de log do serviço.
tail_log() {
    consolelog=$(get_log)
    if [ -n "$consolelog" ]; then
        echo ""
        echo -e "console.log : ${green}$consolelog${reset}"
        echo ""
        docker exec ${CONTAINER_NAME} head -n 15 "$consolelog" 2>/dev/null || echo "Cannot read log"
        echo ...
        docker exec ${CONTAINER_NAME} tail -f -n 15 "$consolelog" 2>/dev/null || echo "Cannot monitor log"
    else
        echo "Chave 'consolefile' não encontrada no arquivo ${pathbin}/${config_filename}."
    fi
}

## Export_service: Exporta as configurações do ambiente onde o serviço sendo executado junto com o logfile.
export_service() {
    # Exportar describe para um arquivo temporário
    docker exec ${CONTAINER_NAME} /bin/bash -c "describe" > /tmp/${SCRIPT_NAME}_describe.txt 2>/dev/null || echo "Failed to export describe" > /tmp/${SCRIPT_NAME}_describe.txt

    # Exportar bibliotecas
    docker exec ${CONTAINER_NAME} ldd -v ${progbin} > /tmp/${SCRIPT_NAME}_library.txt 2>/dev/null || echo "Failed to export libraries" > /tmp/${SCRIPT_NAME}_library.txt

    # Exportar log
    consolelog=$(get_log)
    if [ -n "$consolelog" ]; then
        docker cp ${CONTAINER_NAME}:${consolelog} /tmp/${SCRIPT_NAME}_console.log 2>/dev/null || echo "Failed to export log" > /tmp/${SCRIPT_NAME}_console.log
    else
        echo "Chave 'consolefile' não encontrada no arquivo ${pathbin}/${config_filename}." > /tmp/${SCRIPT_NAME}_console.log
    fi

    # Exportar config
    if [ -n "$(docker exec ${CONTAINER_NAME} test -f ${pathbin}/${config_filename} && echo true 2>/dev/null)" ]; then
        docker cp ${CONTAINER_NAME}:${pathbin}/${config_filename} /tmp/${SCRIPT_NAME}_${config_filename} 2>/dev/null || echo "Failed to export config" > /tmp/${SCRIPT_NAME}_${config_filename}
    else
        echo "O appserver não foi localizado." > /tmp/${SCRIPT_NAME}_${config_filename}
    fi

    # Compactar
    zip_file="/tmp/${SCRIPT_NAME}_export.zip"
    cd /tmp
    zip -r "$zip_file" "${SCRIPT_NAME}_describe.txt" "${SCRIPT_NAME}_console.log" "${SCRIPT_NAME}_${config_filename}" "${SCRIPT_NAME}_library.txt" 2>/dev/null

    if [ -f "$zip_file" ]; then
        echo -e "Pacote criado com sucesso: ${green} $zip_file ${reset}"
    else
        echo -e "${red} Erro ao criar o pacote .zip ${reset}"
    fi
    rm -f /tmp/${SCRIPT_NAME}_describe.txt /tmp/${SCRIPT_NAME}_console.log /tmp/${SCRIPT_NAME}_${config_filename} /tmp/${SCRIPT_NAME}_library.txt
}

## Show_help: Mensagem de ajuda para usar este script.
show_help() {
    cat << EOF
Usage: ${SCRIPT_NAME} {start|stop|kill|restart|status|describe|export|log}

Gerenciamento de serviços permite iniciar, parar, reiniciar, matar, verificar o status, exibir informações.
Use as opções start|stop|kill|restart|status|describe|export|log para realizar operações comuns de serviço com facilidade.

  start     : Inicia o serviço.
  stop      : Encerra o serviço.
  kill      : Encerra o serviço de forma abrupta.
  restart   : Reinicia o serviço.
  status    : Exibe os detalhes do serviço em formato de tabela.
  describe  : Exibe os detalhes do serviço e configurações.
  export    : Exporta as informações do describe junto com o appserver.ini e console.log para
              o arquivo ${SCRIPT_NAME}.zip em /tmp.
  log       : Exibe o log com o comando tail -f.

EOF
}

# MAIN
case "$1" in
start)
    start_service 2>/dev/null
    ;;
stop)
    stop_service
    ;;
kill)
    kill_service
    ;;
restart)
    stop_service
    sleep 1
    start_service 2>/dev/null
    sleep 1
    status
    exit $?
    ;;
status)
    status
    ;;
describe)
    describe
    ;;
log)
    tail_log
    ;;
export)
    export_service
    ;;
*)
    show_help
    exit 1
esac

exit 0