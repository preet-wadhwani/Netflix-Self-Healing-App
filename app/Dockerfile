# Lightweight Python image
FROM python:3.11-slim

# Working directory
WORKDIR /app

RUN apt-get update && apt-get install -y curl

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose application port
EXPOSE 5000

# Container HealthCheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Run with Gunicorn (production server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
