
set -euo pipefail




LOG_FILE="$HOME/projeto-so/logs/process_manager.log"
PID_DIR="$HOME/projeto-so/pids"


registrar() {
  local mensagem="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$LOG_FILE"
}

erro() {
  echo "ERRO: $1" >&2
  exit 1
}

iniciar() {
  local servico="$1"
  local pid_file="$PID_DIR/$servico.pid"

  if [ -f "$pid_file" ]; then
    registrar "Serviço '$servico' já está rodando (PID: $(cat $pid_file))"
    return
  fi

  registrar "Iniciando serviço '$servico'..."
  sleep 3600 &
  echo $! > "$pid_file"
  registrar "Serviço '$servico' iniciado com PID: $(cat $pid_file)"
}

parar() {
  local servico="$1"
  local pid_file="$PID_DIR/$servico.pid"

  if [ ! -f "$pid_file" ]; then
    registrar "Serviço '$servico' não está rodando."
    return
  fi

  local pid
  pid=$(cat "$pid_file")
  registrar "Parando serviço '$servico' (PID: $pid)..."
  kill "$pid" 2>/dev/null || true
  rm -f "$pid_file"
  registrar "Serviço '$servico' parado."
}

status() {
  local servico="$1"
  local pid_file="$PID_DIR/$servico.pid"

  # Pipe (seção 11 do caderno)
  if [ -f "$pid_file" ]; then
    local pid
    pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
      registrar "Serviço '$servico' está RODANDO (PID: $pid)"
    else
      registrar "Serviço '$servico' está PARADO (PID antigo: $pid)"
      rm -f "$pid_file"
    fi
  else
    registrar "Serviço '$servico' está PARADO"
  fi
}

reiniciar() {
  local servico="$1"
  registrar "Reiniciando serviço '$servico'..."
  parar "$servico"
  iniciar "$servico"
  registrar "Serviço '$servico' reiniciado com sucesso."
}


if [ "$#" -lt 2 ]; then
  erro "Uso: bash process_manager.sh <start|stop|status|restart> <servico>"
fi

ACAO="$1"
SERVICO="$2"

mkdir -p "$PID_DIR"

case "$ACAO" in
  start)
    iniciar "$SERVICO"
    ;;
  stop)
    parar "$SERVICO"
    ;;
  status)
    status "$SERVICO"
    ;;
  restart)
    reiniciar "$SERVICO"
    ;;
  *)
    erro "Ação inválida '$ACAO'. Use: start | stop | status | restart"
    ;;
esac