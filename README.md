# SO-CodeSpaces — Infraestrutura e Automação com Linux

Scripts Shell/Bash para automação de tarefas do ambiente de desenvolvimento do app Android (Clínica Maya).

## Scripts

### monitor.sh
Coleta métricas do sistema (CPU, memória e disco) e salva em arquivo de log com timestamp.
```bash
bash scripts/monitor.sh
```

### backup.sh
Faz backup dos scripts, arquivos Gradle e banco de dados SQLite do projeto. Se nenhum banco for encontrado, gera um backup simulado.
```bash
bash scripts/backup.sh
```

### process_manager.sh
Gerencia serviços do backend com os comandos start, stop, status e restart.
```bash
bash scripts/process_manager.sh start backend
bash scripts/process_manager.sh status backend
bash scripts/process_manager.sh restart backend
bash scripts/process_manager.sh stop backend
```

### setup.sh
Verifica e instala as dependências do ambiente de desenvolvimento Android: Java, Gradle, Android SDK, ADB e outras ferramentas.
```bash
bash scripts/setup.sh
```

## Estrutura de pastas
```
SO-CodeSpaces/
├── scripts/   # scripts principais
├── logs/      # logs gerados automaticamente
├── backups/   # backups gerados pelo backup.sh
└── pids/      # controle de processos do process_manager
```

## Conceitos utilizados

- **Pipes**: encadeamento de comandos como `top | grep | awk`
- **Redirecionamento**: logs salvos com `>>` e erros separados com `2>`
- **Variáveis de ambiente**: `JAVA_HOME` e `ANDROID_HOME` configurados no `.bashrc`
- **Cron jobs**: agendamento definido em `cronjobs.txt` para rodar em servidor real
- **Permissões**: todos os scripts com `chmod +x` para execução direta