# SESSION.md

## Proje
**iPad1PDFReader** — orijinal iPad 1 için hafif ama gelişmiş PDF okuyucu.

Repo: `SHapeloglu/iPad1PDFReader`

## Değiştirilemez hedef
- Cihaz: **iPad 1**
- İşlemci: **Apple A4**
- RAM: **toplam 256 MB fiziksel RAM**
- İşletim sistemi: **iOS 5.1.1**
- Mimari: **armv7**
- Objective-C: **non-ARC / MRC**
- Derleme: **Theos**
- SDK: **eski iPhoneOS 6.1 SDK**
- Makefile hedefi şu şekilde kalmalı:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Yalnızca geliştirmeyi kolaylaştırmak için dağıtım hedefini/framework'leri güncelleme.

## Ekosistem mimarisi — belirleyici karar
Üç yardımcı uygulama, kod, RAM ve bakım çoğalmasın diye sorumlulukları bilinçli olarak paylaşır.

```text
iPad1Files
  -> shared filesystem backbone
  -> browse/copy/move/rename/delete/search/favorites/Open With

iPad1FTPDownloader
  -> FTP/network transfer specialist
  -> browse/download/upload/progress/queue/resume/remote operations

iPad1PDFReader
  -> PDF specialist
  -> render/read/search/reflow/bookmark/annotation/page management
```

(iPad1Files: ortak dosya sistemi omurgası · iPad1FTPDownloader: FTP/ağ transfer uzmanı · iPad1PDFReader: PDF uzmanı)

### Standart ortak kök

```text
/var/mobile/Media/iPad1Files
```

PDFReader için önemli ortak klasörler:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

PDFReader ortak PDF'leri güvenli olduğu yerde **bulundukları konumda** açmalıdır. Bir PDF'i bu uygulamalar arasında devretmek için yinelenen fiziksel kopyalar oluşturma.

### PDF URL devir sözleşmesi

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## Güncel geliştirme sürümü
Güncel kaynak, `v3.1.0-memorysafe` üzerine kurulu bir **v3.2 geliştirme sürümüdür**.

Kaynakta zaten bulunanlar:
- Core Graphics ile aktif sayfa görüntüleme;
- yakınlaştırma ortalama iyileştirmesi;
- sayfa değişimlerinde yakınlaştırma oranının korunması;
- yaklaşık görüntü alanı konumunun korunması;
- çift dokunuşla yakınlaştırma;
- doğrudan sayfa numarasına gitme;
- yer imleri ve son sayfadan devam;
- sınırlı küçük resimler;
- sayfa sayfa Yeniden Akış;
- sayfa notu ekleme/görüntüleme/düzenleme/silme;
- çizim, bölge vurgulama ve basit imza notları;
- yer imleri/notlar/vurgular için sınırlı `Belge Gezgini`;
- en fazla 40 sonuç tutan arama ilerlemesi + iptal;
- hafif doğrudan içindekiler hedefi çözümlemesi;
- Sayfa Yöneticisi'nde açık kaydet/dışa aktar;
- iPad1Files ortak PDFs/Downloads bulma;
- `ipad1pdf://` alıcı kaydı.

## Güncel vurgulama aşaması
Önceki "sürükleyerek dikdörtgen" vurgulama esas olarak taranmış/görsel PDF'ler için işe yarıyor, ancak normal metin PDF'leri için istenen birincil deneyim değil.

Hedef deneyim:

```text
select text -> Highlight -> fluorescent color
```

(metni seç -> Vurgula -> fosforlu renk)

Planlanan fosforlu palet:
- sarı;
- yeşil;
- pembe;
- turuncu;
- camgöbeği / açık mavi.

Son kullanılan vurgu rengi hatırlanabilir.

### Gerçek metin vurgulama için bellek kuralı
Bu özellik **Sarı** sınıftadır ve yalnızca sayfa sayfa yazılırsa izinlidir:
- yalnızca aktif sayfa işlenir;
- PDF'in tamamı dizinlenmez;
- belge geneli glif/kelime geometrisi tutulmaz;
- geçici seçim geometrisi sayfa değişiminde ve bellek uyarısında temizlenir;
- yalnızca sayfa + dikdörtgen(ler) + renk gibi küçük not verisi saklanır;
- PDF'te seçilebilir metin katmanı yoksa cihazda OCR yapılmaz; bunun yerine isteğe bağlı bölge vurgulama korunur.

Güncel kaynakta `AnnotationOverlayView` içinde erken bir vurgu rengi desteği var; kullanıcıya yönelik metin seçimi/renk akışı henüz tamamlanmış veya cihazda kanıtlanmış sayılmaz.

## Sıradaki düşük bellekli deneyim adayları
Güncel vurgulama aşaması ve fiziksel doğrulamadan sonra:
- vurgu rengini değiştirme/silme;
- not işaretine dokunarak açma/düzenleme;
- İçindekiler'i birleşik belge gezinme deneyimine ekleme;
- küçük, kesin üst sınırlı hafif okuma geçmişi / geri-ileri;
- yakınlaştırma/not hareketleriyle çakışmıyorsa isteğe bağlı sol/sağ kenara dokunarak sayfa çevirme;
- metin kopyalama, yalnızca sayfa bazlı metin seçimi çalışmasını güvenle yeniden kullanabiliyorsa.

## PDFReader'a bilinçli olarak EKLENMEYEN / BÜYÜTÜLMEYEN özellikler
Çünkü yardımcı uygulamalara aitler:
- genel dosya sistemi yöneticisi;
- gelişmiş kopyala/taşı/yeniden adlandır/favoriler arayüzü;
- FTP istemcisinin büyütülmesi;
- FTP transfer kuyruğu / devam motoru;
- genel ağ dosya gezgini.

Mevcut PDFReader HTTP/FTP/WebDAV kodu **yalnızca bakım modundadır**. Özellik eşitliği için büyütme.

## Kırmızı / cihaz üzerinde kapsam dışı
- OCR motoru;
- AI/ML çıkarımı;
- tüm belgeyi kapsayan bitmap önbelleği;
- kalıcı tam belge metin dizini;
- yüksek çözünürlüklü çok sayfalı ön-görüntüleme;
- güncel bulut SDK'ları;
- yalnızca eşitlik için ağır SMB/SFTP kütüphaneleri;
- gerçek cihazda ölçülmüş kanıt olmadan ağır yeni PDF motoru.

## Bellek bütçeleri
- aynı anda tek aktif tam PDF sayfası görüntüleme;
- küçük resim önbelleği en fazla **8**;
- arama sonucu sınırı **40**;
- Belge Gezgini not özeti en fazla **80**, tür başına en fazla **40**;
- Yeniden Akış sayfa kapsamlı;
- paralel ağır işlem yok;
- bellek uyarısında atılabilir durum temizlenir.

Tercih edilen mühendislik aralıkları:
- normal okumada yaklaşık **30–50 MB**;
- özel işlemler ideal olarak **70–90 MB**'nin oldukça altında;
- sınırsız her türlü büyüme başarısızlıktır.

## Güncel doğrulama durumu
En yeni vurgu rengi çalışması dahil son geliştirme kaynağı, temiz derlenip fiziksel iPad 1'de test edilene kadar **kanıtlanmış bir sürüm değildir**.

## Derleme ortamı
WSL Ubuntu + Theos + eski iPhoneOS6.1 SDK.

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

iPhoneOS9.3 SDK'ya geçme; daha önce simülatör `.tbd` uyarılarına ve armv7 `liblaunch.dylib` bağlama hatasına yol açtı.

## Hemen yapılacak sonraki adım
1. Güncel `main`'i çek/indir.
2. `SESSION.md`, `ARCHITECTURE.md`, `INTEGRATION.md`, `TASKS.md`, `TESTING.md`, `AGENTS.md`, `CLAUDE.md`, `README.md` dosyalarını oku.
3. Tüm belgeyi dizinlemeden **sayfa bazlı gerçek metin vurgulama + fosforlu renk deneyimini** bitir.
4. Dikdörtgen/bölge vurgulamayı yalnızca seçilebilir metni olmayan PDF'ler için yedek olarak tut.
5. Eski toolchain ile temiz derle.
6. Platform kısıtlarını değiştirmeden yalnızca gerçek eski-derleyici hatalarını düzelt.
7. Fiziksel iPad 1'e kur.
8. `TESTING.md`'deki vurgulama, entegrasyon ve bellek testlerini çalıştır.
9. Bu aşama kararlı olmadan daha ağır özelliklere başlama.

## Yeni sohbet başlangıç metni
Yeni bir konuşmada bunu kullan:

```text
https://github.com/SHapeloglu/iPad1PDFReader projesine devam ediyoruz.
Kodu değiştirmeden önce SESSION.md, ARCHITECTURE.md, INTEGRATION.md, TASKS.md,
TESTING.md, AGENTS.md, CLAUDE.md ve README.md dosyalarını oku.
Tam olarak SESSION.md -> "Hemen yapılacak sonraki adım" bölümünden devam et.
iPad 1 / A4 / 256 MB / iOS 5.1.1 / armv7 / non-ARC / Theos kısıtlarını koru.
iPad1Files veya iPad1FTPDownloader sorumluluklarını çoğaltma.
```
