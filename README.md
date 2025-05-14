# 🐳 Ambiente Dockerizado em Linux - TOTVS Protheus 12.1.2410 com SmartView e PostgreSQL

Este projeto oferece um ambiente completo e containerizado do ERP **TOTVS Protheus 12.1.2410** com **SmartView** e **PostgreSQL 16**, utilizando imagens Docker personalizadas e otimizadas para distribuições Linux.


## 📁 Estrutura recomendada do repositório

```bash
brust-protheus2410-smartview-docker-linux-postgres/
.
├── .git/
├── certificate/
├── img_dbaccess/
├── img_license/
├── img_postgres/
├── img_protheus/
├── img_smartview/
├── postgres-data/
├── totvs/
├── .gitignore
├── 1_postgres_image.sh
├── 2_license_server_image.sh
├── 3_dbaccess_image.sh
├── 4_protheus_image.sh
├── 5_smartview_image.sh
├── apprest_container.sh
├── appserver_container.sh
├── dbaccess_container.sh
├── docker-compose.override_modelo.yml
├── docker-compose.yml
├── LICENSE
├── README.md
└── totvs_all_image.sh

```

---

## 🚀 Visão Geral

Este repositório contém os arquivos de configuração e scripts necessários para subir um ambiente **TOTVS Protheus 12.1.2410 com SmartView e PostgreSQL**, totalmente containerizado com Docker.

---

## 📦 Imagens Docker

### 📥 Imagens Docker disponíveis

| Serviço        | Descrição                                         | Imagem Docker                                                              |
|----------------|---------------------------------------------------|----------------------------------------------------------------------------|
| PostgreSQL     | Banco com init dbProtheus + SmartView (Debian 12) | `eduardobrust/...:dbProtheus-dbSmarView-debian12`                          |
| License Server | TOTVS License Server (OpenSUSE 15.6)              | `eduardobrust/...:licenseserver-opensuse15.6`                              |
| DbAccess       | Acesso ao banco de dados (Oracle Linux 9)         | `eduardobrust/...:dbaccess-oracleLinux9`                                   |
| Protheus       | ERP Protheus 12.1.2410 (OpenSUSE 15.6)            | `eduardobrust/...:protheus2410-opensuse15.6`                               |
| SmartView      | Interface de visualização (Oracle Linux 9)        | `eduardobrust/...:smartview-oraclelinux9`                                  |


## Como baixar as imagens Docker

Para rodar o ambiente do Protheus 12.1.2410 com SmartView e PostgreSQL, você precisará baixar várias imagens Docker. 
Abaixo estão os comandos necessários para baixar cada serviço, seguido de uma breve explicação sobre o que cada um faz:

### 1. Baixar a imagem do PostgreSQL com Banco do Protheus e SmartView usando Distro Debian 12

Essa imagem contém o ambiente configurado para o banco de dados do Protheus com o SmartView, rodando em Debian 12.

📦 **Imagem:** `eduardobrust/brust-protheus2410-smartview-linux-postgres:dbProtheus-dbSmarView-debian12`
🐧 **Distro:** Debian GNU/Linux 12
🔒 **Separação lógica:** O Protheus e o SmartView usam aliases distintos (`dbprotheus` e `dbSmartView`) no mesmo container para simular bancos independentes.
🌐 **Portas expostas:** 5433

```bash
docker pull eduardobrust/brust-protheus2410-smartview-linux-postgres:dbProtheus-dbSmarView-debian12
```

### 2. Baixar a imagem do License Server para OpenSUSE 15.6

Essa imagem contém o License Server do Protheus, configurado para rodar em OpenSUSE 15.6.

📦 **Imagem:** `eduardobrust/brust-protheus2410-smartview-linux-postgres:licenseserver-opensuse15.6`
🐧 **Distro:** OpenSUSE Leap 15.6
🔗 **Função:** Garante a licença de uso dos produtos TOTVS no ambiente isolado.
🌐 **Portas expostas:** 2236 / 5556 / 8050

```bash
docker pull eduardobrust/brust-protheus2410-smartview-linux-postgres:licenseserver-opensuse15.6
```

### 3. Baixar a imagem do DbAccess para Oracle Linux 9

Essa imagem contém o DbAccess, a camada de acesso ao banco de dados, configurado para Oracle Linux 9.

📦 **Imagem:** `eduardobrust/brust-protheus2410-smartview-linux-postgres:dbaccess-oracleLinux9`
🐧 **Distro:** Oracle Linux 9
🔄 **Dependências:** Inicia somente após o banco e o license server
💬 **Função:** Estabelece a conexão entre o AppServer e os bancos configurados (via ODBC e portas mapeadas).
🌐 **Portas expostas:** 7892 / 7893

```bash
docker pull eduardobrust/brust-protheus2410-smartview-linux-postgres:dbaccess-oracleLinux9
```

### 4. Baixar a imagem do Protheus 2410 para OpenSUSE 15.6
Essa imagem contém o ambiente Protheus 12.1.2410, configurado para rodar em OpenSUSE 15.6.

📦 **Imagem:** `eduardobrust/brust-protheus2410-smartview-linux-postgres:protheus2410-opensuse15.6`
🐧 **Distro:** OpenSUSE 15.6
🔄 **Dependências:** Inicia somente após o banco, license server e dbaccess
🎯 **Função:** Executa os serviços principais da Release 12.1.2410
🌐 Portas expostas: 1101 / 1102 / 9003 / 9090 / 21021

```bash
docker pull eduardobrust/brust-protheus2410-smartview-linux-postgres:protheus2410-opensuse15.6
```

### 5. Baixar a imagem do SmartView para Oracle Linux 9
Essa imagem contém o ambiente do SmartView configurado para rodar em Oracle Linux 9, permitindo a visualização e interação com o sistema Protheus.

📦 **Imagem:** `eduardobrust/brust-protheus2410-smartview-linux-postgres:smartview-oraclelinux9`
🐧 **Distro:** Oracle Linux 9
🔄 **Dependências:** Inicia somente após o banco, license server, dbaccess , Protheus
🧱 **Separação completa:** Utiliza banco, dbaccess e license independentes
🌐 **Portas expostas:** 7019 / 7017

```bash
docker pull eduardobrust/brust-protheus2410-smartview-linux-postgres:smartview-oraclelinux9
```

### 📌 Observação
Antes de rodar esses comandos, certifique-se de que o Docker está instalado e configurado corretamente em sua máquina. Cada um desses serviços é necessário para montar o ambiente completo do Protheus com SmartView e PostgreSQL.
---

## ✅ Pré-requisitos

* 🐳 Docker instalado
* 💻 Bash (Linux, WSL ou Git Bash no Windows)

---

### 🧪 Compatibilidade testada

- Docker Engine: 24.0+
- Docker Compose: 2.20+
- WSL2 no Windows 11 PRO
- Sistemas baseados em Linux (Debian, Oracle Linux, OpenSUSE)
- Ubuntu como Host - Tive problemas no license Server de Ulimit *

---

## 🛠️ Como usar

### 1. Clone o repositório

```bash
git clone https://github.com/eduardobrust/brust-protheus2410-smartview-docker-linux-postgres.git
cd brust-protheus2410-smartview-docker-linux-postgres
```

### 2. Descrição dos Scripts para geração das Imagens

```bash
./1_postgres_image.sh           # 🔧 Builda e sobe a imagem do PostgreSQL
./2_license_server_image.sh     # 🔧 Builda e sobe a imagem do Totvs License Server
./3_dbaccess_image.sh           # 🔧 Builda e sobe a imagem do Totvs Dbaccess
./4_protheus_image.sh           # 🔧 Builda e sobe a imagem do Protheus 2410
./5_smartview_image.sh          # 🔧 Builda e sobe a imagem do Smart View
./totvs_all_image.sh            # 🔧 Builda e sobe todas as imagens seguindo a ordem acima 
```
---

### 3. Comandos rápidos para geração das Imagens

```bash
./1_postgres_image.sh run     # 🔧 Builda e sobe o container do PostgreSQL
./1_postgres_image.sh stop    # ⛔ Para e remove o container
./1_postgres_image.sh clean   # 🧹 Remove volumes não utilizados
./1_postgres_image.sh logs    # 📜 Mostra logs do PostgreSQL
./1_postgres_image.sh help    # ❓ Mostra o help com os comandos dispononíveis do PostgreSQL
```

## ❗ Problemas comuns

📌 **Persistência do RPO na Pasta `totvs/protheus/apo`**

A pasta `totvs/protheus/apo` é utilizada para persistir o RPO (Repositório de Objetos) do contêiner no sistema de arquivos do host, por meio de um bind mount configurado no `docker-compose.yml`. Para manter o RPO entre diferentes execuções do contêiner, é necessário garantir que o RPO do Protheus esteja presente nesta pasta antes de iniciar o contêiner.

No entanto, cuidado: se a pasta `./totvs/protheus/apo` no host estiver vazia ao iniciar o contêiner, ela sobrescreverá o conteúdo da pasta `/totvs/protheus/apo` dentro do contêiner, podendo apagar o RPO padrão da imagem. Para evitar isso, você pode comentar a linha correspondente no `docker-compose.yml`:

```yaml
# - ./totvs/protheus/apo:/totvs/protheus/apo
```

💡 **Dica de Boas Práticas**

Siga este procedimento para configurar o RPO corretamente:

1. **Inicie o contêiner sem o bind mount:** Comente a linha mencionada acima no `docker-compose.yml` e execute `docker-compose up -d`. Isso permite que o contêiner inicie com o RPO padrão da imagem do Protheus.
2. **Copie o RPO para o host:** Acesse o contêiner e copie o conteúdo da pasta `/totvs/protheus/apo` para o diretório `./totvs/protheus/apo` no host (use `docker cp` para isso).
3. **Remova o contêiner e a imagem:** Execute `docker-compose down` para parar e remover o contêiner. Se necessário, remova a imagem com `docker rmi <nome-da-imagem>`.
4. **Reinicie com o bind mount ativado:** Descomente a linha no `docker-compose.yml` e execute `docker-compose up -d` novamente. Agora, o contêiner usará o RPO persistido na pasta do host.

---

### 🔄 "init.sql" não executa novamente
Isso ocorre porque o volume persiste o estado. Use:

```bash
./1_postgres_image.sh stop && ./1_postgres_image.sh clean && ./1_postgres_image.sh run
```
📌 O script `init.sql` dentro da imagem `img_postgres` será executado **apenas na primeira vez** que o container for criado com volume limpo.
devido a natureza do script ser de criação de tabela.
Para forçar criar a tabela novamente, apague a pasta postgres-data.

🔄 Se quiser forçar nova execução:

```bash
./1_postgres_image.sh stop && ./1_postgres_image.sh clean && ./1_postgres_image.sh run
```
---


### 4. Subir todos as imagens com o script centralizador

```bash
./totvs_all_image.sh run
```

🧩 Ou, se preferir, utilize diretamente o Docker Compose:

```bash
docker-compose up -d
```

💡 *Recomenda-se o uso do script `totvs_all_image.sh`, pois ele pode configurar volumes, certificados e outras dependências antes de iniciar os containers.*

---

## 🔐 Certificados e Segurança

Caso deseje utilizar HTTPS ou integração segura entre os serviços, inclua seus certificados personalizados na pasta `certificate/`.

---

### 📦. Comandos rápidos para manipulação dos containeres

```bash
./apprest_container.sh start        # ▶️ Inicia o serviço do Rest no Protheus
./apprest_container.sh stop         # ⛔ Para o serviço do Rest no Protheus
./apprest_container.sh kill         # 💀 Força a parada do serviço Rest no Protheus
./apprest_container.sh restart      # 🔄 Reinicia o serviço do Rest no Protheus
./apprest_container.sh status       # ℹ️ Mostra o status do serviço Rest no Protheus
./apprest_container.sh describe     # 📝 Mostra detalhes do serviço e as configurações
./apprest_container.sh export       # 📤 Exporta o appserver.ini, console.log para a pasta /temp do host
./apprest_container.sh log          # 📜 Exibe o console.log do Rest na tela 
```

## 📄 Licença

📝 Todas as marcas usadas neste projeto são de propriedade da **TOTVS S.A.**
Este projeto é mantido para fins educacionais e de testes com o ERP TOTVS Protheus.
Licenças de software devem ser providenciadas conforme exigido pela TOTVS.
Todo o projeto foi desenvolvido utilizando uma base teste com empresa 99 do Protheus.

---

## 🧑‍💻 Autor

Criado por **Eduardo Brust**

* 📧 [eduardobrust@gmail.com](mailto:eduardobrust@gmail.com)
* 🎥 [YouTube](https://www.youtube.com/@EduardoBrust)
* 🔗 [LinkedIn](https://www.linkedin.com/in/eduardo-brust/)

---

