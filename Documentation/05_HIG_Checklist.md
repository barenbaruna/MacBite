# Apple HIG Checklist — iOS 26 & SwiftUI

Checklist ini wajib dipenuhi dan diverifikasi sebelum setiap Pull Request (PR) di-merge ke branch `main` atau `development`. Standar ini berpatokan langsung pada dokumentasi resmi Apple:
- [Apple Human Interface Guidelines (HIG)](https://developer.apple.com/design/human-interface-guidelines/)
- [Adopting Liquid Glass — Technology Overviews](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
- [SwiftUI Documentation (iOS 26+)](https://developer.apple.com/documentation/swiftui)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)

---

## 1. Per-Screen Quality Gate (Pre-Merge Checklist)

Setiap layar (`View`) harus lolos audit interaktif berikut:

```
[ ] Dynamic Type Compliance:
    - Diuji pada ukuran terkecil (xSmall) hingga Accessibility 5 (AX5).
    - Teks tidak terpotong (truncated) dan tidak bertumpuk (overlap).
    - Hirarki informasi tetap terbaca jelas (menggunakan semantic text styles).

[ ] Dark Mode & Appearance:
    - Tampilan diuji dalam Light Mode dan Dark Mode.
    - Menggunakan warna semantik (AppColor / System Colors), bebas dari hardcode RGB/Hex statis.
    - Kontras teks: ≥ 4.5:1 untuk normal text, ≥ 3:1 untuk large text (WCAG AA).

[ ] Accessibility & Assistive Tech:
    - VoiceOver: Semua icon-only button memiliki .accessibilityLabel(...) yang jelas dan berbahasa Indonesia.
    - Touch Targets: Semua elemen interaktif berukuran minimal 44×44pt (gunakan .minimumTouchTarget()).
    - Reduce Transparency: Jika diaktifkan pengguna, UI beralih ke solid fill tanpa kehilangan keterbacaan.
    - Reduce Motion: Animasi transisi yang intens dinonaktifkan atau diganti dengan fade sederhana.

[ ] Liquid Glass & Layering (iOS 26):
    - Elemen .glassEffect() HANYA berada pada Navigation Layer atau Floating Action Layer.
    - Tidak ada "Glass on Glass" (elemen glass menumpuk di atas glass lain).
    - Card dan List Row menggunakan AppColor.cardBackground atau .regularMaterial.
    - Multi-elemen custom glass dibungkus dalam GlassEffectContainer.

[ ] Navigation & Modal Semantics:
    - Sheet/Modal menggunakan Button(role: .close) { dismiss() } dan Button(role: .confirm) { save() }.
    - Toolbar tidak meng-override .toolbarBackground(...) dengan warna solid statis.
    - List/Form Section Header menggunakan Title-Style Capitalization (bukan ALL CAPS).
```

---

## 2. Typography & Glanceability Rules

Nutrisi adalah data yang dipantau sekilas (*glanceable*). Tipografi harus memadukan keterbacaan tinggi dan kejelasan visual.

| Kategori | Yang Wajib Digunakan | Yang Dilarang Keras | Alasan Teknis (Apple HIG) |
|---|---|---|---|
| **System Fonts** | SF Pro (System font bawaan) dengan semantic styles (`.largeTitle`, `.title`, `.headline`, `.body`, `.caption`) | Font custom tanpa skalabilitas (`Font.custom(..., size: 16)`) | SF Pro mendukung *Optical Sizing* (otomatis beralih ke SF Pro Text <20pt atau SF Pro Display ≥20pt) dan baseline matching dengan SF Symbols. |
| **Angka Nutrisi** | SF Pro Rounded (`Font.system(.title, design: .rounded).weight(.bold)`) | Font serif atau font dekoratif yang sulit dibaca sekilas | Desain rounded memberi kesan energetik, ramah, dan menjadi standar aplikasi Health/Fitness Apple. |
| **Dynamic Numbers** | `.monospacedDigit()` atau helper `.metricDigits()` | Font proporsional default pada counter yang berubah | Mencegah angka bergoyang horizontal (*jitter/layout shift*) saat kalori atau makro dihitung bertambah. |
| **Dynamic Type** | `@ScaledMetric` jika membutuhkan ukuran icon atau padding yang ikut membesar dengan font | Hardcode ukuran frame tombol (`frame(height: 50)`) tanpa penyesuaian | Tombol akan terpotong saat pengguna lansia menggunakan ukuran Dynamic Type besar (AX1–AX5). |

---

## 3. Color & Contrast Rules

| Kategori | Yang Wajib Digunakan | Yang Dilarang Keras | Alasan Teknis (Apple HIG) |
|---|---|---|---|
| **Surfaces** | `Color(uiColor: .systemBackground)`, `.secondarySystemBackground`, `AppColor.cardBackground` | `Color.white`, `Color.black`, `Color(hex: "#FFFFFF")` | Warna statis akan membutakan mata pengguna dalam Dark Mode atau tidak terlihat saat tema berubah. |
| **Text Styling** | `.foregroundStyle(.primary)` dan `.foregroundStyle(.secondary)` | `.foregroundColor(.gray)` atau `.foregroundColor(.black)` | `.foregroundStyle` mendukung material vibrancy dan hierarki kontras adaptif otomatis. |
| **Domain Nutrisi** | `AppColor.calorie` (Orange), `AppColor.protein` (Blue), `AppColor.carbs` (Yellow), `AppColor.fat` (Purple) | Warna acak yang berbeda di tiap layar | Konsistensi warna membantu pengguna memahami makronutrisi secara instinktif tanpa membaca teks label berulang kali. |
| **Kontras** | Minimum 4.5:1 untuk teks biasa, 3:1 untuk teks besar | Teks putih di atas warna pastel terang | Menjamin inklusivitas bagi pengguna dengan gangguan penglihatan warna (*color blindness*). |

---

## 4. Navigation, Sheets, & Toolbars (iOS 26)

| Skenario | Standar iOS 26 | Anti-Pattern | Alasan Teknis |
|---|---|---|---|
| **Modal Dismissal** | `Button(role: .close) { dismiss() }` | Custom trailing/leading button dengan string manual `"Tutup"` atau `"X"` | `ButtonRole.close` di iOS 26 otomatis memposisikan tombol secara semantik dan menampilkan icon close native tanpa progress loss. |
| **Modal Confirmation** | `Button(role: .confirm) { save() }` | Tombol simpan teks manual di posisi arbitrary | `ButtonRole.confirm` di iOS 26 otomatis menempatkan aksi konfirmasi di posisi utama toolbar modal. |
| **Pemisah Toolbar** | `ToolbarSpacer(.fixed)` atau `ToolbarSpacer(.flexible)` | Memberikan `.padding()` manual antar tombol toolbar | `ToolbarSpacer` di iOS 26 memecah toolbar menjadi kapsul Liquid Glass mandiri yang terpisah rapi secara visual. |
| **Pencarian** | `.searchable(text: $query)` otomatis di bottom bar iPhone | Membuat search bar kustom melayang di atas konten | Di iOS 26, sistem otomatis menempatkan search bar di bagian bawah layar iPhone agar mudah dijangkau satu tangan. |
| **Search Minimization** | `.searchToolbarBehavior(.minimize)` | Menyembunyikan kolom pencarian di balik navigasi baru | Kolom pencarian mengecil menjadi icon ringkas saat konten di-scroll dan membesar saat disentuh. |
| **TabBar Behavior** | `.tabBarMinimizeBehavior(.onScrollDown)` pada `TabView` | Tab bar statis kaku yang memotong konten vertikal | Tab bar mengecil otomatis saat pengguna scroll ke bawah untuk memaksimalkan ruang baca konten makanan. |

---

## 5. Liquid Glass Guidelines (WWDC25 & HIG)

Prinsip panduan berdasarkan dokumen resmi Apple *Adopting Liquid Glass*:

```
+-------------------------------------------------------------+
| NAVIGATION & FLOATING LAYER (Liquid Glass Diizinkan)        |
| - Navigation Bar & Floating Toolbars                        |
| - Floating Action Buttons (misal: Shutter / Quick Scan FAB) |
| - Floating Overlays (Viewfinder controls)                   |
+-------------------------------------------------------------+
                              |
                              v  (Refraksi & Blur Dinamis)
+-------------------------------------------------------------+
| CONTENT LAYER (DILARANG Menggunakan Liquid Glass)           |
| - List Rows & Forms                                         |
| - Food Summary Cards (Gunakan AppColor.cardBackground)      |
| - Nutrition Badges (Gunakan Solid Fill / Soft Tint)         |
+-------------------------------------------------------------+
```

1. **Layer Separation**:
   - `Navigation & Floating Layer`: Gunakan `.glassEffect(.regular.interactive())` atau `.buttonStyle(.glassProminent)`.
   - `Content Layer`: Gunakan `AppColor.cardBackground` atau `.background(.regularMaterial)`.
2. **Never Glass on Glass**:
   - Jangan pernah meletakkan elemen dengan `.glassEffect()` di atas elemen glass lain. Efek refraksi ganda menurunkan kontras teks dan merusak performa GPU rendering.
3. **No Toolbar Background Overrides**:
   - Dilarang memanggil `.toolbarBackground(Color.orange, for: .navigationBar)`. Di iOS 26, bar harus transparan adaptif agar refraksi material Liquid Glass berfungsi natural mengikuti konten di bawahnya.
4. **Multi-Glass Grouping**:
   - Jika terdapat 2 atau lebih kontrol glass mengambang yang berdampingan, bungkus dalam `GlassEffectContainer { ... }` agar efek specular highlight dan sampling optik menyatu.
5. **Section Header Capitalization**:
   - Gunakan **Title-Style Capitalization** (`Section("Detail Makronutrisi")`). Jangan menggunakan huruf kapital semua (`Section("DETAIL MAKRONUTRISI")`).

---

## 6. Layout, Spacing, & Corners

| Elemen | Token yang Digunakan | Larangan |
|---|---|---|
| **Padding Layar** | `AppSpacing.medium` (16pt) | `padding(15)` atau `padding(20)` acak |
| **Jarak Antar Card** | `AppSpacing.regular` (12pt) atau `AppSpacing.large` (24pt) | Magic numbers |
| **Corner Radius Card** | `AppCornerRadius.card` (20pt) | `cornerRadius(12)` |
| **Corner Radius Button** | `AppCornerRadius.button` (14pt) | Radius tajam / arbitrary |
| **Kurva Sudut** | `RoundedRectangle(cornerRadius: r, style: .continuous)` | Sudut non-continuous tanpa kurva Apple squircle |
| **Keselarasan Inset** | `.corner(.containerConcentric)` untuk tombol di dalam container | Radius anak yang menabrak lengkungan induk |

---

## 7. Controls & User Interactions

1. **Minimum Touch Target**:
   - Semua kontrol sentuh (button, toggle, chip, icon link) wajib memiliki area tap minimal **44×44pt**. Jika icon hanya berukuran 20×20pt, bungkus dengan `.minimumTouchTarget()` atau `.contentShape(Rectangle())`.
2. **Sliders & Pickers**:
   - Gunakan `step:` untuk nilai porsi diskrit (contoh: kelipatan 0.5x).
   - Gunakan `neutralValue:` jika slider memiliki titik nol/keseimbangan (contoh: offset kalori dari target).
3. **Haptic Feedback**:
   - Gunakan `AppHaptics.selectionChanged()` saat memilih porsi atau beralih tab.
   - Gunakan `AppHaptics.success()` saat berhasil menyimpan makanan.
   - Gunakan `AppHaptics.warning()` jika asupan melebihi batas target kalori harian.
   - Jangan memicu haptic secara agresif di setiap frame geseran slider.
4. **Destructive Actions**:
   - Penghapusan log makanan wajib menggunakan konfirmasi dialog:
     ```swift
     .confirmationDialog("Hapus Makanan?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
         Button("Hapus", role: .destructive) { deleteMeal() }
         Button("Batal", role: .cancel) { }
     } message: {
         Text("Data nutrisi makanan ini akan dihapus dari catatan harian kamu.")
     }
     ```

---

## 8. SF Symbols & Visual Transitions

1. **Kesesuaian SF Symbols**:
   - Gunakan simbol resmi Apple dengan konteks yang sesuai (misal: `flame.fill` untuk kalori, `camera.fill` untuk food scan, `chart.pie.fill` untuk dashboard ringkasan).
2. **Hierarchical & Monochrome Rendering**:
   - Gunakan `.symbolRenderingMode(.hierarchical)` untuk simbol di layar konten agar memiliki kedalaman optik.
   - Di toolbar iOS 26, biarkan rendering monochrome sistem bekerja secara default.
3. **Symbol Effects & Transitions**:
   - Gunakan `.symbolEffect(.bounce, value: trigger)` untuk umpan balik instan saat data bertambah.
   - Gunakan `.transition(.symbolEffect(.drawOn))` di iOS 26 untuk transisi kemunculan checkmark atau status sukses.

