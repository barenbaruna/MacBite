# Standar Penulisan Kode (Clean Code)

## Mengapa Standar Ini Penting

Dalam tim yang terdiri dari 3 developer dengan kemampuan dan gaya coding yang berbeda, tanpa standar penulisan yang disepakati, codebase akan cepat menjadi tidak konsisten. Satu developer menulis `fetchData`, yang lain menulis `getData`, yang lain lagi menulis `loadData` -- semuanya untuk hal yang sama. Standar ini bukan tentang memaksakan gaya tertentu, tapi tentang membuat perjanjian bersama agar siapa pun yang membaca kode bisa langsung memahami maksudnya.

Prinsip utama:
- **Kode adalah komunikasi.** Kita menulis kode agar manusia lain (termasuk diri kita sendiri 2 minggu ke depan) bisa membacanya.
- **Konsistensi lebih penting dari preferensi pribadi.** Pilih satu cara dan gunakan di mana-mana.
- **Aturan ini ditegakkan oleh SwiftLint.** Lihat [12_SwiftLint_Configuration.md](./12_SwiftLint_Configuration.md) untuk konfigurasi dan penjelasan setiap rule.

---

## File Header

Setiap file Swift yang dibuat harus memiliki header komentar standar di bagian atas. Ini adalah format bawaan Xcode yang otomatis muncul saat membuat file baru, dan kita wajib mempertahankannya.

```swift
//
//  NamaFile.swift
//  MacBite
//
//  Created by Nama Developer on DD/MM/YY.
//
```

Contoh untuk masing-masing anggota tim:

```swift
//
//  FoodScanViewModel.swift
//  MacBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//
```

```swift
//
//  NutritionCalculator.swift
//  MacBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//
```

```swift
//
//  FoodClassifierService.swift
//  MacBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//
```

Aturan:
- Nama project/aplikasi harus **MacBite** (bukan nama lain).
- Nama developer menggunakan nama lengkap atau nama yang konsisten di seluruh proyek.
- Tanggal mengikuti format yang dihasilkan Xcode secara otomatis (DD/MM/YY).
- Jangan menghapus header ini. Jangan menambahkan informasi lain (seperti copyright atau license) kecuali disepakati tim.
- Jika file di-refactor atau dipindahkan, header **Created by** tetap milik pembuat asli. Tidak perlu diubah.

---

## Bahasa dan Framework

| Item | Standar |
|------|---------|
| Language | Swift 6.0+ |
| UI Framework | SwiftUI (tidak menggunakan UIKit kecuali untuk wrapper `UIViewRepresentable`) |
| Target | iOS 26+ |
| Concurrency | async/await sebagai default, Combine untuk reactive streams |

---

## Naming Conventions

Penamaan yang baik membuat komentar menjadi tidak perlu. Jika kamu perlu menulis komentar untuk menjelaskan apa yang dilakukan sebuah variabel, kemungkinan besar nama variabelnya kurang deskriptif.

### Penamaan File

| Tipe File | Format Nama | Contoh |
|-----------|-------------|--------|
| View | `[Nama]View.swift` | `FoodScanView.swift` |
| ViewModel | `[Nama]ViewModel.swift` | `FoodScanViewModel.swift` |
| Model | `[Nama].swift` | `DetectedFoodItem.swift` |
| Service | `[Nama]Service.swift` | `NutritionService.swift` |
| Factory | `[Nama]Factory.swift` | `FoodScanFactory.swift` |
| Protocol | `[Nama]Protocol.swift` | `NutritionServiceProtocol.swift` |
| Component (sub-view) | Nama deskriptif | `MacroProgressRing.swift` |

**Alasan:** Konvensi ini membuat kamu bisa langsung tahu peran sebuah file dari namanya saja, tanpa harus membukanya. `FoodScanViewModel.swift` jelas adalah ViewModel untuk fitur Food Scan.

### Penamaan Swift Code

| Elemen | Style | Contoh | Penjelasan |
|--------|-------|--------|------------|
| Type (struct, class, enum) | PascalCase | `DetectedFoodItem`, `ScanPhase` | Mengikuti Swift API Design Guidelines |
| Property dan method | camelCase | `dailyCalorieTarget`, `calculateMacros()` | Standar Swift |
| Constant | camelCase | `let maxPortionMultiplier: Double = 5.0` | Swift tidak menggunakan SCREAMING_CASE |
| Enum case | camelCase | `.scanning`, `.confirmed` | Mengikuti Swift standard library |
| Protocol | PascalCase, deskriptif | `NutritionProviding`, `FoodDetectable` | Gunakan kata kerja "-ing"/"-able" untuk protocol yang mendeskripsikan kemampuan |
| Boolean | prefix `is`/`has`/`should`/`can` | `isLoading`, `hasReachedGoal`, `canRetake` | Membuat kondisi if/guard terbaca seperti kalimat |

### Penamaan Token Desain & Larangan Singkatan

Mengikuti **Swift API Design Guidelines**:
> *"Clarity at the point of use is your most important goal. Avoid abbreviation. Abbreviations—especially non-standard ones—are effectively the same as inventing a new language."*

1. **Dilarang Menggunakan Singkatan Web/CSS**:
   - Jangan gunakan `xs`, `sm`, `md`, `lg`, `xl` pada token desain.
   - Gunakan nama lengkap bahasa Inggris: `extraSmall`, `small`, `regular`, `medium`, `large`, `extraLarge`.
2. **Kombinasi Scale Primitives & Semantic Role Aliases**:
   - Token geometri memiliki dua tingkatan:
     - **Scale Primitives** (ukuran fisik skala 8-point): `AppCornerRadius.medium`, `AppSpacing.large`.
     - **Semantic Role Aliases** (maksud penggunaan): `AppCornerRadius.button = medium`, `AppCornerRadius.card = large`.
   - Di View, prioritaskan penggunaan *Semantic Role* (`AppCornerRadius.card`) agar jika standar visual button atau card berubah, perubahannya terpusat di satu titik.
3. **Pemisahan Framework Import pada Tokens**:
   - **Skalar Geometri (`AppSpacing`, `AppCornerRadius`)**: Hanya `import CoreGraphics` (bukan `SwiftUI`). Geometri adalah nilai `CGFloat` murni. Hal ini menjaga token tetap modular dan dapat diakses di luar UI tree tanpa mengotori layer logika.
   - **Visual Tokens (`AppColor`, `AppTypography`, `AppAnimation`)**: Mengimpor `SwiftUI` karena menggunakan tipe resmi `Color`, `Font`, dan `Animation`.
   - **Sensory Tokens (`AppHaptics`)**: Mengimpor `UIKit` untuk mengontrol Taptic Engine (`UIFeedbackGenerator`).

### Penamaan Folder

- Nama folder: **PascalCase** (`Features/`, `ViewModels/`, `Components/`)
- Satu file berisi satu tipe utama. Jangan menggabung beberapa struct besar dalam satu file.
- File kecil yang sangat terkait boleh digabung (contoh: beberapa enum status dalam satu file).

**Alasan mengapa PascalCase untuk folder:** Ini konsisten dengan konvensi Xcode project navigator dan memudahkan pembedaan antara folder (`Models/`) dan file (`FoodItem.swift`) saat membaca struktur di terminal.

---

## Formatting dan Spasi

### Horizontal Spacing (Indentasi dan Lebar Baris)

| Aturan | Nilai | Alasan |
|--------|-------|--------|
| Indentasi | 4 spasi | Default Xcode, konsisten di seluruh tim |
| Batas lebar baris (warning) | 120 karakter | Cukup lebar untuk kode deskriptif tanpa harus scroll horizontal |
| Batas lebar baris (error) | 200 karakter | Batas keras, baris sepanjang ini hampir pasti perlu dipecah |

### Vertical Spacing (Baris Kosong)

Gunakan baris kosong untuk memisahkan blok logika yang berbeda, tapi jangan berlebihan.

```swift
// BAIK: baris kosong memisahkan blok logika
func loadDailyProgress() {
    Task {
        isLoading = true
        defer { isLoading = false }

        do {
            let meals = try await mealStore.fetchToday()
            let totals = nutritionCalculator.calculateTotals(from: meals)
            dailyProgress = totals
        } catch {
            errorMessage = "Gagal memuat data hari ini"
        }
    }
}

// BURUK: tidak ada pemisahan visual
func loadDailyProgress() {
    Task {
        isLoading = true
        defer { isLoading = false }
        do {
            let meals = try await mealStore.fetchToday()
            let totals = nutritionCalculator.calculateTotals(from: meals)
            dailyProgress = totals
        } catch {
            errorMessage = "Gagal memuat data hari ini"
        }
    }
}
```

### Penggunaan MARK

Gunakan `// MARK: -` untuk membagi section dalam file yang panjang. Ini membuat navigasi file di Xcode minimap dan jump bar menjadi lebih mudah.

```swift
@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var dailyProgress: DailyProgress?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let mealStore: MealStore
    private let nutritionCalculator: NutritionCalculator

    // MARK: - Initialization

    init(mealStore: MealStore, nutritionCalculator: NutritionCalculator) {
        self.mealStore = mealStore
        self.nutritionCalculator = nutritionCalculator
    }

    // MARK: - Public Methods

    func loadDailyProgress() {
        // ...
    }
}
```

---

## Organisasi Kode dalam File

Susun elemen dalam file dengan urutan yang konsisten. Urutan ini berlaku untuk ViewModel, View, dan Service:

### Urutan di ViewModel

1. Published properties (state yang di-observe oleh View)
2. Private properties (dependencies dan internal state)
3. Initializer
4. Public methods (dipanggil oleh View)
5. Private methods (helper internal)

### Urutan di View

1. Property wrappers (`@ObservedObject`, `@State`, `@Environment`)
2. Other properties (closures seperti `onDismiss`)
3. Initializer
4. `body`
5. Computed properties untuk sub-sections dari body
6. Private helper methods

**Alasan:** Urutan ini mengikuti prinsip "yang paling penting di atas". Saat membuka file ViewModel, hal pertama yang ingin kamu ketahui adalah state apa saja yang dikelola (Published properties). Saat membuka View, kamu ingin tahu data apa yang dibutuhkan (property wrappers) dan bagaimana tampilannya (body).

---

## ViewModel Pattern

```swift
@MainActor
final class FoodScanViewModel: ObservableObject {
    @Published private(set) var detectedItems: [DetectedFoodItem] = []
    @Published private(set) var scanPhase: ScanPhase = .idle
    @Published private(set) var errorMessage: String?

    private let detectionService: FoodDetectionServiceProtocol

    init(detectionService: FoodDetectionServiceProtocol) {
        self.detectionService = detectionService
    }

    func analyzeImage(_ image: UIImage) {
        Task {
            scanPhase = .analyzing
            do {
                detectedItems = try await detectionService.detect(from: image)
                scanPhase = .completed
            } catch {
                errorMessage = "Gagal menganalisis foto makanan"
                scanPhase = .error
            }
        }
    }
}
```

**Aturan ViewModel:**

| Aturan | Alasan |
|--------|--------|
| Selalu `@MainActor` | Semua update `@Published` harus terjadi di main thread. Tanpa ini, SwiftUI bisa crash. |
| `private(set)` untuk `@Published` | View hanya boleh membaca state, tidak boleh menulis langsung. Perubahan state hanya melalui method ViewModel. |
| Dependencies di-inject via `init` | Membuat ViewModel bisa diuji dengan mock service. Lihat [09_Dependency_Injection.md](./09_Dependency_Injection.md). |
| Tidak boleh `import SwiftUI` | ViewModel adalah logika, bukan tampilan. Exception: tipe dasar seperti `CGFloat` jika benar-benar diperlukan. |

---

## View Pattern

```swift
struct FoodScanView: View {
    @ObservedObject private var viewModel: FoodScanViewModel
    let onDismiss: () -> Void

    init(viewModel: FoodScanViewModel, onDismiss: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        // UI code
    }
}
```

**Aturan View:**

| Aturan | Alasan |
|--------|--------|
| ViewModel diterima via init, bukan dibuat di dalam View | View tidak bertanggung jawab membuat dependency. Ini tugas Factory. |
| Gunakan `@ObservedObject` untuk ViewModel yang di-inject | `@StateObject` hanya untuk ViewModel yang dibuat dan dimiliki oleh View itu sendiri. |
| Pecah body yang panjang (>40 baris) ke computed properties | Body yang terlalu panjang sulit dibaca dan di-debug. |

---

## Service Pattern

```swift
final class NutritionCalculator {
    func calculateTotals(from meals: [MealEntry]) -> DailyProgress {
        let totalCalories = meals.reduce(0) { $0 + $1.calories }
        let totalProtein = meals.reduce(0) { $0 + $1.protein }
        let totalCarbs = meals.reduce(0) { $0 + $1.carbs }
        let totalFat = meals.reduce(0) { $0 + $1.fat }

        return DailyProgress(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat
        )
    }
}
```

**Aturan Service:**

| Aturan | Alasan |
|--------|--------|
| Buat protocol hanya jika service perlu di-mock untuk testing | Menghindari abstraksi prematur. Tambahkan protocol saat benar-benar dibutuhkan, bukan "untuk jaga-jaga". |
| `async throws` untuk operasi yang bisa gagal | Network calls dan akses Core ML bisa gagal. Gunakan error handling yang eksplisit. |
| Tidak boleh mengakses `@Published` properties | Service bukan bagian dari UI layer. Service mengembalikan data, ViewModel yang memperbarui state. |

---

## Error Handling

Semua error dalam aplikasi menggunakan tipe `AppError` yang terpusat:

```swift
// Melempar error
throw AppError.networkError(message: "Tidak ada koneksi internet")

// Menampilkan ke user (selalu dalam Bahasa Indonesia)
errorMessage = "Gagal memuat data nutrisi. Periksa koneksi internet kamu."
```

Aturan:
- Error message untuk user selalu dalam **Bahasa Indonesia**.
- Error teknis (log, debug) boleh dalam **Bahasa Inggris**.
- Jangan pernah menampilkan pesan error teknis langsung ke user (misalnya "NSURLError -1009").

---

## Komentar dan Dokumentasi

### Prinsip Utama

Komentar yang baik menjelaskan **"mengapa"**, bukan **"apa"**. Jika kode sudah jelas menyatakan apa yang dilakukan, komentar yang mengulang hal yang sama hanya menambah noise.

```swift
// BAIK -- menjelaskan "mengapa"
// Threshold 0.6 dipilih berdasarkan evaluasi model oleh Fathimah Az Zahra Sanjani (akurasi 89% di atas threshold ini)
guard confidence >= confidenceThreshold else { continue }

// BURUK -- menjelaskan "apa" yang sudah jelas dari kode
// Check if confidence is greater than threshold
guard confidence >= confidenceThreshold else { continue }
```

### Kapan Menulis Komentar

| Situasi | Perlu Komentar? |
|---------|----------------|
| Logika yang tidak obvious (magic number, threshold, business rule) | Ya, jelaskan kenapa |
| Public API yang dipakai oleh developer lain | Ya, gunakan doc comment (`///`) |
| Workaround atau limitasi framework | Ya, jelaskan limitasinya dan kapan bisa dihapus |
| Kode yang self-explanatory | Tidak perlu |

### Doc Comment

Gunakan `///` untuk method yang dipakai oleh developer lain (public API):

```swift
/// Menghitung total nutrisi dari semua meal entry hari ini.
///
/// - Parameter meals: Daftar meal yang sudah dicatat hari ini.
/// - Returns: `DailyProgress` berisi total kalori, protein, karbohidrat, dan lemak.
func calculateTotals(from meals: [MealEntry]) -> DailyProgress {
    // ...
}
```

---

## Bahasa

| Konteks | Bahasa |
|---------|--------|
| Kode (variabel, fungsi, komentar teknis) | Bahasa Inggris |
| UI strings (teks yang dilihat pengguna) | Bahasa Indonesia |
| Error messages untuk pengguna | Bahasa Indonesia |
| Dokumentasi internal tim (folder Documentation/) | Bahasa Indonesia |
| Code documentation (doc comments `///`) | Bahasa Inggris |

**Alasan:** Kode dalam Bahasa Inggris adalah standar industri dan memudahkan jika proyek dibuka untuk kolaborator internasional. Dokumentasi tim dalam Bahasa Indonesia karena seluruh anggota tim berbahasa Indonesia, dan kejelasan komunikasi lebih penting daripada formalitas.

---

## Referensi

- Apple Inc. *Swift API Design Guidelines.* https://www.swift.org/documentation/api-design-guidelines/
- Martin, R.C. (2008). *Clean Code: A Handbook of Agile Software Craftsmanship.* Prentice Hall.
- Fowler, M. (2018). *Refactoring: Improving the Design of Existing Code, 2nd Edition.* Addison-Wesley.
