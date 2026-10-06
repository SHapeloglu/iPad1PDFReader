# CHANGELOG.md

## v3.2 geliştirme sürümü — 2026-08-18
- Yakınlaştırmayı ortalama ve yakınlaştırmanın korunması için kullanıcı deneyimi iyileştirmeleri eklendi.
- Çift dokunuşla yakınlaştırma ve doğrudan sayfa numarasına gitme eklendi.
- Yer imleri, notlar ve vurgular için sınırlı Belge Gezgini eklendi.
- Sayfa sayfa kademeli arama ilerlemesi ve İptal eklendi; en fazla 40 sonuç.
- Çözümlenebildiği yerlerde hafif içindekiler hedefi gezinmesi eklendi.
- Sayfa notu ekleme/görüntüleme/düzenleme/silme eklendi.
- Hafif bölge vurgulama akışı eklendi ve fosforlu vurgu rengi desteğine başlandı.
- Sıradaki aşama: sarı/yeşil/pembe/turuncu/camgöbeği paletiyle sayfa bazlı seçilebilir metin vurgulama.
- Sayfa Yöneticisi artık yalnızca açıkça kaydedildikten sonra dışa aktarıyor ve yeni bir PDF yazıyor.
- iPad1Files'ın `PDFs` ve `Downloads` klasörlerinden ortak PDF bulma eklendi.
- `ipad1pdf://open?path=...` devri ve ortak dosyayı yerinde açma politikası tanımlandı.
- Modüler uygulama ayrımı resmileştirildi: iPad1Files = dosya yönetimi, iPad1FTPDownloader = FTP transferi, iPad1PDFReader = PDF özellikleri.
- PDFReader'ın yerleşik HTTP/FTP/WebDAV kodu yalnızca bakım modunda.
- OCR, AI/ML, tüm belgeyi kapsayan önbellekler/dizinler ve ağır ağ SDK'ları kapsam dışında kalmaya devam ediyor.
- Sürüm etiketlemeden önce fiziksel iPad 1 doğrulaması hâlâ gerekli.

## 3.1.0-memorysafe
- Açık `MemoryBudget` politikası eklendi.
- Küçük resim önbelleği 8 küçük görselle sınırlandı.
- Küçük resim önbelleği bellek uyarısında temizleniyor.
- Arama sonuçları 40 ile sınırlandı.
- Yeniden Akış, metni sayfa sayfa yükleyecek şekilde değiştirildi.
- Bellek uyarısı temizlik yolları eklendi.
- Cihaz üzerinde OCR / AI / büyük çok sayfalı bitmap önbelleği olmadığı yeniden teyit edildi.

## 3.0.0
- `CGPDFScanner` ile içerik akışından metin çıkarma/arama eklendi.
- Yeniden Akış okuma modu eklendi.
- WebDAV / ağ merkezi temeli eklendi.
- Sayfa yöneticisi ve PDF birleştirme/dışa aktarma altyapısı eklendi.
- Notları PDF'e işleyerek dışa aktarma eklendi.
- İsteğe bağlı SMB/SFTP bağlayıcı yer tutucuları eklendi.

## 2.x geliştirme
- Küçük resimler, temalar, arama denemeleri, notlandırma, URL'den içe aktarma, içindekiler desteği ve dosya yönetimi uzantıları eklendi.

## 1.0.0
- iPad 1 için ilk çalışan PDF okuyucu.
- Core Graphics ile tek sayfa görüntüleme.
- PDF kütüphanesi, yakınlaştırma, önceki/sonraki, yer imleri, son sayfadan devam, Dosya Paylaşımı.
- `TARGET = iphone:clang:6.1:5.1` ve eski iPhoneOS6.1 SDK ile derlendiği kanıtlandı.
