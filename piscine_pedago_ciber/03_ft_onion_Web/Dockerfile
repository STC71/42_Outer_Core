# ============================================================================
#  FT_ONION - DOCKERFILE MULTI-STAGE (Orquestado con Python3)
# ============================================================================
#  Servicio Oculto Tor con Python3 como orquestador
#  Build optimizado con Debian:bookworm
# ============================================================================

# Etapa 1: Base con todas las dependencias
FROM debian:bookworm-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    nginx \
    tor \
    openssh-server \
    openssh-client \
    curl \
    wget \
    nano \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Etapa 2: Build de dependencias Python
FROM base AS builder

COPY src/requirements.txt .
RUN pip3 install --no-cache-dir --user --upgrade pip && \
    pip3 install --no-cache-dir --user -r requirements.txt 2>/dev/null || true

# Etapa 3: Final
FROM base AS final

LABEL maintainer="42 Student" \
      description="ft_onion - Tor Hidden Service" \
      version="1.0.0"

# Copiar dependencias Python compiladas
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Crear usuario no-root para Tor
RUN useradd -m -s /bin/bash -d /var/lib/tor tor 2>/dev/null || true && \
    useradd -m -s /bin/bash user 2>/dev/null || true && \
    echo "user:password" | chpasswd && \
    usermod -aG sudo user 2>/dev/null || true

# Crear directorios necesarios
RUN mkdir -p /var/run/sshd \
    /var/lib/tor/hidden_service \
    /var/www/html \
    /app/logs \
    /app/config

# Copiar archivos de configuración
COPY src/nginx.conf /etc/nginx/nginx.conf
COPY src/torrc /etc/tor/torrc
COPY src/sshd_config /etc/ssh/sshd_config
COPY src/index.html /var/www/html/index.html

# Copiar aplicación Python
COPY src/app /app/app
COPY src/*.py /app/

# Script de inicialización
COPY src/setup.sh /app/setup.sh
RUN chmod +x /app/setup.sh

# Permisos correctos
RUN chown -R tor:tor /var/lib/tor/hidden_service \
    /etc/tor/torrc && \
    chmod 700 /var/lib/tor/hidden_service && \
    chmod 600 /etc/tor/torrc && \
    chmod 644 /etc/ssh/sshd_config && \
    chmod 755 /app && \
    chmod 644 /var/www/html/index.html

# Puerto SSH
EXPOSE 4242

# Puertos internos (no expuestos externamente)
EXPOSE 80 9000

# Verificación de salud
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Entrypoint: Orquestador Python
ENTRYPOINT ["/bin/bash"]
CMD ["/app/setup.sh"]
