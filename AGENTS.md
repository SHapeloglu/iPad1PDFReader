# AGENTS.md

## Önce oku
Bu repoda değişiklik yapmadan önce şu sırayla oku:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `INTEGRATION.md`
4. `TASKS.md`
5. `TESTING.md`
6. `README.md`
7. `CLAUDE.md`

Ardından `SESSION.md -> Hemen yapılacak sonraki adım` bölümünden devam et.

## Değiştirilemez platform
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- non-ARC / manuel retain-release
- Theos
- eski iPhoneOS 6.1 SDK

Zorunlu Makefile hedefi:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Yalnızca kolaylık için dağıtım hedefini yükseltme veya iOS 5 sonrasına ait, mevcut olmayan API'leri ekleme.

## Üç uygulamalı ekosistem sınırı
Kardeş uygulamaların sorumluluklarını çoğaltma.

```text
iPad1Files          = shared filesystem/file management/Open With
iPad1FTPDownloader  = FTP browse/download/upload/queue/resume
iPad1PDFReader      = PDF rendering/search/reflow/annotation/page management
```

(iPad1Files = ortak dosya sistemi / dosya yönetimi / "Birlikte Aç"; iPad1FTPDownloader = FTP gezinme / indirme / yükleme / kuyruk / devam; iPad1PDFReader = PDF görüntüleme / arama / yeniden akış / notlandırma / sayfa yönetimi)

PDFReader'daki eski HTTP/FTP/WebDAV kodu yalnızca bakım modundadır. Rakiplerle eşitlenmek için büyütme.

Standart ortak kök:

```text
/var/mobile/Media/iPad1Files
```

PDF devri:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## Özellik sınıflandırması
- **Yeşil**: düşük bellekli / kademeli -> genelde güvenli.
- **Sarı**: kesin üst sınırlar, sayfa bazlı çalışma ve cihaz profili gerektirir.
- **Kırmızı**: cihaz üzerinde reddedilir.

Kırmızı örnekler:
- OCR;
- AI/ML;
- tüm belgeyi kapsayan bitmap önbellekleri;
- kalıcı tam belge metin dizini;
- büyük bulut SDK'ları;
- ölçülmüş bir ihtiyaç olmadan ağır PDF/ağ motorları.

## Kesin bellek kuralları
- aynı anda tek aktif tam sayfa görüntüleme;
- küçük resim önbelleği en fazla 8;
- arama sonucu en fazla 40;
- arama sayfa sayfa;
- Yeniden akış (Reflow) sayfa sayfa;
- Belge Gezgini not özeti en fazla 80, tür başına en fazla 40;
- paralel ağır iş yok;
- bellek uyarısında atılabilir durum temizlenir;
- MRC sahiplik doğruluğu zorunludur.

## Güncel öncelik
Sayfa bazlı **gerçek metin vurgulama + fosforlu renk** deneyimini tamamla.

Kurallar:
- yalnızca aktif sayfa;
- tüm belgeyi kapsayan glif/metin dizini yok;
- geçici seçim geometrisi sayfa değişince/bellek uyarısında serbest bırakılmalı;
- yalnızca sıkıştırılmış dikdörtgen(ler) + renk saklanır;
- görsel/taranmış PDF'lerde bölge vurgulama yedeği kullanılabilir;
- taranmış PDF'leri seçilebilir yapmak için asla OCR ekleme.

## "Bitti" tanımı
Bir özellik şu koşullar sağlanmadan bitmiş sayılmaz:
- eski toolchain ile derleme başarılı;
- fiziksel iPad 1 testi başarılı;
- bellek sınırlı;
- ilgili `TESTING.md` kontrolleri geçti;
- dokümantasyon güncellendi.
