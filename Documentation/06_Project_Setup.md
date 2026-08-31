# Project Setup dan Build

## Persyaratan Sistem

| Item | Minimum |
|------|---------| 
| macOS | 15.0+ (Sequoia) |
| Xcode | 26.0+ |
| iOS Target | 26.0 |
| Swift | 6.0 |
| Device | iPhone (Portrait only) |

---

## Clone dan Buka Project

```bash
git clone <repository-url>
cd CallBite
open CallBite.xcodeproj
```

---

## Build

1. Pilih scheme **CallBite**.
2. Pilih target device/simulator (iPhone 17 Pro recommended).
3. `Cmd + B` untuk build.
4. `Cmd + R` untuk run.

---

## Struktur Xcode Project

Project menggunakan **PBXFileSystemSynchronizedRootGroup**. Ini berarti Xcode otomatis mendeteksi semua file dalam folder project. Tidak perlu drag-and-drop file ke Xcode navigator.

Implikasi:
- Buat file baru langsung di Finder atau terminal, Xcode otomatis include.
- Hapus file langsung, Xcode otomatis remove dari build.
- Tidak perlu edit `.pbxproj` untuk menambah/menghapus file.

---

## ML Model

Model Core ML dikelola oleh Fathimah Az Zahra Sanjani dan terletak di `Infrastructure/ML/`. Xcode otomatis menghasilkan Swift class dari file `.mlpackage` saat build.

Aturan:
- Jangan memindahkan model ke folder lain tanpa update reference.
- Jangan commit model weight baru tanpa diskusi tim terlebih dahulu (file berukuran besar, gunakan Git LFS jika perlu).

---

## Info.plist Keys

Fitur-fitur di PRD membutuhkan permission berikut:

```xml
<key>NSCameraUsageDescription</key>
<string>CallBite membutuhkan akses kamera untuk memfoto makanan dan menganalisis nutrisinya.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>CallBite membutuhkan akses galeri foto untuk memilih foto makanan yang ingin dianalisis.</string>
```

Permission tambahan yang mungkin dibutuhkan di fase selanjutnya:

```xml
<!-- HealthKit (fase eksplorasi) -->
<key>NSHealthShareUsageDescription</key>
<string>CallBite ingin mengakses data kesehatan untuk menyinkronkan data nutrisi.</string>
```

Tambahkan key baru di `Info.plist` jika fitur baru membutuhkan permission. Selalu diskusikan dengan tim sebelum menambahkan permission baru.

---

## Konfigurasi API (Credential Management)

Proyek ini menggunakan API external (USDA FoodData Central, FatSecret). API key tidak boleh disimpan langsung dalam kode.

### Setup

1. Buat file `Secrets.xcconfig` di root proyek (sudah tercantum di `.gitignore`).
2. Isi dengan format:

```
USDA_API_KEY = your_api_key_here
FATSECRET_CLIENT_ID = your_client_id_here
FATSECRET_CLIENT_SECRET = your_client_secret_here
```

3. File template `Secrets.xcconfig.template` sudah ada di repository sebagai referensi format.

Aturan:
- **Jangan pernah commit API key ke repository.**
- File `Secrets.xcconfig` sudah dimasukkan ke `.gitignore`.
- Jika butuh API key baru, minta ke Author dan tambahkan ke template.

---

## SwiftLint

SwiftLint harus diinstal sebelum mulai coding. Panduan lengkap ada di [12_SwiftLint_Configuration.md](./12_SwiftLint_Configuration.md).

Ringkasan instalasi cepat:
```bash
brew install swiftlint
```

---

## Git Workflow

Lihat `README.MD` di root repository untuk branching strategy dan commit conventions.

Referensi cepat:
```bash
# Sinkronisasi dengan development
git checkout development
git pull origin development

# Buat branch fitur baru
git checkout -b feature/nama-fitur

# Commit
git add .
git commit -m "feat(scope): deskripsi perubahan"

# Push
git push -u origin feature/nama-fitur
```

---

## Testing

Test files ada di `CallBiteTests/`. Panduan lengkap ada di [11_Testing_Strategy.md](./11_Testing_Strategy.md).

Menggunakan:
- **Swift Testing** (`@Suite`, `@Test`, `#expect`) untuk unit test baru.
- **XCTest** untuk test yang sudah ada (jika ada migrasi dari proyek sebelumnya).

Menjalankan test:
```bash
xcodebuild test \
    -project CallBite.xcodeproj \
    -scheme CallBite \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Troubleshooting

### "Multiple commands produce" error
Solusi: `Product > Clean Build Folder` (Shift + Cmd + K), lalu rebuild.

### Model class not found
Solusi: Build sekali terlebih dahulu. Xcode menghasilkan Swift class dari `.mlpackage` saat proses build.

### Camera tidak berfungsi di Simulator
Camera membutuhkan device fisik. Gunakan iPhone asli untuk testing fitur Food Scan.

### SwiftLint command not found saat build
Pastikan SwiftLint terinstal via Homebrew dan path `/opt/homebrew/bin` tersedia. Lihat [12_SwiftLint_Configuration.md](./12_SwiftLint_Configuration.md).
