--

# 🐳 Brust Protheus 2410 Docker com PostgreSQL Setup

Este projeto contém uma imagem personalizada do **PostgreSQL 16** com script de inicialização para o banco `dbprotheus`, voltado ao uso com o ERP **Protheus**.

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

As imagens utilizadas estão disponíveis no Docker Hub:

* [`eduardobrust/brust-protheus2410-smartview-linux-postgres`](https://hub.docker.com/r/eduardobrust/brust-protheus2410-smartview-linux-postgres)
* [`brust/postgres`](https://hub.docker.com/r/brust/postgres)
* [`brust/totvs_licenseserver`](https://hub.docker.com/r/brust/totvs_licenseserver)
* [`brust/totvs_dbaccess`](https://hub.docker.com/r/brust/totvs_dbaccess)
* [`brust/smartview_services`](https://hub.docker.com/r/brust/smartview_services)

---

## ✅ Pré-requisitos

* 🐳 Docker instalado
* 💻 Bash (Linux, WSL ou Git Bash no Windows)

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

📌 O script `init.sql` dentro da imagem `img_postgres` será executado **apenas na primeira vez** que o container for criado com volume limpo.

🔄 Se quiser forçar nova execução:

```bash
./postgres.sh stop && ./postgres.sh clean && ./postgres.sh run
```

---

### 3. Subir todos os serviços com o script centralizador

```bash
./totvs.sh
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

