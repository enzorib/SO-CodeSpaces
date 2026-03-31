#!/bin/bash
set -euo pipefail
# setup.sh - verifica e instala as dependencias do ambiente de desenvolvimento Android

LOG_FILE="$HOME/projeto-so/logs/setup.log"
JAVA_VERSION="17"
ANDROID_SDK_DIR="$HOME/android-sdk"

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

logMsg "verificando gradle..."
if command -v gradle &> /dev/null; then
  logMsg "gradle ja instalado: $(gradle --version | head -n1)"
else
  logMsg "instalando gradle..."
  sudo apt-get install -y gradle >> "$LOG_FILE" 2>&1
  logMsg "gradle instalado!"
fi

logMsg "verificando android sdk..."
if [ -d "$ANDROID_SDK_DIR" ]; then
  logMsg "android sdk ja configurado em: $ANDROID_SDK_DIR"
else
  logMsg "baixando android sdk command line tools..."
  mkdir -p "$ANDROID_SDK_DIR"
  cd /tmp
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdtools.zip
  unzip -q cmdtools.zip -d "$ANDROID_SDK_DIR"
  mkdir -p "$ANDROID_SDK_DIR/cmdline-tools/latest"
  mv "$ANDROID_SDK_DIR/cmdline-tools/"* "$ANDROID_SDK_DIR/cmdline-tools/latest/" 2>/dev/null || true
  cd "$HOME/projeto-so"
  logMsg "android sdk baixado em: $ANDROID_SDK_DIR"
fi

logMsg "configurando ANDROID_HOME..."
export ANDROID_HOME="$ANDROID_SDK_DIR"
if ! grep -q "ANDROID_HOME" ~/.bashrc; then
  echo "export ANDROID_HOME=$ANDROID_SDK_DIR" >> ~/.bashrc
  echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> ~/.bashrc
  echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> ~/.bashrc
  logMsg "ANDROID_HOME adicionado no .bashrc"
else
  logMsg "ANDROID_HOME ja configurado"
fi

logMsg "verificando adb..."
if command -v adb &> /dev/null; then
  logMsg "adb ja instalado: $(adb --version | head -n1)"
else
  logMsg "instalando adb..."
  sudo apt-get install -y adb >> "$LOG_FILE" 2>&1
  logMsg "adb instalado!"
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
gradle --version 2>&1 | head -n1 | tee -a "$LOG_FILE" || true
git --version | tee -a "$LOG_FILE" || true

logMsg "=== setup finalizado ==="
logMsg "rode 'source ~/.bashrc' pra aplicar as variaveis"