#!/bin/bash
# backup.sh - faz backup dos scripts e simula backup do banco de dados
set -euo pipefail


BACKUP_DIR="$HOME/projeto-so/backups"
DATA=$(date +%Y-%m-%d_%H-%M-%S)
FONTE="$HOME/projeto-so/scripts"
LOG_FILE="$HOME/projeto-so/logs/backup.log"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ ! -d "$FONTE" ]; then
  echo "pasta de origem nao encontrada" >&2
  exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
  logMsg "criando pasta de backup..."
  mkdir -p "$BACKUP_DIR"
fi

logMsg "fazendo backup dos scripts..."
cp -r "$FONTE" "$BACKUP_DIR/scripts_$DATA"
logMsg "scripts salvos em: $BACKUP_DIR/scripts_$DATA"

logMsg "simulando backup do banco..."
echo "-- backup gerado em $DATA" > "$BACKUP_DIR/banco_$DATA.sql"
echo "-- tabelas: usuarios, logs" >> "$BACKUP_DIR/banco_$DATA.sql"
logMsg "banco salvo em: $BACKUP_DIR/banco_$DATA.sql"

logMsg "backups disponiveis:"
ls -lh "$BACKUP_DIR" | tee -a "$LOG_FILE"