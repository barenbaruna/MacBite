# Design Patterns

## Pendahuluan

Design pattern adalah solusi yang sudah teruji untuk masalah-masalah umum dalam pengembangan perangkat lunak. Tapi bukan berarti kita harus menggunakan semuanya. Setiap pattern yang kita adopsi harus punya alasan yang jelas terkait kebutuhan proyek. Jika sebuah pattern tidak menyelesaikan masalah nyata yang kita hadapi, maka menambahkannya hanya menambah kompleksitas.

Dokumen ini menjelaskan pattern apa saja yang kita gunakan di MacBite, mengapa kita memilihnya, dan yang sama pentingnya, pattern apa yang sengaja tidak kita gunakan.

---

## Pattern yang Digunakan

### 1. Factory Pattern (Creational)

**Masalah yang dipecahkan:**
Setiap fitur membutuhkan beberapa objek yang saling bergantung. Misalnya, `FoodScanView` membutuhkan `FoodScanViewModel`, yang membutuhkan `FoodDetectionService`. Jika View yang bertanggung jawab membuat semua objek ini, View menjadi tahu terlalu banyak tentang bagaimana sistem bekerja di balik layar. View seharusnya hanya peduli tentang menampilkan UI.

**Solusi:**
Setiap fitur memiliki satu Factory yang bertanggung jawab membuat semua objek yang dibutuhkan dan mengembalikan View yang siap digunakan.

```swift
enum FoodScanFactory {
    @MainActor
    static func makeView(onDismiss: @escaping () -> Void = {}) -> some View {
        let detectionService = FoodDetectionService()
        let viewModel = FoodScanViewModel(detectionService: detectionService)
        return FoodScanView(viewModel: viewModel, onDismiss: onDismiss)
    }
}
```

**Mengapa Factory, bukan langsung buat di View?**

Tanpa Factory:
```swift
// Di dalam body RootView (BURUK)
.fullScreenCover(isPresented: $showScan) {
    let service = FoodDetectionService()
    let viewModel = FoodScanViewModel(detectionService: service)
    FoodScanView(viewModel: viewModel, onDismiss: { showScan = false })
}
```

Dengan Factory:
```swift
// Di dalam body RootView (BAIK)
.fullScreenCover(isPresented: $showScan) {
    FoodScanFactory.makeView(onDismiss: { showScan = false })
}
```

Keuntungan:
- **RootView tidak perlu tahu** bahwa FoodScan membutuhkan FoodDetectionService.
- **Jika dependency berubah** (misalnya FoodScanViewModel sekarang butuh `NutritionService` juga), kita hanya mengubah Factory, bukan setiap tempat yang menampilkan FoodScanView.
- **Untuk testing**, kita bisa membuat Factory terpisah yang menggunakan mock services.

**Kapan Factory digunakan di proyek ini:**
- Setiap fitur di folder `Features/` memiliki satu Factory.
- Factory dipanggil dari navigation layer (`AppRouter`) atau dari View yang menampilkan fitur lain.

---

### 2. Dependency Injection via Constructor (Creational)

**Masalah yang dipecahkan:**
Jika ViewModel membuat dependency-nya sendiri (misalnya langsung memanggil `FoodDetectionService()`), maka ViewModel tidak bisa diuji tanpa menjalankan service yang sebenarnya. Kita tidak bisa mengganti service dengan versi tiruan (mock) saat testing.

**Solusi:**
Dependency diberikan ke ViewModel melalui parameter `init`, bukan dibuat di dalam ViewModel.

```swift
// BAIK: dependency di-inject
final class FoodScanViewModel: ObservableObject {
    private let detectionService: FoodDetectionServiceProtocol

    init(detectionService: FoodDetectionServiceProtocol) {
        self.detectionService = detectionService
    }
}

// BURUK: dependency dibuat sendiri (hard-coded)
final class FoodScanViewModel: ObservableObject {
    private let detectionService = FoodDetectionService() // tidak bisa di-mock
}
```

**Mengapa Constructor Injection, bukan cara lain?**

Ada beberapa cara melakukan DI:
- **Constructor Injection** (yang kita pilih): Dependency diberikan saat objek dibuat. Paling eksplisit, paling mudah dipahami.
- **Property Injection**: Dependency di-set setelah objek dibuat. Masalah: objek bisa berada dalam kondisi "belum siap" jika dependency belum di-set.
- **Environment Injection** (`@Environment`): Cocok untuk dependency global, tapi terlalu implisit jika digunakan berlebihan.

Kita memilih Constructor Injection karena:
1. Membuat dependency menjadi **eksplisit** (terlihat jelas dari signature `init`).
2. Objek selalu dalam kondisi **siap pakai** setelah dibuat.
3. Cocok untuk developer junior karena tidak ada "magic" tersembunyi.

Penjelasan lebih mendalam ada di [09_Dependency_Injection.md](./09_Dependency_Injection.md).

---

### 3. Observer Pattern via @Published (Behavioral)

**Masalah yang dipecahkan:**
UI perlu diperbarui secara otomatis setiap kali data berubah. Misalnya, saat user memfoto makanan dan AI mendeteksi hasilnya, daftar makanan di layar harus langsung berubah tanpa user harus me-refresh secara manual.

**Solusi:**
Menggunakan protocol `ObservableObject` dan property wrapper `@Published` yang merupakan implementasi Observer Pattern bawaan dari Apple.

```swift
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var dailyProgress: DailyProgress?
    @Published private(set) var meals: [MealEntry] = []
}
```

**Bagaimana cara kerjanya:**
1. ViewModel meng-conform `ObservableObject`.
2. Property yang ditandai `@Published` akan mengirim notifikasi setiap kali nilainya berubah.
3. View yang meng-observe ViewModel (via `@ObservedObject` atau `@StateObject`) secara otomatis merender ulang UI saat notifikasi diterima.

**Mengapa @Published dan bukan @Observable macro?**
`@Observable` (diperkenalkan di iOS 17) lebih efisien karena melakukan granular tracking. Namun, proyek ini konsisten menggunakan `ObservableObject + @Published` karena:
- Mempermudah integrasi dengan Combine untuk reactive streams (lihat [10_Reactive_Programming.md](./10_Reactive_Programming.md)).
- Sebagai tim junior, lebih baik menguasai satu pendekatan dengan baik daripada mencampur dua sistem state management yang berbeda.

**Kapan Observer digunakan di proyek ini:**
- Semua ViewModel menggunakan `@Published` untuk state yang di-observe oleh View.
- View menggunakan `@ObservedObject` untuk ViewModel yang di-inject dari luar.

---

### 4. Facade Pattern (Structural)

**Masalah yang dipecahkan:**
PRD menyebutkan dua sumber data nutrisi: **USDA FoodData Central** dan **FatSecret**. Keduanya memiliki API yang berbeda, format response yang berbeda, dan cara autentikasi yang berbeda. Jika ViewModel harus berinteraksi dengan kedua API secara langsung, kode akan menjadi rumit dan tightly-coupled dengan detail implementasi masing-masing API.

**Solusi:**
Membuat satu `NutritionServiceFacade` yang menyediakan interface sederhana dan menyembunyikan kompleksitas interaksi dengan multiple API di belakang layar.

```swift
// Protocol: interface yang dilihat oleh ViewModel
protocol NutritionServiceProtocol {
    func searchFood(query: String) async throws -> [FoodSearchResult]
    func getNutrition(for foodID: String) async throws -> NutritionData
}

// Facade: implementasi yang mengoordinasikan multiple API
final class NutritionServiceFacade: NutritionServiceProtocol {
    private let usdaClient: USDAClient
    private let fatSecretClient: FatSecretClient

    init(usdaClient: USDAClient = USDAClient(),
         fatSecretClient: FatSecretClient = FatSecretClient()) {
        self.usdaClient = usdaClient
        self.fatSecretClient = fatSecretClient
    }

    func searchFood(query: String) async throws -> [FoodSearchResult] {
        // Cari di FatSecret terlebih dahulu (database makanan Indonesia lebih lengkap)
        // Jika tidak ditemukan, fallback ke USDA
        let results = try await fatSecretClient.search(query)
        if results.isEmpty {
            return try await usdaClient.search(query)
        }
        return results
    }

    func getNutrition(for foodID: String) async throws -> NutritionData {
        // Detail implementasi tersembunyi dari ViewModel
        return try await fatSecretClient.getNutrients(foodID: foodID)
    }
}
```

**Mengapa Facade?**

Tanpa Facade, ViewModel harus tahu tentang USDA dan FatSecret:
```swift
// BURUK: ViewModel tahu detail implementasi
func searchFood() async {
    let usdaResults = try? await usdaClient.search(query)
    let fatSecretResults = try? await fatSecretClient.search(query)
    // ViewModel harus merge, deduplicate, dan memilih... terlalu banyak tanggung jawab
}
```

Dengan Facade, ViewModel hanya memanggil satu method:
```swift
// BAIK: ViewModel tidak tahu dari mana datanya
func searchFood() async {
    results = try await nutritionService.searchFood(query: searchText)
}
```

Keuntungan:
- **ViewModel tetap sederhana.** Tidak perlu tahu sumber data mana yang dipanggil.
- **Mudah diperluas.** Jika di masa depan kita menambah sumber data ketiga (misalnya database nutrisi lokal), kita hanya mengubah Facade tanpa menyentuh ViewModel.
- **Satu tempat untuk logika fallback.** Strategi "cari di FatSecret dulu, kalau kosong cari di USDA" didefinisikan di satu tempat.

**Peringatan:** Jaga agar Facade tetap tipis. Facade hanya mengoordinasikan panggilan ke subsystem, bukan berisi logika bisnis yang kompleks. Jika Facade mulai membengkak, itu tanda bahwa logikanya perlu dipecah ke Service terpisah.

---

## Pattern yang Sengaja Tidak Digunakan

### Singleton

**Apa itu:** Objek yang hanya memiliki satu instance di seluruh aplikasi, diakses melalui `static let shared`.

**Mengapa tidak digunakan:**
- Singleton membuat unit testing menjadi sulit karena state-nya global dan tidak bisa diganti dengan mock.
- Singleton menyembunyikan dependency, membuat kode sulit dipahami. Kamu tidak tahu bahwa sebuah class bergantung pada Singleton sampai kamu membaca implementasinya baris per baris.
- Alternatif yang kita gunakan (Dependency Injection) memberikan manfaat yang sama (satu instance) tanpa masalah di atas. Instance dibuat sekali di `AppContainer` dan di-inject ke mana pun dibutuhkan.

**Exception:** Jika di kemudian hari kita membutuhkan Logger global atau AnalyticsManager, Singleton bisa dipertimbangkan karena objek-objek ini biasanya stateless dan tidak perlu di-mock.

### Builder Pattern

**Apa itu:** Pattern untuk membuat objek yang kompleks secara bertahap.

**Mengapa tidak digunakan:**
- Model data di proyek ini cukup sederhana (struct dengan beberapa property). Tidak ada objek yang membutuhkan proses pembuatan multi-langkah.
- Swift sudah memiliki mekanisme default parameter values dan memberwise initializer yang mengatasi sebagian besar kebutuhan yang biasanya dipecahkan oleh Builder.

### Adapter Pattern

**Apa itu:** Pattern untuk membuat dua interface yang tidak kompatibel bisa bekerja bersama.

**Mengapa tidak digunakan:**
- Saat ini kita tidak mengintegrasikan library pihak ketiga yang memiliki interface berbeda dari yang kita definisikan. Jika nanti muncul kebutuhan (misalnya mengganti Core ML dengan library deteksi lain yang memiliki interface berbeda), Adapter bisa dipertimbangkan.

### Delegation via Protocol

**Apa itu:** Pattern di mana satu objek mendelegasikan tanggung jawab tertentu ke objek lain melalui protocol.

**Mengapa tidak menjadi pilihan utama:**
- Dalam SwiftUI, komunikasi antara View dan ViewModel sudah ditangani oleh data binding (`@Published` + `@ObservedObject`).
- Delegation lebih relevan di UIKit. Dalam proyek SwiftUI murni, closures dan Combine publishers biasanya lebih ringkas dan mudah dibaca.

---

## Ringkasan

| Kategori | Pattern | Digunakan? | Alasan Singkat |
|----------|---------|-----------|----------------|
| Creational | Factory | Ya | Memisahkan pembuatan dependency dari View |
| Creational | Dependency Injection | Ya | Membuat ViewModel testable dan eksplisit |
| Creational | Singleton | Tidak | Menyulitkan testing, menyembunyikan dependency |
| Creational | Builder | Tidak | Model data cukup sederhana, Swift sudah punya default values |
| Structural | Facade | Ya | Menyederhanakan interaksi dengan multiple API nutrisi |
| Structural | Adapter | Tidak | Belum ada kebutuhan integrasi interface yang tidak kompatibel |
| Behavioral | Observer (@Published) | Ya | Sinergi natural dengan SwiftUI state management |
| Behavioral | Delegation | Tidak | SwiftUI menggunakan data binding, bukan delegation |

---

## Referensi

- Gamma, E., Helm, R., Johnson, R., Vlissides, J. (1994). *Design Patterns: Elements of Reusable Object-Oriented Software.* Addison-Wesley.
- Apple Inc. *Combine Framework Documentation.* https://developer.apple.com/documentation/combine
- Refactoring.Guru. *Design Patterns.* https://refactoring.guru/design-patterns
