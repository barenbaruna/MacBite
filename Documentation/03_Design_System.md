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
    static let small: CGFloat = 16
    static let medium: CGFloat = 20    // Cards, buttons
    static let large: CGFloat = 24     // Large containers, modals
    static let xlarge: CGFloat = 28    // Bottom sheets
    static let button: CGFloat = 20
}
```

### Typography (`AppTypography`)

Menggunakan SF Pro (System Font) yang mendukung Dynamic Type secara otomatis.

```swift
enum AppTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.regular)
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body.weight(.regular)
    static let subheadline = Font.subheadline.weight(.regular)
    static let footnote = Font.footnote.weight(.regular)
    static let caption = Font.caption.weight(.regular)
    static let caption2 = Font.caption2.weight(.regular)
    static let button = Font.body.weight(.semibold)
}
```

### Colors (`AppColor`)

Palet brand dari designer + semantic system colors untuk adaptasi Dark/Light Mode.

```swift
enum AppColor {
    // Brand Primary (Orange)
    static let primary100 = Color(hex: 0xFFDCCE)
    static let primary200 = Color(hex: 0xFFBBA3)
    static let primary300 = Color(hex: 0xFF9878)
    static let primary400 = Color(hex: 0xED7445)
    static let primary500 = Color(hex: 0xD85F34)

    // Brand Secondary (Dark)
    static let secondary900 = Color(hex: 0x19191B)
    static let secondary950 = Color(hex: 0x0C0C0E)

    // Neutral / Grayscale
    static let neutral100 = Color(hex: 0xF7F7F7)
    static let neutral200 = Color(hex: 0xE8E8E8)
    // ... neutral300-800

    // Semantic (Adaptive Light/Dark)
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    // Domain Nutrisi
    static let calorie = Color.orange
    static let protein = Color.blue
    static let carbs = Color.yellow
    static let fat = Color.purple
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
