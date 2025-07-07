# Projeto: Servidor Web com Monitoramento e Alertas na AWS

Este repositório documenta e fornece os scripts realizados durante o projeto Linux do Programa de Bolsas DevSecOps. O objetivo principal é implantar um ambiente web robusto na nuvem da AWS, configurar monitoramento contínuo para sua disponibilidade e automatizar o envio de alertas em caso de falha.

## 🚀 Tecnologias Utilizadas

Este projeto faz uso das seguintes tecnologias e serviços:

*   **AWS (Amazon Web Services):**
    *   **VPC (Virtual Private Cloud):** Para a criação de uma rede virtual isolada e segura na nuvem.
    *   **EC2 (Elastic Compute Cloud):** Como servidor virtual principal para hospedar a aplicação web.
    *   **Security Groups:** Atuam como firewalls virtuais para controlar o tráfego de entrada e saída das instâncias EC2.
*   **Linux (Ubuntu/Amazon Linux):** Sistema operacional base para o servidor EC2.
*   **Nginx:** Servidor web de alto desempenho, utilizado para servir a página HTML.
*   **Bash Scripting:** Essencial para o desenvolvimento do script de monitoramento personalizado.
*   **Cron:** Ferramenta de agendamento de tarefas para automatizar a execução do script de monitoramento.
*   **Discord:** Plataforma de comunicação utilizada para o recebimento de alertas em tempo real (outras opções como Telegram ou Slack também são possíveis).

---

## 📋 Pré-requisitos

Antes de iniciar o projeto, certifique-se de ter:

*   Uma conta ativa na AWS.
*   Conhecimento básico em Linux e linha de comando.
*   Um cliente SSH instalado em sua máquina local.
*   Acesso à internet.

---

## 🛠️ Etapas de Configuração

As etapas a seguir detalham o processo de configuração do ambiente, desde a infraestrutura na AWS até o monitoramento e alertas.

### Etapa 1: Configuração do Ambiente AWS

Esta etapa foca na criação da infraestrutura de rede e do servidor na AWS.

#### 1.1. Criação da VPC (Virtual Private Cloud)

Uma VPC é uma rede virtual isolada que permite provisionar uma seção logicamente isolada da AWS Cloud onde você pode executar seus recursos da AWS em uma rede virtual que você define.

1.  **Acesse o Console da AWS:** Faça login na sua conta AWS e navegue até o serviço de VPC.
2.  **Utilize o Assistente "VPC e mais":** Esta é a abordagem recomendada para criar uma VPC com todos os componentes essenciais (sub-redes, tabelas de rotas, Internet Gateway).
3.  **Configurações Detalhadas:**
    *   **Nome:** Atribua um nome descritivo à sua VPC (ex: `minha-vpc`).
    *   **Bloco CIDR IPv4:** Defina um intervalo de endereços IP para sua VPC (ex: `10.0.0.0/16`).
    *   **Sub-redes:** Crie no mínimo duas sub-redes públicas em diferentes Zonas de Disponibilidade para garantir alta disponibilidade e resiliência, **e duas sub-redes privadas para futuras expansões.**
    *   **Internet Gateway:** Assegure-se de que um Internet Gateway seja criado e anexado à sua VPC para permitir a comunicação com a internet.
    *   **Tabelas de Rotas:** Confirme se as tabelas de rotas estão configuradas corretamente para direcionar o tráfego de internet para as sub-redes públicas.

#### 1.2. Criação da Instância EC2 (Elastic Compute Cloud)

Uma instância EC2 é um servidor virtual escalável na nuvem da AWS.

1.  **Acesse o Console do EC2:** No console da AWS, navegue até o serviço EC2.
2.  **Lance uma Nova Instância:**
    *   **Nome e Tags:** Atribua um nome à sua instância (ex: `servidor-web-nginx`) e adicione tags relevantes para organização.
    *   **AMI (Amazon Machine Image):** Escolha uma AMI adequada, como `Ubuntu Server` (recomendado para este projeto) ou `Amazon Linux`.
    *   **Tipo de Instância:** Selecione um tipo de instância que se alinhe às suas necessidades. O `t2.micro` é uma excelente opção para começar, pois geralmente está incluído no nível gratuito da AWS.
    *   **Par de Chaves:** Crie um novo par de chaves SSH ou utilize um existente. **É crucial fazer o download do arquivo `.pem` e armazená-lo em um local seguro**, pois ele será necessário para acessar a instância via SSH.
    *   **Configurações de Rede:**
        *   **VPC:** Selecione a VPC criada na etapa anterior.
        *   **Sub-rede:** Escolha uma das sub-redes públicas disponíveis.
        *   **Atribuir IP público automaticamente:** Habilite esta opção para que a instância receba um endereço IP público, tornando-a acessível pela internet.
    *   **Security Group:** Crie um novo Security Group para atuar como firewall da sua instância. Configure as seguintes regras de entrada (inbound rules):
        *   **SSH (porta 22):** Permita o tráfego SSH apenas do seu endereço IP (ou de um intervalo de IPs específico) para garantir acesso seguro.
        *   **HTTP (porta 80):** Permita o tráfego HTTP de qualquer lugar (`0.0.0.0/0`) para que seu site seja publicamente acessível.
3.  **Lance a Instância:** Revise todas as configurações e, se estiverem corretas, prossiga com o lançamento da instância.

#### 1.3. Acesso Via SSH

Após a instância EC2 estar em execução, você pode se conectar a ela usando SSH através do terminal:

```bash
# Altere as permissões do seu arquivo de chave .pem para torná-lo seguro
chmod 400 ~/.ssh/minha-chave.pem

# Conecte-se à sua instância EC2. Substitua SEU_IP_PUBLICO pelo IP real da sua instância.
ssh -i ~/.ssh/minha-chave.pem ubuntu@SEU_IP_PUBLICO
```

*Certifique-se de substituir `~/.ssh/minha-chave.pem` pelo caminho real do seu arquivo de chave e `SEU_IP_PUBLICO` pelo endereço IP público da sua instância EC2.*

### Etapa 2: Configuração do Servidor Web (Nginx)

Nginx é um servidor web de código aberto que também pode ser usado como proxy reverso, balanceador de carga e proxy HTTP para e-mail.

#### 2.1. Instalação e Configuração do Nginx

Com a conexão SSH estabelecida, execute os seguintes comandos para instalar e configurar o Nginx:

```bash
# Atualize a lista de pacotes do sistema
sudo apt update -y

# Instale o Nginx
sudo apt install nginx -y

# Inicie o serviço Nginx
sudo systemctl start nginx

# Habilite o Nginx para iniciar automaticamente no boot do sistema
sudo systemctl enable nginx
```

#### 2.2. Criação da Página Web

Crie um arquivo `index.html` simples que será servido pelo Nginx. Você pode criar este arquivo diretamente na instância ou transferi-lo da sua máquina local.

  *   **Criando diretamente na instância:**

    ```bash
    sudo bash -c 'echo "<h1>Bem-vindo ao meu Servidor Web!</h1><p>Projeto final DevSecOps.</p>" > /var/www/html/index.html'
    ```

  *   **Transferindo via SCP (se você tiver um arquivo local):**

    ```bash
    # Transfere o arquivo para o diretório temporário na instância
    scp -i ~/.ssh/minha-chave.pem ./index.html ubuntu@SEU_IP_PUBLICO:/tmp/index.html

    # Conecta via SSH e move o arquivo para o diretório do Nginx
    ssh -i ~/.ssh/minha-chave.pem ubuntu@SEU_IP_PUBLICO "sudo mv /tmp/index.html /var/www/html/index.html"
    ```

### Etapa 3: Monitoramento e Notificações

Esta etapa detalha a configuração do script de monitoramento e o agendamento para alertas automáticos.

#### 3.1. Script de Monitoramento

Crie o arquivo do script de monitoramento. Este script verificará a disponibilidade do Nginx e enviará alertas.

1.  **Crie o diretório para o projeto:**

    ```bash
    sudo mkdir -p /root/projeto
    ```

2.  **Crie o arquivo do script:**

    ```bash
    sudo nano /usr/local/bin/monitoramento.sh
    ```

3.  **Cole o conteúdo do seu script de monitoramento no arquivo `monitoramento.sh`**. Salve e saia (Ctrl+X, Y, Enter no `nano`).

4.  **Torne o script executável:**

    ```bash
    sudo chmod +x /usr/local/bin/monitoramento.sh
    ```

#### 3.2. Arquivo de Configuração

Este arquivo armazenará variáveis de ambiente sensíveis, como o webhook do Discord.

1.  **Crie o arquivo de configuração:**

    ```bash
    sudo nano /caminho/para/config.sh # Caminho atualizado
    ```

2.  **Adicione suas variáveis de ambiente ao arquivo `config.sh`**. Exemplo:

    ```bash
    #!/bin/bash
    DISCORD_WEBHOOK_URL="SUA_URL_DO_WEBHOOK_DISCORD"
    LOG_FILE="/var/log/monitoramento.log"
    SITE_URL="http://SEU_IP_PUBLICO_DA_INSTANCIA_EC2"
    ```

    *Substitua `SUA_URL_DO_WEBHOOK_DISCORD` pela URL real do webhook do seu canal do Discord e `http://SEU_IP_PUBLICO_DA_INSTANCIA_EC2` pela URL do seu site.*

3.  **Proteja o arquivo de configuração:**

    *   É crucial restringir as permissões deste arquivo para que apenas o proprietário (root) possa lê-lo e escrevê-lo, garantindo a segurança das informações sensíveis.

    ```bash
    sudo chmod 600 /caminho/para/config.sh # Caminho atualizado
    ```

#### 3.3. Agendamento com Cron

O Cron é um daemon de agendamento de tarefas baseado em tempo em sistemas operacionais tipo Unix. Para automatizar a execução do script de monitoramento a cada minuto:

1.  **Edite o crontab do usuário `root`:**

    ```bash
    sudo crontab -e
    ```

2.  **Adicione a seguinte linha no final do arquivo:**

    ```cron
    * * * * * /usr/local/bin/monitoramento.sh > /dev/null 2>&1
    ```

    Esta entrada fará com que o script `/usr/local/bin/monitoramento.sh` seja executado a cada minuto. O redirecionamento `> /dev/null 2>&1` descarta a saída padrão e os erros, evitando o preenchimento excessivo do log.

#### 3.4. Lógica do Script `monitoramento.sh`

O script `monitoramento.sh` foi projetado para verificar a disponibilidade do seu servidor web (Nginx) e enviar notificações automáticas para um canal do Discord em caso de falha ou recuperação.

A lógica do script pode ser dividida nas seguintes partes:

  *   **1. Inclusão do Arquivo de Configuração (`config.sh`):**

      *   No início, o script tenta incluir o arquivo `config.sh` (localizado em `/caminho/para/config.sh` - *atenção: este é um placeholder e deve ser substituído pelo caminho real onde você salvará o arquivo*). Este arquivo é crucial, pois contém variáveis sensíveis como a URL do webhook do Discord (`DISCORD_WEBHOOK_URL`), o caminho do arquivo de log (`LOG_FILE`) e a URL do site a ser monitorado (`SITE_URL`). Se o `config.sh` não for encontrado ou acessível, o script exibirá uma mensagem de erro e será encerrado, pois não poderá operar sem as configurações necessárias.

  *   **2. Variáveis de Configuração Internas:**

      *   `SITE_NAME`: Uma variável interna (`"Meu Servidor Web Principal"`) é usada para identificar o site nas mensagens de log e nas notificações, tornando-as mais amigáveis.

  *   **3. Funções Auxiliares:**

      *   **`log_message(TYPE, MESSAGE)`:** Esta função é responsável por registrar eventos no arquivo de log especificado em `config.sh`. Ela formata cada entrada com um timestamp, o tipo da mensagem (ex: "INFO", "ALERTA") e o conteúdo da mensagem. Utiliza `sudo tee -a` para garantir que a mensagem seja adicionada ao final do arquivo de log, mesmo que o script seja executado como um usuário que não tenha permissões diretas de escrita no diretório do log (como `/var/log`).

      *   **`send_discord_notification(MESSAGE)`:** Esta função é encarregada de enviar as mensagens de alerta para o Discord. Primeiro, verifica se a `DISCORD_WEBHOOK_URL` está configurada. Se não estiver, registra um erro e não tenta enviar a notificação. Usa o comando `curl` para fazer uma requisição HTTP POST para a URL do webhook do Discord. O corpo da requisição é um JSON que inclui um `username` (o nome do bot que aparece no Discord) e o `content` (o texto da notificação).

  *   **4. Lógica Principal de Monitoramento:**

      *   O script utiliza `curl` para tentar acessar a `SITE_URL` (definida em `config.sh`) e obter o código de status HTTP.

      *   `curl -o /dev/null -s -w "%{http_code}" "$SITE_URL"`: Este comando tenta acessar a URL.
          *   `-o /dev/null`: Descarta o corpo da resposta HTTP (não precisamos do conteúdo da página).
          *   `-s`: Executa o `curl` em modo silencioso.
          *   `-w "%{http_code}"`: Faz com que o `curl` imprima apenas o código de status HTTP da resposta (ex: `200`, `404`, `500`).
      *   O código de status HTTP retornado é armazenado na variável `HTTP_STATUS`.
      *   **Verificação de Status:**
          *   Se `HTTP_STATUS` for `200` (indicando que o site está online e funcionando corretamente), o script registra uma mensagem "INFO" no log informando que o site está online.
          *   Se `HTTP_STATUS` *não* for `200` (indicando uma falha ou um problema), o script:
              *   Registra uma mensagem de "ALERTA" no log, indicando que o site está offline e qual foi o código de erro.
              *   Formata uma `NOTIFICATION_MESSAGE` específica (ex: "O site [Nome do Site] está fora do ar! (Código HTTP: 'XXX').").
              *   Chama a função `send_discord_notification` para enviar esta mensagem de alerta para o canal do Discord.

Em resumo, o script é um monitor de disponibilidade simples, mas eficaz, que automatiza o processo de detecção de falhas no servidor web e a comunicação de tais eventos via Discord, mantendo um registro detalhado em um arquivo de log.

-----

## 🧪 Etapa 4: Testes e Validação

Para garantir que todas as configurações estão funcionando conforme o esperado, realize os seguintes testes:

  *   **Verificar o log do monitoramento:** `tail -f /var/log/monitoramento.log`
    Acompanhe este log para ver as saídas do script de monitoramento e confirmar se ele está sendo executado regularmente e registrando o status do Nginx.

  *   **Simular uma falha no Nginx:** `sudo systemctl stop nginx`
    Após parar o Nginx, você deve receber um alerta no Discord em até um minuto (devido ao agendamento do cron).

  *   **Verificar as notificações no Discord:**
    Confirme se as mensagens de alerta (e posteriormente de recuperação) estão sendo recebidas no canal do Discord configurado.

  *   **Restaurar o serviço Nginx:** `sudo systemctl start nginx`
    Após reiniciar o Nginx, o script de monitoramento deve detectar que o serviço está online novamente e enviar uma notificação de recuperação para o Discord.

-----

## 📚 Considerações Finais e Próximos Passos

  *   **Segurança:** Sempre revise as regras dos Security Groups e garanta que apenas o tráfego necessário é permitido. Utilize chaves SSH com permissões restritas.
  *   **Escalabilidade:** Para ambientes de produção, considere o uso de Auto Scaling Groups e Load Balancers para alta disponibilidade e escalabilidade.
  *   **Monitoramento Avançado:** Explore serviços AWS como CloudWatch para métricas e logs mais detalhados, e SNS para notificações em múltiplos canais.
  *   **Infraestrutura como Código (IaC):** Para gerenciar a infraestrutura de forma mais eficiente e repetível, considere o uso de ferramentas IaC como AWS CloudFormation ou Terraform.
  *   **Otimização de Custos:** Monitore o uso de seus recursos AWS para otimizar custos, especialmente após o período de nível gratuito.

Este projeto oferece uma base sólida para a implantação e monitoramento de aplicações web na AWS. Sinta-se à vontade para expandi-lo e adaptá-lo às suas necessidades específicas!

