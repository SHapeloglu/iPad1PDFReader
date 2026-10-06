# iPad1PDFReader

Özellikle **orijinal iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7** için yazılmış hafif ama gelişmiş bir PDF okuyucu.

Proje bilinçli olarak özellik sayısı yerine **kararlılığı, sınırlı belleği ve net sorumluluk sınırlarını** önceler.

## Güncel geliştirme durumu
Güncel kaynak, `v3.1.0-memorysafe` üzerine kurulu bir **v3.2 geliştirme sürümüdür**.

Son vurgulama/entegrasyon çalışmasından sonra hâlâ temiz derlenip fiziksel iPad 1'de doğrulanması gerekiyor. Bkz. `SESSION.md`.

## Ekosistem
Bu uygulama üç uygulamalı bir iPad 1 ekosisteminin parçasıdır:

```text
iPad1Files
  -> shared filesystem, copy/move/rename/delete, Open With

iPad1FTPDownloader
  -> FTP browse/download/upload/queue/resume

iPad1PDFReader
  -> PDF read/search/reflow/bookmark/annotation/page management
```

(iPad1Files: ortak dosya sistemi, kopyala/taşı/yeniden adlandır/sil, "Birlikte Aç" · iPad1FTPDownloader: FTP gezinme/indirme/yükleme/kuyruk/devam · iPad1PDFReader: PDF okuma/arama/yeniden akış/yer imi/notlandırma/sayfa yönetimi)

Uygulamalar birbirini **çoğaltmamalı, tamamlamalıdır**.

Standart ortak kök:

```text
/var/mobile/Media/iPad1Files
```

PDFReader ortak PDF'leri en az şu klasörlerden bulur:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

PDF devri:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Ortak PDF'ler gereksiz kopya oluşturmak yerine, güvenli olduğu yerde bulundukları konumda açılmalıdır.

## PDFReader özellikleri
- Core Graphics ile PDF görüntüleme;
- aynı anda tek aktif tam sayfa;
- iki parmakla yakınlaştırma;
- sayfa geçişlerinde yakınlaştırmanın korunması;
- çift dokunuşla yakınlaştırma;
- doğrudan sayfa numarasına gitme;
- yer imleri + son sayfadan devam;
- sınırlı küçük resimler;
- ilerleme/iptal destekli kademeli metin araması;
- sayfa sayfa Yeniden Akış (Reflow);
- içindekiler (outline) desteği;
- yer imleri/notlar/vurgular için Belge Gezgini;
- çizim;
- sayfa notları;
- bölge vurgulama;
- basit imza;
- notları PDF'e işleyerek (flatten) dışa aktarma;
- sayfa sıralama/silme/döndürme/dışa aktarma;
- PDF birleştirme altyapısı;
- iTunes Dosya Paylaşımı / "Birlikte Aç";
- iPad1Files ortak depolama devri.

## Güncel özellik aşaması: daha iyi vurgulama deneyimi
Normal metin için istenen akış:

```text
select text -> Highlight -> fluorescent color
```

(metni seç -> Vurgula -> fosforlu renk)

Hedef renkler:
- sarı;
- yeşil;
- pembe;
- turuncu;
- camgöbeği / açık mavi.

Metin katmanı olmayan taranmış/yalnız görsel PDF'lerde bölge vurgulama hafif yedek yöntem olarak kalır.

Gerçek metin vurgulama sayfa bazlı kalmalıdır; tüm belgeyi kapsayan metin/glif dizinine izin yoktur.

## Bellek politikası
Kesin kurallar:
- aynı anda tek aktif tam sayfa görüntüleme;
- küçük resim önbelleği en fazla **8**;
- arama sonucu en fazla **40**;
- arama sayfa sayfa;
- Yeniden Akış sayfa sayfa;
- Belge Gezgini not özeti en fazla **80**, tür başına en fazla **40**;
- tüm belgeyi kapsayan bitmap önbelleği yok;
- kalıcı tam belge metin dizini yok;
- cihaz üzerinde OCR yok;
- AI/ML yok;
- kontrolsüz paralel ağır iş yok;
- bellek uyarısında atılabilir durum temizlenir.

Tercih edilen mühendislik hedefleri:
- normal okumada yaklaşık **30–50 MB**;
- özel işlemlerde ideal olarak **70–90 MB**'nin oldukça altında.

## Bilinçli olarak devredilen özellikler
Bunları PDFReader içinde büyütme:
- genel dosya yöneticisi -> **iPad1Files**;
- FTP gezinme/indirme/yükleme/kuyruk/devam -> **iPad1FTPDownloader**.

Mevcut yerleşik HTTP/FTP/WebDAV yolları yalnızca bakım modundadır.

## Derleme
Beklenen ortam:
- `~/theos` altında Theos;
- eski `iPhoneOS6.1.sdk`.

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Hedef şu şekilde kalmalı:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Bu projede güncel iPhoneOS9.3 SDK'ya geçme.

## Dokümantasyon
Geliştirmeden önce oku:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `INTEGRATION.md`
4. `TASKS.md`
5. `TESTING.md`
6. `AGENTS.md`
7. `CLAUDE.md`
8. `README.md`

Ardından `SESSION.md -> Hemen yapılacak sonraki adım` bölümünden devam et.

## Altın kural
**Bir özellik Apple A4 / 256 MB RAM / iOS 5.1.1'de kararlılığı riske atıyorsa, onu sayfa bazlı/sınırlı olacak şekilde yeniden tasarla, doğru yardımcı uygulamaya taşı ya da hiç ekleme.**
