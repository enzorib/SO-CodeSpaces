
set -euo pipefail

LOG_DIR="$HOME/projeto-so/logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d).log"

registrar() {
  local mensagem="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$LOG_FILE"
}

coletar_cpu() {
  local uso
  uso=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
  registrar "CPU em uso: ${uso}%"
}

coletar_memoria() {
  local total usado livre
  total=$(free -m | awk '/Mem:/ {print $2}')
  usado=$(free -m | awk '/Mem:/ {print $3}')
  livre=$(free -m | awk '/Mem:/ {print $4}')
  registrar "Memória — Total: ${total}MB | Usado: ${usado}MB | Livre: ${livre}MB"
}

coletar_disco() {
  local uso
  uso=$(df -h / | awk 'NR==2 {print $5}')
  registrar "Disco (/) em uso: $uso"
}

registrar "===== INÍCIO DO MONITORAMENTO ====="

coletar_cpu
coletar_memoria
coletar_disco

registrar "===== FIM DO MONITORAMENTO ====="