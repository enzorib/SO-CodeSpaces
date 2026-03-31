# Relatório — Como os scripts facilitam o ciclo de desenvolvimento

## Introdução

O projeto Clínica Maya é um aplicativo Android desenvolvido em Java no Android Studio.
Durante o desenvolvimento, várias tarefas precisam ser feitas repetidamente: monitorar
o servidor, fazer backups, configurar o ambiente e gerenciar serviços. Fazer isso
manualmente toda vez é lento e sujeito a erro. Os scripts desenvolvidos nesse trabalho
automatizam essas tarefas usando conceitos vistos em aula.

## Scripts e suas funções

### monitor.sh
Coleta métricas de CPU, memória e disco em loop, fazendo 5 coletas com intervalo de
3 segundos entre cada uma. Além das métricas do sistema, verifica se o Gradle está
rodando durante o build do app e se o ADB está conectado a algum dispositivo ou
emulador. Dispara alertas automáticos no log quando CPU passa de 80%, memória de 85%
ou disco de 90%.

### backup.sh
Automatiza o backup dos scripts do projeto, dos arquivos de configuração do Gradle
e do banco de dados SQLite usado pelo app. Se nenhum banco for encontrado, gera um
backup simulado com a estrutura do banco da Clínica Maya. Todos os arquivos são
salvos com data e hora no nome, garantindo um histórico de versões.

### process_manager.sh
Gerencia três tipos de serviço: backend, Gradle e ADB. Para cada um, suporta os
comandos start, stop, status e restart. O status do ADB mostra quantos dispositivos
estão conectados, o Gradle usa seus próprios comandos nativos e o backend é controlado
via PID. Tudo é registrado em log com timestamp.

### setup.sh
Automatiza a configuração do ambiente de desenvolvimento Android do zero. Verifica e
instala Java, Gradle, Android SDK command line tools e ADB. Configura as variáveis
de ambiente JAVA_HOME e ANDROID_HOME automaticamente no .bashrc, deixando o ambiente
pronto para buildar o app com um único comando.

## Conceitos aplicados

- **Pipes**: usados para encadear comandos como `top | grep | awk` e `find | while read`
- **Redirecionamento**: logs salvos com `>>`, erros separados com `2>` e arquivos criados com `>`
- **Variáveis de ambiente**: `JAVA_HOME` e `ANDROID_HOME` configurados automaticamente no `.bashrc`
- **Permissões**: todos os scripts recebem `chmod +x` para execução direta sem precisar chamar o bash explicitamente

## Conclusão

A automação com shell scripts reduz erros humanos, economiza tempo e padroniza os
processos do projeto. Com os quatro scripts desenvolvidos, tarefas que levariam
minutos manuais passam a ser executadas em segundos, facilitando o ciclo de
desenvolvimento do app Clínica Maya.