# Airflow Dev Environment

Local **Apache Airflow 3.x** setup using Docker Compose. DAGs are maintained in a separate repository and mounted into this project.

## Structure

```
.
├── docker-compose.yaml   # Airflow services (api-server, scheduler, dag-processor, triggerer, postgres)
├── Dockerfile            # Extend the base Airflow image with extra deps
├── .env                  # Docker Compose settings only (UID, image, init user)
├── config/
│   └── airflow.cfg       # Airflow runtime configuration
├── dags/                 # Clone your DAGs repo here
├── plugins/              # Custom Airflow plugins
└── logs/                 # Task logs (generated at runtime)
```

## Configuration

Airflow settings live in `config/airflow.cfg` (mounted via `AIRFLOW_CONFIG`). The `.env` file is only for Docker Compose concerns:

| File | Purpose |
|------|---------|
| `config/airflow.cfg` | Executor, database, auth, JWT, scheduler, etc. |
| `.env` | `AIRFLOW_UID`, image name, init admin user, optional pip packages |

Edit `config/airflow.cfg` before first start. At minimum, set `fernet_key` in the `[core]` section:

```bash
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

To see all defaults Airflow ships with:

```bash
docker compose run --rm airflow-apiserver airflow config list --defaults
```

Environment variables (`AIRFLOW__SECTION__KEY`) still override `airflow.cfg` if you need that for secrets in production.

## Airflow 3.x notes

- **API server** replaces the old webserver (`airflow-apiserver` on port 8080).
- **DAG processor** runs as its own service (DAG parsing is no longer inside the scheduler).
- Auth uses the **FAB auth manager** with JWT (`[api_auth] jwt_secret` in `airflow.cfg`).
- DAGs written for Airflow 2.x may need updates for the [Airflow 3 migration guide](https://airflow.apache.org/docs/apache-airflow/stable/installation/upgrading_to_airflow3.html).

## Quick start

### 1. Clone your DAGs repo

```bash
# Remove the placeholder, then clone your DAGs repository into dags/
rm dags/.gitkeep
git clone <your-dags-repo-url> dags
```

Or clone into a temp folder and move contents:

```bash
git clone <your-dags-repo-url> /tmp/my-dags
cp -R /tmp/my-dags/. dags/
```

### 2. Configure

```bash
cp .env.example .env
echo "AIRFLOW_UID=$(id -u)" >> .env
```

Set `fernet_key` in `config/airflow.cfg` (see above).

### 3. Start Airflow

```bash
docker compose up airflow-init
docker compose up -d
```

### 4. Open the UI

- URL: http://localhost:8080
- Username: `airflow` (or value of `_AIRFLOW_WWW_USER_USERNAME` in `.env`)
- Password: `airflow` (or value of `_AIRFLOW_WWW_USER_PASSWORD` in `.env`)

## Common commands

```bash
# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove database volume (full reset)
docker compose down -v

# Rebuild image after Dockerfile changes
docker compose build

# Inspect effective config value
docker compose run --rm airflow-apiserver airflow config get-value core executor
```

## Adding Python dependencies

Either:

1. Add packages to `Dockerfile` and rebuild, or
2. Set `_PIP_ADDITIONAL_REQUIREMENTS` in `.env` (slower startup, good for quick experiments)

## Updating DAGs

Pull the latest from your DAGs repo:

```bash
cd dags && git pull && cd ..
```

Airflow picks up changes automatically (default scan interval ~30s).
