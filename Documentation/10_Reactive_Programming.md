# Reactive Programming: Combine dan async/await

## Konteks

Dalam CallBite, ada dua jenis operasi asinkron yang berbeda bentuknya:

1. **Operasi satu kali (one-shot):** User memfoto makanan, AI menganalisis, dan mengembalikan hasil. Ini terjadi sekali per aksi.
2. **Aliran data yang berubah terus-menerus (stream):** User mengetik di search bar, dan setiap perubahan teks harus memicu pencarian ke API -- tapi tidak pada setiap ketukan tombol, melainkan setelah jeda singkat (debounce).

Swift menyediakan dua mekanisme untuk menangani ini: **async/await** dan **Combine**. Dokumen ini menjelaskan kapan menggunakan yang mana.

---

## Prinsip Pemilihan

Cara paling sederhana untuk memutuskan:

> **"Apakah data ini berubah terus-menerus seiring waktu?"**
>
> Jika **tidak** (satu permintaan, satu jawaban) -- gunakan **async/await**.
>
> Jika **ya** (nilai yang terus mengalir, perlu ditransformasi) -- gunakan **Combine**.

---

## async/await: Default untuk Operasi Satu Kali

### Apa Itu

async/await adalah fitur bawaan Swift untuk menulis kode asinkron yang dibaca seperti kode biasa, dari atas ke bawah. Tidak ada callback bersarang (callback hell) dan tidak perlu mengelola subscription.

### Kapan Digunakan di Proyek Ini

| Skenario di PRD | Mengapa async/await |
|-----------------|---------------------|
| Mengambil foto dan menjalankan AI Food Detection | Satu foto masuk, satu hasil keluar |
| Memanggil USDA/FatSecret API untuk data nutrisi | Satu request, satu response |
| Menyimpan meal entry ke storage lokal | Operasi write satu kali |
| Mengambil riwayat meal hari ini dari database | Satu query, satu hasil |
| Menghasilkan Actionable Insight dari Foundation Models | Satu prompt, satu response |

### Contoh di Proyek Ini

```swift
// FoodScanViewModel.swift
func analyzeImage(_ image: UIImage) {
    Task {
        scanPhase = .analyzing

        do {
            // Satu panggilan, satu hasil
            let items = try await detectionService.detect(from: image)
            detectedItems = items
            scanPhase = .completed
        } catch {
            errorMessage = "Gagal menganalisis foto. Coba ambil ulang dengan pencahayaan lebih baik."
            scanPhase = .error
        }
    }
}
```

```swift
// NutritionResultViewModel.swift
func loadNutrition(for items: [DetectedFoodItem]) {
    Task {
        isLoading = true
        defer { isLoading = false }

        do {
            // Masing-masing item diambil data nutrisinya secara paralel
            nutritionResults = try await withThrowingTaskGroup(of: NutritionData.self) { group in
                for item in items {
                    group.addTask {
                        try await self.nutritionService.getNutrition(for: item.foodID)
                    }
                }

                var results: [NutritionData] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
        } catch {
            errorMessage = "Gagal memuat informasi nutrisi"
        }
    }
}
```

### Keunggulan async/await
- **Mudah dibaca.** Kode dibaca dari atas ke bawah seperti kode biasa.
- **Error handling jelas.** Gunakan `do-catch` seperti biasa.
- **Pembatalan otomatis.** `Task` bisa di-cancel, dan `Task.isCancelled` bisa dicek di dalam fungsi async.

---

## Combine: Untuk Data yang Mengalir Terus-menerus

### Apa Itu

Combine adalah framework reactive dari Apple yang bekerja dengan konsep Publisher (sumber data) dan Subscriber (penerima data). Combine menyediakan operator untuk mentransformasi aliran data: menunggu jeda (debounce), menghilangkan duplikat (removeDuplicates), menggabungkan beberapa sumber (combineLatest), dan lainnya.

### Kapan Digunakan di Proyek Ini

| Skenario di PRD | Mengapa Combine |
|-----------------|-----------------|
| Manual Input: pencarian makanan saat user mengetik | Perlu debounce agar tidak memanggil API setiap ketukan |
| Dashboard: memperbarui progress saat data meal berubah | Menggabungkan beberapa sumber data menjadi satu update |

### Contoh: Debounce Pencarian Makanan

Fitur Manual Input (PRD: "Food search/select + quantity") membutuhkan search bar. Tanpa debounce, setiap huruf yang diketik akan memicu panggilan API -- menghasilkan banyak request yang tidak perlu dan membebani server.

```swift
// ManualInputViewModel.swift
import Combine

@MainActor
final class ManualInputViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var searchResults: [FoodSearchResult] = []
    @Published private(set) var isSearching = false

    private let nutritionService: NutritionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(nutritionService: NutritionServiceProtocol) {
        self.nutritionService = nutritionService
        setupSearchPipeline()
    }

    private func setupSearchPipeline() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            // Tunggu 400ms sejak ketukan terakhir sebelum mengirim request.
            // Jika user mengetik "nasi goreng", hanya "nasi goreng" yang dikirim,
            // bukan "n", "na", "nas", "nasi", "nasi ", "nasi g", dst.
            .removeDuplicates()
            // Jika user mengetik "nasi", menghapus satu huruf, lalu mengetik lagi "nasi",
            // tidak perlu mengirim request yang sama dua kali.
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            // Jangan mengirim request jika search bar kosong.
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        Task {
            isSearching = true
            defer { isSearching = false }

            do {
                searchResults = try await nutritionService.searchFood(query: query)
            } catch {
                searchResults = []
            }
        }
    }
}
```

**Penjelasan baris per baris:**
- `$searchText` -- mengakses Publisher dari property `@Published`. Setiap kali `searchText` berubah, Publisher mengirimkan nilai baru.
- `.debounce(for: .milliseconds(400), ...)` -- menunggu 400 milidetik tanpa perubahan baru sebelum meneruskan nilai. Angka 400ms adalah kompromi: cukup cepat agar user tidak merasa menunggu, tapi cukup lambat untuk menghindari panggilan API berlebihan.
- `.removeDuplicates()` -- mencegah panggilan API jika teks tidak berubah.
- `.filter { ... }` -- mencegah panggilan API dengan query kosong.
- `.sink { ... }` -- menerima nilai akhir dari pipeline dan menjalankan logika pencarian.
- `.store(in: &cancellables)` -- menyimpan subscription agar tidak langsung dihapus dari memori. Tanpa ini, pipeline tidak akan berjalan.

### Penting: Kelola AnyCancellable

Setiap subscription Combine menghasilkan objek `AnyCancellable`. Objek ini harus disimpan selama subscription masih dibutuhkan:

```swift
// BAIK: subscription disimpan
private var cancellables = Set<AnyCancellable>()

// BURUK: subscription tidak disimpan, langsung hilang dari memori
$searchText
    .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
    .sink { query in performSearch(query: query) }
    // subscription langsung de-allocate, tidak pernah berjalan
```

---

## Kapan Combine, Kapan async/await: Panduan Cepat

| Pertanyaan | async/await | Combine |
|------------|-------------|---------|
| Berapa kali data dikirim? | Sekali | Berkali-kali |
| Perlu debounce/throttle? | Tidak | Ya |
| Perlu menggabungkan beberapa sumber? | Tidak biasanya | Ya |
| Apakah mudah dibaca oleh developer junior? | Ya, sangat | Perlu waktu untuk terbiasa |
| Digunakan di mana di proyek ini? | FoodScan, NutritionResult, MealHistory, Profile | ManualInput search, Dashboard update |

**Aturan praktis untuk tim ini:**
- **Defaultnya selalu async/await.** Gunakan async/await kecuali kamu menghadapi masalah yang secara spesifik membutuhkan operator Combine (debounce, combineLatest, dsb).
- **Jangan gunakan Combine hanya karena bisa.** Jika operasinya satu kali (fetch data, save data), async/await lebih sederhana dan lebih mudah di-debug.

---

## Referensi

- Apple Inc. *Combine Framework Documentation.* https://developer.apple.com/documentation/combine
- Apple Inc. *Concurrency - The Swift Programming Language.* https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/
- Sundell, J. *Combine vs async/await.* https://www.swiftbysundell.com/articles/
