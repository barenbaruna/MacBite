# Dependency Injection

## Apa Itu Dependency Injection

Dependency Injection (DI) adalah cara memberikan objek yang dibutuhkan (dependency) kepada sebuah class dari luar, bukan membiarkan class tersebut membuat dependency-nya sendiri.

Analogi sederhana: Bayangkan kamu memesan kopi di kafe. DI seperti kafe yang menyediakan gelas, air panas, dan kopi -- kamu tinggal menyeduh. Tanpa DI, kamu harus pergi ke kebun kopi sendiri, ambil air dari sumur, dan membakar biji kopi sendiri sebelum bisa minum.

Dalam konteks kode, ini berarti:

```swift
// Tanpa DI: ViewModel "pergi ke kebun kopi sendiri"
class FoodScanViewModel: ObservableObject {
    private let service = FoodDetectionService() // membuat sendiri
}

// Dengan DI: ViewModel "terima kopi yang sudah disiapkan"
class FoodScanViewModel: ObservableObject {
    private let service: FoodDetectionServiceProtocol

    init(service: FoodDetectionServiceProtocol) { // diberikan dari luar
        self.service = service
    }
}
```

---

## Mengapa Kita Perlu DI di Proyek Ini

Ada tiga alasan utama mengapa DI penting untuk CallBite:

### 1. Testing

ViewModel `NutritionResultViewModel` bergantung pada `NutritionServiceFacade` yang memanggil API USDA dan FatSecret. Tanpa DI, setiap kali kita menjalankan unit test, kode akan memanggil API asli -- lambat, membutuhkan internet, dan hasilnya tidak konsisten.

Dengan DI, kita bisa mengganti service asli dengan versi tiruan (mock):

```swift
// Mock service untuk testing
final class MockNutritionService: NutritionServiceProtocol {
    func searchFood(query: String) async throws -> [FoodSearchResult] {
        return [
            FoodSearchResult(id: "1", name: "Nasi Putih", calories: 130),
            FoodSearchResult(id: "2", name: "Ayam Goreng", calories: 246)
        ]
    }

    func getNutrition(for foodID: String) async throws -> NutritionData {
        return NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3)
    }
}

// Dalam unit test
@MainActor
func testSearchReturnsResults() async {
    let mockService = MockNutritionService()
    let viewModel = ManualInputViewModel(nutritionService: mockService)

    await viewModel.search(query: "Nasi")

    #expect(viewModel.searchResults.count == 2)
}
```

### 2. SwiftUI Previews

Saat mengembangkan UI, kita ingin melihat preview tanpa harus menyambung ke API asli. DI memungkinkan kita menyediakan data dummy:

```swift
#Preview {
    let mockService = MockNutritionService()
    let viewModel = ManualInputViewModel(nutritionService: mockService)
    ManualInputView(viewModel: viewModel, onDismiss: {})
}
```

### 3. Kejelasan Dependency

Dengan DI, kamu bisa tahu persis apa yang dibutuhkan sebuah ViewModel hanya dengan melihat signature `init`-nya. Tidak ada dependency tersembunyi.

```swift
// Dari init ini, kita langsung tahu ViewModel ini butuh 2 hal:
init(detectionService: FoodDetectionServiceProtocol,
     nutritionService: NutritionServiceProtocol) {
    self.detectionService = detectionService
    self.nutritionService = nutritionService
}
```

---

## Strategi DI di Proyek Ini

### Langkah 1: Definisikan Protocol

Protocol mendefinisikan kontrak: "apa yang bisa dilakukan oleh sebuah service", tanpa menentukan "bagaimana caranya".

```swift
// Services/NutritionService/NutritionServiceProtocol.swift
protocol NutritionServiceProtocol {
    func searchFood(query: String) async throws -> [FoodSearchResult]
    func getNutrition(for foodID: String) async throws -> NutritionData
}
```

Protocol dibuat hanya untuk service yang perlu di-mock saat testing. Jangan membuat protocol untuk setiap class.

Kapan membuat protocol:
- Service memanggil API external (USDA, FatSecret) -- **buat protocol**
- Service menjalankan inferensi ML model -- **buat protocol**
- Service berisi kalkulasi matematika murni -- **tidak perlu protocol** (langsung testable tanpa mock)

### Langkah 2: Buat Implementasi Asli dan Mock

```swift
// Implementasi asli (production)
final class NutritionServiceFacade: NutritionServiceProtocol {
    func searchFood(query: String) async throws -> [FoodSearchResult] {
        // panggil FatSecret API, fallback ke USDA
    }
}

// Implementasi mock (testing & preview)
final class MockNutritionService: NutritionServiceProtocol {
    var mockResults: [FoodSearchResult] = []

    func searchFood(query: String) async throws -> [FoodSearchResult] {
        return mockResults
    }
}
```

### Langkah 3: Inject via Constructor

ViewModel menerima dependency melalui parameter `init`:

```swift
@MainActor
final class ManualInputViewModel: ObservableObject {
    private let nutritionService: NutritionServiceProtocol

    init(nutritionService: NutritionServiceProtocol) {
        self.nutritionService = nutritionService
    }
}
```

### Langkah 4: Wiring di Factory

Factory yang bertanggung jawab menyambungkan implementasi asli ke ViewModel:

```swift
enum ManualInputFactory {
    @MainActor
    static func makeView(onDismiss: @escaping () -> Void = {}) -> some View {
        let nutritionService = NutritionServiceFacade() // implementasi asli
        let viewModel = ManualInputViewModel(nutritionService: nutritionService)
        return ManualInputView(viewModel: viewModel, onDismiss: onDismiss)
    }
}
```

---

## AppContainer (Opsional, untuk Dependency yang Dibagi Lintas Fitur)

Jika ada service yang dipakai oleh banyak fitur (misalnya `NutritionServiceFacade` dipakai oleh FoodScan, ManualInput, dan MealHistory), kita bisa membuat satu container yang menyimpan instance-instance tersebut:

```swift
// App/AppContainer.swift
@MainActor
final class AppContainer: ObservableObject {
    let nutritionService: NutritionServiceProtocol
    let mealStore: MealStore
    let userPreferences: UserPreferencesStore

    init() {
        self.nutritionService = NutritionServiceFacade()
        self.mealStore = MealStore()
        self.userPreferences = UserPreferencesStore()
    }
}
```

Container ini dibuat sekali di entry point aplikasi dan diteruskan ke Factory yang membutuhkan:

```swift
@main
struct CallBiteApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
        }
    }
}
```

---

## Mengapa Tidak Menggunakan Library Pihak Ketiga

Library DI seperti Swinject atau Resolver menyediakan fitur seperti auto-resolution dan scope management. Namun, untuk proyek ini kita tidak menggunakannya karena:

1. **Kompleksitas tambahan yang tidak sebanding.** Proyek ini memiliki sekitar 7-8 fitur. Jumlah dependency yang perlu di-manage masih bisa ditangani secara manual tanpa masalah.

2. **Overhead belajar.** Library DI memiliki konsep-konsep seperti container registration, scope, dan assembly yang perlu dipelajari. Untuk tim junior dengan timeline 12 hari, waktu belajar ini lebih baik digunakan untuk mengembangkan fitur.

3. **Swift sudah menyediakan mekanisme yang cukup.** Kombinasi protocol + constructor injection + Factory sudah mencakup kebutuhan kita. Tidak ada masalah yang tidak bisa diselesaikan tanpa library tambahan.

4. **Ketergantungan minimum.** Semakin sedikit library pihak ketiga, semakin sedikit potensi masalah kompatibilitas dan maintenance di masa depan.

---

## Ringkasan Alur DI

```
Protocol (kontrak)
     |
     v
Implementation (kode asli)  /  Mock (tiruan untuk testing)
     |
     v
Factory (menyambungkan implementation ke ViewModel)
     |
     v
ViewModel (menerima dependency via init)
     |
     v
View (menerima ViewModel via init)
```

---

## Referensi

- Fowler, M. (2004). *Inversion of Control Containers and the Dependency Injection pattern.* https://martinfowler.com/articles/injection.html
- Sundell, J. *Dependency injection in Swift.* https://www.swiftbysundell.com/articles/dependency-injection-in-swift/
- Apple Inc. *SwiftUI Environment Documentation.* https://developer.apple.com/documentation/swiftui/environment
