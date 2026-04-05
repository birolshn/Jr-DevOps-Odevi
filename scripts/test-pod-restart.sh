#!/bin/bash
# ============================================================
# TEST 1: Pod Restart Testi
# Bu test bir webapp pod'unu silerek K8s'in otomatik
# yeniden oluşturmasını ve alarm tetiklenmesini test eder.
# ============================================================

echo "============================================"
echo "  TEST: Pod Restart Senaryosu"
echo "============================================"
echo ""

# Mevcut pod'ları göster
echo "📋 Mevcut webapp pod'ları:"
kubectl get pods -l app=webapp
echo ""

# İlk pod'u al
POD_NAME=$(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}')
echo "🎯 Silinecek pod: $POD_NAME"
echo ""

# İçindeki container'ı yapay olarak çökert (Crash)
echo "💥 Container içindeki süreç sonlandırılıyor (Crash Simülasyonu)..."
kubectl exec $POD_NAME -- pkill java
echo ""

# Yeni pod'un oluşmasını izle
echo "⏳ Kubernetes'in container'ı yeniden başlatması izleniyor (30 saniye)..."
for i in {1..6}; do
    sleep 5
    echo "--- $((i*5)) saniye ---"
    kubectl get pods -l app=webapp
    echo ""
done

echo "============================================"
echo "  ✅ TEST TAMAMLANDI"
echo "============================================"
echo ""
echo "📊 Kontrol et:"
echo "  1. Prometheus'ta 'PodCrashLooping' veya 'ServiceDown' alertini kontrol et"
echo "  2. Grafana'da 'Pod Restart Count' panelini kontrol et"
echo "  3. kubectl get events --sort-by='.lastTimestamp' komutuyla olayları kontrol et"
