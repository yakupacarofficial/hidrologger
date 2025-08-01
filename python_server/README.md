# Python WebSocket Server

Bu Python WebSocket sunucusu, Flutter uygulamasına JSON verileri yayınlamak için kullanılır.

## Kurulum

1. Gerekli kütüphaneleri yükleyin:
```bash
pip install -r requirements.txt
```

## Çalıştırma

Sunucuyu başlatmak için:
```bash
python server.py
```

Sunucu varsayılan olarak `0.0.0.0:8765` adresinde çalışacaktır.

## Özellikler

- ✅ WebSocket sunucusu (0.0.0.0:8765)
- ✅ Client bağlantı yönetimi
- ✅ 1 saniye aralıklarla JSON veri yayını
- ✅ Hata yönetimi ve loglama
- ✅ Otomatik client temizleme
- ✅ Graceful shutdown

## JSON Formatı

Şu anda boş JSON yapısı kullanılmaktadır. Format kullanıcı tarafından belirtilecektir.

## Loglar

Sunucu çalışırken tüm işlemler terminal üzerinden takip edilebilir. 