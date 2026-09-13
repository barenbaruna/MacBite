# Product Requirements Document (PRD)

**Nama Produk:** MacBite (Food Analysis Camera Companion)

**Deskripsi Singkat:** Transformasi bot nutrisi WhatsApp menjadi aplikasi iOS native.

**Timeline Proyek:** 30 Agustus -- 11 September 2026

---

## 1. Product Overview

MacBite dibangun berdasarkan bot nutrisi AI yang sudah ada di WhatsApp. Bot tersebut dapat menganalisis makanan melalui perintah percakapan dan input foto, tetapi memiliki keterbatasan:

| Keterbatasan Bot | Dampak bagi Pengguna |
|---|---|
| Harus mengetik perintah tertentu (command) | Menambah friction pada setiap interaksi |
| Hasil diberikan dalam format teks chat | Informasi nutrisi sulit dilihat kembali |
| Progress harian tenggelam di chat | Pengguna kehilangan visibilitas terhadap target |

Aplikasi native yang diusulkan tetap mempertahankan kemampuan AI yang sudah berguna, sekaligus merancang ulang user experience agar berfokus pada:

1. Pencatatan makanan yang cepat dan minim langkah
2. Informasi nutrisi yang terstruktur dan mudah dipahami
3. Progres target harian yang selalu terlihat
4. Insight yang dapat langsung ditindaklanjuti untuk jadwal makan berikutnya

### App Concept

Sebuah aplikasi yang membantu orang-orang dengan target fisik spesifik untuk memahami pemenuhan kebutuhan kalori dan makronutrien harian, dengan cara:

- Mengurangi langkah-langkah yang diperlukan untuk melihat daily progress nutrisi melalui input foto atau manual
- Menganalisis makanan secara otomatis menggunakan AI
- Memberikan insight yang dipersonalisasi berdasarkan asupan harian mereka

---

## 2. User

| Kategori | Detail |
|---|---|
| **Target User Profile** | Individu yang memantau asupan makanan untuk mendukung target fisik spesifik (menaikkan massa otot/bulking, menurunkan lemak/cutting, atau mempertahankan berat badan/maintaining) |
| **User Need** | Membutuhkan visibilitas langsung terhadap batas kalori harian dan rincian makronutrisi (terutama asupan protein) untuk mencapai target mereka |
| **Struggle** | Proses mendapatkan informasi kalori saat ini masih menggunakan bot teks yang membutuhkan banyak effort, dan informasi progres harian kurang dapat dipahami dengan mudah karena bentuknya teks di chat yang bisa tertumpuk |

---

## 3. Insights

### Insight 1: Pengguna tahu apa yang dimakan, tapi belum tahu berapa nutrisinya

Orang sudah tahu apa yang dimakan dan nutrisi apa yang penting, tetapi masih perlu mencari di internet, menimbang makanan, atau menghitung untuk mengetahui jumlah nutrisi yang mereka konsumsi dan apakah jumlah tersebut sudah sesuai dengan target pribadi mereka.

- Kalori dan protein muncul sebagai informasi yang paling sering diperhatikan.
- Setelah mendapatkan angka, pengguna masih perlu membandingkannya dengan target pribadi.
- Sebagian pengguna akhirnya menghafal pola makanan yang sering dikonsumsi sehingga tidak lagi melakukan tracking.

### Insight 2: Chatbot belum cukup membantu secara konsisten

Chatbot AI di WhatsApp belum membuat pengguna merasa terbantu secara konsisten karena interaksinya ribet, estimasi kadang kurang dipercaya, dan progres harian mudah tenggelam di dalam chat.

- Progress harian sulit dilihat kembali dalam chat stream.
- Interaksi yang harus dilakukan dengan command menambah friction.
- Estimasi foto dipertanyakan ketika portion size, minyak, bahan tersembunyi, atau metode memasak tidak diketahui.

---

## 4. Competitive Landscape

| Area | Existing (Bot WhatsApp) | Opportunity (Aplikasi Native) |
|---|---|---|
| Chatbot | Text command dan photo scan | App flow tanpa perlu mengingat command |
| Nutrition information | Hasil diberikan dalam chat | Informasi terstruktur dan mudah dilihat kembali |
| Daily progress | Progress tenggelam di chat | Visual calorie + macro progress terhadap target |
| Adjustment | Koreksi perlu memasukkan command lagi | Quick edit portion/ingredients |
| Logging | Typing command, membaca response | Low friction camera/manual logging |
| Decision support | Informasi berupa respons chat | Actionable next meal insight |

---

## 5. User Flow

### Primary Flow

1. User membuka aplikasi (atau melalui widget) dan mengambil foto makanan.
2. AI mengidentifikasi makanan menggunakan model Vision/Foundation, mendeteksi jenis makanan (misalnya: Nasi Putih, Ayam Goreng, Telur).
3. Konfirmasi porsi melalui interactive sheet modal, sehingga user bisa edit item atau porsi.
4. Kalkulasi nutrisi otomatis: sistem mengambil data dari database nutrisi untuk rincian makronutrisi (Kalori, Protein, Karbohidrat, Lemak).
5. Progres berdasarkan target harian: dashboard visual langsung memperbarui progress bar sisa kalori dan protein harian.
6. Saran makanan berikutnya: AI menghasilkan saran singkat untuk sesi makan berikutnya.

---

## 6. Feature Specifications

| No | Feature | Purpose | Minimum Requirement |
|----|---------|---------|---------------------|
| 1 | Food Scan | Foto makanan | Capture/select photo dan submit analysis |
| 2 | Manual Input | Alternatif ketika foto tidak praktis | Food search/select + quantity |
| 3 | AI Food Detection | Mengenali makanan | Detected food ada opsi untuk Add / Remove / Edit |
| 4 | Portion & Ingredient Confirmation | Mengoreksi hasil detection | Edit portion dan relevant preparation/ingredient (sliders/toggles/text field) |
| 5 | Nutrition Calculation | Menghasilkan nutrition estimate | Calories, protein, carbs, fat |
| 6 | Goal Based Progress | Memahami posisi progres terhadap target harian | Intake, target, remaining, visual progress |
| 7 | Actionable Insight | Membantu next meal decision | Insight berdasarkan intake + goal |
| 8 | Meal History | Melihat riwayat makanan yang tercatat | Daftar meal per hari |
| 9 | Profile | Mengatur target nutrisi personal | Input target kalori, protein, carbs, fat |

---

## 7. Framework dan Tech Stack

| Framework / Source | Role | Priority |
|---|---|---|
| SwiftUI | Native UI, camera flow, analysis result, progress, history | Core |
| Vision / VisionKit | Camera/image processing; OCR/barcode if needed | Core / Optional |
| Apple Foundation Models | Image + text prompt -> structured food information -> insight | Core candidate |
| USDA FoodData Central, FatSecret | Food search and detailed nutrient data; avoid building DB from scratch | Data source / Exploration |
| HealthKit | Potential health/nutrition data and history integration | Exploratory |
| Core ML + Create ML | Specialised food classifier if Foundation Models is insufficient | Optional |

---

## 8. User Experience Principles

| Principle | Meaning |
|---|---|
| Less effort, not less information | Hilangkan input yang tidak perlu, tetap jaga informasi yang dibutuhkan untuk keputusan yang percaya diri |
| Context over isolated numbers | Tampilkan asupan relatif terhadap target personal, bukan angka terisolasi |
| Make the next action clear | Terjemahkan data menjadi implikasi yang bisa dipahami untuk jadwal makan berikutnya |
| Trust through transparency | Komunikasikan bahwa hasil adalah estimasi dan izinkan koreksi |
| One glance over chat digging | Progres harian yang penting harus selalu terlihat dalam satu pandangan (*glanceable*) |
| Progressive disclosure | Prioritaskan kalori, makro utama, dan insight; tampilkan detail lebih dalam hanya saat diminta |
| Native Apple Typography & Dynamic Type | Wajib menggunakan font sistem Apple (SF Pro & SF Pro Rounded) dengan dukungan Dynamic Type penuh (xSmall hingga AX5). Hindari font custom statis demi aksesibilitas optimal dan layout stability |
| Liquid Glass & Ergonomic Navigation | Mengadopsi prinsip navigasi iOS 26: bottom-aligned search untuk jangkauan satu tangan yang ergonomis, dan Liquid Glass hanya pada navigation/floating layer |

---

## 9. User Correction Scenarios

Berikut skenario di mana user perlu melakukan koreksi, dan bagaimana aplikasi harus merespons:

| Skenario | Respons Aplikasi |
|---|---|
| Gambar tidak jelas | Tawarkan retake foto atau manual input |
| Multiple makanan dalam satu foto | Tampilkan setiap item terpisah untuk koreksi individual |
| Bahan tersembunyi / metode memasak tidak diketahui | Izinkan adjustment atau tandai sebagai estimasi |
| Porsi tidak pasti | Minta konfirmasi atau hindari presisi palsu |
| Makanan tidak dikenali | Sediakan manual search/input |
| Label nutrisi yang diketahui berbeda dari estimasi | Izinkan koreksi manual oleh user |
| User tidak mau memfoto di tempat umum | Sediakan fast manual logging |

---

## 10. Key Timeline

| Milestone | Target Date | Deliverables |
|---|---|---|
| Lo-Fi | Rabu, 2 September | User flow diagrams, hand-drawn wireframe lo-fi screens (Dashboard, Camera, Bottom Sheet), base app architecture setup |
| Mid-Fi | Jumat, 4 September | Sketch prototype BnW, functional camera scan dengan AI, macro nutrition calculator |
| Hi-Fi + Code Freeze | Kamis, 10 September | Full visual UI design applied (SF Symbols, custom color), final SwiftUI layout integrated, error handling complete |
| Final Demo | Jumat, 11 September | End-to-end polish, responsive haptic feedback, bug fixes, final project presentation |
