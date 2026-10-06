# TASKS.md

## Öncelik 0 — güncel geliştirme sürümünü bitir ve kanıtla
- [ ] Güncel `main`'i çek ve eski Theos/iPhoneOS6.1 SDK ile temiz derle.
- [ ] `ARCHS = armv7` ve `TARGET = iphone:clang:6.1:5.1` değerlerini değiştirme.
- [ ] Yalnızca gerçek iOS 5.1.1 / MRC derleme sorunlarını düzelt.
- [ ] Fiziksel iPad 1'e kur.
- [ ] iPad1Files'tan gelen ortak PDF'lerin yinelenen kopya olmadan açıldığını doğrula.
- [ ] `ipad1pdf://open?path=...` devrini doğrula.
- [ ] Yakınlaştırma ortalama, yakınlaştırmanın korunması, çift dokunuş ve sayfa numarasına gitmeyi doğrula.
- [ ] Belge Gezgini, arama ilerlemesi/iptali, içindekiler sayfa atlamaları ve Sayfa Yöneticisi'nde açık kaydetmeyi doğrula.

## Öncelik 1 — gerçek metin vurgulama + fosforlu palet
Güncel ana özellik aşaması.

- [ ] Metin seçerek vurgulamayı yalnızca aktif sayfa için yaz.
- [ ] Tüm belgeyi kapsayan metin/glif dizini oluşturma.
- [ ] Geçici seçim geometrisini sınırlı tut ve sayfa değişince temizle.
- [ ] Bellek uyarısında geçici seçim durumunu temizle.
- [ ] Fosforlu renkleri ekle:
  - [ ] sarı
  - [ ] yeşil
  - [ ] pembe
  - [ ] turuncu
  - [ ] camgöbeği / açık mavi
- [ ] Son kullanılan vurgu rengini hafif bir kalıcılıkla hatırla.
- [ ] Yalnızca sıkıştırılmış vurgu verisini sakla: sayfa + dikdörtgen(ler) + renk.
- [ ] Taranmış/görsel PDF'ler için dikdörtgen bölge vurgulamayı yedek olarak koru.
- [ ] Seçilebilir metin katmanı yoksa nazikçe başarısız ol; cihaz üzerinde asla OCR başlatma.
- [ ] Notları işlenmiş dışa aktarmanın seçilen vurgu renklerini koruduğundan emin ol.

## Öncelik 2 — vurgulama kararlı olduktan sonra notlandırma/belge deneyimi
- [ ] Mevcut vurguya dokun -> rengini değiştir / sil.
- [ ] Not işaretine dokun -> notu doğrudan aç.
- [ ] Düşük maliyetliyse İçindekiler'i birleşik belge gezinmesine dahil et.
- [ ] Küçük ve kesin üst sınırlı (ör. 10–20 konum) okuma geçmişi / geri-ileri ekle.
- [ ] Sol/sağ kenara dokunarak sayfa çevirmeyi yalnızca yakınlaştırma/not hareketleriyle çakışmıyorsa düşün.
- [ ] Metin kopyalamayı yalnızca sayfa bazlı seçim durumunu güvenle yeniden kullanabiliyorsa ekle.

## Öncelik 3 — bellek/kararlılık doğrulaması
- [ ] 100+ sayfada küçük resim kaydırma; önbellek en fazla 8 kalıyor.
- [ ] Arama sonuçları en fazla 40 kalıyor.
- [ ] Tekrar tekrar ara/iptal et; kademeli büyüme yok.
- [ ] Yeniden akış sayfa bazlı kalıyor.
- [ ] Belge Gezgini 80 not özeti öğesi, tür başına en fazla 40 ile sınırlı kalıyor.
- [ ] Birkaç büyük PDF'i art arda aç/kapat.
- [ ] 10 dakika boyunca yakınlaştır/sayfa değiştir.
- [ ] Yakınlaştırılmışken tekrar tekrar döndür.
- [ ] Bellek baskısı oluştur ve geçici seçim verisinin bırakıldığını doğrula.
- [ ] 50+ ve 200+ sayfalık PDF'leri test et.

## Yardımcı uygulama sınırı — çoğaltma
### iPad1Files'a bırakılır
- [ ] PDFReader'da genel kopyala/taşı/yeniden adlandır/sil gezgin özellikleri yazma.
- [ ] Favorileri / dosya düzenlemeyi / "Birlikte Aç" kaydını çoğaltma.

### iPad1FTPDownloader'a bırakılır
- [ ] PDFReader'da FTP gezinme/indirme/yükleme/kuyruk/devam özelliklerini genişletme.
- [ ] Mevcut PDFReader FTP/WebDAV kodu yalnızca bakım modunda.

## Cihaz üzerinde açıkça kapsam dışı
- [ ] OCR motoru yok.
- [ ] AI/ML çıkarımı yok.
- [ ] Tüm belgeyi kapsayan yüksek çözünürlüklü bitmap önbelleği yok.
- [ ] Kalıcı tam belge metin dizini yok.
- [ ] Büyük arka plan dizinleme servisi yok.
- [ ] Güncel bulut sağlayıcı SDK'ları yok.
- [ ] Yalnızca rakip eşitliği için SMB/SFTP kütüphanesi yok.
- [ ] Fiziksel cihazda ölçülmüş kanıt olmadan ağır yeni PDF motoru yok.

## "Bitti" tanımı
Bir özellik ancak şu durumda tamamlanmış sayılır:
- eski hedefle derleniyor;
- fiziksel iPad 1'de çalışıyor;
- bellek kullanımı sınırlı;
- ilgili `TESTING.md` kontrolleri geçiyor;
- dokümanlar güncellendi.
