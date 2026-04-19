# Backend Dockerfile — FastAPI (uvicorn)
FROM python:3.11-slim

# System deps for numerical packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# copy the requirements.txt from the repository root (build context is the repo root)
# the file is placed at 3.Trabajos/2. Trabajo/requirements.txt in this repo layout
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# copy project
COPY . /app

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
