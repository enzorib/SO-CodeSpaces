#!/bin/bash
# process_manager.sh - gerencia servicos do backend (start, stop, status, restart)
set -euo pipefail


LOG_FILE="$HOME/projeto-so/logs/process_manager.log"
PID_DIR="$HOME/projeto-so/pids"

mkdir -p "$PID_DIR"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ "$#" -lt 2 ]; then
  echo "uso: bash process_manager.sh <start|stop|status|restart> <servico>" >&2
  exit 1
fi

acao="$1"
servico="$2"
pid_file="$PID_DIR/$servico.pid"

case "$acao" in
  start)
    if [ -f "$pid_file" ]; then
      logMsg "$servico ja ta rodando (PID: $(cat $pid_file))"
    else
      sleep 3600 &
      echo $! > "$pid_file"
      logMsg "$servico iniciado com PID: $(cat $pid_file)"
    fi
    ;;
  stop)
    if [ ! -f "$pid_file" ]; then
      logMsg "$servico nao ta rodando"
    else
      kill "$(cat $pid_file)" 2>/dev/null || true
      rm -f "$pid_file"
      logMsg "$servico parado"
    fi
    ;;
  status)
    if [ -f "$pid_file" ] && kill -0 "$(cat $pid_file)" 2>/dev/null; then
      logMsg "$servico ta RODANDO (PID: $(cat $pid_file))"
    else
      logMsg "$servico ta PARADO"
      rm -f "$pid_file" 2>/dev/null || true
    fi
    ;;
  restart)
    logMsg "reiniciando $servico..."
    kill "$(cat $pid_file)" 2>/dev/null || true
    rm -f "$pid_file" 2>/dev/null || true
    sleep 3600 &
    echo $! > "$pid_file"
    logMsg "$servico reiniciado com PID: $(cat $pid_file)"
    ;;
  *)
    echo "acao invalida. use: start | stop | status | restart" >&2
    exit 1
    ;;
esac