# Design System

## Overview

CallBite menggunakan design system berbasis token yang konsisten di seluruh aplikasi. Semua nilai visual (warna, spacing, typography, corner radius) didefinisikan sebagai konstanta di `Core/DesignSystem/Tokens/`.

Tujuan dari design system ini: jika designer mengubah warna aksen atau ukuran spacing, kita hanya perlu mengubah satu file token, dan seluruh aplikasi otomatis terupdate.

---

## Tokens

### Spacing (`AppSpacing`)

```swift
enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16    // Default padding
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

Gunakan `AppSpacing` untuk semua padding dan gap. Jangan hardcode angka. Ini mengikuti 8-point grid system yang menjadi standar industri.

### Corner Radius (`AppCornerRadius`)

```swift
enum AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12    // Cards, buttons
    static let lg: CGFloat = 16    // Large containers, modals, bottom sheets
}
```

### Typography (`AppTypography`)

```swift
enum AppTypography {
    static let title = Font.custom("AvenirNext-DemiBold", size: 28)
    static let subtitle = Font.custom("AvenirNext-Regular", size: 18)
    static let body = Font.custom("AvenirNext-Regular", size: 16)
    static let bodyBold = Font.custom("AvenirNext-DemiBold", size: 16)
    static let caption = Font.custom("AvenirNext-Regular", size: 13)
}
```

Catatan: Typography token akan disesuaikan setelah Hi-Fi design dari tim designer tersedia.

### Colors (`AppColor`)

```swift
enum AppColor {
    static let textPrimary = Color(...)
    static let textSecondary = Color(...)
    static let accentPrimary = Color(...)    // Brand color utama
    static let accentDanger = Color(...)     // Errors, destructive actions
    static let borderSubtle = Color(...)

    // Warna khusus nutrisi
    static let calorieColor = Color(...)     // Untuk progress bar kalori
    static let proteinColor = Color(...)     // Untuk progress bar protein
    static let carbsColor = Color(...)       // Untuk progress bar karbohidrat
    static let fatColor = Color(...)         // Untuk progress bar lemak
}
```

**Aturan warna:**
- Gunakan `.primary` dan `.secondary` dari SwiftUI untuk teks di atas material backgrounds.
- Gunakan `AppColor` untuk elemen brand-specific dan indikator nutrisi.
- Jangan hardcode `Color.black` atau `Color.white`, gunakan semantic colors agar Dark Mode otomatis bekerja.

Catatan: Palet warna nutrisi (calorie, protein, carbs, fat) akan didefinisikan setelah visual design tersedia. Gunakan placeholder yang semantik untuk saat ini.

---

## Komponen Reusable

Komponen berikut dapat digunakan di seluruh aplikasi. Definisi detail akan diperbarui seiring pengembangan.

### AppCard

Card dengan border dan background standar. Digunakan untuk menampilkan item makanan, ringkasan nutrisi, dsb.

```swift
AppCard {
    VStack { ... }
}
```

### GlassCard

Card dengan material background. Digunakan di result screens dan dashboard overlay.

```swift
GlassCard {
    VStack { ... }
}
```

### PrimaryButton

Button utama dengan styling konsisten.

```swift
PrimaryButton(title: "Simpan Makanan", action: { ... })
```

### State Views

Views untuk menampilkan state khusus:
- `LoadingStateView(title:subtitle:)` -- Loading indicator
- `ErrorStateView(title:message:primaryActionTitle:onPrimaryAction:)` -- Error state
- `EmptyStateView(title:message:...)` -- Empty content (misalnya belum ada meal hari ini)

---

## iOS 26 dan Liquid Glass

### Yang Otomatis

Komponen SwiftUI standar otomatis mendapat Liquid Glass saat build dengan iOS 26 SDK:
- `NavigationStack` navigation bar
- `TabView` tab bar
- `Sheet` presentation
- `.toolbar { }` items
- Standard `Button`, `Toggle`, `Picker`

### Yang Manual

Untuk custom floating elements, gunakan `.glassEffect()`:

```swift
Button("Ambil Foto") { }
    .padding()
    .glassEffect(.regular.interactive())

// Penting: .glassEffect() harus jadi modifier TERAKHIR
```

### Yang Tidak Boleh

- Jangan gunakan `.glassEffect()` pada List rows atau form content.
- Jangan override `toolbarBackground` -- biarkan system yang menangani.
- Jangan campurkan `.background(.ultraThinMaterial)` dengan `.glassEffect()` -- pilih salah satu.
- Jangan gunakan glass di content layer. Glass hanya untuk navigation/floating layer.
