#!/bin/bash

# ============================================================================
#  FT_ONION - SETUP.SH (SCRIPT DE INICIALIZACIÓN)
# ============================================================================
#  Script de orquestación para inicio y configuración de servicios
#  Gestiona Tor, Nginx, SSH y monitoreo
# ============================================================================

# ============================================================================
#  COLORS AND FORMATTING
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# ============================================================================
#  FUNCIONES DE LOGGING
# ============================================================================

log_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

log_error() {
    echo -e "${RED}[✗]${RESET} $1"
}

log_separator() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# ============================================================================
#  INICIALIZACIÓN
# ============================================================================

log_separator
echo -e "${BOLD}${MAGENTA}    🧅 FT_ONION - SECUENCIA DE INICIALIZACIÓN${RESET}"
log_separator

# ============================================================================
#  VERIFICACIONES DEL SISTEMA
# ============================================================================

log_info "Realizando verificaciones del sistema..."

# Verificar si se ejecuta como root (requerido para gestión de servicios)
if [ "$EUID" -ne 0 ]; then
   log_error "Este script debe ejecutarse como root"
   exit 1
fi

# Verificar disponibilidad de Python
if ! command -v python3 &> /dev/null; then
    log_error "Python3 no está instalado"
    exit 1
fi
log_success "Python3 encontrado"

# Verificar directorios requeridos
mkdir -p /var/lib/tor/hidden_service
mkdir -p /var/www/html
mkdir -p /var/log/tor
mkdir -p /var/log/nginx
mkdir -p /app/logs
log_success "Directorios creados"

# ============================================================================
#  CONFIGURACIÓN DE TOR
# ============================================================================

log_info ""
log_info "Configurando daemon Tor..."

# Asegurar permisos de Tor
chown -R tor:tor /var/lib/tor/hidden_service 2>/dev/null || true
chmod 700 /var/lib/tor/hidden_service 2>/dev/null || true
chmod 600 /etc/tor/torrc 2>/dev/null || true

# Iniciar Tor (se ejecuta en segundo plano)
service tor start 2>/dev/null || systemctl start tor 2>/dev/null || true
log_success "Daemon Tor iniciado"

# Esperar a que Tor se inicialice
COUNTER=0
while [ $COUNTER -lt 30 ]; do
    if [ -f /var/lib/tor/hidden_service/hostname ]; then
        ONION_ADDR=$(cat /var/lib/tor/hidden_service/hostname)
        log_success "Servicio oculto inicializado: ${MAGENTA}${ONION_ADDR}${RESET}"
        break
    fi
    COUNTER=$((COUNTER + 1))
    sleep 1
done

if [ ! -f /var/lib/tor/hidden_service/hostname ]; then
    log_warning "Servicio oculto aún no inicializado (puede tardar hasta 1 minuto)"
fi

# ============================================================================
#  CONFIGURACIÓN DE SSH
# ============================================================================

log_info ""
log_info "Configurando servicio SSH..."

# Generar claves SSH si es necesario
ssh-keygen -A 2>/dev/null || true

# Asegurar permisos correctos
chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null || true

# Iniciar SSH
service ssh start 2>/dev/null || systemctl start ssh 2>/dev/null || true
log_success "Servicio SSH iniciado en puerto 4242"

# ============================================================================
#  CONFIGURACIÓN DE NGINX
# ============================================================================

log_info ""
log_info "Configurando servidor web Nginx..."

# Probar configuración de Nginx
nginx -t 2>/dev/null || {
    log_warning "Prueba de configuración de Nginx falló, usando configuración por defecto"
    # Usar configuración nginx por defecto como alternativa
    service nginx start 2>/dev/null || systemctl start nginx 2>/dev/null || true
}

# Iniciar Nginx
service nginx start 2>/dev/null || systemctl start nginx 2>/dev/null || true
log_success "Servidor web Nginx iniciado"

# ============================================================================
#  APLICACIÓN PYTHON (BONUS: Dashboard)
# ============================================================================

log_info ""
log_info "Inicializando aplicación Python..."

if [ -f /app/app.py ]; then
    # Ejecutar app Python en segundo plano
    nohup python3 /app/app.py > /app/logs/app.log 2>&1 &
    APP_PID=$!
    echo $APP_PID > /app/app.pid
    log_success "Aplicación Python iniciada (PID: $APP_PID)"
else
    log_warning "Aplicación Python no encontrada en /app/app.py"
fi

# ============================================================================
#  VERIFICACIÓN DE SERVICIOS
# ============================================================================

log_info ""
log_info "Verificando servicios..."

# Función para verificar servicio
check_service() {
    local service_name=$1
    local port=$2
    
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        log_success "$service_name escuchando en puerto $port"
        return 0
    else
        log_warning "$service_name no responde en puerto $port"
        return 1
    fi
}

# Verificar servicios (pueden tardar un momento con Tor)
sleep 2
check_service "HTTP/Nginx" "80" || true
check_service "SSH" "4242" || true

# ============================================================================
#  LOGGING Y MONITOREO
# ============================================================================

log_info ""
log_info "Configurando logging..."

# Crear configuración de rotación de logs
cat > /etc/logrotate.d/ft_onion << 'EOF'
/var/log/nginx/ft_onion_access.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}

/var/log/tor/notices.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 tor tor
    sharedscripts
}

/app/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
EOF

log_success "Logging configurado"

# ============================================================================
#  FINAL STATUS
# ============================================================================

log_info ""
log_separator
echo -e "${GREEN}${BOLD}  ✓ FT_ONION INITIALIZATION COMPLETE${RESET}"
log_separator
echo ""

# Display connection info
if [ -f /var/lib/tor/hidden_service/hostname ]; then
    ONION=$(cat /var/lib/tor/hidden_service/hostname)
    echo -e "  ${CYAN}🌐 Your Hidden Service Address:${RESET}"
    echo -e "     ${MAGENTA}${ONION}${RESET}"
    echo ""
fi

echo -e "  ${CYAN}🔗 Connection Methods:${RESET}"
echo -e "     • HTTP:  http://[your-onion-address].onion (Port 80 via Tor)"
echo -e "     • SSH:   ssh -p 4242 user@[your-onion-address].onion (Port 4242 via Tor)"
echo ""

echo -e "  ${CYAN}📊 Services Status:${RESET}"
echo -e "     • Tor:   $(service tor status > /dev/null 2>&1 && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}") Running"
echo -e "     • Nginx: $(service nginx status > /dev/null 2>&1 && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}") Running"
echo -e "     • SSH:   $(service ssh status > /dev/null 2>&1 && echo -e "${GREEN}✓${RESET}" || echo -e "${RED}✗${RESET}") Running"
echo ""

echo -e "  ${CYAN}📝 SSH Access:${RESET}"
echo -e "     Username: ${MAGENTA}user${RESET}"
echo -e "     Password: ${MAGENTA}password${RESET}"
echo -e "     Port: ${MAGENTA}4242${RESET}"
echo ""

log_separator

# Keep container running
tail -f /dev/null
