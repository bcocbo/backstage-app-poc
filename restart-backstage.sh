#!/bin/bash

echo "🛑 Deteniendo Backstage..."

# Encontrar y matar procesos de Backstage
pkill -f "backstage-cli.*start" || true
pkill -f "node.*backend.*index" || true

echo "⏳ Esperando a que los procesos terminen..."
sleep 3

echo "🔍 Verificando configuración..."

# Verificar que el token esté configurado
if grep -q "GITHUB_TOKEN=ghp_" .env; then
    echo "✅ Token de GitHub configurado en .env"
else
    echo "❌ Token de GitHub NO encontrado en .env"
    exit 1
fi

# Verificar que app-config.yaml tenga la integración
if grep -q "github:" app-config.yaml; then
    echo "✅ Integración de GitHub configurada en app-config.yaml"
else
    echo "❌ Integración de GitHub NO encontrada en app-config.yaml"
    exit 1
fi

echo ""
echo "🚀 Iniciando Backstage..."
echo "📝 Logs se guardarán en backstage.log"
echo ""

# Iniciar Backstage en background
nohup yarn start > backstage.log 2>&1 &

echo "⏳ Esperando a que Backstage inicie (esto puede tomar 1-2 minutos)..."
sleep 10

echo ""
echo "✅ Backstage iniciado!"
echo ""
echo "📍 URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:7007"
echo ""
echo "📋 Para ver logs en tiempo real:"
echo "   tail -f backstage.log"
echo ""
echo "🧪 Para probar el template:"
echo "   1. Ve a http://localhost:3000"
echo "   2. Click en 'Create...'"
echo "   3. Selecciona 'ArgoCD - Aplicación Hola Mundo'"
echo ""
