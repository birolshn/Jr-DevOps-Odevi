#!/bin/bash
# ============================================================
# DevOps Monitoring - Tüm Bileşenleri Deploy Et
# ============================================================
set -e

echo "============================================"
echo "  DevOps Monitoring Stack - Deploy Script"
echo "============================================"

# 1. Kubernetes Secret
echo ""
echo "[1/8] PostgreSQL Secret oluşturuluyor..."
kubectl apply -f kubernetes/secrets.yml
echo "✅ Secret oluşturuldu"

# 2. PostgreSQL
echo ""
echo "[2/8] PostgreSQL deploy ediliyor..."
kubectl apply -f kubernetes/postgresql-deployment.yml
kubectl apply -f kubernetes/postgresql-service.yml
echo "⏳ PostgreSQL hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s
echo "✅ PostgreSQL hazır"

# 3. Web Application
echo ""
echo "[3/8] Web Application deploy ediliyor..."
kubectl apply -f kubernetes/webapp-deployment.yml
kubectl apply -f kubernetes/webapp-service.yml
echo "⏳ Webapp hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=webapp --timeout=180s
echo "✅ Webapp hazır"

# 4. Nginx Ingress
echo ""
echo "[4/8] Nginx Ingress yapılandırılıyor..."
kubectl apply -f kubernetes/nginx-ingress.yml
echo "✅ Ingress oluşturuldu"

# 5. Monitoring Namespace
echo ""
echo "[5/8] Monitoring namespace oluşturuluyor..."
kubectl apply -f kubernetes/monitoring/namespace.yml
echo "✅ Namespace oluşturuldu"

# 6. Prometheus Stack
echo ""
echo "[6/8] Prometheus Stack deploy ediliyor..."
kubectl apply -f kubernetes/monitoring/prometheus-config.yml
kubectl apply -f kubernetes/monitoring/prometheus-rules.yml
kubectl apply -f kubernetes/monitoring/prometheus-deployment.yml
kubectl apply -f kubernetes/monitoring/alertmanager-config.yml
kubectl apply -f kubernetes/monitoring/alertmanager-deployment.yml
echo "⏳ Prometheus hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s
echo "✅ Prometheus hazır"

# 7. Grafana
echo ""
echo "[7/8] Grafana deploy ediliyor..."
kubectl apply -f kubernetes/monitoring/grafana-dashboards-config.yml
kubectl apply -f kubernetes/monitoring/grafana-deployment.yml
echo "⏳ Grafana hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s
echo "✅ Grafana hazır"

# 8. Exporters
echo ""
echo "[8/8] Node Exporter ve Kube State Metrics deploy ediliyor..."
kubectl apply -f kubernetes/monitoring/node-exporter-daemonset.yml
kubectl apply -f kubernetes/monitoring/kube-state-metrics.yml
echo "⏳ Exporters hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=node-exporter -n monitoring --timeout=60s
kubectl wait --for=condition=ready pod -l app=kube-state-metrics -n monitoring --timeout=60s
echo "✅ Exporters hazır"

# Sonuç
echo ""
echo "============================================"
echo "  ✅ TÜM BİLEŞENLER BAŞARIYLA DEPLOY EDİLDİ"
echo "============================================"
echo ""
echo "📊 Erişim Bilgileri:"
echo "-------------------------------------------"
echo "  Webapp:       minikube service webapp-service --url"
echo "  Prometheus:   minikube service prometheus -n monitoring --url"
echo "  Grafana:      minikube service grafana -n monitoring --url"
echo "  Alertmanager: minikube service alertmanager -n monitoring --url"
echo ""
echo "  Grafana Login: admin / admin123"
echo "-------------------------------------------"
echo ""
echo "📋 Pod Durumları:"
kubectl get pods -A
