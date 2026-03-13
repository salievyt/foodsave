FROM python:3.12-slim

WORKDIR /app
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p staticfiles media

ENV CHANNEL_LAYERS__DEFAULT__BACKEND=channels.layers.InMemoryChannelLayer

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
