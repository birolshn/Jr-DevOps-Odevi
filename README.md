# Driver Management Monitoring Projesi

Bu proje, Spring Boot tabanlı bir web uygulamasının Kubernetes (Minikube) ortamında çalıştırılması ve Prometheus, Grafana ve Zabbix kullanılarak kapsamlı bir şekilde izlenmesini (monitoring) içermektedir.

## Projede Neler Yapıldı?

1. **Uygulama Metrikleri:** Spring Boot uygulamasına `actuator` ve `micrometer` bağımlılıkları eklenerek uygulamanın kendi metriklerini `/actuator/prometheus` adresinde yayınlaması sağlandı.
2. **Kubernetes Optimizasyonları:** Web uygulamasının Dockerfile'ı üretim (production) standartlarına göre güncellendi. Bellek limitleri (JVM ayarları), K8s Liveness/Readiness yapılandırmaları ve Secret kullanımı ile güvenlik artırıldı.
3. **Prometheus & Grafana (Minikube):** Kubernetes içinde çalışan tüm pod'ların, nodeların ve uygulamanın metrikleri Prometheus ile toplanıp Grafana Dashboard'larına yansıtıldı.
4. **Zabbix Kurulumu (VM):** Sunucu altyapısını ve kurulu olan PostgreSQL gibi bağımlı servisleri izlemek için Docker Compose üzerinden Zabbix Server ve Agent çalıştırılarak genel sistem takibi yapıldı.
5. **Alarm Senaryoları:** Pod'ların çökmesi (CrashLoopBackOff), yüksek CPU kullanımı veya servisin yanıt vermemesi gibi durumlar için Prometheus Alert kuralları yazıldı.
6. **Stres Testleri:** CPU yük bindirme, Pod'u zorla kapatma ve Veritabanı bağlantısını kesme gibi test scriptleriyle alarm kurallarının çalıştığı kanıtlandı.
7. **Email Uyarı Sistemi (Bonus):** Prometheus üzerinden tetiklenen alarmların Alertmanager ile otomatik e-posta olarak gönderilmesi sağlandı. (Not: Güvenlik amacıyla config dosyasında hassas şifreler "your-password" şeklinde maskelenmiştir).

## Nasıl Kurulur ve Çalıştırılır?

Projenin çalışması için bilgisayarınızda **Docker Desktop** ve **Minikube** kurulu olmalıdır.

### 1. Minikube Kümesini Başlatın
```bash
minikube start
minikube addons enable ingress
minikube addons enable metrics-server
```

### 2. İmajı Derleyin ve Sisteme Yükleyin
```bash
# Minikube'un Docker ortamına geçiş yapın
eval $(minikube docker-env)

# Uygulamayı build edin
./gradlew clean bootJar

# Docker imajını oluşturun
docker build -t birol29/assignment:latest .
```

### 3. Kubernetes ve Monitoring Araçlarını Kurun
Aşağıdaki script sırasıyla veritabanını, web uygulamasını, Prometheus'u, Alertmanager'ı ve Grafana'yı otomatik kuracaktır:
```bash
bash scripts/deploy-all.sh
```

### 4. Zabbix ve Sanal Makine Servislerini Başlatın
```bash
# Host'un kendi makinesine dönün
eval $(minikube docker-env -u)

# Zabbix ve ilgili VM bileşenlerini başlatın
docker compose -f docker-compose-vm.yml up -d
```

## Servislere Erişim Linkleri

Servislere erişmek için bulunduğunuz terminalden aşağıdaki tünel komutlarını çalıştırabilirsiniz:

- **Web Uygulaması:** `minikube service webapp-service --url`
- **Grafana Paneli:** `minikube service grafana -n monitoring --url` (admin / admin123)
- **Prometheus Paneli:** `minikube service prometheus -n monitoring --url`
- **Zabbix Paneli:** `http://localhost:8080` (Admin / zabbix)

*(Not: Grafana için JSON formatında dışa aktarılmış dashboard tasarımları projenin JSON klasörü içerisinde mevcuttur)*
