# Design System

## Overview

MacBite menggunakan design system berbasis token yang konsisten di seluruh aplikasi. Semua nilai visual (warna, spacing, typography, corner radius) didefinisikan sebagai konstanta di `Core/DesignSystem/Tokens/`.

Tujuan dari design system ini: jika designer mengubah warna aksen atau ukuran spacing, kita hanya perlu mengubah satu file token, dan seluruh aplikasi otomatis terupdate.

---

## Tokens

### Spacing (`AppSpacing`)

```swift
import CoreGraphics

/// Standar skala spacing mengikuti Apple 8-point grid system.
/// Menggunakan CoreGraphics (bukan SwiftUI) agar framework-agnostic.
enum AppSpacing {
    /// 4pt - Micro spacing (padding badge, jarak icon-text kecil)
    static let extraSmall: CGFloat = 4
    
    /// 8pt - Compact spacing (jarak antar elemen yang saling terkait rapat)
    static let small: CGFloat = 8
    
    /// 12pt - Regular spacing (jarak antar field formulir atau baris list)
    static let regular: CGFloat = 12
    
    /// 16pt - Default screen margin & padding card standar
    static let medium: CGFloat = 16
    
    /// 24pt - Section separation (jarak pemisah antar section konten)
    static let large: CGFloat = 24
    
    /// 32pt - Hero spacing (jarak judul utama ke konten / container besar)
    static let extraLarge: CGFloat = 32
}
```

Gunakan `AppSpacing` untuk semua padding dan gap. Jangan pernah melakukan hardcode angka (misal `padding(16)`). Mengikuti 8-point grid system Apple HIG memastikan layout proporsional di seluruh resolusi layar Retina (@2x dan @3x) tanpa sub-pixel rendering.

### Corner Radius (`AppCornerRadius`)

```swift
import CoreGraphics

/// Skala corner radius mengikuti Apple HIG (Human Interface Guidelines).
/// Menggunakan kombinasi Scale Primitives dan Semantic Role Aliases.
enum AppCornerRadius {
    // MARK: - Scale Primitives (Kata penuh, menghindari singkatan ambigu)
    static let extraSmall: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 28
    static let full: CGFloat = 999
    
    // MARK: - Semantic Role Aliases (Clarity at Point of Use)
    /// Digunakan untuk badge nutrisi, tag kategori (6pt)
    static let badge: CGFloat = extraSmall
    
    /// Digunakan untuk interactive button, text field, chip (14pt)
    static let button: CGFloat = medium
    
    /// Digunakan untuk food item card, dashboard summary card (20pt)
    static let card: CGFloat = large
    
    /// Digunakan untuk bottom sheet, modal presentation (28pt)
    static let sheet: CGFloat = extraLarge
    
    /// Digunakan untuk pill-shaped button, circular icon (999pt)
    static let pill: CGFloat = full
}
```

**Aturan kurva sudut:**
Gunakan `RoundedRectangle(cornerRadius: radius, style: .continuous)`. Gaya `.continuous` (superellipse/squircle) adalah ciri khas hardware dan software Apple yang menghasilkan kurva sudut halus tanpa patahan optik.

### Typography (`AppTypography`)

> [!IMPORTANT]
> **Prinsip Apple HIG Typography & Dynamic Type:**
> 1. **Gunakan System Fonts (San Francisco / SF Pro):** SF Pro dirancang khusus oleh Apple dengan *Optical Sizing* (otomatis beralih antara *SF Pro Text* untuk <20pt dan *SF Pro Display* untuk ≥20pt), serta sejajar secara sempurna (*baseline & weight matching*) dengan **SF Symbols**.
> 2. **Dukungan Penuh Dynamic Type:** Jangan gunakan font fixed point-size tanpa referensi (`Font.custom(_, size:)`). Gunakan semantic text styles (`.largeTitle`, `.title`, `.headline`, `.body`, `.caption`) agar ukuran teks otomatis beradaptasi saat pengguna mengubah preferensi ukuran teks sistem (dari standard hingga Accessibility Sizes AX1–AX5).
> 3. **SF Pro Rounded untuk Nutrisi & Metrik:** Sesuai standar aplikasi Health & Fitness Apple (Apple Fitness, HealthKit), angka nutrisi menggunakan varian `.rounded` untuk memberikan kesan bersahabat, energetik, dan mudah dibaca sekilas (*glanceable*).
> 4. **Numeric Monospace (`.monospacedDigit()`):** Wajib digunakan pada angka kalori dan makro yang dinamis agar angka tidak bergetar (*jitter*) saat dianimasikan atau nilainya berubah.

```swift
import SwiftUI

/// Tipografi MacBite yang sepenuhnya patuh pada Dynamic Type dan Apple HIG.
enum AppTypography {
    // MARK: - Hierarki Standar (Dynamic Type Adaptive)
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body.weight(.regular)
    static let bodyBold = Font.body.weight(.semibold)
    static let subheadline = Font.subheadline.weight(.regular)
    static let footnote = Font.footnote.weight(.regular)
    static let caption = Font.caption.weight(.regular)
    static let caption2 = Font.caption2.weight(.medium)
    static let button = Font.body.weight(.semibold)

    // MARK: - Khusus Angka Nutrisi (SF Pro Rounded)
    /// Digunakan untuk counter kalori besar di Dashboard dan Review Sheet
    static let calorieMetric = Font.system(.largeTitle, design: .rounded).weight(.bold)
    
    /// Digunakan untuk gramatur makro (contoh: "145g", "32g")
    static let macroMetric = Font.system(.headline, design: .rounded).weight(.bold)
    
    /// Digunakan untuk label ringkas pada badge makronutrien
    static let badgeLabel = Font.system(.caption, design: .rounded).weight(.semibold)
}

extension View {
    /// Menerapkan numeric monospace agar angka kalori/makro yang berubah tidak jitter.
    func metricDigits() -> some View {
        self.monospacedDigit()
    }
}
```

### Colors (`AppColor`)

```swift
import SwiftUI

/// Palet warna semantik adaptif (Light/Dark Mode) dan palet domain nutrisi MacBite.
enum AppColor {
    // MARK: - Surfaces & Backgrounds (Semantic)
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)

    // MARK: - Separator & Borders
    static let borderSubtle = Color(uiColor: .separator).opacity(0.4)
    static let borderProminent = Color(uiColor: .separator)

    // MARK: - Brand & Accents
    static let accentPrimary = Color.accentColor
    static let accentDestructive = Color.red
    static let accentSuccess = Color.green
    static let accentWarning = Color.orange

    // MARK: - Palet Domain Nutrisi (Design System Official Accents)
    /// Indikator energi dan kalori (Orange #D85F34)
    static let calorie = orange500
    
    /// Indikator pembentukan otot dan protein (LossWeight Accent #02FBF4)
    static let protein = lossWeight
    
    /// Indikator sumber tenaga karbohidrat (MainWeight Accent #65FE4E)
    static let carbs = mainWeight
    
    /// Indikator lemak sehat (GainWeight Accent #FF6B35)
    static let fat = gainWeight

    // MARK: - Soft Tint Backgrounds (Untuk Badge & Progress Bar Track)
    static let calorieSoft = calorie.opacity(0.15)
    static let proteinSoft = protein.opacity(0.15)
    static let carbsSoft = carbs.opacity(0.15)
    static let fatSoft = fat.opacity(0.15)
}
```

**Aturan warna:**
- Gunakan warna semantik sistem (`Color(uiColor: .systemBackground)`, dsb.) agar otomatis beradaptasi dengan **Dark Mode** dan **High Contrast Mode**.
- Gunakan `AppColor` untuk elemen domain nutrisi dan brand.
- Dilarang hardcode nilai RGB statis atau `Color.black`/`Color.white` tanpa semantik adaptif.
- Pastikan kontras teks terhadap background minimal **4.5:1** (WCAG AA).

### Animation (`AppAnimation`)

```swift
import SwiftUI

/// Kurva animasi standar MacBite yang selaras dengan fluid interaction physics Apple HIG.
enum AppAnimation {
    /// Spring responsif untuk interaksi sentuh cepat (tap button, toggle chip)
    static let quick = Animation.spring(response: 0.28, dampingFraction: 0.72)
    
    /// Spring halus untuk perubahan layout, expand card, dan transisi modal sheet
    static let smooth = Animation.spring(response: 0.38, dampingFraction: 0.82)
    
    /// Spring terukur untuk pengisian ring chart dan animasi angka metrik nutrisi
    static let metricFill = Animation.spring(response: 0.55, dampingFraction: 0.88)
}
```

### Haptics (`AppHaptics`)

```swift
import UIKit

/// Umpan balik getaran fisik (Taptic Engine) yang proporsional sesuai Apple HIG.
enum AppHaptics {
    /// Dipicu saat user menggeser slider porsi atau berganti tab
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Dipicu saat user menekan tombol CTA utama / shutter scan makanan
    static func primaryAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Dipicu saat makanan berhasil dianalisis atau disimpan
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Dipicu jika kalori melebihi target harian
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
```

---

## Komponen Reusable

Semua komponen reusable diletakkan di `Core/DesignSystem/Components/` dan `Core/DesignSystem/Modifiers/`.

### AppCard (`Core/DesignSystem/Components/Cards/AppCard.swift`)

Kontainer visual untuk *Content Layer* (list row, ringkasan nutrisi, card makanan). Sesuai aturan HIG Liquid Glass, card konten menggunakan `AppColor.cardBackground` adaptif dengan kurva sudut `.continuous` dan border halus, **bukan** material `.glassEffect()`.

```swift
AppCard {
    VStack(alignment: .leading, spacing: AppSpacing.small) {
        Text("Makan Siang")
            .font(AppTypography.headline)
        Text("750 kkal • 45g Protein")
            .font(AppTypography.subheadline)
            .foregroundStyle(.secondary)
    }
}
```

### MacroBadge (`Core/DesignSystem/Components/Nutrition/MacroBadge.swift`)

Badge informatif untuk menampilkan kalori atau gramatur makronutrisi (Protein, Karbohidrat, Lemak) dengan soft background tint dan font rounded yang mudah dibaca sekilas (*glanceable*).

```swift
HStack(spacing: AppSpacing.small) {
    MacroBadge(label: "Protein", value: "32g", color: AppColor.protein, softColor: AppColor.proteinSoft)
    MacroBadge(label: "Karbo", value: "45g", color: AppColor.carbs, softColor: AppColor.carbsSoft)
    MacroBadge(label: "Lemak", value: "14g", color: AppColor.fat, softColor: AppColor.fatSoft)
}
```

### PrimaryButton (`Core/DesignSystem/Components/Buttons/PrimaryButton.swift`)

Tombol Call-to-Action utama yang mematuhi standar Apple HIG: touch target terjamin, support Dynamic Type, dan haptic feedback saat ditekan.

```swift
PrimaryButton(title: "Konfirmasi & Simpan") {
    viewModel.saveMeal()
}
```

### MinimumTouchTarget Modifier (`Core/DesignSystem/Modifiers/MinimumTouchTarget.swift`)

Modifier untuk menjamin semua elemen interaktif memenuhi batas minimal Apple HIG **44×44pt**:

```swift
Button {
    dismiss()
} label: {
    Image(systemName: "xmark")
}
.minimumTouchTarget() // Memperluas frame interaktif ke minimum 44x44pt tanpa merusak layout visual
```

### State Views

Views standar untuk kondisi transisi dan error:
- `LoadingStateView(title:subtitle:)` — Loading indicator dengan pesan ramah.
- `ErrorStateView(title:message:primaryActionTitle:onPrimaryAction:)` — Penanganan kegagalan analisis/jaringan dengan opsi coba lagi.
- `EmptyStateView(title:message:)` — Tampilan informatif saat belum ada makanan tercatat hari ini (menggunakan `ContentUnavailableView` native).

---

## iOS 26 dan Liquid Glass

### Yang Otomatis

Komponen SwiftUI standar otomatis mendapat Liquid Glass saat build dengan iOS 26 SDK:
- `NavigationStack` navigation bar
- `TabView` tab bar
- `Sheet` presentation
- `.toolbar { }` items
- Standard `Button`, `Toggle`, `Picker`
- Inset corner curvature pada partial-height `Sheet`
- Bottom-aligned search field pada iPhone saat menggunakan `.searchable`

### Yang Manual

Untuk custom floating elements (seperti tombol kamera melayang atau tag analisis), gunakan `.glassEffect()`:

```swift
Button {
    // Action
} label: {
    Image(systemName: "camera.fill")
}
.padding()
.glassEffect(.regular.interactive())

// Penting: .glassEffect() harus menjadi modifier TERAKHIR
```

Jika menggabungkan beberapa elemen custom glass yang berdekatan, wajib dibungkus dalam `GlassEffectContainer` agar sampling optik tidak rusak:

```swift
GlassEffectContainer {
    HStack(spacing: AppSpacing.medium) {
        Button { } label: { Image(systemName: "bolt.fill") }.glassEffect()
        Button { } label: { Image(systemName: "camera.fill") }.glassEffect(.regular.interactive())
    }
}
```

### Aturan Emas Liquid Glass (Adopting Liquid Glass HIG)

1. **Hanya di Navigation & Floating Layer**: Jangan pernah menggunakan `.glassEffect()` pada elemen di *Content Layer* (seperti card makanan, list rows, atau form textfield). Gunakan `AppColor.cardBackground` atau `.regularMaterial`.
2. **Never Glass on Glass**: Jangan pernah menumpuk elemen Liquid Glass di atas permukaan Liquid Glass lain. Di atas permukaan glass, gunakan fills solid berwarna dengan `.tint(...)` atau *vibrant overlays*.
3. **Dilarang Override `toolbarBackground`**: Jangan gunakan `.toolbarBackground(...)` dengan warna statis, karena akan merusak kemampuan refraksi cahaya dan *scroll edge blur effect* sistem.
4. **Title-Style Capitalization pada List/Form Header**: Di iOS 26, `Section(header:)` tidak lagi dipaksa ALL CAPS oleh sistem. Tulis header menggunakan huruf kapital hanya di awal kata (contoh: `Section("Ringkasan Nutrisi Harian")`).
5. **Dukungan Native Modal**: Manfaatkan `Button(role: .close) { dismiss() }` dan `Button(role: .confirm) { save() }` di dalam toolbar sheet untuk mendapatkan penempatan posisi dan icon native secara otomatis.
