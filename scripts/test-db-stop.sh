#!/bin/bash
# ============================================================
# TEST 2: Database Down Testi
# PostgreSQL pod'unu durdurarak DB Down alarmı tetikler.
# ============================================================

echo "============================================"
echo "  TEST: Database Down Senaryosu"
echo "============================================"
echo ""

# Mevcut durumu göster
echo "📋 PostgreSQL pod durumu:"
kubectl get pods -l app=postgres
echo ""

# PostgreSQL deployment'ı 0 replica'ya ölçekle (durdur)
echo "💥 PostgreSQL durduruluyor (replicas=0)..."
kubectl scale deployment postgres-deployment --replicas=0
echo ""

# Durumu izle
echo "⏳ Alarm tetiklenmesi bekleniyor (60 saniye)..."
for i in {1..6}; do
    sleep 10
    echo "--- $((i*10)) saniye ---"
    echo "Pod durumu:"
    kubectl get pods -l app=postgres 2>/dev/null || echo "  (Pod bulunamadı - beklenen davranış)"
    echo "Webapp durumu:"
    kubectl get pods -l app=webapp
    echo ""
done

echo "============================================"
echo "  📊 SONUÇ KONTROL"
echo "============================================"
echo ""
echo "Kontrol et:"
echo "  1. Prometheus Alerts sayfasında 'DatabaseDown' alertini kontrol et"
echo "  2. Grafana'da 'Uygulama Durumu' panelini kontrol et"
echo "  3. Webapp loglarını kontrol et: kubectl logs -l app=webapp --tail=20"
echo ""

# Geri yükleme
read -p "📌 PostgreSQL'i geri yüklemek için Enter'a bas..."
echo ""
echo "🔄 PostgreSQL geri yükleniyor (replicas=1)..."
kubectl scale deployment postgres-deployment --replicas=1
echo "⏳ PostgreSQL hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s
echo "✅ PostgreSQL tekrar çalışıyor!"
