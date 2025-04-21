# 🛠️ Jenkins Builder Script

Bu repo, Jenkins projelerini komut satırı üzerinden tetiklemek ve derleme süreçlerini izlemek için geliştirilmiş bir `batch` dosyasını içerir.

## 🚀 Özellikler
- Jenkins API token kullanarak yetkili build tetikleme
- Proje listesi içinden seçim yapma {Kullanımınıza göre özelleştirmeniz gerekir.}
- Parametreli derleme başlatma (branch, version, obfuscator vb.)
- Derleme durumunu gerçek zamanlı takip etme
- Otomatik konfigürasyon dosyası oluşturma (`jenkins-config.bat`)

## 🔧 Kullanım
1. `jenkins-builder.bat` dosyasını çalıştır
2. İlk kullanımda kullanıcı adı ve API token'ı girerek `jenkins-config.bat` oluştur
3. Listeden bir proje seç
4. Gerekli parametreleri gir ve derlemeyi başlat
