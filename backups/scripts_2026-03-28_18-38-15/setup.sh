#!/bin/bash
# setup.sh - verifica e instala as dependencias do ambiente de desenvolvimento
set -euo pipefail
LOG_FILE="$HOME/projeto-so/logs/setup.log"
JAVA_VERSION="17"

logMsg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

logMsg "=== iniciando setup ==="

logMsg "verificando java..."
if command -v java &> /dev/null; then
  logMsg "java ja instalado: $(java -version 2>&1 | head -n1)"
else
  logMsg "instalando java $JAVA_VERSION..."
  sudo apt-get update -y >> "$LOG_FILE" 2>&1
  sudo apt-get install -y "openjdk-$JAVA_VERSION-jdk" >> "$LOG_FILE" 2>&1
  logMsg "java instalado!"
fi

logMsg "configurando JAVA_HOME..."
java_path=$(readlink -f "$(which java)" | xargs dirname | xargs dirname)
export JAVA_HOME="$java_path"
if ! grep -q "JAVA_HOME" ~/.bashrc; then
  echo "export JAVA_HOME=$java_path" >> ~/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
  logMsg "JAVA_HOME adicionado no .bashrc"
else
  logMsg "JAVA_HOME ja configurado"
fi

logMsg "verificando outras ferramentas..."
for ferramenta in git curl wget unzip; do
  if command -v "$ferramenta" &> /dev/null; then
    logMsg "$ferramenta ok"
  else
    logMsg "instalando $ferramenta..."
    sudo apt-get install -y "$ferramenta" >> "$LOG_FILE" 2>&1
  fi
done

logMsg "versoes instaladas:"
java -version 2>&1 | tee -a "$LOG_FILE" || true
git --version | tee -a "$LOG_FILE" || true

logMsg "=== setup finalizado ==="
logMsg "rode 'source ~/.bashrc' pra aplicar as variaveis"