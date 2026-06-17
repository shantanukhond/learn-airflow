# Learn Airflow

Local **Apache Airflow 3.x** dev environment with Docker Compose. DAGs are maintained in a [separate repository](https://github.com/shantanukhond/learn-airflow-dags) and cloned into `dags/` locally.

## Related repos

| Repo | Purpose |
|------|---------|
| [learn-airflow](https://github.com/shantanukhond/learn-airflow) | Docker Compose, config, plugins (this repo) |
| [learn-airflow-dags](https://github.com/shantanukhond/learn-airflow-dags) | DAG examples for the tutorial series |

## Structure

```
.
├── docker-compose.yaml   # api-server, scheduler, dag-processor, triggerer, postgres
├── Dockerfile            # extend the Airflow image with extra deps
├── .env                  # Docker Compose settings only (UID, image, init user)
├── config/
│   └── airflow.cfg       # Airflow runtime configuration
├── dags/                 # clone learn-airflow-dags here (not tracked in git)
├── plugins/              # custom Airflow plugins
└── logs/                 # task logs (generated at runtime)
```

## Quick start

### 1. Clone this repo

```bash
git clone --depth=1 https://github.com/shantanukhond/learn-airflow.git
cd learn-airflow
```

### 2. Clone DAGs (optional)

Skip this step if you only want the Airflow environment and will add your own DAGs.

```bash
git clone --depth=1 https://github.com/shantanukhond/learn-airflow-dags.git dags
```

### 3. Configure

```bash
cp .env.example .env
echo "AIRFLOW_UID=$(id -u)" >> .env
```

Set `fernet_key` in `config/airflow.cfg`:

```bash
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### 4. Start Airflow

```bash
docker compose up airflow-init
docker compose up -d
```

### 5. Open the UI

- URL: http://localhost:8080
- Username: `airflow`
- Password: `airflow`

## Configuration

Airflow settings live in `config/airflow.cfg`. The `.env` file is only for Docker Compose:

| File | Purpose |
|------|---------|
| `config/airflow.cfg` | executor, database, auth, JWT, scheduler |
| `.env` | `AIRFLOW_UID`, image name, init admin user |

Environment variables (`AIRFLOW__SECTION__KEY`) override `airflow.cfg` when needed.

## Updating DAGs

```bash
cd dags && git pull && cd ..
```

Airflow picks up changes automatically (default scan interval ~30s).

## Common commands

```bash
docker compose logs -f
docker compose down
docker compose down -v          # full reset (removes database volume)
docker compose build            # rebuild after Dockerfile changes
```

## Airflow 3.x notes

- **API server** replaces the old webserver (`airflow-apiserver` on port 8080)
- **DAG processor** runs as its own service
- Auth uses the **FAB auth manager** with JWT (`[api_auth] jwt_secret` in `airflow.cfg`)
- DAGs written for Airflow 2.x may need updates — see the [Airflow 3 migration guide](https://airflow.apache.org/docs/apache-airflow/stable/installation/upgrading_to_airflow3.html)

## Links

- DAGs: [learn-airflow-dags](https://github.com/shantanukhond/learn-airflow-dags)
- Docs: [airflow.atwish.org](https://airflow.atwish.org)
- Videos: [YouTube](https://youtube.com/@shantanukhond)
