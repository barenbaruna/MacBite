# MacBite

MacBite adalah aplikasi iOS native yang dirancang untuk membantu individu dengan target fisik spesifik (seperti menaikkan massa otot/bulking, menurunkan lemak/cutting, atau menjaga berat badan/maintaining) dalam memantau asupan kalori dan makronutrien harian secara efisien.

Aplikasi ini mentransformasikan alur interaksi bot berbasis teks ke dalam pengalaman aplikasi native yang intuitif, cepat, dan terstruktur dengan memanfaatkan analisis foto berbasis Artificial Intelligence (AI), konfirmasi porsi interaktif, visualisasi progres target harian, serta rekomendasi makanan berikutnya (actionable insights).

---

## Team dan Roles

| Nama | Peran | Tanggung Jawab Utama |
|---|---|---|
| **Baren Baruna Harahap (Author)** | Tech / iOS Developer | Arsitektur aplikasi, implementasi UI/UX dengan SwiftUI, alur kamera dan integrasi sistem |
| **Joshua Valentine Manik** | Tech / iOS Developer | Logika kalkulasi nutrisi, manajemen data lokal, integrasi API nutrisi, dan pengujian |
| **Fathimah Az Zahra Sanjani** | Machine Learning Engineer | Eksperimen model klasifikasi makanan, prompt engineering, optimasi inferensi, dan integrasi Core ML/Foundation Models |

---

## Tech Stack

| Kategori | Framework / Teknologi |
|---|---|
| UI dan Application Core | SwiftUI, Combine, Swift Concurrency (async/await) |
| Image Processing | Vision, VisionKit |
| Machine Learning dan AI | Apple Foundation Models, Core ML, Create ML |
| Nutritional Database | USDA FoodData Central API, FatSecret API |
| Health Integration | HealthKit (Eksplorasi) |

---

## Dokumentasi Teknis

Semua dokumentasi teknis (arsitektur, coding standards, design patterns, testing strategy, dsb.) ada di folder [Documentation/](./Documentation/README.md).

Baca folder tersebut terlebih dahulu sebelum mulai coding.

---

## Branching Strategy

Repository ini menerapkan strategi branching berbasis peran dan fungsionalitas untuk menjaga stabilitas kode:

| Branch | Tujuan | Siapa |
|---|---|---|
| `main` | Versi produksi stabil, siap rilis atau demo. | Tidak ada yang commit langsung ke sini. |
| `development` | Branch integrasi. Semua fitur dan model digabung di sini sebelum ke `main`. | Semua developer merge ke sini via Pull Request. |
| `feature/<nama>` | Pengembangan fitur aplikasi iOS. | Baren, Joshua |
| `ML/<nama>` | Eksperimen ML: dataset, evaluasi model, ekspor Core ML. | Fathimah Az Zahra |
| `Tech/<nama>` | Setup arsitektur, refactoring, konfigurasi. | Baren, Joshua |

### Penamaan Branch

Gunakan huruf kecil (lowercase) dengan tanda hubung (kebab-case):

```
feature/camera-food-scan
feature/daily-macro-progress
feature/portion-sheet-modal
feature/manual-food-search
ML/food-classifier-model
ML/prompt-engineering-insight
Tech/swiftlint-setup
Tech/nutrition-api-service
```

---

## Merge Flow

Semua perubahan mengalir dari branch kerja ke `development`, lalu dari `development` ke `main`:

```
feature/<nama>   Tech/<nama>   ML/<nama>
       |              |             |
       +--------------+-------------+
                      |
                      v  Pull Request + Code Review
                 development
                      |
                      v  Regression Testing + Code Freeze
                    main
```

### Langkah Integrasi

1. **Kerjakan di branch sendiri.** Setiap developer bekerja pada branch sesuai tugasnya.
2. **Sinkronisasi sebelum Pull Request.** Pastikan branch sudah diperbarui dengan versi terbaru `development`:
   ```bash
   git checkout development
   git pull origin development
   git checkout feature/nama-fitur
   git merge development
   ```
   Jika terjadi conflict, selesaikan di branch fitur (bukan di development).
3. **Buat Pull Request ke `development`.** Tuliskan deskripsi perubahan dan langkah pengujian.
4. **Review dan merge.** Setelah mendapat 1 approval, merge menggunakan **Squash and Merge** agar commit history di development tetap bersih.
5. **Hapus branch setelah merge.** Baik di remote maupun lokal.

---

## Repository Rules

### 1. Proteksi Branch

- **Dilarang** melakukan `git push --force` ke `main` atau `development`.
- Semua perubahan ke `main` dan `development` wajib melalui Pull Request.
- Tidak ada yang commit langsung ke `main`. Titik.

### 2. Pull Request

Setiap Pull Request harus memenuhi:

| Syarat | Detail |
|--------|--------|
| Deskripsi | Jelaskan apa yang berubah, mengapa berubah, dan komponen yang terpengaruh. |
| Review | Minimal 1 approval sebelum merge. |
| Review assignment | Perubahan fitur iOS: direview oleh sesama Tech. Perubahan model AI: direview bersama Tech dan ML Engineer. |
| Build | Kode harus bisa di-build tanpa error. |
| SwiftLint | Tidak ada SwiftLint error. Warning diperbolehkan tapi harus di-track. |
| Test | Unit test untuk ViewModel yang memiliki logika bisnis. |

### 3. Resolusi Conflict

Saat terjadi merge conflict:

1. Conflict diselesaikan di **branch fitur**, bukan di `development`.
2. Jika conflict melibatkan kode yang ditulis developer lain, **koordinasikan langsung** dengan developer tersebut sebelum menyelesaikan conflict.
3. **Dilarang** melakukan override paksa yang menghapus pekerjaan orang lain.
4. Setelah resolve conflict, build dan test ulang sebelum push.

```bash
# Cara menyelesaikan conflict
git checkout development
git pull origin development
git checkout feature/nama-fitur
git merge development
# --> Resolve conflicts di editor
# --> Build dan test
git add .
git commit -m "merge: resolve conflict with development"
git push
```

### 4. Kebersihan Repository

- Hapus branch di remote dan lokal setelah Pull Request berhasil di-merge:
  ```bash
  git branch -d feature/nama-fitur
  git push origin --delete feature/nama-fitur
  ```
- Jangan pernah commit: API key, token, file credential, file binary besar, dataset mentah.
- Gunakan `.gitignore` untuk memastikan file-file tersebut tidak ter-track.
- Untuk file ML model yang besar (>50MB), gunakan Git LFS.

---

## Conventional Commits

Setiap commit message wajib mengikuti standar [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

### Format

```
<type>(<scope>): <deskripsi singkat dalam bentuk imperatif>
```

### Tipe Commit

| Type | Kapan Digunakan | Contoh |
|------|-----------------|--------|
| `feat` | Menambahkan fitur baru | `feat(camera): implement food scanning using VisionKit` |
| `fix` | Memperbaiki bug | `fix(nutrition): correct protein calculation for portion multiplier` |
| `ml` | Perubahan terkait ML (model, dataset, prompt) | `ml(detection): integrate Core ML model for food recognition` |
| `docs` | Perubahan dokumentasi | `docs(readme): add branching strategy section` |
| `refactor` | Restrukturisasi kode tanpa mengubah perilaku | `refactor(viewmodel): extract nutrition calculation to service` |
| `test` | Menambah atau memperbaiki unit test | `test(dashboard): add test for calorie progress calculation` |
| `chore` | Konfigurasi build, tooling, aset | `chore(lint): configure SwiftLint rules` |
| `style` | Formatting, spacing, tanpa perubahan logika | `style(scan): fix indentation in FoodScanView` |
| `perf` | Optimasi performa | `perf(search): optimize food search debounce interval` |

### Aturan Penulisan

1. **Deskripsi dalam bentuk imperatif.** Tulis seolah-olah kamu memerintahkan codebase: "add camera button", bukan "added camera button" atau "adding camera button".
2. **Scope menjelaskan area yang berubah.** Gunakan nama fitur atau komponen: `camera`, `dashboard`, `nutrition`, `profile`, `search`, `detection`.
3. **Satu commit = satu perubahan logis.** Jangan campur fix bug dengan penambahan fitur dalam satu commit.
4. **Huruf kecil semua.** Tidak ada huruf kapital di awal deskripsi.

### Commit yang Dilarang

```
update
fix bug
revisi tampilan
coba lagi
model baru fix
WIP
asdf
```

---

## Developer Workflow

### 1. Clone Repository

```bash
git clone <repository-url>
cd CallBite
```

### 2. Sinkronisasi Branch Development

Selalu mulai dari versi terbaru:

```bash
git checkout development
git pull origin development
```

### 3. Buat Branch Baru

```bash
# Fitur iOS
git checkout -b feature/portion-confirmation-sheet

# Eksperimen ML
git checkout -b ML/food-detection-evaluation

# Setup teknis
git checkout -b Tech/swiftlint-setup
```

### 4. Commit Perubahan

```bash
git status
git add .
git commit -m "feat(sheet): create interactive portion slider component"
```

### 5. Push ke Remote

```bash
git push -u origin feature/portion-confirmation-sheet
```

### 6. Buat Pull Request

1. Buka repository di GitHub.
2. Buat Pull Request dari branch kamu ke `development`.
3. Tulis deskripsi: apa yang berubah, mengapa, dan cara mengujinya.
4. Assign reviewer.
5. Setelah approval, merge dengan **Squash and Merge**.
6. Hapus branch:
   ```bash
   git branch -d feature/portion-confirmation-sheet
   git push origin --delete feature/portion-confirmation-sheet
   ```

---

## Checklist Sebelum Push

Sebelum push dan membuat Pull Request, pastikan:

- [ ] Build berhasil tanpa error (`Cmd + B`).
- [ ] SwiftLint tidak menampilkan error (`swiftlint` di terminal).
- [ ] Unit test lulus (`Cmd + U`).
- [ ] Tidak ada API key, token, atau data sensitif yang ter-commit.
- [ ] Commit message mengikuti format Conventional Commits.
- [ ] Target Pull Request adalah `development`, bukan `main`.
- [ ] Branch sudah disinkronisasi dengan `development` terbaru.
