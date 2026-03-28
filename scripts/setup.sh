set -euo pipefail


LOG_FILE="$HOME/projeto-so/logs/setup.log"
JAVA_VERSION="17"


registrar() {
  local mensagem="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$LOG_FILE"
}

erro() {
  echo "ERRO: $1" >&2
  exit 1
}

verificar_instalado() {
  local programa="$1"
  if command -v "$programa" &> /dev/null; then
    registrar "$programa já está instalado: $(command -v $programa)"
    return 0
  else
    return 1
  fi
}

instalar_java() {
  registrar "Verificando Java..."

  if verificar_instalado java; then
    java -version 2>&1 | tee -a "$LOG_FILE"
    return
  fi

  registrar "Instalando Java $JAVA_VERSION..."
  sudo apt-get update -y >> "$LOG_FILE" 2>&1
  sudo apt-get install -y "openjdk-$JAVA_VERSION-jdk" >> "$LOG_FILE" 2>&1
  registrar "Java instalado com sucesso!"
}

configurar_java_home() {
  registrar "Configurando JAVA_HOME..."

  local java_path
  java_path=$(dirname $(dirname $(readlink -f $(which java))))
  export JAVA_HOME="$java_path"

  if ! grep -q "JAVA_HOME" ~/.bashrc; then
    echo "export JAVA_HOME=$java_path" >> ~/.bashrc
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
    registrar "JAVA_HOME configurado em ~/.bashrc: $java_path"
  else
    registrar "JAVA_HOME já configurado em ~/.bashrc"
  fi
}

instalar_ferramentas_build() {
  registrar "Verificando ferramentas de build..."

  for ferramenta in git curl wget unzip; do
    if verificar_instalado "$ferramenta"; then
      registrar "$ferramenta OK"
    else
      registrar "Instalando $ferramenta..."
      sudo apt-get install -y "$ferramenta" >> "$LOG_FILE" 2>&1
      registrar "$ferramenta instalado!"
    fi
  done
}

verificar_ambiente() {
  registrar "Verificando ambiente final..."

  echo "--- Versões instaladas ---" | tee -a "$LOG_FILE"
  java -version 2>&1 | tee -a "$LOG_FILE" || true
  git --version | tee -a "$LOG_FILE" || true
  curl --version | head -n 1 | tee -a "$LOG_FILE" || true

  registrar "JAVA_HOME: ${JAVA_HOME:-não configurado}"
  registrar "PATH: $PATH"
}


registrar "===== INÍCIO DO SETUP DO AMBIENTE ====="

instalar_java
configurar_java_home
instalar_ferramentas_build
verificar_ambiente

registrar "===== SETUP CONCLUÍDO ====="
registrar "Execute 'source ~/.bashrc' para aplicar as variáveis de ambiente."