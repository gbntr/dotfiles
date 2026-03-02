#!/bin/bash
set -e

echo "=== Aplicando Otimizações para Pendrive ==="

echo ">>> 1. Reduzindo o tempo de desligamento (90s -> 10s)..."
# Isso evita que o pendrive fique travado eternamente na tela preta ao desligar
sudo sed -i 's/.*DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf

echo ">>> 2. Instalando e configurando ZRAM..."
# O ZRAM vai usar metade da sua RAM para evitar desgastar a memória flash do pendrive
sudo pacman -S --needed --noconfirm zram-generator

sudo bash -c 'cat << EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF'

echo ">>> 3. Recarregando serviços e ativando otimizações..."
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0 || echo "Aviso: ZRAM já ativo ou requer reboot para iniciar."

echo "✅ Otimizações do pendrive aplicadas com sucesso!"
