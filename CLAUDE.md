# CLAUDE.md

Kodu değiştirmeden önce `SESSION.md`, `ARCHITECTURE.md`, `INTEGRATION.md`, `TASKS.md`, `TESTING.md` ve `AGENTS.md` dosyalarını oku.

## Temel kural
**iPad 1 kararlılığını asla özellik sayısıyla takas etme.**

Kalıcı hedef:
- iPad 1 / Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- non-ARC / MRC
- Theos + eski iPhoneOS6.1 SDK

## Ekosistem kuralı
iPad1PDFReader'ı monolitik bir uygulamaya dönüştürme.

- Yerel dosya yönetimi / ortak depolama / "Birlikte Aç" iPad1Files'ındır.
- FTP transferi / gezinme / kuyruk / devam iPad1FTPDownloader'ındır.
- PDF okuma / arama / yeniden akış / notlandırma / sayfa işlemleri iPad1PDFReader'ındır.

Motorları çoğaltmak yerine hafif devri tercih et.

## Kod stili
- iOS 5 ile uyumlu eski Objective-C;
- açık manuel bellek sahipliği;
- önce Foundation / UIKit / CoreGraphics;
- kontrolsüz eşzamanlılıktan kaçın;
- geçici metin / görsel / geometri kısa ömürlü olsun;
- liste ve önbelleklerde kesin üst sınırlar;
- desteklenmeyen PDF yapılarında nazikçe başarısız ol.

## Güncel geliştirme önceliği
Fosforlu renklerle, yalnızca sayfa bazlı gerçek metin vurgulama.

Tüm belgeyi kapsayan metin/glif dizini oluşturma. OCR/AI ekleme. Görsel PDF'ler için bölge vurgulamayı yedek olarak koru.

## Yeni sohbette devam
Her zaman şuradan devam et:

```text
SESSION.md -> Hemen yapılacak sonraki adım
```

Repo dokümantasyonu aksini söylüyorsa daha eski bir sohbet durumunu varsayma.
