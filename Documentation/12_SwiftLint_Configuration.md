# SwiftLint: Konfigurasi dan Panduan

## Apa Itu SwiftLint

SwiftLint adalah alat yang secara otomatis memeriksa kode Swift terhadap sekumpulan aturan penulisan. Jika ada kode yang melanggar aturan, SwiftLint menampilkan peringatan (warning) atau error langsung di Xcode, sehingga bisa diperbaiki sebelum membuat Pull Request.

Dengan SwiftLint, kita tidak perlu berdebat tentang gaya penulisan di code review. Mesin yang memastikan konsistensi, manusia yang fokus membahas logika dan arsitektur.

---

## Instalasi

### 1. Install SwiftLint via Homebrew

```bash
brew install swiftlint
```

Verifikasi:

```bash
swiftlint version
```

### 2. Tambahkan Build Phase di Xcode

1. Buka Xcode, pilih project di navigator.
2. Pilih target `CallBite`.
3. Tab **Build Phases** > klik **+** > **New Run Script Phase**.
4. Beri nama: `SwiftLint`.
5. Masukkan script:

```bash
if which swiftlint > /dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed. Install with: brew install swiftlint"
fi
```

6. Pindahkan phase ini ke posisi **setelah** "Compile Sources".
7. Build (`Cmd + B`). Pelanggaran akan muncul di Issue Navigator.

### 3. Buat File `.swiftlint.yml`

File ini **bukan dibuat dari Xcode**. Ini file YAML biasa yang dibuat manual.

**Lewat Terminal (paling cepat):**
```bash
cd ~/path/to/CallBite       # folder yang berisi .xcodeproj
touch .swiftlint.yml
open -a "Visual Studio Code" .swiftlint.yml
```

**Lewat VSCode:**
1. Buka folder proyek di VSCode.
2. Klik kanan di panel Explorer > **New File**.
3. Ketik: `.swiftlint.yml` (awali dengan titik).
4. Paste konfigurasi di bawah.

**Lewat Finder:**
1. Jalankan `touch .swiftlint.yml` di Terminal (folder root proyek).
2. Tekan `Cmd + Shift + .` di Finder untuk menampilkan hidden files.
3. Buka file dengan text editor.

File ini wajib di-commit ke repository agar Baren Baruna Harahap, Joshua Valentine Manik, dan Fathimah Az Zahra Sanjani menggunakan aturan yang sama.

---

## Konfigurasi `.swiftlint.yml`

Salin seluruh konten berikut ke file `.swiftlint.yml`:

```yaml
# ==================================================================
# .swiftlint.yml -- CallBite
# ==================================================================
# Referensi lengkap semua rules:
# https://realm.github.io/SwiftLint/rule-directory.html
#
# Lihat semua rules yang tersedia di versi kamu:
# $ swiftlint rules
# ==================================================================

# --- Folder yang Diabaikan ---
excluded:
  - DerivedData
  - .build
  - Pods
  - Carthage

# --- Aturan Default yang Dinonaktifkan ---
disabled_rules:
  - trailing_whitespace
  - void_return

# --- Aturan Tambahan yang Diaktifkan ---
opt_in_rules:
  - force_unwrapping
  - force_cast
  - fatal_error_message
  - empty_count
  - first_where
  - toggle_bool
  - sorted_imports
  - modifier_order
  - convenience_type
  - unused_declaration
  - closure_body_length
  - accessibility_label_for_image

# --- Batas Baris ---
line_length:
  warning: 120
  error: 200
  ignores_urls: true
  ignores_comments: true

# --- Batas Panjang Fungsi ---
function_body_length:
  warning: 50
  error: 100

# --- Batas Panjang Tipe ---
type_body_length:
  warning: 250
  error: 400

# --- Batas Panjang File ---
file_length:
  warning: 400
  error: 600

# --- Format Output ---
reporter: xcode
```

---

## Mengapa Aturan Ini Dipilih

Setiap aturan dipilih berdasarkan tiga kriteria:

1. Apakah aturan ini mencegah bug atau crash yang nyata?
2. Apakah aturan ini meningkatkan keterbacaan kode di proyek dengan 3 developer?
3. Apakah aturan ini proporsional dengan skala proyek (12 hari, tim junior)?

Jika aturan tidak memenuhi minimal satu kriteria di atas, aturan tersebut tidak dimasukkan.

---

### Aturan yang Dinonaktifkan

#### `trailing_whitespace` -- Dimatikan

**Apa yang dilakukan:** Menandai spasi kosong di akhir baris sebagai pelanggaran.

**Mengapa dimatikan:** Xcode secara otomatis menambahkan trailing whitespace saat kamu menekan Enter di baris kosong. Memperbaiki ini satu per satu tidak meningkatkan kualitas kode, tapi menghasilkan banyak noise di git diff. Biarkan editor yang menangani formatting whitespace.

**Alternatif:** Jika ingin menghilangkan trailing whitespace secara otomatis, aktifkan opsi "Including whitespace-only lines" di Xcode > Settings > Text Editing > Editing.

#### `void_return` -- Dimatikan

**Apa yang dilakukan:** Memaksa `-> ()` sebagai pengganti `-> Void`.

**Mengapa dimatikan:** Ini murni masalah preferensi penulisan, bukan keamanan atau performa. Kita konsisten menggunakan `-> Void` karena lebih eksplisit saat dibaca. Apple sendiri menggunakan `Void` (huruf kapital) di dokumentasi resmi Swift.

---

### Aturan Keamanan (Mencegah Crash)

#### `force_unwrapping` -- Diaktifkan

**Apa yang dilakukan:** Menandai penggunaan operator `!` pada Optional.

**Mengapa diaktifkan:** Force unwrap adalah penyebab crash yang paling umum dan paling mudah dicegah di Swift. Saat variabel bernilai `nil` dan kita mengaksesnya dengan `!`, aplikasi langsung crash tanpa pesan error yang berguna. Untuk tim junior, ini adalah jaring pengaman yang paling berdampak.

**Apa yang harus dilakukan sebagai gantinya:**

```swift
// Situasi 1: Kamu yakin nilainya tidak nil, tapi tetap perlu handling
guard let nutritionData = food.nutritionData else {
    errorMessage = "Data nutrisi tidak tersedia"
    return
}
let calories = nutritionData.calories

// Situasi 2: Kamu ingin nilai default jika nil
let name = food.name ?? "Makanan Tidak Diketahui"
```

**Referensi:** Swift Programming Language Guide, "Optional Chaining" -- https://docs.swift.org/swift-book/documentation/the-swift-programming-language/optionalchaining/

#### `force_cast` -- Diaktifkan

**Apa yang dilakukan:** Menandai penggunaan `as!` untuk type casting.

**Mengapa diaktifkan:** Sama seperti force unwrap, `as!` menyebabkan crash jika tipe tidak cocok. Masalah ini sering terjadi saat bekerja dengan data dari API yang tipenya tidak selalu sesuai ekspektasi.

```swift
// Crash jika response bukan Dictionary
let dict = response as! [String: Any]

// Aman: mengembalikan nil jika tipe tidak cocok
guard let dict = response as? [String: Any] else { return }
```

**Referensi:** Swift API Design Guidelines, "Type Casting" -- https://docs.swift.org/swift-book/documentation/the-swift-programming-language/typecasting/

#### `fatal_error_message` -- Diaktifkan

**Apa yang dilakukan:** Memastikan setiap `fatalError()` memiliki pesan penjelasan.

**Mengapa diaktifkan:** Saat aplikasi crash karena `fatalError()` tanpa pesan, developer yang men-debug tidak tahu mengapa crash terjadi. Pesan yang jelas mempercepat proses debugging secara signifikan, terutama di tim yang bekerja pada area kode yang berbeda.

```swift
// Buruk: crash tanpa konteks
fatalError()

// Baik: developer langsung tahu masalahnya
fatalError("NutritionService belum diregister di AppContainer. Pastikan container sudah di-setup di CallBiteApp.")
```

---

### Aturan Performa

#### `empty_count` -- Diaktifkan

**Apa yang dilakukan:** Memaksa penggunaan `.isEmpty` daripada `.count == 0`.

**Mengapa diaktifkan:** `.isEmpty` lebih efisien karena langsung mengembalikan `true/false` tanpa menghitung seluruh elemen. Untuk koleksi kecil bedanya tidak terasa, tapi ini adalah kebiasaan baik yang mencegah masalah performa di koleksi besar (misalnya daftar hasil pencarian makanan dari API FatSecret).

**Sumber:** Apple Developer Documentation -- "Collection.isEmpty is O(1), while Collection.count is O(n) for some collections."

```swift
// O(n) -- harus menghitung semua elemen dulu
if detectedItems.count == 0 { showEmptyState() }

// O(1) -- langsung cek, tidak menghitung
if detectedItems.isEmpty { showEmptyState() }
```

#### `first_where` -- Diaktifkan

**Apa yang dilakukan:** Memaksa `.first(where:)` daripada `.filter { }.first`.

**Mengapa diaktifkan:** `.filter { }.first` memproses seluruh array untuk membuat array baru, lalu mengambil elemen pertama. `.first(where:)` berhenti begitu menemukan elemen pertama yang cocok. Di proyek ini, kita akan sering mencari item spesifik di daftar makanan. Kebiasaan ini mencegah pemrosesan yang tidak perlu.

```swift
// Memproses seluruh array, membuat array baru, baru ambil pertama
let nasi = meals.filter { $0.name == "Nasi Putih" }.first

// Berhenti di elemen pertama yang cocok
let nasi = meals.first(where: { $0.name == "Nasi Putih" })
```

---

### Aturan Konsistensi Kode

#### `toggle_bool` -- Diaktifkan

**Apa yang dilakukan:** Memaksa `.toggle()` daripada `value = !value`.

**Mengapa diaktifkan:** `.toggle()` lebih ringkas dan lebih jelas menyatakan niat (membalik nilai boolean). Untuk satu baris ini mungkin tampak kecil, tapi konsistensi di seluruh codebase membuat kode lebih mudah di-scan secara visual.

```swift
isLoading = !isLoading  // kurang idiomatik
isLoading.toggle()      // idiomatik Swift
```

#### `sorted_imports` -- Diaktifkan

**Apa yang dilakukan:** Memastikan import statements diurutkan secara alfabet.

**Mengapa diaktifkan:** Saat file memiliki banyak import, urutan alfabet mempermudah pencarian apakah sebuah framework sudah di-import atau belum. Ini juga mengurangi merge conflict: jika dua developer menambahkan import berbeda di baris yang sama, urutan alfabet memberikan posisi yang deterministik.

Aturan ini bisa diperbaiki otomatis dengan `swiftlint --fix`.

```swift
// Sebelum (acak)
import SwiftUI
import Combine
import Foundation

// Sesudah (alfabet)
import Combine
import Foundation
import SwiftUI
```

#### `modifier_order` -- Diaktifkan

**Apa yang dilakukan:** Memastikan urutan modifier pada deklarasi konsisten (misalnya `override` sebelum `public`, `public` sebelum `func`).

**Mengapa diaktifkan:** Swift tidak memaksa urutan tertentu, tapi kode yang konsisten lebih mudah di-scan. Saat code review, reviewer tidak perlu memproses "apakah ini `public override` atau `override public`" -- selalu sama.

#### `convenience_type` -- Diaktifkan

**Apa yang dilakukan:** Menandai `struct` atau `class` yang hanya berisi `static` members, dan menyarankan `enum` sebagai gantinya.

**Mengapa diaktifkan:** Enum tanpa case tidak bisa di-instantiate. Ini mencegah seseorang secara tidak sengaja membuat instance dari tipe yang seharusnya hanya digunakan sebagai namespace (seperti `AppSpacing` atau `AppColor` di Design System kita).

```swift
// Buruk: bisa di-instantiate (let x = AppSpacing())
struct AppSpacing {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
}

// Baik: tidak bisa di-instantiate
enum AppSpacing {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
}
```

**Referensi:** Swift API Design Guidelines menyarankan penggunaan caseless enums sebagai namespaces.

---

### Aturan Kebersihan Kode

#### `unused_declaration` -- Diaktifkan

**Apa yang dilakukan:** Mendeteksi variabel, fungsi, atau tipe yang dideklarasikan tapi tidak pernah digunakan.

**Mengapa diaktifkan:** Kode mati (dead code) membingungkan developer yang mencoba memahami codebase. Saat Joshua Valentine Manik membaca `FoodScanViewModel` dan menemukan sebuah fungsi yang tidak dipanggil di mana pun, dia harus membuang waktu untuk mencari tahu apakah fungsi itu dibutuhkan atau hanya sisa dari refactoring sebelumnya. Aturan ini menghilangkan keraguan tersebut.

#### `closure_body_length` -- Diaktifkan

**Apa yang dilakukan:** Menandai closure yang terlalu panjang (default: warning di 30 baris, error di 100 baris).

**Mengapa diaktifkan:** Closure panjang sering muncul di SwiftUI (terutama di `body`) dan di callback async. Jika closure melebihi batas, itu sinyal bahwa logikanya perlu diekstrak ke computed property atau method terpisah. Ini menjaga agar setiap blok kode punya satu tanggung jawab yang jelas.

---

### Aturan Aksesibilitas

#### `accessibility_label_for_image` -- Diaktifkan

**Apa yang dilakukan:** Memastikan `Image` yang memberikan informasi punya accessibility label, atau secara eksplisit disembunyikan dari VoiceOver dengan `.accessibilityHidden(true)`.

**Mengapa diaktifkan:** HIG Apple secara eksplisit menyatakan bahwa semua konten yang bermakna harus accessible. Di proyek CallBite, ikon nutrisi dan gambar makanan perlu label agar pengguna VoiceOver bisa memahami konteks layar. Aturan ini juga merupakan salah satu item di [05_HIG_Checklist.md](./05_HIG_Checklist.md).

**Referensi:** Apple HIG, "Accessibility > Images" -- https://developer.apple.com/design/human-interface-guidelines/accessibility

---

### Pengaturan Batas

| Setting | Warning | Error | Alasan |
|---------|---------|-------|--------|
| `line_length` | 120 | 200 | 120 karakter cukup untuk nama deskriptif tanpa horizontal scroll. 200 adalah batas keras. URL dan komentar dikecualikan karena sering panjang secara natural. |
| `function_body_length` | 50 | 100 | Fungsi > 50 baris biasanya melakukan terlalu banyak hal dan perlu dipecah. 100 adalah batas keras karena fungsi sepanjang itu sangat sulit diuji secara terisolasi. |
| `type_body_length` | 250 | 400 | ViewModel atau View > 250 baris menandakan fitur terlalu besar untuk satu file. Pertimbangkan memecah ke sub-komponen. |
| `file_length` | 400 | 600 | File > 400 baris sulit dinavigasi di Xcode. Jika melebihi ini, tinjau apakah file menampung terlalu banyak tanggung jawab. |

---

## Aturan yang Sengaja Tidak Dimasukkan

Berikut aturan yang dipertimbangkan tapi **tidak diaktifkan**, beserta alasannya:

| Rule | Alasan Tidak Dimasukkan |
|------|------------------------|
| `explicit_self` | Memaksa penulisan `self.` di setiap akses property. Menambah banyak noise tanpa meningkatkan kejelasan di codebase SwiftUI kecil. Cocok untuk proyek besar dengan banyak layer, bukan untuk tim 3 orang. |
| `file_name` | Memaksa nama file harus sama dengan nama tipe di dalamnya. Bisa menyulitkan saat satu file berisi beberapa tipe kecil yang terkait (misalnya enum state + error di file yang sama). |
| `identifier_name` | Memaksa panjang minimal nama variabel. Terlalu ketat untuk loop counter (`i`, `x`) dan parameter closure pendek yang sudah jelas dari konteks. |
| `nesting` | Membatasi kedalaman nesting (if di dalam if di dalam for). Di SwiftUI, nesting di `body` sering terjadi secara natural karena view composition. Aturan ini akan menghasilkan banyak false positive. |
| `explicit_type_interface` | Memaksa penulisan tipe eksplisit di setiap deklarasi. Swift dirancang dengan type inference yang kuat, dan menulis tipe secara eksplisit di mana-mana justru bertentangan dengan prinsip Swift. |

---

## Cara Menangani Pelanggaran

### Perbaikan Otomatis

```bash
swiftlint --fix
```

Rules yang bisa diperbaiki otomatis: `sorted_imports`, `toggle_bool`, `modifier_order`, trailing semicolons.

Rules yang harus diperbaiki manual: `force_unwrapping`, `force_cast`, `function_body_length`, `unused_declaration`.

### Menonaktifkan untuk Baris Tertentu

Gunakan hanya jika pelanggaran benar-benar tidak bisa dihindari. Selalu tulis alasan.

```swift
// swiftlint:disable:next force_unwrapping -- Bundle identifier pasti ada di main bundle
let bundle = Bundle.main.bundleIdentifier!
```

Modifier yang tersedia:
- `disable:this` -- baris ini saja
- `disable:next` -- baris berikutnya
- Jangan pernah gunakan `disable` tanpa modifier (menonaktifkan untuk seluruh file)

### Melihat Semua Rules

```bash
# Daftar semua rules
swiftlint rules

# Detail satu rule
swiftlint rules force_unwrapping
```

---

## Referensi

- Realm Inc. *SwiftLint Repository.* https://github.com/realm/SwiftLint
- Realm Inc. *SwiftLint Rule Directory.* https://realm.github.io/SwiftLint/rule-directory.html
- Apple Inc. *Swift API Design Guidelines.* https://www.swift.org/documentation/api-design-guidelines/
- Apple Inc. *The Swift Programming Language -- Optional Chaining.* https://docs.swift.org/swift-book/documentation/the-swift-programming-language/optionalchaining/
