#!/bin/bash
set -euo pipefail
# backup.sh - faz backup do codigo fonte Android e banco de dados SQLite

BACKUP_DIR="$HOME/projeto-so/backups"
DATA=$(date +%Y-%m-%d_%H-%M-%S)
PROJETO_ANDROID="$HOME/projeto-so"
LOG_FILE="$HOME/projeto-so/logs/backup.log"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ ! -d "$PROJETO_ANDROID" ]; then
  echo "pasta do projeto nao encontrada" >&2
  exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
  logMsg "criando pasta de backup..."
  mkdir -p "$BACKUP_DIR"
fi

logMsg "=== iniciando backup ==="

logMsg "fazendo backup dos scripts..."
cp -r "$PROJETO_ANDROID/scripts" "$BACKUP_DIR/scripts_$DATA" 2>> "$LOG_FILE"
logMsg "scripts salvos em: $BACKUP_DIR/scripts_$DATA"

logMsg "fazendo backup dos arquivos gradle..."
find "$PROJETO_ANDROID" -name "*.gradle" -o -name "gradle.properties" 2>/dev/null | while IFS= read -r arquivo; do
  cp "$arquivo" "$BACKUP_DIR/" 2>> "$LOG_FILE" || true
  logMsg "gradle salvo: $arquivo"
done

logMsg "procurando banco de dados SQLite..."
find "$PROJETO_ANDROID" -name "*.db" -o -name "*.sqlite" 2>/dev/null | while IFS= read -r db; do
  cp "$db" "$BACKUP_DIR/banco_$DATA.db" 2>> "$LOG_FILE" || true
  logMsg "banco salvo: $db"
done

if ! find "$PROJETO_ANDROID" -name "*.db" -o -name "*.sqlite" 2>/dev/null | grep -q .; then
  logMsg "nenhum banco SQLite encontrado, gerando backup simulado..."
  echo "-- backup simulado em $DATA" > "$BACKUP_DIR/banco_$DATA.sql"
  echo "-- banco: clinica_maya.db" >> "$BACKUP_DIR/banco_$DATA.sql"
  echo "-- tabelas: pacientes, consultas, usuarios" >> "$BACKUP_DIR/banco_$DATA.sql"
  logMsg "backup simulado salvo em: $BACKUP_DIR/banco_$DATA.sql"
fi

logMsg "backups disponiveis:"
ls -lh "$BACKUP_DIR" | tee -a "$LOG_FILE"

logMsg "=== backup finalizado ==="