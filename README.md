# SO-CodeSpaces

# Infraestrutura e Automação com Linux

Scripts Shell/Bash para automação de tarefas do ambiente de desenvolvimento.

## Scripts

### monitor.sh
Coleta métricas do sistema (CPU, memória e disco) e salva em um arquivo de log com timestamp.
```bash
bash scripts/monitor.sh
```

### backup.sh
Faz backup dos scripts do projeto e simula um backup do banco de dados. Os arquivos são salvos com data e hora no nome.
```bash
bash scripts/backup.sh
```

### process_manager.sh
Gerencia serviços do backend. Aceita os comandos start, stop, status e restart.
```bash
bash scripts/process_manager.sh start backend
bash scripts/process_manager.sh status backend
bash scripts/process_manager.sh restart backend
bash scripts/process_manager.sh stop backend
```

### setup.sh
Verifica e instala as dependências do ambiente (Java, git, curl, wget, unzip) e configura o JAVA_HOME.
```bash
bash scripts/setup.sh
```

## Estrutura de pastas
```
projeto-so/
├── scripts/   # scripts principais
├── logs/      # logs gerados automaticamente
├── backups/   # backups gerados pelo backup.sh
└── pids/      # controle de processos do process_manager
```

## Conceitos utilizados

- Pipes
- Redirecionamento de saída
- Variáveis de ambiente
- Cron jobs
- Permissões de arquivo