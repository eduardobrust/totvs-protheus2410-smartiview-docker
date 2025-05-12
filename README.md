--

# 🐳 Ambiente Dockerizado TOTVS Protheus 12.1.2410 com SmartView e PostgreSQL

Este projeto oferece um ambiente completo e containerizado do ERP **TOTVS Protheus 12.1.2410** com **SmartView** e **PostgreSQL 16**, utilizando imagens Docker personalizadas e otimizadas para distribuições Linux.


## 📁 Estrutura recomendada do repositório

```bash
brust-protheus2410-smartview-docker-linux-postgres/
├── docker-compose.yml
├── totvs.sh
├── protheus.sh
├── smartview.sh
├── dbaccess.sh
├── license.sh
├── postgres.sh
├── img_protheus/
├── img_smartview/
├── img_dbaccess/
├── img_license/
├── img_postgres/
├── certificate/
├── postgres-data/
└── README.md
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

### Observação
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

---

### 2. Comandos rápidos

```bash
./postgres.sh run     # 🔧 Builda e sobe o container do PostgreSQL
./postgres.sh stop    # ⛔ Para e remove o container
./postgres.sh clean   # 🧹 Remove volumes não utilizados
./postgres.sh logs    # 📜 Mostra logs do PostgreSQL
```

## ❗ Problemas comuns

### 🔄 "init.sql" não executa novamente
Isso ocorre porque o volume persiste o estado. Use:

```bash
./postgres.sh stop && ./postgres.sh clean && ./postgres.sh run
```
📌 O script `init.sql` dentro da imagem `img_postgres` será executado **apenas na primeira vez** que o container for criado com volume limpo.

🔄 Se quiser forçar nova execução:

```bash
./postgres.sh stop && ./postgres.sh clean && ./postgres.sh run
```
---

### 3. Subir todos os serviços com o script centralizador

```bash
./totvs.sh run
```

🧩 Ou, se preferir, utilize diretamente o Docker Compose:

```bash
docker-compose up -d
```

💡 *Recomenda-se o uso do script `totvs.sh`, pois ele pode configurar volumes, certificados e outras dependências antes de iniciar os containers.*

---

## 🔐 Certificados e Segurança

Caso deseje utilizar HTTPS ou integração segura entre os serviços, inclua seus certificados personalizados na pasta `certificate/`.

---

## 📄 Licença

📝 Todas as marcas usadas neste projeto são de propriedade da **TOTVS S.A.**
Este projeto é mantido para fins educacionais e de testes com o ERP TOTVS Protheus.
Licenças de software devem ser providenciadas conforme exigido pela TOTVS.

---

## 🧑‍💻 Autor

Criado por **Eduardo Brust**

* 📧 [eduardobrust@gmail.com](mailto:eduardobrust@gmail.com)
* 🎥 [YouTube](https://www.youtube.com/@EduardoBrust)
* 🔗 [LinkedIn](https://linkedin.com/in/eduardobrust)

---

