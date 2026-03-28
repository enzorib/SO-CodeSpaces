set -euo pipefail

BACKUP_DIR="$HOME/projeto-so/backups"
DATA=$(date +%Y-%m-%d_%H-%M-%S)
FONTE="$HOME/projeto-so/scripts"
LOG_FILE="$HOME/projeto-so/logs/backup.log"


registrar() {
  local mensagem="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$LOG_FILE"
}

erro() {
  echo "ERRO: $1" >&2
  exit 1
}

verificar_origem() {
  if [ ! -d "$FONTE" ]; then
    erro "Diretório de origem '$FONTE' não encontrado."
  fi
  registrar "Origem verificada: $FONTE"
}

criar_destino() {
  if [ ! -d "$BACKUP_DIR" ]; then
    registrar "Criando diretório de backup..."
    mkdir -p "$BACKUP_DIR"
  fi
}

fazer_backup_codigo() {
  local destino="$BACKUP_DIR/scripts_$DATA"
  registrar "Iniciando backup do código-fonte..."

  cp -r "$FONTE" "$destino" 2>> "$LOG_FILE"
  registrar "Backup do código salvo em: $destino"
}

fazer_backup_banco() {
  local destino="$BACKUP_DIR/banco_$DATA.sql"
  registrar "Simulando backup do banco de dados..."

  echo "-- Backup simulado em $DATA" > "$destino"
  echo "-- Banco: projeto_so" >> "$destino"
  echo "-- Tabelas: usuarios, logs, configuracoes" >> "$destino"
  registrar "Backup do banco salvo em: $destino"
}

listar_backups() {
  registrar "Backups disponíveis:"
  # Pipe (seção 11 do caderno)
  ls -lh "$BACKUP_DIR" | tee -a "$LOG_FILE"
}

registrar "===== INÍCIO DO BACKUP ====="

verificar_origem
criar_destino
fazer_backup_codigo
fazer_backup_banco
listar_backups

registrar "===== FIM DO BACKUP ====="