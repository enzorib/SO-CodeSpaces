#!/bin/bash
# monitor.sh - coleta metricas de CPU, memoria e disco e salva em log
set -euo pipefail


LOG_DIR="$HOME/projeto-so/logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d).log"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

getCpu() {
  uso=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
  logMsg "CPU: $uso%"
}

getMemoria() {
  total=$(free -m | awk '/Mem:/ {print $2}')
  usado=$(free -m | awk '/Mem:/ {print $3}')
  logMsg "Memoria: $usado MB usados de $total MB"
}

getDisco() {
  uso=$(df -h / | awk 'NR==2 {print $5}')
  logMsg "Disco: $uso em uso"
}

logMsg "=== iniciando monitoramento ==="
getCpu
getMemoria
getDisco
logMsg "=== fim ==="