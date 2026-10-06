# TESTING.md

## Doğruluk kaynağı
Doğruluk kaynağı fiziksel **iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** cihazıdır. Yalnızca simülatörde başarı yeterli değildir.

## Derleme doğrulaması

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Gerekenler:
- armv7;
- en düşük iOS 5.1;
- eski iPhoneOS 6.1 SDK;
- non-ARC / MRC.

`building for iOS 5.1.0 is deprecated` uyarısı kabul edilebilir.
iPhoneOS9.3.sdk kaynaklı simülatör `.tbd` / armv7 bağlayıcı belirtilerini kabul etme.

## Temel duman testi
- [ ] Uygulama açılıyor.
- [ ] Kütüphane açılıyor.
- [ ] Yerel PDF açılıyor.
- [ ] Önceki/sonraki çalışıyor.
- [ ] İki parmakla yakınlaştırma zıplamıyor / sola kaymıyor.
- [ ] Yakınlaştırma oranı sayfa değişiminde korunuyor.
- [ ] Yakınlaştırılmışken sayfa değişince yaklaşık okuma konumu korunuyor.
- [ ] Çift dokunuşla yakınlaştırma çalışıyor ve 1x'e dönüyor.
- [ ] Doğrudan sayfa numarasına gitme aralığı doğruluyor.
- [ ] Son sayfa hatırlanıyor.
- [ ] Yer imi hatırlanıyor.

## iPad1Files entegrasyonu
- [ ] `/var/mobile/Media/iPad1Files/PDFs` içindeki PDF'ler görünüyor.
- [ ] `/var/mobile/Media/iPad1Files/Downloads` içindeki PDF'ler görünüyor.
- [ ] Ortak PDF bulunduğu yerde açılıyor.
- [ ] Ortak PDF'i açmak uygulamanın Documents klasöründe sessizce kopya oluşturmuyor.
- [ ] `ipad1pdf://open?path=...` istenen mevcut PDF'i açıyor.
- [ ] Geçersiz / olmayan yol güvenle başarısız oluyor.

## Arama
- [ ] 100+ sayfalık metin PDF'inde arama kademeli ilerliyor.
- [ ] Sayfalar arasında arayüz yanıt veriyor.
- [ ] İptal aramayı güvenle durduruyor.
- [ ] Sonuçlar 40 ile sınırlı kalıyor.
- [ ] Kalıcı tam belge metin dizini oluşmuyor.
- [ ] 10 kez ara/iptal et; kademeli yavaşlama/çökme yok.

## Belge Gezgini
- [ ] Yer imleri doğru listeleniyor.
- [ ] Notlar doğru listeleniyor.
- [ ] Vurgular doğru listeleniyor.
- [ ] Bir öğe seçilince doğru sayfaya gidiliyor.
- [ ] Not özeti toplam en fazla 80, tür başına en fazla 40 kalıyor.
- [ ] 200+ sayfalık PDF'te tekrar tekrar aç/kapat belleği kademeli büyütmüyor.

## İçindekiler
- [ ] Doğrudan `/Dest` içindekiler hedefi doğru sayfaya gidiyor.
- [ ] Doğrudan `/A /GoTo` dizi hedefi doğru sayfaya gidiyor.
- [ ] Desteklenmeyen / adlandırılmış hedef çökmeden nazikçe başarısız oluyor.

## Vurgulama — güncel öncelik
### Seçilebilir metinli PDF
- [ ] Metin seçimi yalnızca aktif sayfanın geçici geometrisini kullanıyor.
- [ ] Seçilen metin vurgulanabiliyor.
- [ ] Sarı fosforlu renk doğru görünüyor.
- [ ] Yeşil fosforlu renk doğru görünüyor.
- [ ] Pembe fosforlu renk doğru görünüyor.
- [ ] Turuncu fosforlu renk doğru görünüyor.
- [ ] Camgöbeği / açık mavi fosforlu renk doğru görünüyor.
- [ ] Vurgu saydamlığından metin okunabilir kalıyor.
- [ ] Yazıldıysa son kullanılan renk hatırlanıyor.
- [ ] Sayfa değişimi geçici seçim durumunu temizliyor.
- [ ] Bellek uyarısı geçici seçim durumunu temizliyor.
- [ ] Sayfaya dönünce kayıtlı vurgu sıkıştırılmış not verisinden yeniden çiziliyor.

### Metin katmanı olmayan görsel/taranmış PDF
- [ ] Gerçek metin seçimi nazikçe başarısız oluyor.
- [ ] Cihazda OCR başlamıyor.
- [ ] İsteğe bağlı bölge/dikdörtgen vurgulama yedek olarak kullanılabilir kalıyor.

### Vurgu bakımı
Yazıldığında:
- [ ] Mevcut vurguya dokun/seç.
- [ ] Rengini değiştir.
- [ ] Vurguyu sil.
- [ ] Notları işlenmiş dışa aktarma rengi koruyor.

## Notlar
- [ ] Not ekle.
- [ ] Notu görüntüle.
- [ ] Notu düzenle.
- [ ] Notu sil.
- [ ] Not sayfaya özgü kalıyor.
- [ ] Özellik yazıldığında işarete dokunarak açma.

## Sayfa Yöneticisi
Silinebilir PDF'ler kullan.
- [ ] Sayfaları yeniden sırala.
- [ ] Sayfa sil.
- [ ] Sayfa döndür.
- [ ] Açıkça kaydetmeden çıkınca çıktı oluşmuyor.
- [ ] `Kaydet` yeni, düzenlenmiş bir PDF oluşturuyor.
- [ ] Orijinal bozulmadan kalıyor.

## Küçük resim bellek testi
- [ ] 100+ sayfalık PDF aç.
- [ ] Sona ve geri tekrar tekrar kaydır.
- [ ] Önbellek en fazla 8 küçük resim kalıyor.
- [ ] Bellek baskısından sonra önbellek toparlanabiliyor.

## Yeniden Akış bellek testi
- [ ] 30+ sayfa boyunca ilerle.
- [ ] Yalnızca güncel / sayfa kapsamlı metin tutuluyor.
- [ ] Yazı boyutu kontrolleri yanıt veriyor.

## Uzun okuma kararlılığı
- [ ] Büyük bir PDF'i 10+ dakika açık tut.
- [ ] 1x -> en büyük -> 1x yakınlaştırmayı tekrarla.
- [ ] 1x'te hızlı sayfa değiştir.
- [ ] Yakınlaştırılmışken hızlı sayfa değiştir.
- [ ] Dikey/yatay tekrar tekrar döndür.
- [ ] Birden fazla PDF'i art arda aç/kapat.
- [ ] Kademeli yavaşlama veya çökme yok.

## Bellek uyarısı
Baskı altında doğrula:
- [ ] küçük resim önbelleği temizleniyor;
- [ ] atılabilir arama sonuçları/durumu güvenle temizlenebiliyor;
- [ ] geçici vurgu / metin seçimi geometrisi temizleniyor;
- [ ] Belge Gezgini geçici özeti temizlenebiliyor;
- [ ] güncel PDF/sayfa kurtarılabilir kalıyor.

## Yardımcı uygulama sınırı regresyonu
PDFReader dosya yöneticisi veya FTP istemcisi olarak genişletilmiyor.

- [ ] Mevcut eski HTTP/FTP/WebDAV uyumluluğu bozulmuyor.
- [ ] Buraya yeni transfer kuyruğu / devam alt sistemi eklenmiyor.
- [ ] Ortak dosya yönetimi iPad1Files'a devredilmiş kalıyor.
- [ ] FTP transfer işi iPad1FTPDownloader'a devredilmiş kalıyor.

## RAM mühendislik hedefleri
- normal okuma: tercihen yaklaşık **30–50 MB**;
- özel işlemler: ideal olarak **70–90 MB**'nin oldukça altında;
- hiçbir özellik sınırsız diziler, tüm belge metnini tutma veya çok sayfalı tam çözünürlüklü bitmap önbelleği getiremez;
- sürekli, sınırsız bellek artışı test başarısızlığıdır.
