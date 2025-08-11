# 🏭 BYCOZ - Depolar Arası Sevk Yönetim Sistemi

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Mobile](https://img.shields.io/badge/Mobile-Android%20%7C%20iOS-000000?style=for-the-badge&logo=mobile&logoColor=white)

**Modern ve kullanıcı dostu depolar arası sevk yönetim uygulaması**

[🚀 Özellikler](#-özellikler) • [📱 Ekran Görüntüleri](#-ekran-görüntüleri) • [🛠️ Kurulum](#️-kurulum) • [📖 Kullanım](#-kullanım) • [🔧 Teknik Detaylar](#-teknik-detaylar) • [🤝 Katkıda Bulunma](#-katkıda-bulunma)

</div>

---

## 🚀 Özellikler

### 📋 Ana Özellikler
- **Depolar Arası Sevk Yönetimi**: Gönderen ve alıcı depolar arasında ürün sevk işlemleri
- **Barkod Tarama**: QR kod ve barkod tarama ile hızlı ürün seçimi
- **Gerçek Zamanlı Veri**: API entegrasyonu ile anlık veri güncellemeleri
- **Çoklu Para Birimi Desteği**: TL, USD, EUR para birimi desteği
- **Responsive Tasarım**: Tüm ekran boyutlarında mükemmel görünüm

### 🎯 Kullanıcı Deneyimi
- **Modern UI/UX**: Material Design 3 prensipleri ile tasarlanmış arayüz
- **Sezgisel Navigasyon**: Alt navigasyon ile kolay sayfa geçişleri
- **Modal Dialoglar**: Kullanıcı dostu modal pencereler
- **Arama ve Filtreleme**: Ürün arama ve filtreleme özellikleri
- **Form Validasyonu**: Gelişmiş form doğrulama sistemi

### 🔧 Teknik Özellikler
- **Flutter 3.8.1+**: En güncel Flutter sürümü
- **HTTP API Entegrasyonu**: RESTful API ile backend bağlantısı
- **Shared Preferences**: Yerel veri saklama
- **Mobile Scanner**: Kamera ile barkod tarama
- **State Management**: Modern state yönetimi

---

## 📱 Ekran Görüntüleri

<div align="center">

### Ana Sayfa
![Ana Sayfa](https://via.placeholder.com/300x600/4CAF50/FFFFFF?text=Ana+Sayfa)

### Sevk Ekleme
![Sevk Ekleme](https://via.placeholder.com/300x600/2E7D32/FFFFFF?text=Sevk+Ekleme)

### Barkod Tarama
![Barkod Tarama](https://via.placeholder.com/300x600/1B5E20/FFFFFF?text=Barkod+Tarama)

</div>

---

## 🛠️ Kurulum

### Gereksinimler
- Flutter SDK 3.8.1 veya üzeri
- Dart SDK 3.8.1 veya üzeri
- Android Studio / VS Code
- Android SDK (Android için)
- Xcode (iOS için)

### Adım Adım Kurulum

1. **Projeyi Klonlayın**
   ```bash
   git clone https://github.com/kullaniciadi/bycoz.git
   cd bycoz
   ```

2. **Bağımlılıkları Yükleyin**
   ```bash
   flutter pub get
   ```

3. **API Sunucusunu Başlatın**
   ```bash
   # Backend sunucusunun çalıştığından emin olun
   # Varsayılan port: 5000
   ```

4. **Uygulamayı Çalıştırın**
   ```bash
   flutter run
   ```

### Platform Spesifik Kurulum

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

---

## 📖 Kullanım

### 🏠 Ana Sayfa
Uygulama iki ana sekmeden oluşur:
- **Sevkler**: Mevcut sevk kayıtlarını görüntüleme
- **Sevk Ekle**: Yeni sevk işlemi oluşturma

### 📝 Yeni Sevk Oluşturma

1. **IP Adresi Girişi**
   - İlk açılışta API sunucu IP adresini girin
   - Format: `192.168.1.100`

2. **Genel Bilgiler**
   - Belge numarası girin
   - Gönderen depo seçin
   - Alıcı depo seçin
   - Açıklama ekleyin (opsiyonel)

3. **Ürün Ekleme**
   - "Ürün Ekle" butonuna tıklayın
   - Ürün listesinden seçim yapın
   - Miktar ve birim fiyat girin
   - "Listeye Ekle" ile ürünü ekleyin

4. **Barkod ile Hızlı Ekleme**
   - Sağ üst köşedeki QR kod ikonuna tıklayın
   - Barkodu tarayın veya manuel girin
   - Ürün otomatik olarak seçilir

5. **Sevk Kaydetme**
   - Tüm ürünler eklendikten sonra "Sevk Kaydet" butonuna tıklayın
   - İşlem başarılı olduğunda bildirim alırsınız

### 🔍 Sevk Listesi Görüntüleme
- Mevcut tüm sevk kayıtlarını görüntüleyin
- Sevk detaylarını inceleyin
- Gerektiğinde sevk kayıtlarını silin

---

## 🔧 Teknik Detaylar

### 📁 Proje Yapısı
```
lib/
├── main.dart              # Ana uygulama girişi
├── api_helper.dart        # API yardımcı sınıfı
├── ip_input_page.dart     # IP giriş sayfası
├── sevkler.dart          # Sevk listesi sayfası
└── sevk_ekle_sayfasi.dart # Sevk ekleme sayfası
```

### 🎨 Tema Renkleri
```dart
primaryGreen: Color(0xFF2E7D32)    // Ana yeşil
lightGreen: Color(0xFF4CAF50)      // Açık yeşil
darkGreen: Color(0xFF1B5E20)       // Koyu yeşil
backgroundColor: Color(0xFFF5F5F5) // Arka plan
```

### 📦 Kullanılan Paketler
```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.4.0                    # HTTP istekleri
  mobile_scanner: ^3.5.7          # Barkod tarama
  shared_preferences: ^2.2.2      # Yerel veri saklama
```

### 🔌 API Endpoints
- `GET /api/depolar` - Depo listesi
- `GET /api/urunler?depono={id}` - Depo ürünleri
- `GET /api/sevkler` - Sevk listesi
- `POST /api/sevk_ekle` - Yeni sevk ekleme
- `DELETE /api/sevkler/{evrakno}` - Sevk silme
- `GET /api/stoklar/barkod/{barkod}` - Barkod ile ürün arama

---

## 🚀 Geliştirme

### 🔄 State Management
Uygulama Flutter'ın built-in state management sistemini kullanır:
- `StatefulWidget` ile local state yönetimi
- `setState()` ile UI güncellemeleri
- `FutureBuilder` ile async işlemler

### 📱 Responsive Design
- `MediaQuery` ile ekran boyutu adaptasyonu
- `Flexible` ve `Expanded` widget'ları
- Platform-specific optimizasyonlar

### 🔒 Güvenlik
- HTTP isteklerinde header validasyonu
- Form input sanitization
- Error handling ve user feedback

---

## 🤝 Katkıda Bulunma

1. **Fork yapın** 🍴
2. **Feature branch oluşturun** (`git checkout -b feature/amazing-feature`)
3. **Değişikliklerinizi commit edin** (`git commit -m 'Add amazing feature'`)
4. **Branch'inizi push edin** (`git push origin feature/amazing-feature`)
5. **Pull Request oluşturun** 🔄

### 📋 Katkı Kuralları
- Kod standartlarına uyun
- Test yazın
- Dokümantasyonu güncelleyin
- Commit mesajlarını açıklayıcı yazın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 📞 İletişim

- **Geliştirici**: [Adınız]
- **Email**: [email@example.com]
- **GitHub**: [@kullaniciadi]

---

<div align="center">

**⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!**

Made with ❤️ using Flutter

</div>
