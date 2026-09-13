# SwiftUI & iOS 26 Quick Reference

Referensi cepat API dan pattern yang digunakan di project ini. Untuk detail lengkap, lihat dokumentasi Apple:

- **HIG**: https://developer.apple.com/design/human-interface-guidelines/
- **SwiftUI**: https://developer.apple.com/documentation/swiftui
- **WWDC25 — Liquid Glass**: https://developer.apple.com/videos/play/wwdc2025/219/
- **WWDC25 — New SwiftUI**: https://developer.apple.com/videos/play/wwdc2025/256/
- **WWDC25 — Build with New Design**: https://developer.apple.com/videos/play/wwdc2025/323/
- **SF Symbols**: https://developer.apple.com/sf-symbols/

---

## Navigation & Toolbars (iOS 26 Style)

Di iOS 26, seluruh navigation dan toolbar container otomatis mengadopsi material **Liquid Glass**. Elemen toolbar melayang di atas konten dalam kapsul adaptif yang secara otomatis memisahkan diri dari tombol navigasi sistem (seperti back button).

```swift
NavigationStack {
    ContentView()
        .navigationTitle("MacBite")
        .toolbarTitleDisplayMode(.inline)    // Opsi: .inline, .inlineLarge, atau default large
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button { /* Scan Makanan */ } label: {
                    Image(systemName: "camera.fill")
                }
                Button { /* Tambah Manual */ } label: {
                    Image(systemName: "plus")
                }
            }
            
            // 🌟 Baru di iOS 26: Memisahkan kapsul Liquid Glass secara visual
            ToolbarSpacer(.fixed)
            
            ToolbarItem(placement: .primaryAction) {
                Button { /* Pengaturan */ } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
}
```

### Fitur Baru Toolbar di iOS 26 (WWDC25 Session 256 & 323):
- **`ToolbarSpacer(.fixed)` & `ToolbarSpacer(.flexible)`**: Digunakan untuk memecah toolbar items menjadi beberapa kapsul Liquid Glass terpisah atau memberi jarak fleksibel (misal di bottom bar).
- **`.sharedBackgroundVisibility(.hidden)`**: Digunakan untuk melepas kapsul background glass pada item tertentu (contohnya avatar user).
- **`.badge(_:)` pada ToolbarItem**: Menampilkan indikator angka/badge langsung pada tombol toolbar.
- **Monochrome Rendering Default**: Icon di toolbar sekarang menggunakan palet monokrom untuk menjaga fokus pada konten. Gunakan `.tint(...)` hanya untuk aksi yang butuh penekanan semantik (CTA).

## Toolbar Placements

| Placement | Posisi / Semantik | Penggunaan |
|-----------|-------------------|------------|
| `.cancellationAction` | Kiri atas di modal (iOS) | Tombol Batal / Tutup |
| `.confirmationAction` | Kanan atas di modal (iOS) | Tombol Simpan / Selesai |
| `.primaryAction` | Trailing action slot | Aksi utama di toolbar |
| `.secondaryAction` | Overflow menu / secondary | Aksi pendukung |
| `.topBarLeading` | Posisi eksplisit kiri | Custom leading item |
| `.topBarTrailing` | Posisi eksplisit kanan | Custom trailing item |
| `.bottomBar` | Floating / bottom toolbar | Tool actions di bawah |
| `.principal` | Tengah toolbar | Custom title / segmented control |

## Modal/Sheet Pattern (iOS 26 Style)

Di iOS 26+, Apple memperluas `ButtonRole` dengan menambahkan `.close` dan `.confirm`. Tombol dengan role ini dapat dideklarasikan langsung di dalam `.toolbar`, dan sistem secara otomatis menentukan posisi semantik serta menampilkan icon native yang sesuai (icon close "X" untuk `.close`, icon confirm untuk `.confirm`):

```swift
.sheet(isPresented: $showForm) {
    NavigationStack {
        FormView()
            .navigationTitle("Konfirmasi Porsi")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
                Button(role: .confirm) {
                    save()
                }
            }
            .interactiveDismissDisabled(hasChanges)
    }
}
```

> **Dokumentasi Resmi Apple (`SwiftUI.ButtonRole` di iOS 26+):**
> - **`ButtonRole.close` ([Documentation](https://developer.apple.com/documentation/swiftui/buttonrole/close))**: Menutup operasi yang sedang berlangsung. Berbeda dari `.cancel`, aksi `.close` tidak membuang progres user. Sistem otomatis menampilkan icon close di toolbar.
> - **`ButtonRole.confirm` ([Documentation](https://developer.apple.com/documentation/swiftui/buttonrole/confirm))**: Mengonfirmasi operasi (misalnya menyimpan meal / konfirmasi porsi). Sistem otomatis menampilkannya sebagai tombol konfirmasi di toolbar.
> - **`ButtonRole.cancel`**: Mengindikasikan operasi dibatalkan secara eksplisit.
> - **`ButtonRole.destructive`**: Mengindikasikan operasi destruktif (hapus data).

## Liquid Glass — Kapan Pakai

| Skenario | Pendekatan |
|----------|-----------|
| NavigationBar, TabBar, Toolbar | **Otomatis** — jangan style manual |
| Floating action button | `.buttonStyle(.glassProminent)` |
| Custom floating element | `.glassEffect(.regular.interactive())` — **modifier terakhir** |
| Card background | `.regularMaterial` — BUKAN `.glassEffect()` |
| Multiple glass elements | Wrap dalam `GlassEffectContainer { }` |

**Yang TIDAK boleh:**
- `.glassEffect()` pada List rows atau form content
- `.background(.ultraThinMaterial).glassEffect()` (double material)
- Override `toolbarBackground` di iOS 26
- Glass di content layer (hanya untuk navigation/floating layer)

## Scroll APIs

```swift
ScrollView {
    content
}
.scrollEdgeEffectStyle(.soft, for: .top)      // Smooth edge fade
.contentMargins(.bottom, 30, for: .scrollContent)
.scrollDismissesKeyboard(.immediately)
```

## TabView (iOS 26)

```swift
TabView {
    Tab("Dashboard", systemImage: "chart.pie.fill") { DashboardView() }
    Tab("Scan", systemImage: "camera.fill") { FoodScanView() }
    Tab("Riwayat", systemImage: "clock.fill") { MealHistoryView() }
    Tab(role: .search) { ManualSearchView() } // Dedicated search tab
}
.tabViewStyle(.sidebarAdaptable)              // Tab otomatis menjadi Sidebar di iPad/Mac
.tabBarMinimizeBehavior(.onScrollDown)        // Tab bar mengecil saat scroll ke bawah
```

## Search (iOS 26 Style)

1. **Bottom-Aligned Search di iPhone (Otomatis)**:
   Pada iOS 26, saat kamu memasang `.searchable(text: $query)` pada `NavigationStack` atau `NavigationSplitView`, sistem iPhone secara otomatis memindahkan kolom pencarian ke **bagian bawah layar** (ergonomis untuk satu tangan).
2. **Minimized Search Behavior**:
   ```swift
   .searchable(text: $query, prompt: "Cari makanan...")
   .searchToolbarBehavior(.minimize) // Mengecil menjadi tombol icon, membesar saat di-tap
   ```

## Controls Baru (iOS 26)

1. **Button Styles Liquid Glass**:
   - `.buttonStyle(.glass)` — Tombol standar dengan material Liquid Glass.
   - `.buttonStyle(.glassProminent)` — Tombol aksi utama floating dengan aksen liquid glass.
   - `.controlSize(.extraLarge)` — Tombol ukuran besar untuk aksi paling utama (Call to Action).
   - Tombol ber-border secara default berbentuk **Capsule** di iOS 26.
2. **Slider dengan Tick Marks & Neutral Value**:
   ```swift
   // Slider porsi dengan tick mark otomatis
   Slider(value: $portionMultiplier, in: 0.5...3.0, step: 0.5)
   
   // Slider dengan neutral value (titik awal pengisian track)
   Slider(value: $calorieOffset, in: -500...500, neutralValue: 0)
   ```
3. **Corner Concentricity**:
   Agar radius sudut tombol sejajar secara konsentris dengan lengkungan layar atau sheet container:
   ```swift
   Rectangle()
       .corner(.containerConcentric)
   ```

## Typography

| Style | Size | Weight | Gunakan untuk |
|-------|------|--------|---------------|
| `.largeTitle` | 34pt | Regular | Screen title |
| `.title` | 28pt | Regular | Section title |
| `.title3` | 20pt | Semibold | Prominent label |
| `.headline` | 17pt | Semibold | Row primary |
| `.body` | 17pt | Regular | Content text |
| `.subheadline` | 15pt | Regular | Secondary label |
| `.footnote` | 13pt | Regular | Small info |
| `.caption` | 12pt | Regular | Metadata |

```swift
// Font width (baru iOS 26)
Text("TITLE").fontWidth(.expanded)      // Lebih lebar, monumental
Text("label").fontWidth(.condensed)     // Lebih sempit, compact
```

## Colors

```swift
// Teks
.foregroundStyle(.primary)               // Teks utama
.foregroundStyle(.secondary)             // Teks pendukung

// Backgrounds
Color(.systemBackground)                 // Base
Color(.systemGroupedBackground)          // List/grouped

// Interactive
.tint(.accentColor)                      // System tint

// JANGAN gunakan:
.foregroundColor(.black)                 // ❌ Tidak adaptif
Color(hex: "...")                        // ❌ Hardcode
```

## SF Symbols & Effects

```swift
// Rendering modes
Image(systemName: "sparkles")
    .symbolRenderingMode(.hierarchical)          // Depth
    .symbolEffect(.bounce, value: trigger)       // Animate on trigger
    .contentTransition(.symbolEffect(.replace))  // Magic replace

// Draw Transition Effects (iOS 26)
Image(systemName: "checkmark.circle.fill")
    .transition(.symbolEffect(.drawOn))          // Draw on appearance
    .transition(.symbolEffect(.drawOn.byLayer))  // Draw layer-by-layer
```

## State Management

Project ini menggunakan **ObservableObject + @Published** (bukan @Observable):

```swift
// ViewModel
@MainActor
final class MyViewModel: ObservableObject {
    @Published private(set) var items: [Item] = []
}

// View (inject dari factory)
struct MyView: View {
    @ObservedObject private var viewModel: MyViewModel
    
    init(viewModel: MyViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
}
```

## Modifier Order (Penting!)

```swift
Text("Hello")
    .font(.headline)              // 1. Content
    .foregroundStyle(.primary)
    .padding()                    // 2. Layout
    .frame(maxWidth: .infinity)
    .background(...)              // 3. Background
    .shadow(radius: 4)            // 4. Effects
    .onTapGesture { }             // 5. Gestures
    .onAppear { }                 // 6. Lifecycle
    .glassEffect()                // 7. ⚠️ SELALU TERAKHIR (jika dipakai)
```

## Empty States

```swift
ContentUnavailableView(
    "Belum Ada Data",
    systemImage: "tray",
    description: Text("Mulai scan untuk melihat hasil.")
)
```

## Accessibility Minimum

```swift
// Touch target: 44×44pt minimum
// Dynamic Type: gunakan semantic font styles
// VoiceOver: label semua elemen interaktif
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorit")
```

## Performance

```swift
// Lazy loading untuk list panjang
ScrollView {
    LazyVStack { ForEach(items) { ... } }
}

// Cancel tasks saat view hilang
.onDisappear { task?.cancel() }

// Weak self di closures
Task { [weak self] in
    guard let self else { return }
    await self.fetchData()
}
```

## Referensi Apple

| Topik | URL |
|-------|-----|
| HIG Home | https://developer.apple.com/design/human-interface-guidelines/ |
| Color | https://developer.apple.com/design/human-interface-guidelines/color |
| Typography | https://developer.apple.com/design/human-interface-guidelines/typography |
| Materials | https://developer.apple.com/design/human-interface-guidelines/materials |
| Navigation | https://developer.apple.com/design/human-interface-guidelines/navigation |
| Accessibility | https://developer.apple.com/design/human-interface-guidelines/accessibility |
| SwiftUI Docs | https://developer.apple.com/documentation/swiftui |
| SF Symbols | https://developer.apple.com/sf-symbols/ |
| Swift API Guidelines | https://www.swift.org/documentation/api-design-guidelines/ |
