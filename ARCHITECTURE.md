# ARCHITECTURE.md

## Hedef
**Orijinal iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** üzerinde, kararlılığı özellik sayısına feda etmeden, pratikte mümkün olan en yetenekli PDF okuyucuyu yapmak.

## Değiştirilemez platform

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

- non-ARC / manuel retain-release;
- Theos;
- eski iPhoneOS 6.1 SDK;
- isteğe bağlı ve çalışma zamanında korumalı değilse iOS 5 sonrası bağımlılık yok.

## Özellik sınıflandırması
Her özellik yazılmadan önce sınıflandırılır:

- **Yeşil**: düşük bellekli, kademeli, tasarım gereği güvenli.
- **Sarı**: faydalı ama kesin sınırlar, sayfa bazlı işlem ve fiziksel cihaz profili gerektirir.
- **Kırmızı**: cihaz üzerinde uygulanmak üzere reddedilir.

Kırmızı örnekler:
- OCR;
- AI/ML;
- tüm belgeyi bitmap olarak görüntüleme;
- kalıcı tam belge metin dizinleri;
- yüksek çözünürlüklü çok sayfalı önbellekler;
- ağır bulut SDK'ları;
- ölçülmüş kanıt olmadan ağır bir PDF motoruyla değiştirme.

## Görüntüleme
`PDFPageView`, Core Graphics / `CGPDFDocument` kullanır.

Kurallar:
- aynı anda tek aktif tam sayfa görüntüle;
- belgenin tamamını asla önceden görüntüleme;
- birden fazla tam çözünürlüklü sayfa bitmap'ini asla tutma;
- bellek uyarısında atılabilir durumu temizle.

## Küçük resimler
`ThumbnailViewController` tembel (lazy) ve sınırlıdır.

Kesin önbellek sınırı:

```text
8 thumbnails
```

## Arama
`PDFTextExtractor` / `SearchViewController` sayfa sayfa, sıralı metin çıkarma kullanır.

Kurallar:
- her kademede tek sayfa;
- görünür ilerleme;
- kullanıcı iptali;
- bellekte kalıcı belge geneli metin dizini yok;
- tutulan sonuç en fazla **40**.

## Yeniden Akış (Reflow)
Yeniden akış sayfa kapsamlıdır. Belgenin tamamını asla tek büyük bir metinde birleştirme.

## Notlandırma mimarisi
`AnnotationStore` hafif sözlükleri saklar, `AnnotationOverlayView` bunları çizer.

Desteklenen / hafif türler:
- çizim;
- not;
- basit imza;
- bölge vurgulama;
- planlanan sayfa bazlı anlamsal metin vurgulama.

### Gerçek metin vurgulama
Gerçek metin vurgulama **Sarı** sınıftadır.

İzin verilen tasarım:
- yalnızca aktif sayfanın metin geometrisini çıkar/seç;
- geçici seçim geometrisini sayfa değişince/bellek uyarısında at;
- yalnızca sayfa + sıkıştırılmış dikdörtgen listesi + fosforlu renk sakla;
- belgenin tamamı önceden dizinlenmez;
- cihaz üzerinde OCR yedeği yok.

Hedef fosforlu palet:
- sarı;
- yeşil;
- pembe;
- turuncu;
- camgöbeği / açık mavi.

Yalnız görsel içeren/taranmış PDF'ler için bölge vurgulama yedek olarak kalır.

`PDFAnnotationExporter`, ileride profil aksini kanıtlamadıkça ağır, düzenlenebilir bir `/Annots` motoru yazmak yerine yeni ve notları işlenmiş (flattened) bir PDF üretmeye devam etmelidir.

## Belge gezinme
`DocumentNavigatorViewController` notlar/yer imleri arasında sınırlı gezinme sağlar.

Kesin sınırlar:
- not özeti öğesi en fazla **80**;
- tür başına en fazla **40**.

İçindekiler çözümlemesi hafif kalmalı ve desteklenmeyen adlandırılmış hedeflerde nazikçe başarısız olmalıdır.

## Sayfa işlemleri
`PageManager` / `PageManagerViewController`:
- yeniden sıralama;
- silme;
- döndürme;
- **yeni bir PDF'e** dışa aktarma;
- orijinali asla sessizce değiştirmez;
- yalnızca açıkça kaydedildikten sonra dışa aktarır.

## Ekosistem sınırı
Uygulama ailesi bilinçli olarak modülerdir:

```text
iPad1Files          -> filesystem backbone
iPad1FTPDownloader  -> FTP/network transfer specialist
iPad1PDFReader      -> PDF specialist
```

(iPad1Files: dosya sistemi omurgası · iPad1FTPDownloader: FTP/ağ transfer uzmanı · iPad1PDFReader: PDF uzmanı)

### iPad1Files'ın sorumlulukları
- gezinme / kopyalama / taşıma / yeniden adlandırma / silme;
- ortak klasörler;
- favoriler;
- "Birlikte Aç";
- dosya sınıflandırma / düzenleme.

### iPad1FTPDownloader'ın sorumlulukları
- uzak FTP gezinme;
- indirme / yükleme;
- kuyruk / devam / ilerleme / hız;
- kayıtlı sunucular;
- uzak dosya komutları.

### iPad1PDFReader'ın sorumlulukları
- PDF görüntüleme / okuma deneyimi;
- arama / yeniden akış;
- yer imi / içindekiler;
- notlandırma;
- sayfa yönetimi / dışa aktarma.

Yardımcı uygulamaların motorlarını PDFReader içinde çoğaltma.

## Ortak depolama
Standart kök:

```text
/var/mobile/Media/iPad1Files
```

PDFReader'ın doğrudan taradığı klasörler:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Uygulamalar arası sözleşme:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Ortak dosyalar güvenli olduğu yerde bulundukları konumda açılır; yinelenen fiziksel kopyalardan kaçınılır.

## Ağ
PDFReader'daki mevcut HTTP/FTP/WebDAV kodu **yalnızca bakım modundadır**.

Yalnızca özellik eşitliği için genişletme. iPad1FTPDownloader/iPad1Files devrini tercih et.

İleride somut bir ihtiyaç ve gerçek iPad RAM profili gerekçelendirmedikçe SMB/SFTP kütüphaneleri pakete eklenmez.

## Bellek yönetimi
Proje MRC kullanır.

Kurallar:
- açık sahiplik;
- geçici nesneleri agresif şekilde serbest bırak;
- tekrarlanan geçici işlerin etrafında yerel autorelease pool'lar;
- kontrolsüz paralel ağır iş yok;
- bellek uyarısında geçici metin/geometri/liste verisini temizle;
- kodlama kolaylığı için dağıtım hedefini asla yükseltme.

## Mühendislik RAM hedefleri
- normal okumada tercihen yaklaşık **30–50 MB**;
- özel işlemler ideal olarak **70–90 MB**'nin oldukça altında kalmalı;
- sürekli, sınırsız artış testten kalır.

## Ana bileşenler
- `AppDelegate` — başlatma + URL / "Birlikte Aç" devri.
- `PDFLibraryViewController` — yerel/ortak PDF bulma.
- `PDFReaderViewController` — okuyucu yönetimi.
- `PDFPageView` — aktif sayfayı görüntüleme.
- `BookmarkStore` — yer imi / son sayfa durumu.
- `AppearanceStore` — okuma görünümü.
- `ThumbnailViewController` — sınırlı küçük resimler.
- `PDFTextExtractor` / `SearchViewController` — kademeli arama.
- `ReflowViewController` — sayfa bazlı yeniden akış.
- `AnnotationStore` / `AnnotationOverlayView` — hafif notlandırma.
- `DocumentNavigatorViewController` — sınırlı belge gezinme.
- `PDFAnnotationExporter` — notları işlenmiş dışa aktarma.
- `PageManager` / `PageManagerViewController` — güvenli sayfa işlemleri.
- `PDFOutlineParser` / `OutlineViewController` — içindekiler işleme.
- eski ağ sınıfları — yalnızca uyumluluk için.
- `MemoryBudget` — açık iPad 1 sınırları.
