# Dockerfile for Tatva AI Gateway Backend (AWS App Runner / ECS / ECR)
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    EXP_GATEWAY_PORT=8000

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY pyproject.toml README.md ./
COPY exp ./exp
COPY assets ./assets

# Install dependencies and Tatva AI package
RUN pip install --upgrade pip && \
    pip install .

# Copy existing configuration if present or prepare directory
RUN mkdir -p /app/.exp

# Expose default gateway port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/v1/models || exit 1

# Start Tatva Gateway
CMD ["tatva", "run", "--port", "8000", "--root", "/app/.exp"]
