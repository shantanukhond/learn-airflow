# Learn Airflow

Local **Apache Airflow 3.x** dev environment with Docker Compose. DAGs live in a separate repo and are included here as a [git submodule](https://github.com/shantanukhond/learn-airflow-dags).

On GitHub, the `dags` folder appears as **`dags @ <commit>`** (for example `dags @ 55a2946`). That is normal — it links to a specific commit in [learn-airflow-dags](https://github.com/shantanukhond/learn-airflow-dags), not a branch name. Git submodules always pin a commit hash.

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
├── .gitmodules           # links dags/ → learn-airflow-dags
├── config/
│   └── airflow.cfg       # Airflow runtime configuration
├── dags/                 # git submodule → learn-airflow-dags
├── plugins/              # custom Airflow plugins
└── logs/                 # task logs (generated at runtime)
```

## Quick start

### 1. Clone this repo **with submodules**

```bash
git clone --recurse-submodules https://github.com/shantanukhond/learn-airflow.git
cd learn-airflow
```

If you already cloned without submodules, initialize them:

```bash
git submodule update --init --recursive
```

To pull the latest DAGs from `main` after cloning:

```bash
git submodule update --remote dags
```

### 2. Configure

```bash
cp .env.example .env
echo "AIRFLOW_UID=$(id -u)" >> .env
```

Set `fernet_key` in `config/airflow.cfg`:

```bash
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### 3. Start Airflow

```bash
docker compose up airflow-init
docker compose up -d
```

### 4. Open the UI

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

**As a learner** — get the latest DAGs from `main`:

```bash
git submodule update --remote dags
```

**As a maintainer** — after pushing to `learn-airflow-dags`, update the submodule pointer in this repo:

```bash
git submodule update --remote dags
git add dags
git commit -m "Update DAGs submodule to latest main"
git push
```

GitHub will then show a new commit hash next to `dags` (e.g. `dags @ abc1234`).

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
