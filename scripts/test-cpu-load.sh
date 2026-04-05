#!/bin/bash
# ============================================================
# TEST 3: CPU Load Testi
# Geçici bir pod ile CPU yükü oluşturarak
# HighCPUUsage alarmını tetikler.
# ============================================================

echo "============================================"
echo "  TEST: CPU Load Senaryosu"
echo "============================================"
echo ""

# Mevcut CPU durumunu göster
echo "📋 Mevcut node kaynak durumu:"
kubectl top nodes 2>/dev/null || echo "  (metrics-server gerekli: minikube addons enable metrics-server)"
echo ""

# CPU stress pod'u oluştur
echo "💥 CPU stress pod'u oluşturuluyor..."
kubectl run cpu-stress --image=polinux/stress --restart=Never -- \
  stress --cpu 8 --timeout 400s

echo ""
echo "⏳ CPU yükü 6-7 dakika boyunca devam edecek (Alarm kuralındaki 5m şartını doldurmak için)..."
echo "⏳ Alarm tetiklenmesi izleniyor..."
echo ""

for i in {1..36}; do
    sleep 10
    echo "--- $((i*10)) saniye ---"
    kubectl top nodes 2>/dev/null || echo "  (metrics-server bekleniyor...)"
    echo ""
done

echo "============================================"
echo "  📊 SONUÇ KONTROL"
echo "============================================"
echo ""
echo "Kontrol et:"
echo "  1. Prometheus'ta 'HighCPUUsage' alertini kontrol et"
echo "  2. Grafana Kubernetes Dashboard'da CPU grafiğini kontrol et"
echo "  3. Node Exporter metriklerini kontrol et"
echo ""

# Temizlik
echo "🧹 Stress pod'u temizleniyor..."
kubectl delete pod cpu-stress --ignore-not-found=true
echo "✅ Temizlik tamamlandı!"
