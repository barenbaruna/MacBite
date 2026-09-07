# Panduan Membuat Fitur Baru

## Langkah-langkah

### 1. Buat Folder Fitur

Buat folder baru di `Features/` dengan struktur standar:

```
CallBite/Features/[NamaFitur]/
├── [NamaFitur]Factory.swift
├── Models/
├── Services/              (opsional, jika ada logika bisnis khusus)
├── ViewModels/
│   └── [NamaFitur]ViewModel.swift
└── Views/
    ├── [NamaFitur]View.swift
    └── Components/
```

### 2. Buat Models

Definisikan data model yang dibutuhkan fitur ini.

```swift
//
//  NutritionData.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 31/08/26.
//

import Foundation

struct NutritionData: Identifiable, Equatable {
    let id: UUID
    let foodName: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    init(id: UUID = UUID(), foodName: String, calories: Double,
         protein: Double, carbs: Double, fat: Double) {
        self.id = id
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}
```

### 3. Buat Service (Jika Diperlukan)

Hanya buat service jika ada logika kompleks yang terpisah dari UI. Lihat [08_Design_Patterns.md](./08_Design_Patterns.md) untuk kapan service perlu protocol.

```swift
//
//  InsightService.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 31/08/26.
//

import Foundation

final class InsightService {
    func generateInsight(
        intake: DailyProgress,
        target: NutritionTarget
    ) async throws -> String {
        // Menggunakan Foundation Models untuk menghasilkan saran
        // berdasarkan intake vs target
    }
}
```

### 4. Buat ViewModel

ViewModel mengikuti aturan di [02_Coding_Standards.md](./02_Coding_Standards.md):

```swift
//
//  NutritionResultViewModel.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 31/08/26.
//

import Combine

@MainActor
final class NutritionResultViewModel: ObservableObject {
    @Published private(set) var nutritionItems: [NutritionData] = []
    @Published private(set) var insight: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let nutritionService: NutritionServiceProtocol
    private let insightService: InsightService

    init(nutritionService: NutritionServiceProtocol,
         insightService: InsightService) {
        self.nutritionService = nutritionService
        self.insightService = insightService
    }

    func loadNutrition(for items: [DetectedFoodItem]) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // Ambil data nutrisi untuk setiap item yang terdeteksi
                var results: [NutritionData] = []
                for item in items {
                    let data = try await nutritionService.getNutrition(for: item.foodID)
                    results.append(data)
                }
                nutritionItems = results
            } catch {
                errorMessage = "Gagal memuat informasi nutrisi"
            }
        }
    }
}
```

### 5. Buat View

```swift
//
//  NutritionResultView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

struct NutritionResultView: View {
    @ObservedObject private var viewModel: NutritionResultViewModel
    let onDismiss: () -> Void

    init(viewModel: NutritionResultViewModel, onDismiss: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            List(viewModel.nutritionItems) { item in
                NutritionItemRow(item: item)
            }
            .navigationTitle("Hasil Nutrisi")
            .onAppear { viewModel.loadNutrition(for: detectedItems) }
        }
    }
}
```

### 6. Buat Factory

Factory menghubungkan semua dependency. Lihat [08_Design_Patterns.md](./08_Design_Patterns.md) dan [09_Dependency_Injection.md](./09_Dependency_Injection.md).

```swift
//
//  NutritionResultFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

enum NutritionResultFactory {
    @MainActor
    static func makeView(
        detectedItems: [DetectedFoodItem],
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        let nutritionService = NutritionServiceFacade()
        let insightService = InsightService()
        let viewModel = NutritionResultViewModel(
            nutritionService: nutritionService,
            insightService: insightService
        )
        return NutritionResultView(viewModel: viewModel, onDismiss: onDismiss)
    }
}
```

### 7. Tambahkan Route (Jika Navigasi dari Halaman Lain)

Tambahkan case baru di `App/Navigation/AppRoute.swift`:

```swift
enum AppRoute: Hashable {
    case dashboard
    case foodScan
    case nutritionResult(items: [DetectedFoodItem])   // tambah ini
    case manualInput
    case mealHistory
    case profile
}
```

### 8. Hubungkan dari Halaman Pemanggil

Dari FoodScanView atau halaman lain:

```swift
.fullScreenCover(isPresented: $showResult) {
    NutritionResultFactory.makeView(
        detectedItems: viewModel.detectedItems,
        onDismiss: { showResult = false }
    )
}
```

---

## Checklist Fitur Baru

Sebelum membuat Pull Request untuk fitur baru, pastikan:

- [ ] File header standar Xcode (`//  NamaFile.swift`, `CallBite`, `Created by ...`) ada di setiap file baru
- [ ] Folder fitur dibuat di `Features/[NamaFitur]/`
- [ ] Factory method tersedia
- [ ] ViewModel menggunakan `@MainActor` + `ObservableObject`
- [ ] View menerima ViewModel via init (bukan buat sendiri)
- [ ] Dependencies di-inject via constructor (lihat [09_Dependency_Injection.md](./09_Dependency_Injection.md))
- [ ] Error ditampilkan dalam Bahasa Indonesia
- [ ] Menggunakan design tokens (`AppSpacing`, `AppCornerRadius`, `AppColor`, `AppTypography`, `AppAnimation`, `AppHaptics`)
- [ ] Memenuhi semua kriteria [05_HIG_Checklist.md](./05_HIG_Checklist.md) (Dynamic Type xSmall-AX5, minimum 44×44pt touch target, semantic modal dismiss/confirm, Liquid Glass layer compliance)
- [ ] Tidak ada kode yang duplikat dengan Core
- [ ] Commit message sesuai Conventional Commits
- [ ] Minimal satu unit test untuk ViewModel (jika ada logika bisnis)
- [ ] SwiftLint tidak menampilkan error atau warning yang melanggar rules

---

## Yang Tidak Boleh Dilakukan

- Membuat UseCase, Repository, DataSource, Mapper terpisah (kecuali benar-benar perlu untuk mengurangi kompleksitas ViewModel)
- Membuat protocol untuk setiap service (hanya jika perlu di-mock, lihat [09_Dependency_Injection.md](./09_Dependency_Injection.md))
- Meletakkan UI string dalam Bahasa Inggris
- Hardcode warna, spacing, atau font size
- Import library third-party tanpa diskusi tim
- Commit langsung ke `main` atau `development`
