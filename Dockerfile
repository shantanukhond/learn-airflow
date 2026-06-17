FROM apache/airflow:3.2.2

USER root

# Install any system dependencies your DAGs may need.
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/*

USER airflow

# Add Python packages required by your DAGs here, or use _PIP_ADDITIONAL_REQUIREMENTS in .env
# COPY requirements.txt /
# RUN pip install --no-cache-dir -r /requirements.txt
