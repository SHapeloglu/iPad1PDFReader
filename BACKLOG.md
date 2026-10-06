# BACKLOG.md — iPad1PDFReader

Planlı işler: `TASKS.md` (Ö0 güncel sürümü cihazda kanıtla → Ö1 gerçek metin vurgulama + fosforlu palet → Ö2 notlandırma/belge deneyimi → Ö3 bellek/kararlılık). Her fikir `TASKS.md`'ye geçmeden önce `ARCHITECTURE.md`'ye göre **Yeşil / Sarı / Kırmızı** olarak sınıflandırılmalıdır.

## Sarı — kesin sınırlar ve cihaz profiliyle mümkün

- Aktif sayfadan metin kopyalama (yalnızca sayfa bazlı seçim durumu yeniden kullanılır).
- Sınırlı okuma geçmişi / geri-ileri (10–20 konum).
- Yakınlaştırma/not hareketleriyle çakışmıyorsa kenara dokunarak sayfa çevirme.
- Düşük maliyetliyse birleşik belge gezgininde İçindekiler.
- Sayfa bazlı renk dönüşümüyle gece/sepya görüntüleme modu.
- Belge başına son yakınlaştırma / son sayfayı geri yükleme (yalnızca sıkıştırılmış metadata).

## Kırmızı — cihaz üzerinde reddedildi (tekrar önerilmesin diye burada kayıtlı)

OCR · AI/ML çıkarımı · tüm belgeyi kapsayan yüksek çözünürlüklü bitmap önbelleği · kalıcı tam belge metin dizini · büyük arka plan dizinleme · güncel bulut SDK'ları · eşitlik için SMB/SFTP kütüphaneleri · ölçülmüş kanıt olmadan ağır yeni PDF motoru.

## Yalnızca bakım modundaki alanlar

Mevcut HTTP/FTP/WebDAV içe aktarma kodu (`URLImportViewController`, `WebDAVClient`, `NetworkCenterViewController`) — yalnızca hata düzeltilir; yeni transfer özellikleri iPad1FTPDownloader / iPad1Files devrine aittir.
