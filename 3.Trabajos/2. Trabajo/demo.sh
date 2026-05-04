#!/bin/bash

# ==============================================================================
# Script para levantar el proyecto y exponerlo con tunnel público
# Ideal para presentaciones en clase o demos remotas
# ==============================================================================

set -e

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 SIMULADOR M/M/k/k - ERLANG B (Demo en Vivo)${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Función para verificar si cloudflared está instalado
check_cloudflared() {
    if command -v cloudflared &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Función para verificar si docker está corriendo
check_docker() {
    if docker info &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Función para verificar si docker compose está disponible
check_compose() {
    if docker compose version &> /dev/null || docker-compose --version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Verificar dependencias
echo -e "${YELLOW}📋 Verificando dependencias...${NC}"

if ! check_docker; then
    echo -e "${RED}❌ Docker no está corriendo. Inicialo primero.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker:${NC} corriendo"

if ! check_compose; then
    echo -e "${RED}❌ Docker Compose no está disponible.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose:${NC} disponible"

CLOUDFLARED_AVAILABLE=false
if check_cloudflared; then
    CLOUDFLARED_AVAILABLE=true
    echo -e "${GREEN}✓ Cloudflared:${NC} instalado (podrás generar tunnel)"
else
    echo -e "${YELLOW}⚠ Cloudflared:${NC} no instalado (no se podrá generar tunnel público)"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🐳 Levantando contenedores...${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Detener contenedores previos si existen
echo -e "${YELLOW}🧹 Limpiando contenedores previos...${NC}"
docker compose down 2>/dev/null || true

# Construir y levantar
echo -e "${YELLOW}🔨 Construyendo y levantando servicios...${NC}"
docker compose up -d --build

# Esperar a que estén listos
echo -e "${YELLOW}⏳ Esperando a que los servicios estén listos...${NC}"
sleep 5

# Verificar que estén corriendo
BACKEND_RUNNING=false
FRONTEND_RUNNING=false

if curl -s http://localhost:8000/health &> /dev/null; then
    BACKEND_RUNNING=true
fi

if curl -s http://localhost:5173 &> /dev/null; then
    FRONTEND_RUNNING=true
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📊 ESTADO DE LOS SERVICIOS${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$BACKEND_RUNNING" = true ]; then
    echo -e "${GREEN}✅ Backend (FastAPI):${NC} http://localhost:8000"
    echo "   - Docs API: http://localhost:8000/docs"
else
    echo -e "${RED}❌ Backend (FastAPI):${NC} No disponible"
fi

if [ "$FRONTEND_RUNNING" = true ]; then
    echo -e "${GREEN}✅ Frontend (React Dashboard):${NC} http://localhost:5173"
else
    echo -e "${RED}❌ Frontend (React Dashboard):${NC} No disponible"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🌐 ACCESO PÚBLICO${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$CLOUDFLARED_AVAILABLE" = true ]; then
    echo -e "${YELLOW}🚀 Generando tunnel público con cloudflared...${NC}"
    echo ""
    echo -e "${YELLOW}📱 Escanea este código QR en tu celular:${NC}"
    echo -e "${YELLOW}   (O copia la URL que aparece abajo)${NC}"
    echo ""
    
    # Iniciar cloudflared en background redirigiendo output a un archivo temporal
    TMP_LOG=$(mktemp)
    cloudflared tunnel --url http://localhost:5173 2>&1 > "$TMP_LOG" &
    CLOUDFLARED_PID=$!
    
    # Esperar a que cloudflared genere la URL
    sleep 8
    
    # Buscar la URL en el archivo temporal
    TUNNEL_URL=$(grep -oE 'https://[a-zA-Z0-9.-]+\.trycloudflare.com' "$TMP_LOG" | head -1)
    
    if [ -n "$TUNNEL_URL" ]; then
        echo -e "${GREEN}🔗 URL PÚBLICA:${NC} $TUNNEL_URL"
        echo ""
        echo -e "${YELLOW}💡 Esta URL estará activa mientras corra este script.${NC}"
        echo -e "${YELLOW}💡 Para detener, presiona Ctrl+C${NC}"
        
        # Mantener el script corriendo
        wait $CLOUDFLARED_PID
    else
        echo -e "${RED}❌ No se pudo generar el tunnel. Verifica cloudflared.${NC}"
    fi
    
    # Limpiar archivo temporal
    rm -f "$TMP_LOG"
else
    echo -e "${YELLOW}⚠️  Cloudflared no está instalado.${NC}"
    echo ""
    echo "Para instalarlo en macOS:"
    echo "  brew install cloudflared"
    echo ""
    echo "Para instalarlo en Linux:"
    echo "  sudo curl -s -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared"
    echo "  sudo chmod +x /usr/local/bin/cloudflared"
    echo ""
    echo "Una vez instalado, volvé a correr este script."
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🛑Para detener todo:${NC}"
echo "  docker compose down"
echo "  pkill -f cloudflared"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"