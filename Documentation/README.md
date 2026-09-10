# Dokumentasi Teknis -- CallBite

Dokumentasi ini adalah panduan utama bagi tim pengembang (Baren Baruna Harahap, Joshua Valentine Manik, Fathimah Az Zahra Sanjani) untuk memahami bagaimana proyek ini dibangun, mengapa keputusan teknis tertentu diambil, dan bagaimana kita berkolaborasi secara efektif.

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand."
> -- Martin Fowler, Refactoring: Improving the Design of Existing Code

---

## Filosofi Tim

Proyek ini bukan sekadar membuat aplikasi yang berjalan. Proyek ini adalah portofolio profesional, dan setiap baris kode yang kita tulis harus bisa dipertanggungjawabkan. Kita sepakat pada prinsip berikut:

1. **Setiap keputusan harus punya alasan.** Jika tidak bisa menjelaskan kenapa memilih suatu pendekatan, maka pendekatan itu akan ditolak saat code review.
2. **Sistem yang baik itu sederhana untuk dipelajari, mudah di-debug, fleksibel terhadap perubahan, dan perilakunya bisa diprediksi.** Kita tidak mengejar kompleksitas, kita mengejar kejelasan.
3. **Kode ditulis untuk dibaca manusia, bukan hanya untuk dijalankan mesin.**

---

## Tim dan Pembagian Tanggung Jawab

| Nama | Peran | Area Tanggung Jawab |
|---|---|---|
| **Baren Baruna Harahap (Author)** | Tech / iOS Developer | Arsitektur aplikasi, implementasi UI/UX dengan SwiftUI, alur kamera, integrasi sistem |
| **Joshua Valentine Manik** | Tech / iOS Developer | Logika kalkulasi nutrisi, manajemen data lokal, integrasi API nutrisi (USDA/FatSecret), pengujian |
| **Fathimah Az Zahra Sanjani** | Machine Learning Engineer | Eksperimen model klasifikasi makanan, prompt engineering dengan Foundation Models, optimasi inferensi, integrasi Core ML |

---

## Daftar Dokumen

Setiap dokumen membahas satu topik spesifik. Baca secara berurutan jika ini pertama kalinya kamu membuka proyek ini.

### Produk

| No | Dokumen | Isi |
|----|---------|-----|
| 00 | [PRD](./00_PRD.md) | Product Requirements Document: fitur, user flow, timeline, dan tech stack |

### Fondasi Arsitektur dan Kode

| No | Dokumen | Isi |
|----|---------|-----|
| 01 | [Architecture](./01_Architecture.md) | Mengapa MVVM + Feature-Based, struktur folder, alur data |
| 02 | [Coding Standards](./02_Coding_Standards.md) | Konvensi penamaan, formatting, pengorganisasian kode, token principles, dan Clean Code |
| 03 | [Design System](./03_Design_System.md) | Token visual (spacing, corner radius, color, typography, animation, haptics), komponen reusable, dan aturan Liquid Glass iOS 26 |

### Design Pattern dan Strategi Teknis

| No | Dokumen | Isi |
|----|---------|-----|
| 08 | [Design Patterns](./08_Design_Patterns.md) | Pattern yang dipilih (Factory, DI, Observer, Facade) dan alasan di baliknya |
| 09 | [Dependency Injection](./09_Dependency_Injection.md) | Strategi injeksi dependensi tanpa library pihak ketiga |
| 10 | [Reactive Programming](./10_Reactive_Programming.md) | Kapan pakai Combine, kapan pakai async/await, dan mengapa |
| 11 | [Testing Strategy](./11_Testing_Strategy.md) | Pendekatan TDD, fokus unit test ViewModel, format Given-When-Then |

### Panduan Operasional

| No | Dokumen | Isi |
|----|---------|-----|
| 04 | [New Feature Guide](./04_New_Feature_Guide.md) | Langkah-langkah membuat fitur baru dengan template dan checklist |
| 05 | [HIG Checklist](./05_HIG_Checklist.md) | Checklist resmi Apple HIG & iOS 26 (Dynamic Type, Liquid Glass, ButtonRole close/confirm, touch target 44×44pt) |
| 06 | [Project Setup](./06_Project_Setup.md) | Setup environment, build, konfigurasi proyek |
| 07 | [SwiftUI & iOS 26 Reference](./07_SwiftUI_iOS26_Reference.md) | Quick reference API & pattern SwiftUI di iOS 26 (Liquid Glass, ButtonRole, ToolbarSpacer, Draw transitions) |
| 12 | [SwiftLint Configuration](./12_SwiftLint_Configuration.md) | Konfigurasi SwiftLint, penjelasan setiap rule, dan panduan instalasi |

---

## Cara Menggunakan Dokumentasi Ini

**Jika kamu baru bergabung atau memulai sprint pertama:**
1. Baca [01_Architecture.md](./01_Architecture.md) untuk memahami gambaran besar sistem.
2. Baca [02_Coding_Standards.md](./02_Coding_Standards.md) untuk tahu aturan penulisan kode.
3. Baca [08_Design_Patterns.md](./08_Design_Patterns.md) untuk memahami pola-pola yang kita gunakan.
4. Setup lingkungan kerja mengikuti [06_Project_Setup.md](./06_Project_Setup.md).
5. Install SwiftLint mengikuti [12_SwiftLint_Configuration.md](./12_SwiftLint_Configuration.md).

**Jika kamu ingin mulai mengerjakan fitur baru:**
1. Ikuti panduan di [04_New_Feature_Guide.md](./04_New_Feature_Guide.md).
2. Pastikan fitur lulus checklist di [05_HIG_Checklist.md](./05_HIG_Checklist.md).

**Jika kamu perlu referensi cepat saat coding:**
- SwiftUI API dan pattern: [07_SwiftUI_iOS26_Reference.md](./07_SwiftUI_iOS26_Reference.md)
- Design tokens: [03_Design_System.md](./03_Design_System.md)

---

## Referensi Utama (Wajib Dibaca)

| Topik | URL |
|-------|-----|
| Human Interface Guidelines | https://developer.apple.com/design/human-interface-guidelines/ |
| SwiftUI Documentation | https://developer.apple.com/documentation/swiftui |
| Swift API Design Guidelines | https://www.swift.org/documentation/api-design-guidelines/ |
| SF Symbols | https://developer.apple.com/sf-symbols/ |
| Conventional Commits | https://www.conventionalcommits.org/en/v1.0.0/ |

---

## Prinsip Dokumentasi

1. **Tulis yang diperlukan.** Dokumentasi harus membantu developer bekerja, bukan menjadi beban administratif.
2. **Update saat ada perubahan.** Dokumen yang usang lebih berbahaya dari tidak ada dokumentasi. Jika kamu mengubah arsitektur atau menambah pattern baru, update dokumen terkait dalam Pull Request yang sama.
3. **Referensikan ke sumber resmi.** Untuk detail mendalam, selalu arahkan ke dokumentasi Apple atau sumber terpercaya lainnya.
