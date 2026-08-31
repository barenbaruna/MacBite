# Arsitektur Aplikasi

## Ringkasan

CallBite menggunakan arsitektur **MVVM (Model-View-ViewModel) + Feature-Based** dengan SwiftUI sebagai framework UI.

| Item | Value |
|------|-------|
| Architecture Pattern | MVVM (Model-View-ViewModel) |
| Organisasi Kode | Feature-based folders |
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
- Kesimpulan: Tidak cocok untuk proyek dengan 8+ fitur yang saling terhubung seperti CallBite.

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
│   ├── CallBiteApp.swift
│   ├── AppContainer.swift            # Dependency container utama
│   ├── Navigation/
│   │   ├── AppRoute.swift            # Enum semua route navigasi
│   │   └── AppRouter.swift           # Router logic
│   └── Root/
│       ├── RootView.swift
│       └── RootViewModel.swift
│
├── Core/                             # Kode yang dipakai bersama oleh semua fitur
│   ├── DesignSystem/
│   │   ├── Components/               # Komponen UI reusable (AppCard, PrimaryButton, dsb.)
│   │   ├── Modifiers/                # Custom view modifiers
│   │   └── Tokens/                   # Konstanta visual (AppColor, AppSpacing, AppTypography)
│   ├── Error/                        # AppError enum dan error mapping
│   ├── Extensions/                   # Extension Swift/SwiftUI yang dipakai global
│   ├── Logging/                      # Logger utility
│   └── State/                        # Generic state types (loading, error, loaded)
│
├── Features/                         # Semua fitur, masing-masing folder mandiri
│   ├── Dashboard/                    # Goal Based Progress + ringkasan harian
│   │   ├── DashboardFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   │   └── DashboardViewModel.swift
│   │   └── Views/
│   │       ├── DashboardView.swift
│   │       └── Components/           # Sub-views khusus Dashboard (ProgressRing, MacroCard)
│   │
│   ├── FoodScan/                     # Camera capture + AI food detection
│   │   ├── FoodScanFactory.swift
│   │   ├── Models/
│   │   │   └── DetectedFoodItem.swift
│   │   ├── Services/
│   │   │   └── FoodDetectionService.swift
│   │   ├── ViewModels/
│   │   │   └── FoodScanViewModel.swift
│   │   └── Views/
│   │       ├── FoodScanView.swift
│   │       └── Components/
│   │
│   ├── PortionConfirmation/          # Portion & Ingredient Confirmation (bottom sheet)
│   │   ├── PortionConfirmationFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   │
│   ├── NutritionResult/              # Nutrition Calculation + Actionable Insight
│   │   ├── NutritionResultFactory.swift
│   │   ├── Models/
│   │   │   └── NutritionData.swift
│   │   ├── Services/
│   │   │   └── InsightService.swift
│   │   ├── ViewModels/
│   │   └── Views/
│   │
│   ├── ManualInput/                  # Manual food search dan input
│   │   ├── ManualInputFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   │
│   ├── MealHistory/                  # Riwayat makanan harian
│   │   ├── MealHistoryFactory.swift
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   │
│   └── Profile/                      # Profil pengguna dan target nutrisi
│       ├── ProfileFactory.swift
│       ├── Models/
│       ├── ViewModels/
│       └── Views/
│
├── Services/                         # Service yang dipakai lintas fitur
│   ├── NutritionService/             # Facade: USDA + FatSecret API
│   │   ├── NutritionServiceProtocol.swift
│   │   ├── NutritionServiceFacade.swift
│   │   ├── USDAClient.swift
│   │   └── FatSecretClient.swift
│   ├── HealthKit/                    # Integrasi HealthKit (eksplorasi)
│   └── Persistence/                  # Penyimpanan data lokal
│       ├── MealStore.swift
│       └── UserPreferencesStore.swift
│
└── Infrastructure/                   # Aset ML dan konfigurasi external
    └── ML/
        └── FoodClassifier.mlpackage  # Model Core ML (dikelola oleh Fathimah Az Zahra Sanjani)
```

### Penjelasan Setiap Layer

**App/** -- Entry point aplikasi. Berisi konfigurasi awal, dependency container, dan sistem navigasi. Hanya diubah saat menambah route baru atau mengubah cara bootstrapping aplikasi.

**Core/** -- Kode infrastruktur yang tidak terikat dengan fitur spesifik. Design system, error handling, dan utility. Perubahan di sini berdampak ke seluruh aplikasi, jadi perlu hati-hati dan selalu dikomunikasikan.

**Features/** -- Setiap fitur dari PRD menjadi satu folder mandiri. Folder ini berisi semua yang dibutuhkan fitur tersebut: model data, ViewModel, View, dan Service khusus (jika ada). Satu developer bisa mengerjakan satu folder tanpa mengganggu pekerjaan developer lain.

**Services/** -- Service yang dibutuhkan oleh lebih dari satu fitur. Contoh: `NutritionServiceFacade` dipakai oleh FoodScan (untuk mendapatkan data nutrisi setelah deteksi) dan ManualInput (untuk mencari makanan secara manual). Lihat [08_Design_Patterns.md](./08_Design_Patterns.md) untuk penjelasan Facade Pattern.

**Infrastructure/** -- File external yang tidak ditulis manual: model Core ML, konfigurasi build, dsb.

---

## Alur Data

Alur data dalam aplikasi ini bersifat satu arah (unidirectional), mengikuti pola standar MVVM:

```
User Action --> View --> ViewModel --> Service (jika ada) --> ViewModel --> View Update
```

Penjelasan langkah demi langkah (contoh: user memfoto makanan):

1. **User menekan tombol kamera** di `FoodScanView`.
2. **View memanggil method** di `FoodScanViewModel` (misalnya `capturePhoto()`).
3. **ViewModel menjalankan logika**: memanggil `FoodDetectionService` untuk menjalankan inferensi model AI.
4. **Service mengembalikan hasil** (daftar makanan yang terdeteksi) ke ViewModel.
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
├── Models/                        # Struct, enum, data model khusus fitur ini
├── Services/                      # Logika bisnis khusus fitur ini (opsional)
├── ViewModels/
│   └── [NamaFitur]ViewModel.swift
└── Views/
    ├── [NamaFitur]View.swift      # View utama
    └── Components/                # Sub-views kecil yang hanya dipakai di fitur ini
```

---

## Navigasi

Navigasi menggunakan `AppRouter` dengan `NavigationStack`:

- `AppRoute` adalah enum yang mendefinisikan semua route yang tersedia dalam aplikasi.
- Route baru ditambahkan sebagai case baru di `AppRoute`.
- Factory dipanggil dari view yang menampilkan fitur (biasanya via `.fullScreenCover` atau `NavigationLink`).

Penjelasan lebih lanjut tentang Factory Pattern ada di [08_Design_Patterns.md](./08_Design_Patterns.md).

---

## Referensi

- Fowler, M. (2018). *Refactoring: Improving the Design of Existing Code, 2nd Edition.* Addison-Wesley.
- Apple Inc. *SwiftUI Documentation.* https://developer.apple.com/documentation/swiftui
- Nimje, R. (2024). *The Truth About Clean Architecture in iOS.* https://medium.com/@rahulnimje94/the-truth-about-clean-architecture-in-ios-what-works-in-real-teams-vs-theory
