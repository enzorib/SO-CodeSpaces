# Relatório — Como os scripts facilitam o ciclo de desenvolvimento

## Introdução

Durante o desenvolvimento de um projeto, várias tarefas precisam ser feitas
repetidamente: monitorar o servidor, fazer backups, configurar o ambiente e
gerenciar serviços. Fazer isso manualmente toda vez é lento e sujeito a erro.
Os scripts desenvolvidos nesse trabalho automatizam essas tarefas.

## Scripts e suas funções

### monitor.sh
Sem o script, verificar CPU, memória e disco exigiria rodar vários comandos
separados e anotar os resultados manualmente. Com o script, uma única execução
coleta tudo e salva automaticamente em log com timestamp, permitindo acompanhar
o histórico do sistema ao longo do tempo.

### backup.sh
Fazer backup manual é uma tarefa fácil de esquecer. O script automatiza a cópia
dos arquivos do projeto e simula o dump do banco de dados, salvando tudo com
data e hora no nome. Isso garante que sempre exista uma versão recente salva.

### process_manager.sh
Gerenciar serviços manualmente exige lembrar de PIDs e comandos específicos.
O script centraliza isso em uma interface simples de start, stop, status e
restart, além de registrar tudo em log para facilitar a identificação de falhas.

### setup.sh
Configurar um ambiente do zero em uma máquina nova pode levar horas. O script
automatiza a verificação e instalação das dependências necessárias, garantindo
que qualquer desenvolvedor consiga preparar o ambiente com um único comando.

## Conceitos aplicados

- **Pipes**: usados para encadear comandos como `top | grep | awk`
- **Redirecionamento**: logs salvos com `>>` e erros separados com `2>`
- **Variáveis de ambiente**: `JAVA_HOME` configurado automaticamente no `.bashrc`
- **Cron jobs**: agendamento do monitor e backup definido em `cronjobs.txt`
- **Permissões**: todos os scripts com `chmod +x` para execução direta

## Conclusão

A automação com shell scripts reduz erros humanos, economiza tempo e padroniza
os processos do projeto. Tarefas que levariam minutos manuais passam a ser
executadas em segundos com um único comando.