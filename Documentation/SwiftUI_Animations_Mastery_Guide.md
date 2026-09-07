# SwiftUI Advanced Animations Mastery Guide
*Spesifikasi Arsitektur, Matematika, dan Implementasi Produksi Animasi SwiftUI Modern (iOS 17 & iOS 18+)*
*Disusun Berdasarkan Analisis Komprehensif Repository `SwiftUI-Animations-master` & Standar Apple WWDC 2023/2024*

---

## 📑 Daftar Isi
1. [Mental Model & Render Engine SwiftUI Modern](#1-mental-model--render-engine-swiftui-modern)
2. [Penyelesaian 8 Blindspot Teknis Kritis](#2-penyelesaian-8-blindspot-teknis-kritis)
3. [Katalog 12 Pola Arsitektur Animasi Produksi](#3-katalog-12-pola-arsitektur-animasi-produksi)
   - [Pola 1: 3D Spatial Flip, Hinge Edges & Perspective Matrix](#pola-1-3d-spatial-flip-hinge-edges--perspective-matrix)
   - [Pola 2: Isometric 3D Volume & Directional Lighting](#pola-2-isometric-3d-volume--directional-lighting)
   - [Pola 3: Liquid Wave Physics & Sine Trigonometry](#pola-3-liquid-wave-physics--sine-trigonometry)
   - [Pola 4: High-Order Vector Morphing via AnimatableData](#pola-4-high-order-vector-morphing-via-animatabledata)
   - [Pola 5: Particle Burst Systems & Staggered Physics](#pola-5-particle-burst-systems--staggered-physics)
   - [Pola 6: Polar Trigonometry & Gesture Arc Sliders](#pola-6-polar-trigonometry--gesture-arc-sliders)
   - [Pola 7: Soft-Brush Gesture Masking & Dynamic Retirement](#pola-7-soft-brush-gesture-masking--dynamic-retirement)
   - [Pola 8: Character-Level Magnification Dock Physics](#pola-8-character-level-magnification-dock-physics)
   - [Pola 9: Interactive Depth Layering & Stack Shuffling](#pola-9-interactive-depth-layering--stack-shuffling)
   - [Pola 10: State-Driven Button Morphing & Slot-Machine Panels](#pola-10-state-driven-button-morphing--slot-machine-panels)
   - [Pola 11: Compound Multi-Axis State Machines](#pola-11-compound-multi-axis-state-machines)
   - [Pola 12: Metal Shaders dalam SwiftUI (iOS 17+)](#pola-12-metal-shaders-dalam-swiftui-ios-17)
4. [Modernisasi WWDC 2023/2024: PhaseAnimator, KeyframeAnimator & TimelineView](#4-modernisasi-wwdc-20232024-phaseanimator-keyframeanimator--timelineview)
5. [Bank Komponen Reusable Siap Pakai](#5-bank-komponen-reusable-siap-pakai)
6. [15 Guiding Questions (GQ) & Checklist Verifikasi Produksi](#6-15-guiding-questions-gq--checklist-verifikasi-produksi)
7. [Daftar Aturan Anti-Pattern Produksi](#7-daftar-aturan-anti-pattern-produksi)

---

## 1. Filosofi & Mental Model Animasi SwiftUI Modern

SwiftUI adalah sistem UI **deklaratif**. Kita tidak pernah menggerakkan piksel secara imperatif; kita mendefinisikan hubungan matematis antara **State** dan **Representasi Visual**:

```
           ┌───────────────────────┐
           │   State Berubah       │
           │   (@State, @Binding)  │
           └───────────┬───────────┘
                       │
                       ▼
           ┌───────────────────────┐
           │ Interpolasi Animasi   │  ◄── (Spring Physics: Response, Damping)
           │ (V-Sync 60Hz / 120Hz) │
           └───────────┬───────────┘
                       │
                       ▼
           ┌───────────────────────┐
           │ Core Animation / GPU  │  ◄── (Transform, Opacity, Render Tree)
           │ Tanpa Structural Relayout
           └───────────────────────┘
```

### Prinsip Utama Render Engine SwiftUI:
1. **Transform vs Structural Modifiers**:
   - *Structural Modifiers* (`padding`, `frame`, `Spacer`, `if-else` views): Memaksa SwiftUI menghitung ulang geometri hierarki view (*layout pass*). Sangat mahal jika dianimasikan berulang.
   - *Transform Modifiers* (`scaleEffect`, `offset`, `rotationEffect`, `rotation3DEffect`, `opacity`): Diproses langsung oleh GPU (*Core Animation layer*) tanpa memicu layout ulang pada elemen tetangga. **Selalu prioritaskan transform modifier untuk animasi berkecepatan tinggi!**
2. **Spring Physics Formula**:
   - Apple SwiftUI meninggalkan kurva bezier konvensional (`easeInOut`) dan beralih ke fisika pegas harmonik teredam (*damped harmonic oscillator*):
     $$F = -kx - c\dot{x}$$
   - Parameter modern (`Animation.spring(response:dampingFraction:blendDuration)`):
     - `response` ($T_0$): Waktu alami getaran tanpa redaman ($T_0 = 2\pi\sqrt{m/k}$). Semakin kecil, semakin cepat gerakan dimulai.
     - `dampingFraction` ($\zeta$): Rasio redaman.
       - $\zeta < 1.0$: *Under-damped* (ada efek pantulan/overshoot alami).
       - $\zeta = 1.0$: *Critically damped* (berhenti secepat mungkin tanpa overshoot).
       - $\zeta > 1.0$: *Over-damped* (lambat dan berat tanpa osilasi).

---

## 2. Eksplorasi 8 Blindspots Kritis & Cara Mengatasinya

Sebelum membuat animasi tingkat tinggi, seorang agen atau developer wajib memahami blindspot teknis berikut agar tidak mengalami bug yang membingungkan:

### ⚠️ Blindspot 1: Mengapa Custom Shape Tidak Teranimasi Meskipun Ada di dalam `withAnimation`?
- **Penyebab**: SwiftUI hanya dapat menginterpolasi tipe data yang mengadopsi protokol `VectorArithmetic`. Logika di dalam `func path(in rect: CGRect) -> Path` dieksekusi setiap frame, tetapi jika Shape tidak mendeklarasikan properti mana yang menjadi `animatableData`, SwiftUI hanya akan melihat nilai akhir dan langsung melompat tanpa interpolasi.
- **Solusi**:
  - Untuk 1 properti: `var animatableData: CGFloat { get { ... } set { ... } }`
  - Untuk 2 properti: `var animatableData: AnimatablePair<CGFloat, CGFloat>`
  - Untuk >2 properti: Nesting rekursif `AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>`.

### ⚠️ Blindspot 2: Mengapa Teks & Ikon Terbalik (Mirrored) Saat Rotasi 3D $180^\circ$?
- **Penyebab**: Pada ruang 3D, memutar objek $180^\circ$ pada sumbu Y berarti kita melihat bagian belakang objek (lateral inversion). SwiftUI tidak memiliki flag `backface-visibility: hidden` bawaan seperti CSS 3D Transforms.
- **Solusi**:
  Sisi belakang harus diputarbalik secara internal sebesar $180^\circ$ sebelum dimasukkan ke dalam container flip, atau menggunakan threshold pergantian sudut di $90^\circ$:
  ```swift
  CardBackView()
      .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
      .opacity(isFlipped ? 1 : 0)
  ```

### ⚠️ Blindspot 3: Kerusakan Frame & Memory Leak Akibat `Timer.scheduledTimer`
- **Penyebab**: Kode legacy menggunakan `Timer.scheduledTimer(withTimeInterval: 0.01)`. Timer di iOS berjalan pada RunLoop mode default yang **berhenti saat pengguna melakukan scroll**, berjalan pada interval CPU yang tidak sinkron dengan refresh rate layar ProMotion 120Hz, dan menahan *strong reference* ke closures sehingga memicu memory leak.
- **Solusi Modern**: Gantikan seluruh timer animasi kontinu dengan `TimelineView(.animation)` + `Canvas` atau WWDC23 `PhaseAnimator`. Ini menjamin sinkronisasi frame sempurna dengan GPU clock (V-Sync).

### ⚠️ Blindspot 4: Diskontinuitas Sudut Polar pada $0^\circ / 360^\circ$ (`atan2`)
- **Penyebab**: Fungsi `atan2(deltaY, deltaX)` mengembalikan nilai dalam rentang radian $[-\pi, \pi]$ (derajat $[-180^\circ, 180^\circ]$). Saat jari pengguna bergerak melewati kuadran II ke kuadran III, nilai meloncat seketika sebesar $360^\circ$, menyebabkan slider/knob tersentak atau terhenti.
- **Solusi**: Wajib menormalisasi sudut negatif ke domain positif $[0, 360^\circ]$:
  ```swift
  var angle = atan2(dy, dx) * 180 / .pi
  if angle < 0 { angle += 360 }
  ```

### ⚠️ Blindspot 5: Truncation Shader Metal di Tepi Tampilan (`maxSampleOffset`)
- **Penyebab**: Pada iOS 17 Metal Shaders (`.distortionEffect` atau `.layerEffect`), Metal hanya mengalokasikan area render sesuai ukuran bounding box view. Jika shader menarik atau mendistorsi piksel keluar dari batas view (seperti ripple atau chromatic aberration), efek akan terpotong kaku di tepi kotak.
- **Solusi**: Wajib menyertakan parameter `maxSampleOffset: CGSize(width: N, height: N)` pada pemanggilan modifier di SwiftUI!

### ⚠️ Blindspot 6: Perlombaan State (*Race Condition*) pada Rantai Callback Timer
- **Penyebab**: Modul interaksi bertahap (seperti Submit Button atau Cart) yang menjadwalkan 3 hingga 5 timer bersarang (`Timer.scheduledTimer`) rentan rusak jika pengguna mengetuk tombol berkali-kali sebelum siklus selesai.
- **Solusi**: Gunakan State Machine eksplisit (`enum AnimationState`) dengan proteksi `guard state == .idle else { return }`, serta manfaatkan `Task` async/await atau `PhaseAnimator`.

### ⚠️ Blindspot 7: Perbedaan Mendasar `.clipShape()` vs `.mask()`
- **Penyebab**: Menggunakan `.clipShape()` untuk efek fade brush/liquid tidak akan menghasilkan gradasi lembut (feathered edges). `.clipShape()` adalah operasi biner (titik di dalam path = terlihat, di luar path = terpotong).
- **Solusi**: Gunakan `.mask()`. `.mask()` membaca nilai *alpha channel* dan *luminance*. Gradien radial dengan alpha $1.0 \to 0.0$ akan menghasilkan tepian transparan yang lembut.

### ⚠️ Blindspot 8: Layout Shifting Akibat Animasi Frame Struktural
- **Penyebab**: Menganimasikan `.frame(width: isExpanded ? 300 : 50)` menyebabkan seluruh view induk menghitung ulang posisi elemen di sekitarnya, menghasilkan stutter pada perangkat yang lebih lambat.
- **Solusi**: Jika memungkinkan, pertahankan ukuran frame tetap dan animasikan `.scaleEffect()` atau gunakan kontainer bertopeng (`.mask()`) dengan panel yang meluncur (*slot-machine translation*).

---

## 3. Katalog 12 Pola Arsitektur Animasi Mendalam

### Pola 1: 3D Spatial Flip, Hinge Edges & Perspective Matrix
*Studi Kasus: Modul `Bank Card` (`CardView.swift`) & `3dLoader` (`RotatingLoaderView.swift`)*

#### Anatomi Mekanisme
Animasi 3D di SwiftUI dimodelkan melalui matriks proyeksi 4x4, di mana parameter `perspective` mewakili elemen $m34$ pada matriks transformasi ($m34 = -1/d$):

```
┌                  ┐   ┌   ┐
│  1   0   0   0   │   │ x │
│  0   1   0   0   │   │ y │
│  0   0   1  -1/d │ * │ z │
│  0   0   0   1   │   │ 1 │
└                  ┘   └   ┘
```

#### Rumus & Hubungan Perspektif:
- `perspective: 0` $\to$ Ortografis murni (tampak datar tanpa penyusutan jarak).
- `perspective: 0.1` $\to$ Sangat dramatis (efek lensa wide-angle/fish-eye).
- `perspective: 0.3` $\to$ Nilai ideal Apple untuk kartu fisik dan panel kartu UI.

#### Hinge Edge Pivot (Rotasi Engsel Tepi):
Untuk membuat efek buku atau kubus berputar di mana poros bukan di tengah, melainkan di tepi (`.leading` atau `.trailing`):
```swift
enum CubeRotation: CaseIterable {
    case swingInFromLeft, swingOutToRight
    
    var values: (degree: Double, offset: CGFloat, anchor: UnitPoint, yAxis: CGFloat) {
        switch self {
        case .swingInFromLeft:
            return (degree: 0, offset: 0, anchor: .leading, yAxis: 1)
        case .swingOutToRight:
            return (degree: 90, offset: -260, anchor: .trailing, yAxis: -1)
        }
    }
}
```

---

### Pola 2: Isometric 3D Volume & Fake Directional Lighting
*Studi Kasus: Modul `3D Graph` (`ThreeDGraphView.swift`)*

#### Anatomi Mekanisme
SwiftUI dapat menghasilkan objek volumetrik isometrik 3D murni tanpa memerlukan SceneKit atau RealityKit. Kuncinya adalah menyusun 3 bidang vektor (*Top, Left, Right Faces*) dan menyimulasikan pencahayaan terarah (*directional light*) dengan mengatur tingkat kecerahan (`.brightness`):

```
         /\
        /  \     ◄── TopFace (.brightness(0) - Cahaya Utama)
       /\  /\
      /  \/  \
     |   ||   |
     | L || R |  ◄── LeftFace (.brightness(-0.05) - Sisi Bayangan)
     |   ||   |  ◄── RightFace (.brightness(0.1) - Sisi Pantulan)
      \  /\  /
       \/  \/
```

#### Geometri Vektor Isometrik:
```swift
struct IsometricTopFace: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: 0, y: rect.width / 4)
        path.move(to: start)
        path.addLine(to: CGPoint(x: rect.width - (rect.width / 2.1), y: rect.width / 25))
        path.addLine(to: CGPoint(x: rect.width, y: rect.width / 4))
        path.addLine(to: CGPoint(x: rect.width / 2.1, y: rect.width / 2.1))
        path.closeSubpath()
        return path
    }
}
```

#### Trik Penataan Layer:
1. `HStack(spacing: -unit / 2)`: Spasi negatif menumpuk batang secara diagonal.
2. `.zIndex(CGFloat(bars.count - index))`: Menjamin batang di depan selalu digambar di atas batang di belakangnya.
3. `.offset(y: unit / 3.5 * -CGFloat(index))`: Menggeser bertingkat ke atas-kanan.

---

### Pola 3: Liquid Wave Physics & Sine Trigonometry
*Studi Kasus: Modul `Circular Download` (`DownloadWaveFill.swift`) & `PillLoader` (`WaveFill.swift`)*

#### Formula Matematika Gelombang Air:
$$y(x, t) = \sin\left(\left(\frac{x}{\text{height}} + \phi(t)\right) \cdot \lambda \cdot \pi\right) \cdot A + y_{\text{waterLevel}}$$
Di mana:
- $\phi(t)$ (`curve`): Fase perpindahan horizontal terhadap waktu.
- $\lambda$ (`curveLength`): Frekuensi spasial gelombang.
- $A$ (`curveHeight`): Amplitudo puncak riak dalam poin.
- $y_{\text{waterLevel}}$: Ketinggian permukaan air ($0 \to \text{height}$).

#### Kedalaman Visual Berlapis (Dual Wave Layering):
Untuk menghasilkan efek fluida realistis, gabungkan dua gelombang dengan fase dan kecepatan berbeda:
1. **Lapisan Depan**: `opacity: 0.985`, kecepatan fase $0.25\times$, tinggi riak $10\text{pt}$.
2. **Lapisan Belakang**: `opacity: 0.900`, kecepatan fase $5.00\times$, tinggi riak $12\text{pt}$, di-offset sedikit horizontal.

---

### Pola 4: High-Order Vector Morphing via AnimatableData
*Studi Kasus: Modul `Circular Download` (`DownloadArrowShape.swift`)*

#### Rekursi `AnimatablePair` untuk N Properti
Jika sebuah Shape membutuhkan interpolasi lebih dari dua parameter independen (misalnya: panjang batang, lebar sayap, dan lengkungan kurva):

```swift
struct MultiParamMorphShape: Shape {
    var length: CGFloat
    var width: CGFloat
    var curve: CGFloat

    // Mengemas 3 parameter ke dalam hirarki AnimatablePair
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(length, AnimatablePair(width, curve))
        }
        set {
            length = newValue.first
            width = newValue.second.first
            curve = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Menggambar path menggunakan length, width, curve yang telah diinterpolasi mulus
        return path
    }
}
```

---

### Pola 5: Particle Burst Systems & Staggered Physics
*Studi Kasus: Modul `PillLoader` (`PillsDropView.swift`) & `Wifi` (`CircleEmitter.swift`)*

#### Formula Staggered Cascade Delay:
$$t_{\text{delay}}(i) = t_{\text{base}} + i \cdot \Delta t$$
- Menghindari partikel meledak secara serentak (terlihat kaku dan artifisial).
- Setiap partikel menerima vektor acak $(\Delta x, \Delta y)$, tetapi delay bertahap membuat ledakan terlihat seperti semburan fluida alami.

```swift
ForEach(0..<particleCount, id: \.self) { index in
    Circle()
        .offset(isBurst ? targetOffset(for: index) : .zero)
        .scaleEffect(isBurst ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.65)
            .delay(Double(index) * 0.015),
            value: isBurst
        )
}
```

---

### Pola 6: Polar Trigonometry & Gesture Arc Sliders
*Studi Kasus: Modul `Light Bulb` (`CurvedSlider.swift`) & `TextSwirl` (`TextSwirlView.swift`)*

#### Eliminasi Diskontinuitas Sudut
1. Hitung translasi sentuhan relatif terhadap titik pusat busur:
   $$\Delta x = P_{\text{touch}}.x - C.x, \quad \Delta y = P_{\text{touch}}.y - C.y$$
2. Hitung sudut radian lalu ubah ke derajat:
   $$\theta = \text{atan2}(\Delta y, \Delta x) \times \frac{180}{\pi}$$
3. Normalisasi agar selalu positif di $[0, 360^\circ]$:
   $$\theta_{\text{norm}} = \theta < 0 \ ? \ (\theta + 360) : \theta$$
4. Proyeksikan kembali ke titik koordinat ujung knob:
   $$x_{\text{knob}} = C.x + R \cdot \cos\left(\theta_{\text{norm}} \times \frac{\pi}{180}\right)$$
   $$y_{\text{knob}} = C.y + R \cdot \sin\left(\theta_{\text{norm}} \times \frac{\pi}{180}\right)$$

---

### Pola 7: Soft-Brush Gesture Masking & Dynamic Retirement
*Studi Kasus: Modul `Scratch to Reveal` (`RevealView.swift`)*

#### Arsitektur Canvas Masking
Menggabungkan `DragGesture(minimumDistance: 0)` dengan array titik riwayat sentuhan `[FadePoint]`. Titik-titik ini digambar ke dalam `.mask(Canvas { ... })` menggunakan `.radialGradient` (pusat putih opasitas 1.0 $\to$ tepi transparan 0.0).

#### Dynamic Point Retirement (Auto-Fade Loop):
Setiap titik touch memiliki `timestamp: Date`. Antarmuka menghapus titik-titik yang umurnya melebihi ambang batas (`fadeDuration = 0.25s`):
```swift
// Modern TimelineView Loop (menggantikan Timer berulang yang rawan bocor)
TimelineView(.animation) { timeline in
    let now = timeline.date
    Canvas { context, size in
        let validPoints = points.filter { now.timeIntervalSince($0.timestamp) < fadeDuration }
        for point in validPoints {
            // Gambar radial gradient brush
        }
    }
}
```

---

### Pola 8: Character-Level Magnification Dock Physics
*Studi Kasus: Modul `Text Bouncing` (`TextBouncingView.swift`)*

#### Tracking Koordinat Huruf via `PreferenceKey`
SwiftUI `Text` tidak mengekspos frame setiap karakter secara langsung. Solusinya:
1. Pisahkan kata menjadi array karakter individual dalam `HStack(spacing: 0)`.
2. Setiap karakter membaca frame-nya sendiri menggunakan `GeometryReader` di dalam `.background()` dan mengirimkannya ke parent melalui custom `PreferenceKey`:
   ```swift
   struct CharacterBoundsKey: PreferenceKey {
       static var defaultValue: [Int: CGRect] = [:]
       static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
           value.merge(nextValue()) { $1 }
       }
   }
   ```
3. Parent menangkap `DragGesture` pada named coordinate space `"textArea"`. Ketika $X_{\text{drag}}$ berada di dalam rentang frame karakter $i$, maka karakter $i$ aktif ($1.4\times$ scale, $-20\text{pt}$ offset), dan karakter $i \pm 1$ ikut terangkat proporsional ($1.15\times$, $-8\text{pt}$).

---

### Pola 9: Interactive Depth Layering & Stack Shuffling
*Studi Kasus: Modul `Cards Shuffle` (`CardsShuffleView.swift`) & `Cards Swap` (`CardSwapView.swift`)*

#### Ilusi Kedalaman 2.5D Matematis:
Untuk tumpukan kartu tanpa representasi 3D penuh:
$$\text{scale}(d) = 1.0 - d \cdot 0.05, \quad \text{offsetY}(d) = d \cdot -16\text{pt}, \quad \text{zIndex}(d) = -d$$
Di mana $d$ adalah indeks kedalaman kartu ($0 =$ kartu paling depan).

#### Threshold Gesture Dismissal:
- Jika jarak seret ke atas melampaui batas ambang ($\text{translation.y} < -60\text{pt}$), kartu teratas dipindahkan ke posisi paling belakang:
  ```swift
  withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
      let frontCard = cards.removeLast()
      cards.insert(frontCard, at: 0)
      dragOffset = .zero
  }
  ```
- Jika kurang dari ambang batas, kartu memantul kembali (*snapback*) ke posisi semula dengan pegas alami.

---

### Pola 10: State-Driven Button Morphing & Slot-Machine Panels
*Studi Kasus: Modul `DownloadButton` (`DownloadButton.swift`) & `SubmitView` (`SubmitView.swift`)*

#### Teknik Morphing Bentuk Kontainer:
1. Lebar tombol menyusut: `width: isAnimating ? 92 : 300`.
2. Sudut melengkung bertambah: `cornerRadius: isAnimating ? 46 : 20`.
   *(Ketika `width == height` dan `cornerRadius == width / 2`, persegi panjang otomatis bermutasi menjadi lingkaran sempurna!)*
3. **Slot-Machine Panel Sliding**: Tiga label teks diletakkan vertikal di dalam kontainer bertopeng (`.mask(RoundedRectangle(...))`). Mengubah offset `y` membuat teks meluncur masuk dan keluar tanpa layout jump.
4. Orbiting Particle Loader (`RotatingCircle`): Lingkaran kecil berotasi pada lintasan radius luar ($360^\circ \times N$) sebelum checkmark (`Tick`) digambar menggunakan `.trim(from: 0, to: 1)`.

---

### Pola 11: Compound Multi-Axis State Machines
*Studi Kasus: Modul `BookLoader` (`BookLoaderView.swift`)*

#### Penanganan State Jamak via Tuple
Ketika animasi melibatkan 3–6 elemen yang bergerak bersamaan pada sumbu berbeda (misalnya lembar kiri, punggung tengah, dan lembar kanan buku), jangan gunakan `@State` terpisah untuk setiap properti. Definisikan **Compound Enum**:

```swift
enum BookFlipPhase {
    case leftClosed, spineShift, rightClosed
    
    var configuration: (leftAngle: Angle, spineOffset: CGFloat, rightAngle: Angle) {
        switch self {
        case .leftClosed:
            return (.degrees(0), 0, .degrees(-180))
        case .spineShift:
            return (.degrees(90), -15, .degrees(-90))
        case .rightClosed:
            return (.degrees(180), 0, .degrees(0))
        }
    }
}
```

---

### Pola 12: Modern Metal Shaders dalam SwiftUI (iOS 17+)
*Studi Kasus: Seluruh Modul Shaders (`RippleEffect`, `GlitchEffect`, `ChromaticAberration`, `BurnEffect`)*

#### 3 Jenis Shader Modifier SwiftUI:
1. **`.distortionEffect`** (Distorsi Geometri):
   - Signature Metal: `[[ stitchable ]] float2 funcName(float2 position, ...)`
   - Mentransformasi koordinat sampling. Cocok untuk ripple, gelombang cairan, efek kanta pembesar, gelombang suara.
2. **`.layerEffect`** (Konvolusi Multi-Piksel):
   - Signature Metal: `[[ stitchable ]] half4 funcName(float2 position, SwiftUI::Layer layer, ...)`
   - Dapat membaca piksel tetangga melalui `layer.sample(position + offset)`. Wajib menyertakan `maxSampleOffset`. Cocok untuk chromatic aberration, blur kustom, glitch baris, efek terbakar/ember reveal.
3. **`.colorEffect`** (Transformasi Warna Piksel):
   - Signature Metal: `[[ stitchable ]] half4 funcName(float2 position, half4 color, ...)`
   - Mentransformasi warna setiap piksel secara independen. Cocok untuk halftone, duotone, color grading, thermal filter.

---

## 4. Modernisasi WWDC 2023/2024: Dari Timer ke PhaseAnimator & KeyframeAnimator

Repository lawas mengandalkan rantai `Timer.scheduledTimer` yang rapuh. Standar Apple terkini menggunakan dua API deklaratif utama:

### 1. `PhaseAnimator` (Transisi Antar State Diskret)
Digunakan ketika animasi bergerak melalui tahapan-tahapan state yang jelas (`idle` $\to$ `shrink` $\to$ `spin` $\to$ `expand` $\to$ `success`):

```swift
enum ActionPhase: CaseIterable {
    case idle, pressed, loading, completed
}

struct ModernMorphButton: View {
    @State private var trigger = false

    var body: some View {
        Button("Submit") { trigger.toggle() }
            .phaseAnimator(ActionPhase.allCases, trigger: trigger) { content, phase in
                content
                    .scaleEffect(phase == .pressed ? 0.9 : 1.0)
                    .frame(width: phase == .loading ? 60 : 200)
                    .opacity(phase == .completed ? 0.8 : 1.0)
            } animation: { phase in
                switch phase {
                case .idle: .default
                case .pressed: .snappy(duration: 0.15)
                case .loading: .smooth(duration: 0.4)
                case .completed: .bouncy(duration: 0.5)
                }
            }
    }
}
```

### 2. `KeyframeAnimator` (Kurva Multi-Parameter Bebas)
Digunakan ketika berbagai parameter (posisi, skala, rotasi, opasitas) harus diinterpolasi sepanjang sumbu waktu yang berbeda menggunakan kurva Bezier atau Spring keyframes:

```swift
struct ParticleBounceAnimation: View {
    @State private var trigger = false

    var body: some View {
        Circle()
            .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
                content
                    .scaleEffect(value.scale)
                    .offset(y: value.verticalOffset)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.4, duration: 0.2, spring: .snappy)
                    CubicKeyframe(1.0, duration: 0.3)
                }
                KeyframeTrack(\.verticalOffset) {
                    CubicKeyframe(-60, duration: 0.25)
                    SpringKeyframe(0, duration: 0.35, spring: .bouncy)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0.8, duration: 0.2)
                    LinearKeyframe(1.0, duration: 0.4)
                }
            }
    }
}
```

---

## 5. Koleksi Komponen Reusable Siap Pakai (Production-Ready)

Berikut adalah komponen mandiri (*self-contained*) yang dirancang khusus agar dapat langsung disalin ke codebase project iOS mana pun:

### Reusable Component 1: `Interactive3DCardFlip`
```swift
import SwiftUI

/// Kontainer kartu 3D universal dengan mitigasi anti-cermin dan perspektif realistis.
public struct Interactive3DCardFlip<Front: View, Back: View>: View {
    @Binding public var isFlipped: Bool
    public var perspective: CGFloat
    public var animation: Animation
    @ViewBuilder public var front: () -> Front
    @ViewBuilder public var back: () -> Back

    public init(
        isFlipped: Binding<Bool>,
        perspective: CGFloat = 0.3,
        animation: Animation = .smooth(duration: 0.65),
        @ViewBuilder front: @escaping () -> Front,
        @ViewBuilder back: @escaping () -> Back
    ) {
        self._isFlipped = isFlipped
        self.perspective = perspective
        self.animation = animation
        self.front = front
        self.back = back
    }

    public var body: some View {
        ZStack {
            back()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)

            front()
                .opacity(isFlipped ? 0 : 1)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: perspective
        )
        .animation(animation, value: isFlipped)
    }
}
```

### Reusable Component 2: `HighPerformanceLiquidFill`
```swift
import SwiftUI

/// Indikator pengisi fluida matematis dengan sinkronisasi ProMotion 120Hz (TimelineView + Canvas).
public struct HighPerformanceLiquidFill: View {
    public var progress: CGFloat // 0.0 ... 1.0
    public var tintColor: Color
    public var waveFrequency: CGFloat
    public var waveAmplitude: CGFloat

    public init(
        progress: CGFloat,
        tintColor: Color = .blue,
        waveFrequency: CGFloat = 2.5,
        waveAmplitude: CGFloat = 8.0
    ) {
        self.progress = max(0, min(1, progress))
        self.tintColor = tintColor
        self.waveFrequency = waveFrequency
        self.waveAmplitude = waveAmplitude
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let phase = CGFloat(time * 3.0)
                let waterHeight = size.height * (1.0 - progress)

                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: waterHeight))

                for x in stride(from: 0, to: size.width, by: 2) {
                    let relativeX = x / size.width
                    let y = sin((relativeX * waveFrequency * .pi) + phase) * waveAmplitude + waterHeight
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.closeSubpath()

                context.fill(path, with: .color(tintColor))
            }
        }
    }
}
```

### Reusable Component 3: `MorphingStateButton`
```swift
import SwiftUI

public enum ButtonActionState: Equatable {
    case idle, inProgress, success
}

/// Tombol morphing dari pill menjadi spinner melingkar dan akhirnya checkmark.
public struct MorphingStateButton: View {
    public var title: String
    @Binding public var state: ButtonActionState
    public var action: () -> Void

    public init(
        title: String,
        state: Binding<ButtonActionState>,
        action: @escaping () -> Void
    ) {
        self.title = title
        self._state = state
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard state == .idle else { return }
            action()
        }) {
            ZStack {
                Capsule()
                    .fill(state == .success ? Color.green : Color.blue)
                    .frame(
                        width: state == .inProgress ? 54 : (state == .success ? 54 : 220),
                        height: 54
                    )

                if state == .idle {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if state == .inProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .transition(.scale.combined(with: .opacity))
                } else if state == .success {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.35), value: state)
    }
}
```

---

## 6. 15 Guiding Questions (GQ) & Tolok Ukur Pemahaman 100%

Gunakan instrumen pertanyaan reflektif berikut untuk memvalidasi pemahaman diri sendiri atau agent lain:

1. **GQ 1**: Apa perbedaan teknis paling mendasar antara `.rotationEffect` dan `.rotation3DEffect`?
   - *Jawaban*: `rotationEffect` hanya memutar bidang koordinat 2D pada sumbu $Z$. `rotation3DEffect` mengaplikasikan matriks proyeksi affine 3D dengan perspektif $m34$, memungkinkan kedalaman nyata pada sumbu $X$ atau $Y$.
2. **GQ 2**: Mengapa kita membutuhkan `AnimatablePair` pada custom Shape?
   - *Jawaban*: SwiftUI `Path` digambar secara prosedural di setiap frame. Tanpa `animatableData` yang mematuhi `VectorArithmetic`, SwiftUI tidak tahu variabel numerik mana di dalam Shape yang harus diinterpolasi antar frame.
3. **GQ 3**: Mengapa penggunaan `Timer.scheduledTimer` sangat tidak disarankan untuk animasi modern?
   - *Jawaban*: Timer tidak terikat pada V-Sync layar, berjalan di runloop default yang tertahan saat scrolling, memicu frame drops pada layar 120Hz ProMotion, dan rentan menimbulkan memory leak jika view di-dismiss.
4. **GQ 4**: Bagaimana formula normalisasi sudut saat memetakan `DragGesture` pada dial lingkaran menggunakan `atan2`?
   - *Jawaban*: `var deg = atan2(dy, dx) * 180 / .pi; if deg < 0 { deg += 360 }`. Ini mencegah loncatan dari $-180^\circ$ ke $+180^\circ$.
5. **GQ 5**: Apa perbedaan kegunaan antara `PhaseAnimator` dan `KeyframeAnimator`?
   - *Jawaban*: `PhaseAnimator` digunakan untuk transisi diskret antara tahapan state (misal `idle -> loading -> success`). `KeyframeAnimator` digunakan untuk interpolasi nilai-nilai numerik kontinu multi-jalur sepanjang rentang waktu yang telah ditentukan.
6. **GQ 6**: Mengapa `.mask()` dapat menghasilkan soft feathered edges sedangkan `.clipShape()` tidak?
   - *Jawaban*: `.clipShape()` hanya mengevaluasi inklusi geometri (ada atau tidak di dalam kurva). `.mask()` membaca channel alpha dan luminance piksel, sehingga gradien transparan dapat menembus gambar di baliknya.
7. **GQ 7**: Kapan wajib menambahkan `maxSampleOffset` pada shader Metal SwiftUI?
   - *Jawaban*: Ketika shader mengambil sampel piksel di luar koordinat asli (`layer.sample(position + offset)`), seperti pada efek blur, chromatic aberration, atau gelombang ripple. Tanpa itu, piksel di tepi frame akan terpotong kaku.
8. **GQ 8**: Mengapa pada 3D flip kartu, sisi belakang harus di-rotate $180^\circ$ terlebih dahulu?
   - *Jawaban*: Karena memutar kartu $180^\circ$ pada sumbu vertikal membalik orientasi horizontal visual. Tanpa pre-rotasi $180^\circ$, teks dan ikon pada kartu belakang akan terbaca terbalik (seperti melihat tulisan di cermin).
9. **GQ 9**: Bagaimana cara membuat efek pencahayaan semu (*fake directional lighting*) pada bentuk isometrik?
   - *Jawaban*: Dengan mewarnai ketiga sisi kubus dengan warna dasar yang sama, tetapi menambahkan `.brightness(0)` untuk sisi atas, `.brightness(-0.05)` untuk sisi kiri (bayangan), dan `.brightness(0.1)` untuk sisi kanan (pantulan cahaya).
10. **GQ 10**: Mengapa transform modifier (`scaleEffect`, `offset`) lebih disukai daripada structural modifier (`frame`, `padding`) saat animasi berulang?
    - *Jawaban*: Transform modifier diproses langsung oleh GPU (Core Animation Render Layer) tanpa memicu kalkulasi ulang tata letak (*layout pass*), menjaga FPS tetap stabil di 60/120 FPS.
11. **GQ 11**: Bagaimana cara mengemas 4 variabel numerik ke dalam `AnimatableData`?
    - *Jawaban*: Gunakan nesting ganda: `AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>`.
12. **GQ 12**: Mengapa array kartu pada efek tumpukan shuffle harus memiliki `.zIndex` eksplisit?
    - *Jawaban*: Karena saat elemen kartu dipindahkan dari indeks terakhir ke indeks 0 di dalam array data, urutan rendering Z-Stack akan berubah seketika. `.zIndex(Double(index))` menjaga layer tetap tersusun rapi dari belakang ke depan selama animasi pegas berlangsung.
13. **GQ 13**: Bagaimana cara mengukur posisi sentuhan terhadap karakter teks individual dalam SwiftUI?
    - *Jawaban*: Menggunakan `GeometryReader` di latar belakang setiap karakter yang mempublikasikan frame lokalnya ke parent via `PreferenceKey`, lalu parent mencocokkan koordinat sentuhan `DragGesture`.
14. **GQ 14**: Apa fungsi formula Gaussian envelope $e^{-(d - w)^2 \cdot k}$ pada shader ripple Metal?
    - *Jawaban*: Menghasilkan cincin gelombang terpusat yang memudar tajam ke arah dalam dan luar dari garis depan gelombang (*wavefront*), menciptakan batas riak air yang realistis.
15. **GQ 15**: Bagaimana cara mencegah glitch visual saat state animasi diinterupsi oleh tap berulang pengguna?
    - *Jawaban*: Terapkan State Machine dengan flag penjaga (`guard state == .idle else { return }`) dan gunakan spring animation dengan parameter `blendDuration` agar kecepatan pergerakan awal dapat menyatu mulus dengan lintasan baru tanpa sentakan.

---

## 7. Daftar Aturan Anti-Pattern ("Never Do" List)

Simpan aturan ini sebagai guardrail permanen untuk setiap agen:

- ❌ **DILARANG** menggunakan `Timer.scheduledTimer` untuk loop animasi render. Gunakan `TimelineView` atau `PhaseAnimator`.
- ❌ **DILARANG** menganimasikan dimensi `frame(width:height:)` dari elemen bertetangga di dalam `HStack`/`VStack` kompleks jika dapat dicapai dengan `.scaleEffect()` atau `.mask()`.
- ❌ **DILARANG** melakukan rotasi 3D $180^\circ$ tanpa counter-rotasi pada sisi belakang (akan menghasilkan cermin).
- ❌ **DILARANG** mengasumsikan custom Shape akan bergerak di `withAnimation` tanpa mengimplementasikan protokol `animatableData`.
- ❌ **DILARANG** memanggil shader Metal `.layerEffect` tanpa menyertakan `maxSampleOffset` jika shader melakukan displacement piksel.
- ❌ **DILARANG** mencampur structural layout (`Spacer()`, conditional view insertion `if condition`) di tengah siklus animasi pegas berkecepatan tinggi tanpa deklarasi `.matchedGeometryEffect()` atau transition eksplisit.
