#!/bin/bash
set -euo pipefail
# monitor.sh - coleta metricas de CPU, memoria, disco, Gradle e ADB em loop

LOG_DIR="$HOME/projeto-so/logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d).log"
TOTAL_COLETAS=5
INTERVALO=3
ALERTA_CPU=80
ALERTA_MEM=85
ALERTA_DISCO=90

mkdir -p "$LOG_DIR"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

getCpu() {
  uso=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
  if [ -z "$uso" ]; then
    uso=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f", usage}')
  fi
  echo "$uso"
}

getMemoria() {
  total=$(free -m | awk '/Mem:/ {print $2}')
  usado=$(free -m | awk '/Mem:/ {print $3}')
  percent=$(awk "BEGIN {printf \"%.1f\", ($usado/$total)*100}")
  echo "$percent|$usado|$total"
}

getDisco() {
  df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5"|"$3"|"$2}'
}

getGradle() {
  pid=$(pgrep -f "gradle" 2>/dev/null | head -1 || true)
  if [ -n "$pid" ]; then
    echo "RODANDO|$pid"
  else
    echo "PARADO|-"
  fi
}

getAdb() {
  if command -v adb &>/dev/null; then
    dispositivos=$(adb devices 2>/dev/null | grep -v "List of" | grep -v "^$" | wc -l)
    if [ "$dispositivos" -gt 0 ]; then
      echo "CONECTADO|$dispositivos dispositivo(s)"
    else
      echo "NENHUM DISPOSITIVO|-"
    fi
  else
    echo "ADB NAO INSTALADO|-"
  fi
}

checarAlertas() {
  local cpu="$1"
  local mem="$2"
  local disco="$3"

  cpu_int=${cpu%.*}
  mem_int=${mem%.*}

  if [ "$cpu_int" -gt "$ALERTA_CPU" ]; then
    logMsg "ALERTA: CPU acima de $ALERTA_CPU%! Atual: $cpu%"
  fi
  if [ "$mem_int" -gt "$ALERTA_MEM" ]; then
    logMsg "ALERTA: Memoria acima de $ALERTA_MEM%! Atual: $mem%"
  fi
  if [ "$disco" -gt "$ALERTA_DISCO" ]; then
    logMsg "ALERTA: Disco acima de $ALERTA_DISCO%! Atual: $disco%"
  fi
}

logMsg "=== iniciando monitoramento ($TOTAL_COLETAS coletas a cada ${INTERVALO}s) ==="

for ((i=1; i<=TOTAL_COLETAS; i++)); do
  logMsg "--- coleta $i/$TOTAL_COLETAS ---"

  cpu=$(getCpu)
  logMsg "CPU: $cpu%"

  mem_info=$(getMemoria)
  mem_percent=$(echo "$mem_info" | cut -d'|' -f1)
  mem_usado=$(echo "$mem_info" | cut -d'|' -f2)
  mem_total=$(echo "$mem_info" | cut -d'|' -f3)
  logMsg "Memoria: $mem_percent% ($mem_usado MB usados de $mem_total MB)"

  disco_info=$(getDisco)
  disco_percent=$(echo "$disco_info" | cut -d'|' -f1)
  disco_usado=$(echo "$disco_info" | cut -d'|' -f2)
  disco_total=$(echo "$disco_info" | cut -d'|' -f3)
  logMsg "Disco: $disco_percent% ($disco_usado usados de $disco_total)"

  gradle_info=$(getGradle)
  gradle_status=$(echo "$gradle_info" | cut -d'|' -f1)
  gradle_pid=$(echo "$gradle_info" | cut -d'|' -f2)
  logMsg "Gradle: $gradle_status (PID: $gradle_pid)"

  adb_info=$(getAdb)
  adb_status=$(echo "$adb_info" | cut -d'|' -f1)
  adb_detalhe=$(echo "$adb_info" | cut -d'|' -f2)
  logMsg "ADB: $adb_status ($adb_detalhe)"

  checarAlertas "$cpu" "$mem_percent" "$disco_percent"

  if [ $i -lt $TOTAL_COLETAS ]; then
    sleep "$INTERVALO"
  fi
done

logMsg "=== monitoramento finalizado ==="