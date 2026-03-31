#!/bin/bash
set -euo pipefail
# process_manager.sh - gerencia servicos do backend, Gradle e ADB

LOG_FILE="$HOME/projeto-so/logs/process_manager.log"
PID_DIR="$HOME/projeto-so/pids"

mkdir -p "$PID_DIR"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ "$#" -lt 2 ]; then
  echo "uso: bash process_manager.sh <start|stop|status|restart> <servico>" >&2
  echo "servicos disponiveis: backend, gradle, adb" >&2
  exit 1
fi

acao="$1"
servico="$2"
pid_file="$PID_DIR/$servico.pid"

startServico() {
  if [ -f "$pid_file" ] && kill -0 "$(cat $pid_file)" 2>/dev/null; then
    logMsg "$servico ja ta rodando (PID: $(cat $pid_file))"
    return
  fi

  case "$servico" in
    backend)
      sleep 3600 &
      echo $! > "$pid_file"
      logMsg "backend iniciado com PID: $(cat $pid_file)"
      ;;
    gradle)
      if command -v gradle &>/dev/null; then
        gradle --status >> "$LOG_FILE" 2>&1 &
        echo $! > "$pid_file"
        logMsg "gradle iniciado com PID: $(cat $pid_file)"
      else
        logMsg "gradle nao encontrado. rode o setup.sh primeiro"
      fi
      ;;
    adb)
      if command -v adb &>/dev/null; then
        adb start-server >> "$LOG_FILE" 2>&1
        pgrep adb > "$pid_file" || true
        logMsg "adb iniciado"
      else
        logMsg "adb nao encontrado. rode o setup.sh primeiro"
      fi
      ;;
    *)
      echo "servico '$servico' nao reconhecido. use: backend, gradle, adb" >&2
      exit 1
      ;;
  esac
}

stopServico() {
  case "$servico" in
    adb)
      if command -v adb &>/dev/null; then
        adb kill-server >> "$LOG_FILE" 2>&1 || true
        rm -f "$pid_file"
        logMsg "adb parado"
      else
        logMsg "adb nao encontrado"
      fi
      ;;
    gradle)
      if command -v gradle &>/dev/null; then
        gradle --stop >> "$LOG_FILE" 2>&1 || true
        rm -f "$pid_file"
        logMsg "gradle parado"
      else
        logMsg "gradle nao encontrado"
      fi
      ;;
    *)
      if [ ! -f "$pid_file" ]; then
        logMsg "$servico nao ta rodando"
        return
      fi
      kill "$(cat $pid_file)" 2>/dev/null || true
      rm -f "$pid_file"
      logMsg "$servico parado"
      ;;
  esac
}

statusServico() {
  case "$servico" in
    adb)
      if command -v adb &>/dev/null; then
        dispositivos=$(adb devices 2>/dev/null | grep -v "List of" | grep -v "^$" | wc -l)
        if [ "$dispositivos" -gt 0 ]; then
          logMsg "adb RODANDO — $dispositivos dispositivo(s) conectado(s)"
        else
          logMsg "adb RODANDO mas sem dispositivos conectados"
        fi
      else
        logMsg "adb nao encontrado"
      fi
      ;;
    gradle)
      if pgrep -f "gradle" &>/dev/null; then
        logMsg "gradle ta RODANDO (PID: $(pgrep -f gradle | head -1))"
      else
        logMsg "gradle ta PARADO"
      fi
      ;;
    *)
      if [ -f "$pid_file" ] && kill -0 "$(cat $pid_file)" 2>/dev/null; then
        logMsg "$servico ta RODANDO (PID: $(cat $pid_file))"
      else
        logMsg "$servico ta PARADO"
        rm -f "$pid_file" 2>/dev/null || true
      fi
      ;;
  esac
}

restartServico() {
  logMsg "reiniciando $servico..."
  stopServico
  sleep 1
  startServico
  logMsg "$servico reiniciado"
}

case "$acao" in
  start)   startServico ;;
  stop)    stopServico ;;
  status)  statusServico ;;
  restart) restartServico ;;
  *)
    echo "acao invalida. use: start | stop | status | restart" >&2
    exit 1
    ;;
esac