#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
    FT_ONION - APLICACIÓN WEB (BONUS: DASHBOARD)
    
    Aplicación FastAPI para monitoreo en tiempo real
    APIs REST + WebSocket para actualización de estado
"""

import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

try:
    from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
    from fastapi.responses import FileResponse, JSONResponse
    from fastapi.staticfiles import StaticFiles
    from fastapi.middleware.cors import CORSMiddleware
    import uvicorn
except ImportError:
    print("FastAPI not installed. Bonus dashboard unavailable.")
    print("Install with: pip3 install fastapi uvicorn")
    sys.exit(1)

import subprocess
import psutil

# ============================================================================
#  CONFIGURACIÓN DE APLICACIÓN
# ============================================================================

APP_VERSION = "1.0.0"
APP_NAME = "ft_onion"

app = FastAPI(
    title=f"{APP_NAME} Dashboard",
    description="Real-time monitoring and management dashboard for ft_onion",
    version=APP_VERSION
)

# ============================================================================
#  MIDDLEWARE
# ============================================================================

# Middleware CORS para solicitudes de origen cruzado
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
#  FUNCIONES UTILITARIAS
# ============================================================================

def check_service(service_name: str) -> Dict:
    """Verificar estado del servicio"""
    try:
        result = subprocess.run(
            ['systemctl', 'is-active', service_name],
            capture_output=True,
            text=True,
            timeout=5
        )
        return {
            'name': service_name,
            'running': result.returncode == 0,
            'status': 'running' if result.returncode == 0 else 'stopped',
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        return {
            'name': service_name,
            'running': False,
            'status': f'error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }


def get_system_stats() -> Dict:
    """Obtener uso de recursos del sistema"""
    try:
        return {
            'cpu': psutil.cpu_percent(interval=1),
            'memory': psutil.virtual_memory().percent,
            'disk': psutil.disk_usage('/').percent,
            'processes': len(psutil.pids()),
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        return {
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }


def get_onion_address() -> Optional[str]:
    """Obtener la dirección .onion"""
    hostname_file = '/var/lib/tor/hidden_service/hostname'
    try:
        if os.path.exists(hostname_file):
            with open(hostname_file, 'r') as f:
                return f.read().strip()
    except Exception:
        pass
    return None


def read_log_file(filepath: str, lines: int = 50) -> List[str]:
    """Leer últimas N líneas de un archivo de log"""
    try:
        if not os.path.exists(filepath):
            return []
        
        with open(filepath, 'r') as f:
            all_lines = f.readlines()
            return [l.rstrip('\n') for l in all_lines[-lines:]]
    except Exception:
        return []


# ============================================================================
#  ENDPOINTS API REST
# ============================================================================

@app.get('/api/health')
async def health_check() -> Dict:
    """Endpoint de verificación de salud"""
    return {
        'status': 'healthy',
        'version': APP_VERSION,
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/status')
async def get_status() -> Dict:
    """Obtener estado completo del sistema"""
    services = {
        'tor': check_service('tor'),
        'nginx': check_service('nginx'),
        'ssh': check_service('ssh'),
    }
    
    return {
        'application': {
            'name': APP_NAME,
            'version': APP_VERSION,
            'uptime': 'calculating...'
        },
        'services': services,
        'system': get_system_stats(),
        'onion_address': get_onion_address(),
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/services')
async def get_services() -> Dict:
    """Obtener estado de todos los servicios"""
    return {
        'services': {
            'tor': check_service('tor'),
            'nginx': check_service('nginx'),
            'ssh': check_service('ssh'),
        },
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/system')
async def get_system_info() -> Dict:
    """Obtener información del sistema"""
    return {
        'system': get_system_stats(),
        'machine': {
            'hostname': os.environ.get('HOSTNAME', 'unknown'),
            'platform': sys.platform,
            'python_version': sys.version.split()[0]
        },
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/onion')
async def get_onion_info() -> Dict:
    """Obtener información del servicio oculto Tor"""
    address = get_onion_address()
    return {
        'address': address,
        'status': 'initialized' if address else 'initializing',
        'ports': [
            {'port': 80, 'protocol': 'HTTP'},
            {'port': 4242, 'protocol': 'SSH'}
        ],
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/logs/nginx')
async def get_nginx_logs(lines: int = 50) -> Dict:
    """Obtener logs de acceso de Nginx"""
    logs = read_log_file('/var/log/nginx/ft_onion_access.log', lines)
    return {
        'service': 'nginx',
        'file': '/var/log/nginx/ft_onion_access.log',
        'lines': logs,
        'count': len(logs),
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/logs/tor')
async def get_tor_logs(lines: int = 50) -> Dict:
    """Obtener logs del daemon Tor"""
    logs = read_log_file('/var/log/tor/notices.log', lines)
    return {
        'service': 'tor',
        'file': '/var/log/tor/notices.log',
        'lines': logs,
        'count': len(logs),
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/logs/ssh')
async def get_ssh_logs(lines: int = 50) -> Dict:
    """Obtener logs de SSH"""
    logs = read_log_file('/var/log/auth.log', lines)
    return {
        'service': 'ssh',
        'file': '/var/log/auth.log',
        'lines': logs,
        'count': len(logs),
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/config/summary')
async def get_config_summary() -> Dict:
    """Obtener resumen de configuración"""
    config_files = {
        'nginx': '/etc/nginx/nginx.conf',
        'tor': '/etc/tor/torrc',
        'ssh': '/etc/ssh/sshd_config',
    }
    
    summary = {}
    for name, path in config_files.items():
        if os.path.exists(path):
            size = os.path.getsize(path)
            summary[name] = {
                'path': path,
                'size': f'{size} bytes',
                'exists': True
            }
        else:
            summary[name] = {'path': path, 'exists': False}
    
    return {
        'configurations': summary,
        'timestamp': datetime.now().isoformat()
    }


@app.get('/api/metrics')
async def get_metrics() -> Dict:
    """Obtener métricas de rendimiento"""
    stats = get_system_stats()
    
    return {
        'metrics': {
            'cpu_usage': stats.get('cpu', 0),
            'memory_usage': stats.get('memory', 0),
            'disk_usage': stats.get('disk', 0),
            'running_processes': stats.get('processes', 0),
        },
        'uptime': 'calculating...',
        'timestamp': datetime.now().isoformat()
    }


# ============================================================================
#  ARCHIVOS ESTÁTICOS
# ============================================================================

@app.get('/')
async def serve_root() -> FileResponse:
    """Servir página principal"""
    return FileResponse('/var/www/html/index.html')


@app.get('/favicon.ico')
async def favicon():
    """Endpoint de favicon"""
    return JSONResponse({'status': 'ok'})


# ============================================================================
#  MANEJADORES DE ERRORES
# ============================================================================

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Manejar excepciones globales"""
    return JSONResponse(
        status_code=500,
        content={
            'error': 'Internal server error',
            'detail': str(exc),
            'timestamp': datetime.now().isoformat()
        }
    )


# ============================================================================
#  INICIO Y APAGADO
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Evento de inicio"""
    print(f"🧅 {APP_NAME} v{APP_VERSION} iniciado exitosamente")
    print(f"📊 Dashboard disponible en http://localhost:8000/api")
    print(f"🏥 Verificación de salud en http://localhost:8000/api/health")


@app.on_event("shutdown")
async def shutdown_event():
    """Evento de apagado"""
    print(f"🧅 {APP_NAME} apagando...")


# ============================================================================
#  PUNTO DE ENTRADA
# ============================================================================

if __name__ == '__main__':
    uvicorn.run(
        app,
        host='127.0.0.1',
        port=8000,
        log_level='info',
        access_log=False,
        use_colors=True,
    )
