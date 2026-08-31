# Testing Strategy

## Pendekatan Kita Terhadap Testing

Testing bukan tentang menguji segalanya. Testing tentang menguji hal yang benar dengan cara yang efektif. Dengan timeline 12 hari dan tim 3 orang, kita harus strategis: fokus pada bagian kode yang paling berisiko menyebabkan bug, yaitu logika bisnis di ViewModel dan Service.

Pendekatan kita: **Test the logic, not the layout.**

| Layer | Dites? | Alasan |
|-------|--------|--------|
| ViewModel | Ya (unit test) | Berisi logika bisnis: kalkulasi nutrisi, transformasi data, state management |
| Service | Ya (unit test) | Berisi logika integrasi: parsing response API, fallback logic |
| View (SwiftUI) | Tidak (gunakan Preview) | SwiftUI View adalah deklarasi UI, bukan logika. Validasi visual dilakukan via Preview dan manual testing |
| Model (struct) | Opsional | Biasanya cukup sederhana, tapi test jika ada computed properties atau validasi |

---

## Format Test: Given-When-Then

Setiap test ditulis dengan struktur **Given-When-Then** (juga dikenal sebagai Arrange-Act-Assert). Format ini membuat setiap test mudah dibaca dan dipahami, bahkan oleh developer yang tidak menulis test tersebut.

- **Given (Persiapan):** Siapkan kondisi awal dan dependency yang dibutuhkan.
- **When (Aksi):** Jalankan aksi yang ingin diuji.
- **Then (Verifikasi):** Periksa apakah hasilnya sesuai ekspektasi.

```swift
@Test("Kalkulasi total kalori dari beberapa meal entry")
@MainActor
func totalCaloriesCalculation() {
    // Given: dua meal entry dengan kalori yang diketahui
    let meals = [
        MealEntry(name: "Nasi Putih", calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
        MealEntry(name: "Ayam Goreng", calories: 246, protein: 25, carbs: 8, fat: 14)
    ]
    let calculator = NutritionCalculator()

    // When: hitung total
    let totals = calculator.calculateTotals(from: meals)

    // Then: total kalori harus 376
    #expect(totals.calories == 376)
    #expect(totals.protein == 27.7)
}
```

---

## Framework Testing: Swift Testing

Proyek ini menggunakan **Swift Testing** (diperkenalkan oleh Apple tahun 2024) sebagai framework utama, bukan XCTest. Keduanya bisa berdampingan dalam satu proyek, tapi untuk test baru, gunakan Swift Testing.

### Mengapa Swift Testing, Bukan XCTest

| Aspek | XCTest | Swift Testing |
|-------|--------|---------------|
| Syntax | `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| Diagnostik saat gagal | Menunjukkan "expected X, got Y" | Menunjukkan nilai sebenarnya dari setiap ekspresi |
| Organisasi | Class-based (`XCTestCase`) | Struct-based (`@Suite`, `@Test`) |
| Paralelisme | Manual | Otomatis (test berjalan paralel secara default) |

Swift Testing menghasilkan pesan error yang lebih informatif. Misalnya:

```swift
// Jika test ini gagal...
#expect(totals.calories == 376)

// Swift Testing menampilkan:
// Expectation failed: (totals.calories → 375) == 376
// Langsung terlihat bahwa totalnya 375, bukan 376.
```

### Syntax Dasar Swift Testing

```swift
import Testing
@testable import CallBite

@Suite("NutritionCalculator Tests")
struct NutritionCalculatorTests {

    @Test("Mengembalikan nol jika tidak ada meal")
    func emptyMealsReturnsZero() {
        let calculator = NutritionCalculator()
        let totals = calculator.calculateTotals(from: [])

        #expect(totals.calories == 0)
        #expect(totals.protein == 0)
    }

    @Test("Menghitung total dari multiple meals")
    func multipleMealsCalculation() {
        let meals = [
            MealEntry(name: "Nasi Putih", calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
            MealEntry(name: "Telur Rebus", calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3)
        ]
        let calculator = NutritionCalculator()
        let totals = calculator.calculateTotals(from: meals)

        #expect(totals.calories == 208)
    }
}
```

---

## Apa yang Harus Diuji di Proyek Ini

Berikut daftar skenario testing yang relevan berdasarkan fitur-fitur di PRD:

### Dashboard / Goal Based Progress

| Skenario | Yang Diuji |
|----------|------------|
| Kalkulasi total kalori dari beberapa meal | `NutritionCalculator.calculateTotals()` |
| Kalkulasi sisa kalori (target - intake) | `DashboardViewModel.remainingCalories` |
| Persentase progress harian | `DashboardViewModel.progressPercentage` |
| Kondisi saat intake melebihi target | Apakah ViewModel menangani kelebihan dengan benar |

### FoodScan / AI Food Detection

| Skenario | Yang Diuji |
|----------|------------|
| Detection berhasil menghasilkan daftar makanan | `FoodScanViewModel.detectedItems` terisi setelah `analyzeImage()` |
| Detection gagal menampilkan pesan error | `FoodScanViewModel.errorMessage` terisi saat service throw error |
| State berubah dari idle -> analyzing -> completed | Urutan perubahan `scanPhase` |

### ManualInput

| Skenario | Yang Diuji |
|----------|------------|
| Pencarian mengembalikan hasil | `ManualInputViewModel.searchResults` terisi setelah pencarian |
| Pencarian kosong tidak memanggil API | Verifikasi bahwa mock service tidak dipanggil |

### NutritionResult / Portion Confirmation

| Skenario | Yang Diuji |
|----------|------------|
| Mengubah portion multiplier mengubah kalori | `PortionConfirmationViewModel.adjustedCalories` |
| Kalkulasi nutrisi untuk multiple items | Total dari beberapa `NutritionData` |

---

## Contoh Unit Test ViewModel (Lengkap)

```swift
import Testing
@testable import CallBite

@Suite("FoodScanViewModel Tests")
struct FoodScanViewModelTests {

    // Mock service yang mengembalikan data dummy
    final class MockDetectionService: FoodDetectionServiceProtocol {
        var shouldFail = false

        func detect(from image: UIImage) async throws -> [DetectedFoodItem] {
            if shouldFail {
                throw AppError.detectionFailed(message: "Model tidak tersedia")
            }
            return [
                DetectedFoodItem(id: "1", name: "Nasi Putih", confidence: 0.92),
                DetectedFoodItem(id: "2", name: "Ayam Goreng", confidence: 0.87)
            ]
        }
    }

    @Test("Detection berhasil mengisi detected items")
    @MainActor
    func successfulDetection() async {
        // Given
        let mockService = MockDetectionService()
        let viewModel = FoodScanViewModel(detectionService: mockService)

        // When
        await viewModel.analyzeImage(UIImage())

        // Then
        #expect(viewModel.detectedItems.count == 2)
        #expect(viewModel.scanPhase == .completed)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Detection gagal menampilkan error message")
    @MainActor
    func failedDetection() async {
        // Given
        let mockService = MockDetectionService()
        mockService.shouldFail = true
        let viewModel = FoodScanViewModel(detectionService: mockService)

        // When
        await viewModel.analyzeImage(UIImage())

        // Then
        #expect(viewModel.detectedItems.isEmpty)
        #expect(viewModel.scanPhase == .error)
        #expect(viewModel.errorMessage != nil)
    }
}
```

---

## Menjalankan Test

### Di Xcode
- `Cmd + U` untuk menjalankan semua test.
- Klik ikon berlian di sebelah kiri `@Test` untuk menjalankan satu test.

### Di Terminal
```bash
xcodebuild test \
    -project CallBite.xcodeproj \
    -scheme CallBite \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Aturan Testing untuk Tim

1. **Setiap ViewModel yang memiliki logika bisnis harus memiliki minimal satu test.** "Logika bisnis" berarti kalkulasi, transformasi data, atau keputusan kondisional. Jika ViewModel hanya meneruskan data dari Service ke View tanpa transformasi, test tidak wajib.

2. **Test ditulis bersamaan dengan kode, bukan setelah semua fitur selesai.** Idealnya sebelum menulis implementasi (TDD), tapi minimal ditulis dalam Pull Request yang sama dengan fitur yang bersangkutan.

3. **Nama test harus menjelaskan skenario, bukan implementasi.** Bandingkan:
   - Buruk: `testCalculate()`
   - Baik: `@Test("Kalkulasi total kalori dari beberapa meal entry")`

4. **Satu test menguji satu hal.** Jangan membuat test yang menguji 5 skenario sekaligus. Jika satu bagian gagal, kamu tidak tahu bagian mana yang bermasalah.

5. **Mock hanya untuk external dependency.** Jangan mock segala hal. Jika `NutritionCalculator` hanya berisi kalkulasi matematika murni, langsung test tanpa mock.

---

## Referensi

- Apple Inc. *Swift Testing Documentation.* https://developer.apple.com/documentation/testing
- Apple Inc. *WWDC24: Meet Swift Testing.* https://developer.apple.com/videos/play/wwdc2024/10179/
- Beck, K. (2002). *Test Driven Development: By Example.* Addison-Wesley.
- Sundell, J. *Unit testing Swift code.* https://www.swiftbysundell.com/articles/unit-testing-swift-code/
