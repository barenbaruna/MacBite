# Arsitektur Aplikasi

## Ringkasan

MacBite menggunakan arsitektur **MVVM (Model-View-ViewModel) + Feature-Based** dengan SwiftUI sebagai framework UI.

| Item | Value |
|------|-------|
| Architecture Pattern | MVVM (Model-View-ViewModel) |
| Organisasi Kode | Feature-based folders + Shared Domain |
| UI Framework | SwiftUI |
| Target iOS | 26+ |
| Language | Swift 6.0+ |
| Concurrency | Swift Concurrency (async/await) + Combine (untuk reactive streams) |

---

## Mengapa MVVM + Feature-Based?

Sebelum menulis kode, kita perlu memahami mengapa arsitektur ini dipilih dan apa alternatif yang tidak kita gunakan.

### Alternatif yang Dipertimbangkan

**MVC (Model-View-Controller)**
- Arsitektur paling sederhana dari Apple.
- Masalah: Dalam SwiftUI, tidak ada "Controller" secara eksplisit. Logika bisnis cenderung menumpuk di dalam View, sehingga sulit diuji dan sulit dibaca saat fitur bertambah kompleks.
- Kesimpulan: Tidak cocok untuk proyek dengan 8+ fitur yang saling terhubung seperti MacBite.

**VIPER (View-Interactor-Presenter-Entity-Router)**
- Arsitektur yang sangat terstruktur, cocok untuk tim besar (10+ developer) dengan proyek berskala enterprise.
- Masalah: Setiap screen membutuhkan minimal 5 file terpisah (View, Interactor, Presenter, Entity, Router). Untuk tim 3 orang dengan timeline 12 hari, overhead ini memperlambat pengembangan secara signifikan tanpa memberikan manfaat yang sebanding.
- Kesimpulan: Over-engineering untuk skala proyek kita.

**Clean Architecture (dengan UseCase, Repository, DataSource)**
- Pendekatan berlapis yang memisahkan domain logic dari detail implementasi.
- Masalah: Untuk fitur sederhana seperti menampilkan Meal History, kita harus membuat UseCase, Repository, DataSource, Mapper, Entity, dan DTO. Layer-layer ini menambah kompleksitas tanpa manfaat nyata di skala proyek kita.
- Kesimpulan: Kita mengambil prinsipnya (separation of concerns) tanpa adopsi penuh layer-nya.

### Mengapa MVVM Cocok untuk Proyek Ini

1. **Sinergi dengan SwiftUI.** SwiftUI adalah framework yang berbasis state. Property wrapper seperti `@Published`, `@ObservedObject`, dan `@StateObject` secara natural membentuk pola Observer yang menjadi inti dari MVVM. ViewModel menjadi tempat state dan logika bisnis, SwiftUI secara otomatis merender ulang UI saat state berubah.

2. **Keseimbangan antara kecepatan dan struktur.** MVVM memberikan pemisahan yang jelas antara tampilan (View) dan logika (ViewModel) tanpa memaksa kita membuat banyak file boilerplate seperti VIPER. Untuk fitur baru, kita hanya perlu membuat 3-4 file (Model, ViewModel, View, dan opsional Service/Factory).

3. **Ukuran tim dan timeline.** Dengan 3 developer dan 12 hari kerja, kita membutuhkan arsitektur yang bisa dipelajari dalam hitungan jam, bukan hari. MVVM adalah pattern yang paling banyak didokumentasikan untuk SwiftUI, sehingga setiap anggota tim bisa produktif dengan cepat.

4. **Testability yang cukup.** ViewModel yang terpisah dari View memungkinkan kita menulis unit test untuk logika bisnis (kalkulasi nutrisi, validasi input, transformasi data) tanpa perlu menjalankan simulator.

### Mengapa Feature-Based (Bukan Group-by-Type)

Ada dua cara mengorganisasi folder dalam proyek:

**Group-by-Type** (tidak kita gunakan):
```
Views/
    DashboardView.swift
    CameraScanView.swift
    MealHistoryView.swift
ViewModels/
    DashboardViewModel.swift
    CameraScanViewModel.swift
    MealHistoryViewModel.swift
Models/
    FoodItem.swift
    NutritionData.swift
```

Masalah: Saat mengerjakan fitur Camera Scan, kamu harus membuka 3 folder berbeda dan mencari file di antara puluhan file lain. Semakin banyak fitur, semakin sulit navigasinya.

**Feature-Based** (yang kita gunakan):
```
Features/
    CameraScan/
        Models/
        ViewModels/
        Views/
        Services/
```

Keuntungan: Semua kode yang berhubungan dengan satu fitur ada dalam satu folder. Jika kamu ingin memahami atau mengubah fitur Camera Scan, cukup buka satu folder. Jika fitur tersebut dihapus, cukup hapus satu folder tanpa membahayakan bagian lain.

---

## Struktur Folder Proyek

Struktur berikut dirancang berdasarkan fitur-fitur yang tercantum dalam PRD (Food Scan, AI Food Detection, Nutrition Calculation, Goal Based Progress, Actionable Insight, Manual Input, Meal History, Profile):

```
CallBite/
├── App/                              # App lifecycle dan navigasi
│   ├── AppRoute.swift                # Enum semua route navigasi
│   ├── CallBiteWidgetAction+AppRoute.swift
│   └── LoggingDestinationView.swift  # Destination view handler
│
├── Core/                             # Kode yang dipakai bersama oleh semua fitur
│   ├── Domain/                       # Domain models (dipakai lintas fitur)
│   │   ├── Meals/
│   │   │   ├── FoodItem.swift        # Satu item makanan (nama, porsi, nutrisi)
│   │   │   └── MealTimeSlot.swift    # Slot waktu makan (sarapan, siang, dll)
│   │   ├── Nutrition/
│   │   │   ├── NutritionFacts.swift  # Data nutrisi: kalori, protein, carbs, fat
│   │   │   └── DailySummary.swift    # Ringkasan harian: intake vs target
│   │   ├── Goals/
│   │   │   ├── NutritionGoal.swift   # Target harian user (kalori, protein, dll)
│   │   │   └── GoalCalculator.swift  # Logika hitung sisa target
│   │   └── Analysis/
│   │       ├── FoodCandidate.swift    # Hasil deteksi AI (nama + confidence score)
│   │       └── FoodAnalyzing.swift    # Protocol untuk analyzer (Gemini/CoreML/Mock)
│   │
│   ├── Persistence/                  # Penyimpanan data lokal
│   │   ├── Models/
│   │   │   ├── MealRecord.swift      # Representasi database (terpisah dari domain)
│   │   │   └── FoodItemRecord.swift
│   │   └── SwiftDataMealStore.swift  # Implementasi store
│   │
│   ├── DesignSystem/
│   │   ├── Components/               # Komponen UI reusable (AppCard, PrimaryButton)
│   │   ├── Modifiers/                # Custom view modifiers
│   │   └── Tokens/                   # Konstanta visual (AppColor, AppSpacing)
│   │
│   ├── Errors/
│   │   └── AppError.swift            # Error enum dan error mapping
│   │
│   └── Extensions/                   # Extension Swift/SwiftUI yang dipakai global
│
├── Features/                         # Semua fitur, masing-masing folder mandiri
│   ├── Splash/                       # Layar animasi awal
│   │   └── View/
│   │       └── SplashScreenView.swift
│   ├── Onboarding/                   # Setup awal: HealthKit, Biometrik, Target
│   │   ├── OnboardingFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── Dashboard/                    # Goal Based Progress, ringkasan harian, dan meal history
│   │   ├── DashboardFactory.swift
│   │   ├── ViewModels/
│   │   │   ├── DashboardViewModel.swift
│   │   │   ├── DashboardViewModel+Analysis.swift
│   │   │   ├── DashboardViewModel+Animation.swift
│   │   │   ├── DashboardViewModel+Insight.swift
│   │   │   └── DashboardViewModel+Persistence.swift
│   │   └── Views/
│   │       ├── DashboardView.swift
│   │       ├── DashboardView+Subviews.swift
│   │       └── Components/
│   ├── Calendar/                     # Kalender mingguan & navigasi riwayat
│   │   ├── CalorieCalendarFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── FoodCapture/                  # Camera capture + orientasi + AI food detection
│   │   ├── FoodCaptureFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Views/
│   ├── ManualLogging/                # Input manual makanan dan kalkulasi nutrisi
│   │   ├── ManualLoggingFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── Goals/                        # Pengaturan target nutrisi & scientific slider
│   │   ├── GoalsFactory.swift
│   │   ├── ViewModels/
│   │   └── Views/
│   └── Profile/                      # Profil biometrik dan target personal
│       ├── ProfileFactory.swift
│       ├── ViewModels/
│       └── Views/
│
├── AI/                               # Implementasi on-device AI/ML
│   ├── CoreML/                       # Klasifikasi makanan & regresi massa
│   │   ├── CoreMLFoodAnalyzer.swift
│   │   ├── FoodGateService.swift
│   │   ├── NutritionRegressionService.swift
│   │   └── ImagePreprocessingService.swift
│   ├── FoundationModels/             # Apple Foundation Models untuk estimasi & coach insight
│   │   ├── FoundationModelFoodNamer.swift
│   │   ├── FoundationModelNutritionEstimator.swift
│   │   ├── FoundationModelInsightGenerator.swift
│   │   └── VisionEvidenceExtractor.swift
│   └── Mock/                         # Mock analyzer untuk preview & unit tests
│       ├── MockFoodAnalyzer.swift
│       ├── MockNutritionEstimator.swift
│       └── MockInsightGenerator.swift
│
├── Services/                         # Service integrasi sistem
│   └── Health/
│       ├── HealthKitClient.swift
│       ├── HealthServiceProtocol.swift
│       └── MockHealthKitService.swift
│
├── CallBiteShared/                   # Model & store yang dibagi dengan extension
│   └── Widget/
│       ├── CallBiteWidgetSnapshot.swift
│       ├── CallBiteWidgetSnapshotStore.swift
│       ├── CallBiteWidgetConfiguration.swift
│       └── CallBiteWidgetAction.swift
│
└── CallBiteWidget/                   # Target Home Screen Widget Extension
    ├── CallBiteWidget.swift
    ├── CallBiteWidgetProvider.swift
    ├── CallBiteWidgetEntry.swift
    └── CallBiteWidgetView.swift
```

---

## Mengapa Domain Models di Core, Bukan di Setiap Feature?

Ini adalah keputusan arsitektur yang paling penting untuk dipahami.

### Masalah: Model yang Dipakai Banyak Fitur

Perhatikan model `FoodItem` (satu item makanan). Model ini dibutuhkan oleh:

| Fitur | Kebutuhan |
|-------|-----------|
| FoodCapture | Menerima hasil deteksi AI sebagai daftar FoodItem |
| MealReview | Menampilkan daftar FoodItem untuk diedit porsinya |
| ManualLogging | Membuat FoodItem baru dari pencarian manual |
| Dashboard | Menampilkan total nutrisi dari semua FoodItem hari ini |
| MealHistory | Menampilkan daftar FoodItem per meal yang tercatat |

Jika `FoodItem` didefinisikan di dalam folder `FoodCapture/Models/`, maka fitur-fitur lain harus `import FoodCapture` untuk mengakses model tersebut. Ini membuat fitur-fitur yang seharusnya independen menjadi saling bergantung. Jika suatu hari fitur FoodCapture dihapus atau di-refactor, semua fitur yang import-nya akan ikut rusak.

### Solusi: Core/Domain sebagai Shared Layer

Dengan meletakkan `FoodItem` di `Core/Domain/Meals/`, semua fitur cukup mengakses `Core` -- layer yang memang dirancang untuk dipakai bersama. Tidak ada fitur yang bergantung pada fitur lain.

```
FoodCapture  --import-->  Core/Domain    <--import--  Dashboard
MealReview   --import-->  Core/Domain    <--import--  MealHistory
ManualLogging --import--> Core/Domain    <--import--  Goals
```

Aliran dependency hanya satu arah: **Feature -> Core**. Tidak pernah sebaliknya.

### Mengapa Dikelompokkan Per Sub-Domain (Meals, Nutrition, Goals, Analysis)?

Daripada melempar semua model ke satu folder datar (`Core/Domain/FoodItem.swift`, `Core/Domain/NutritionFacts.swift`, `Core/Domain/NutritionGoal.swift`), kita mengelompokkan berdasarkan sub-domain:

- `Meals/` -- Semua yang terkait makanan yang dicatat (item, draft, entry)
- `Nutrition/` -- Semua yang terkait angka nutrisi (fakta nutrisi, ringkasan, sumber data)
- `Goals/` -- Semua yang terkait target harian user
- `Analysis/` -- Semua yang terkait proses deteksi AI

Alasannya: Saat jumlah model bertambah (dan pasti akan bertambah), sub-folder ini mencegah satu folder berisi 15+ file yang sulit dinavigasi. Pengelompokan ini juga membantu developer baru memahami domain proyek: "Oh, semua yang berhubungan dengan target nutrisi ada di `Goals/`."

### Aturan untuk Domain Models

1. **Harus berupa struct.** Bukan class. Struct menggunakan value semantics, artinya setiap copy adalah salinan independen. Ini mencegah bug di mana dua fitur tanpa sengaja memodifikasi data yang sama.
2. **Hanya import Foundation.** Tidak boleh import SwiftUI, Combine, atau framework lain. Domain model murni menyimpan data, bukan logika UI.
3. **Tidak boleh berisi logika side-effect.** Tidak ada network call, tidak ada akses database. Logika tersebut ada di Service.

Contoh domain model yang benar:

```swift
//
//  FoodItem.swift
//  MacBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation

struct FoodItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let portionSize: Double
    let portionUnit: String
    let preparationMethod: String?

    init(id: UUID = UUID(), name: String, portionSize: Double,
         portionUnit: String, preparationMethod: String? = nil) {
        self.id = id
        self.name = name
        self.portionSize = portionSize
        self.portionUnit = portionUnit
        self.preparationMethod = preparationMethod
    }
}
```

### Kapan Model Boleh Tetap di Dalam Feature?

Jika sebuah model **hanya dipakai oleh satu fitur** dan tidak relevan di tempat lain, letakkan di folder feature tersebut. Contoh:

| Model | Lokasi | Alasan |
|-------|--------|--------|
| `CameraState` (enum: idle, capturing, processing) | `Features/FoodCapture/Models/` | Hanya relevan untuk UI kamera |
| `SearchResult` (wrapper hasil pencarian API) | `Features/ManualLogging/Models/` | Hanya untuk flow pencarian |
| `ProfileFormData` (temporary state form) | `Features/Settings/Models/` | Hanya untuk UI form profil |

Aturan sederhana:
- Dipakai oleh 2+ fitur -> `Core/Domain/`
- Dipakai oleh 1 fitur saja -> `Features/[Nama]/Models/`

---

## Mengapa Persistence Models Terpisah dari Domain Models?

Di `Core/Persistence/Models/` ada `FoodItemRecord.swift` yang menyimpan data terpisah dari `FoodItem.swift` di `Core/Domain/Meals/`. Mengapa tidak pakai satu model saja?

Jawaban: **Domain model dan persistence model punya lifecycle yang berbeda.**

- `FoodItem` (domain) adalah representasi data yang dimengerti oleh seluruh fitur aplikasi. Strukturnya ditentukan oleh kebutuhan fitur dan UI.
- `FoodItemRecord` & `MealRecord` (persistence) adalah representasi entitas database (SwiftData). Strukturnya ditentukan oleh kebutuhan penyimpanan data lokal.

Saat ini mungkin terlihat mirip. Tapi saat aplikasi berkembang, keduanya berevolusi secara independen:
- Database mungkin perlu menyimpan field tambahan (timestamp sinkronisasi, relasi SwiftData `@Relationship`).
- Domain model berfokus pada value type (`struct`), formatting, dan computed properties.

Mapping antara keduanya dilakukan di persistence service (`SwiftDataMealStore` / `MealDataService`). Ini memastikan jika skema database berubah, fitur-fitur UI tidak langsung terdampak.

---

## Alur Data

Alur data dalam aplikasi ini bersifat satu arah (unidirectional), mengikuti pola standar MVVM:

```
User Action --> View --> ViewModel --> Service (jika ada) --> ViewModel --> View Update
```

Penjelasan langkah demi langkah (contoh: user memfoto makanan):

1. **User menekan tombol kamera** di `FoodCaptureView`.
2. **View memanggil method** di `FoodCaptureViewModel` (misalnya `capturePhoto()`).
3. **ViewModel menjalankan logika**: memanggil AI analyzer (yang conform ke protocol `FoodAnalyzing` di `Core/Domain/Analysis/`) untuk deteksi makanan.
4. **Analyzer mengembalikan hasil** berupa `[FoodCandidate]` (domain model dari `Core/Domain/Analysis/`).
5. **ViewModel memperbarui `@Published` property** (misalnya `detectedItems`).
6. **SwiftUI secara otomatis merender ulang View** karena state berubah.

Aturan penting:
- **View tidak boleh memanggil Service secara langsung.** Semua komunikasi ke Service melalui ViewModel.
- **Service tidak boleh mengakses UI atau property `@Published`.** Service murni berisi logika bisnis.
- **ViewModel tidak boleh import SwiftUI** (kecuali untuk tipe dasar seperti `CGFloat` atau `Color` jika benar-benar diperlukan).

---

## Feature Module Template

Setiap fitur baru mengikuti struktur ini. Template lengkap dan panduan langkah demi langkah ada di [04_New_Feature_Guide.md](./04_New_Feature_Guide.md).

```
Features/[NamaFitur]/
├── [NamaFitur]Factory.swift      # Factory method: membuat view beserta semua dependency-nya
├── Models/                        # Struct khusus fitur ini (jika ada, bukan domain model)
├── ViewModels/
│   └── [NamaFitur]ViewModel.swift
└── Views/
    ├── [NamaFitur]View.swift      # View utama
    └── Components/                # Sub-views kecil yang hanya dipakai di fitur ini
```

Catatan: Folder `Models/` di dalam feature hanya untuk model yang eksklusif milik fitur tersebut. Model yang dipakai lintas fitur harus di `Core/Domain/`.

---

## Navigasi

Navigasi menggunakan `AppRoute` enum di `App/`:

- `AppRoute` adalah enum yang mendefinisikan semua route yang tersedia dalam aplikasi.
- Route baru ditambahkan sebagai case baru di `AppRoute`.
- Factory dipanggil dari view yang menampilkan fitur (biasanya via `.fullScreenCover` atau `NavigationLink`).

Penjelasan lebih lanjut tentang Factory Pattern ada di [08_Design_Patterns.md](./08_Design_Patterns.md).

---

## Referensi

- Fowler, M. (2018). *Refactoring: Improving the Design of Existing Code, 2nd Edition.* Addison-Wesley.
- Apple Inc. *SwiftUI Documentation.* https://developer.apple.com/documentation/swiftui
- Nimje, R. (2024). *The Truth About Clean Architecture in iOS.* https://medium.com/@rahulnimje94/the-truth-about-clean-architecture-in-ios-what-works-in-real-teams-vs-theory
