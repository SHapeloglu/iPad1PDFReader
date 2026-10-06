# INTEGRATION.md

## Amaç
Bu dosya iPad 1 uzman uygulamaları arasındaki belirleyici entegrasyon sözleşmesidir.

Amaç, uygulamaların motorları, depolamayı veya bellek ağırlıklı özellikleri çoğaltmadan birbirini tamamlamasıdır.

## Platform sözleşmesi
Tüm entegrasyonlar şunları korumalıdır:
- iPad 1;
- Apple A4;
- 256 MB RAM;
- iOS 5.1.1;
- armv7;
- non-ARC / MRC;
- Theos;
- eski iPhoneOS 6.1 SDK uyumluluğu.

## Sorumluluk dağılımı

### iPad1Files
Standart ortak depolama, yerel dosya/klasör gezinme, kopyala/taşı/yeniden adlandır/sil, seçiciler, favoriler, yerel arama, ZIP/arşiv ve uygulamalar arası açmadan sorumludur. Ağ transferi, PDF görüntüleme veya medya oynatma motoruna dönüşmemelidir.

### iPad1FTPDownloader
FTP bağlantısı, uzak gezinme, FTP indirme/yükleme, FTP transfer durumu, kayıtlı sunucular ve uzak FTP işlemlerinden sorumludur. Genel HTTP/HTTPS indirme yazmamalıdır.

### iPad1HTTPDownloader
HTTP/HTTPS URL indirmeleri, yönlendirmeler, yanıt/başlık işleme, akışla yazma, `.part` yaşam döngüsü, ilerleme/hız/kalan süre, desteklenen yerde Range ile devam, iptal/yeniden deneme, sınırlı kuyruk ve HTTP'ye özgü hatadan kurtarmadan sorumludur. Dosya yöneticisine, PDF okuyucuya veya medya oynatıcıya dönüşmemelidir.

### iPad1PDFReader
PDF görüntüleme, yakınlaştırma/gezinme, arama/yeniden akış, yer imleri, içindekiler, notlandırma/vurgu/not/imza ve PDF sayfa işlemleri/dışa aktarmadan sorumludur. HTTP/FTP transfer motorlarını çoğaltmamalıdır.

### iPad1Player
Yerel medya çözme/oynatma, ileri sarma, codec'ler ve altyazı bulma/göstermeden sorumludur. İndirici uygulamalardan yalnızca tamamlanmış ve erişilebilir yerel medya yollarını alır.

## Standart ortak dosya sistemi
iPad1Files'a ait:

```text
/var/mobile/Media/iPad1Files
```

Ortak klasörler: `Downloads/`, `Documents/`, `PDFs/`, `Images/`, `Music/`, `Videos/`, `Archives/`, `Shared/`, `Temp/` ve `AppData/`.

## İndirici depolama sözleşmesi
Hem FTP hem HTTP indiricileri tamamlanan dosyaları doğrudan standart ortak depolamaya, normalde şuraya yazmalıdır:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Bir mantıksal transfer bir fiziksel dosya üretmelidir. Tamamlanan bir dosyayı yalnızca entegrasyon için indiriciye veya okuyucuya özel bir klasöre kopyalama.

## Tamamlanan dosyanın yönlendirilmesi
Transfer başarıyla bittikten ve yalnızca yerel dosya erişilebilir olduktan sonra:

```text
.mkv/.mp4/.mov/.m4v/.avi -> ipad1player://open?path=<percent-encoded-absolute-path>
.pdf                     -> ipad1pdf://open?path=<percent-encoded-absolute-path>
other                    -> ipad1files://show?path=<percent-encoded-absolute-path>
```

Gönderen aynı fiziksel dosya yolunu iletir. Entegrasyon için kopyalamaya izin yoktur.

## PDFReader bulma sözleşmesi
PDFReader en az şu klasörleri doğrudan taramalıdır:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

İzinler elverdiği ölçüde ortak PDF'ler bulundukları yerde açılmalıdır.

## PDF devri URL scheme'i
Belirleyici alıcı sözleşmesi:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Kurallar:
- gönderen mutlak yol iletir;
- yol yüzde-kodlanmış olmalıdır;
- PDFReader açmadan önce dosyanın varlığını ve `.pdf` türünü doğrular;
- ortak dosyalar yalnızca devir nedeniyle kopyalanmamalıdır;
- sıradan harici "Birlikte Aç" dosyaları gerektiğinde yine uygulamaya ait kalıcı bir konuma kopyalanabilir.

## Ağ politikası
PDFReader içindeki mevcut hafif HTTP/FTP/WebDAV kodu yalnızca bakım modundadır. Yeni HTTP/HTTPS indirme özellikleri iPad1HTTPDownloader'a, FTP transfer özellikleri iPad1FTPDownloader'a aittir.

PDFReader'a yalnızca rakiplerle eşitlenmek için `libsmb2`, `libssh2`, bulut SDK'ları veya başka ağır yığınlar ekleme.

## iPad 1 bellek politikası
- cihaz üzerinde OCR veya AI/ML yok;
- dosyanın tamamını tutan indirme tamponları yok;
- yinelenen entegrasyon kopyaları yok;
- uygulamalar arası sözleşmeler yol tabanlı ve hafif kalır.

## Değişiklik kontrol kuralı
Standart kök, ortak klasör adları, URL scheme'leri, uygulama sorumluluk sınırları veya AppData ad alanlarındaki her değişiklik, aynı geliştirme aşamasında ilgili entegrasyon/devir dokümantasyonunu da güncellemelidir. Belirleyici olan fiziksel iPad testidir.
