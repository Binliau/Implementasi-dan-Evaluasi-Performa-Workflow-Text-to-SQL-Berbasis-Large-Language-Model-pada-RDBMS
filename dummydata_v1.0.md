
---

### **BAGIAN 1: DATA MASTER (Dengan `user_id` Terurut)**

**1. Tabel `roles`** (Tidak ada perubahan)
```sql
-- Memasukkan data untuk tabel: roles
INSERT INTO `roles` (`id`, `nama_role`, `deskripsi`) VALUES
(1, 'Admin', 'Memiliki akses penuh ke semua fitur sistem, termasuk manajemen pengguna dan konfigurasi.'),
(2, 'Manajer Gudang', 'Bertanggung jawab atas manajemen stok di satu atau beberapa gudang, termasuk restock dan transfer.'),
(3, 'Staf', 'Memiliki akses untuk mencatat transaksi harian seperti penjualan dan melihat stok.');
```

**2. Tabel `gudang`** (Tidak ada perubahan)
```sql
-- Memasukkan data untuk tabel: gudang
INSERT INTO `gudang` (`id`, `nama_gudang`, `alamat`, `keterangan`) VALUES
(1, 'Gudang Utama Jakarta', 'Jl. Industri Raya No. 1, Jakarta Pusat', 'Gudang pusat untuk distribusi nasional.'),
(2, 'Gudang Regional Surabaya', 'Jl. Rungkut Industri V No. 8, Surabaya', 'Melayani distribusi untuk wilayah Indonesia Timur.'),
(3, 'Gudang Klinik Bandung', 'Jl. Pasteur No. 28, Bandung', 'Gudang pendukung untuk klinik-klinik di area Jawa Barat.');
```

**3. Tabel `kategori_barang`** (Tidak ada perubahan)
```sql
-- Memasukkan data untuk tabel: kategori_barang
INSERT INTO `kategori_barang` (`id`, `nama_kategori`, `deskripsi`) VALUES
(1, 'Alat Medis', 'Peralatan yang digunakan untuk diagnosis, pemantauan, atau perawatan medis.'),
(2, 'Obat-obatan', 'Sediaan atau paduan bahan-bahan yang siap untuk digunakan untuk mempengaruhi atau menyelidiki sistem fisiologi.'),
(3, 'Bahan Habis Pakai', 'Barang sekali pakai yang digunakan dalam prosedur medis atau perawatan pasien.'),
(4, 'Reagen Laboratorium', 'Bahan kimia yang digunakan untuk melakukan tes atau analisis di laboratorium.');
```

**4. Tabel `users` (DIMODIFIKASI)**
```sql
-- Memasukkan data untuk tabel: users (ID diurutkan berdasarkan peran)
-- Catatan: password_hash ini adalah contoh. Gunakan hash yang aman dalam aplikasi nyata.
INSERT INTO `users` (`id`, `username`, `password_hash`, `nama_lengkap`, `role_id`, `aktif`) VALUES
-- Admin (ID 1)
(1, 'admin_utama', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Administrator Sistem', 1, 1),
-- Manajer (ID 2-4)
(2, 'manajer.jkt', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Budi Santoso', 2, 1),
(3, 'manajer.sby', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Citra Lestari', 2, 1),
(4, 'manajer.bdg', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Asep Sunandar', 2, 1),
-- Staf (ID 5-10)
(5, 'staf.jkt1', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Eko Prasetyo', 3, 1),
(6, 'staf.jkt2', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Fitriani', 3, 1),
(7, 'staf.sby1', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Gunawan', 3, 1),
(8, 'staf.sby2', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Hilda', 3, 1),
(9, 'staf.bdg1', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Dewi Anggraini', 3, 1),
(10, 'staf.bdg2', '$2y$10$UvDBA.5.e.a.Q5mH7qG6UuWJzJ.6.sJz.Q5mH7qG6UuWJzJ.6.sJ', 'Irfan Maulana', 3, 1);
```

**5. Tabel `barang`** (Tidak ada perubahan)
```sql
-- Memasukkan data untuk tabel: barang
INSERT INTO `barang` (`id`, `kode_barang`, `nama_barang`, `kategori_id`, `satuan`) VALUES
(1, 'ALK-001', 'Termometer Digital', 1, 'pcs'), (2, 'ALK-002', 'Stetoskop', 1, 'pcs'), (3, 'ALK-003', 'Tensimeter Digital', 1, 'pcs'), (4, 'OBT-001', 'Paracetamol 500mg', 2, 'strip'), (5, 'OBT-002', 'Amoxicillin 500mg', 2, 'strip'), (6, 'OBT-003', 'Vitamin C 500mg', 2, 'botol'), (7, 'BHP-001', 'Masker Medis 3-ply', 3, 'box'), (8, 'BHP-002', 'Sarung Tangan Latex', 3, 'box'), (9, 'BHP-003', 'Kapas Steril', 3, 'roll'), (10, 'BHP-004', 'Alkohol Swab', 3, 'box'), (11, 'BHP-005', 'Perban Elastis 10cm', 3, 'roll'), (12, 'BHP-006', 'Jarum Suntik 3ml', 3, 'box'), (13, 'RGN-001', 'Reagen Tes Glukosa', 4, 'kit'), (14, 'RGN-002', 'Reagen Tes Kolesterol', 4, 'kit'), (15, 'RGN-003', 'Reagen Tes Asam Urat', 4, 'kit'), (16, 'OBT-004', 'Obat Batuk Sirup', 2, 'botol'), (17, 'ALK-004', 'Oximeter', 1, 'pcs'), (18, 'BHP-007', 'Plester Luka', 3, 'box'), (19, 'OBT-005', 'Loratadine 10mg', 2, 'strip'), (20, 'RGN-004', 'Reagen Tes Golongan Darah', 4, 'kit');
```

---

### **BAGIAN 2: DATA TRANSAKSI (Dengan `user_id` yang Disesuaikan)**

**6. Tabel `restock` (DIMODIFIKASI)**
```sql
-- Memasukkan data untuk tabel: restock (user_id disesuaikan dengan urutan baru)
INSERT INTO `restock` (`barang_id`, `gudang_id`, `jumlah`, `tanggal`, `nomor_batch`, `tanggal_kadaluarsa`, `user_id`) VALUES
-- Gudang 1 (Jakarta) - Manajer ID 2, Staf ID 5
(1, 1, 500, '2023-11-10', 'TD2311A', '2028-11-09', 2),
(3, 1, 250, '2023-11-11', 'TS2311B', '2028-11-10', 2),
(4, 1, 8000, '2023-11-15', 'PC2311C', '2025-11-14', 2),
(7, 1, 20000, '2023-11-20', 'MM2311D', '2026-11-19', 2),
(8, 1, 15000, '2023-11-20', 'SL2311E', '2026-11-19', 2),
(12, 1, 5000, '2023-12-01', 'JS2312F', '2027-11-30', 2),
(13, 1, 1000, '2023-12-05', 'RG2312G', '2025-06-04', 5), -- Oleh Staf
(17, 1, 400, '2023-12-06', 'OX2312H', '2028-12-05', 2),
(19, 1, 3000, '2023-12-07', 'LR2312I', '2025-12-06', 2),
-- Gudang 2 (Surabaya) - Manajer ID 3, Staf ID 7
(2, 2, 300, '2023-11-12', 'ST2311J', '2028-11-11', 3),
(5, 2, 7000, '2023-11-18', 'AM2311K', '2025-11-17', 3),
(7, 2, 18000, '2023-11-22', 'MM2311L', '2026-11-21', 3),
(8, 2, 12000, '2023-11-22', 'SL2311M', '2026-11-21', 3),
(10, 2, 4000, '2023-12-02', 'AS2312N', '2025-12-01', 7), -- Oleh Staf
(11, 2, 2000, '2023-12-03', 'PE2312O', '2027-12-02', 3),
(14, 2, 800, '2023-12-08', 'RK2312P', '2025-06-07', 3),
(16, 2, 1500, '2023-12-09', 'OB2312Q', '2025-12-08', 3),
-- Gudang 3 (Bandung) - Manajer ID 4, Staf ID 9
(6, 3, 3000, '2023-11-25', 'VC2311R', '2025-11-24', 4),
(7, 3, 10000, '2023-11-28', 'MM2311S', '2026-11-27', 4),
(8, 3, 8000, '2023-11-29', 'SL2311T', '2026-11-28', 4),
(9, 3, 2500, '2023-12-03', 'KS2312U', '2027-12-02', 9), -- Oleh Staf
(15, 3, 750, '2023-12-11', 'RA2312V', '2025-06-10', 4),
(18, 3, 4000, '2023-12-10', 'PL2312W', '2026-12-09', 4),
(20, 3, 500, '2023-12-12', 'GD2312X', '2025-06-11', 4);
```

**7. Tabel `penjualan` (DIMODIFIKASI)**
```sql
-- Memasukkan data untuk tabel: penjualan (user_id disesuaikan dengan urutan baru)
INSERT INTO `penjualan` (`barang_id`, `gudang_id`, `jumlah`, `tanggal`, `harga_satuan`, `nama_pembeli`, `user_id`) VALUES
(7, 1, 50, '2024-01-15', 25000.00, 'Klinik Sehat Medika', 5),
(8, 1, 40, '2024-01-16', 45000.00, 'RS Harapan Bunda', 6),
(7, 2, 60, '2024-01-18', 25500.00, 'Apotek Farma Surabaya', 7),
(8, 3, 30, '2024-01-20', 46000.00, 'Dr. Anita Puspita', 9),
(4, 1, 100, '2024-01-22', 7500.00, 'Apotek Roxy', 5),
(5, 2, 150, '2024-01-25', 12000.00, 'Puskesmas Rungkut', 8),
(7, 1, 200, '2024-02-01', 24500.00, 'Puskesmas Cempaka Putih', 6),
(8, 2, 150, '2024-02-05', 45000.00, 'RS Mitra Keluarga SBY', 7),
(1, 3, 10, '2024-02-10', 80000.00, 'Klinik Tong Fang', 10),
(13, 1, 20, '2024-02-15', 150000.00, 'Lab Cito Jakarta', 5),
(7, 3, 120, '2024-02-18', 26000.00, 'RS Borromeus', 9),
(8, 1, 180, '2024-02-20', 45500.00, 'RS Siloam Kebon Jeruk', 2), -- Oleh Manajer
(10, 2, 50, '2024-02-22', 30000.00, 'Klinik Gigi Sehat', 8),
(12, 1, 80, '2024-02-25', 60000.00, 'RS St. Carolus', 6),
(16, 2, 30, '2024-03-01', 22000.00, 'Apotek K-24 Surabaya', 7),
(7, 2, 250, '2024-03-05', 25000.00, 'Dinas Kesehatan Jatim', 3), -- Oleh Manajer
(8, 3, 100, '2024-03-08', 46000.00, 'RS Hermina Pasteur', 10),
(9, 3, 40, '2024-03-12', 15000.00, 'Klinik Bersalin Bunda', 9),
(3, 1, 5, '2024-03-15', 450000.00, 'Dr. Budi Prakoso', 5),
(7, 1, 300, '2024-03-20', 24000.00, 'Pengadaan RSUD Tarakan', 6),
(8, 1, 250, '2024-03-22', 45000.00, 'RS Premier Jatinegara', 5),
(6, 3, 60, '2024-03-25', 35000.00, 'Apotek Sentosa', 10),
(18, 3, 70, '2024-04-01', 28000.00, 'Puskesmas Kiaracondong', 9),
(7, 2, 180, '2024-04-04', 25500.00, 'RSUD Dr. Soetomo', 7),
(8, 2, 200, '2024-04-06', 45000.00, 'RS Husada Utama', 8),
(17, 1, 15, '2024-04-10', 120000.00, 'Bapak Hermawan', 6),
(19, 1, 50, '2024-04-15', 18000.00, 'Apotek Century', 5),
(7, 1, 220, '2024-04-18', 25000.00, 'Klinik Prodia', 6),
(8, 3, 130, '2024-04-22', 46500.00, 'RS Advent Bandung', 10),
(20, 3, 25, '2024-04-28', 250000.00, 'PMI Kota Bandung', 4), -- Oleh Manajer
(7, 3, 150, '2024-05-02', 26000.00, 'RS Santosa', 9),
(8, 1, 300, '2024-05-05', 44500.00, 'RS Medistra', 5),
(4, 1, 200, '2024-05-10', 7500.00, 'Apotek Melawai', 6),
(11, 2, 35, '2024-05-15', 20000.00, 'Klinik Fisioterapi', 7),
(7, 2, 300, '2024-05-20', 25000.00, 'RS Royal Surabaya', 8),
(8, 2, 280, '2024-05-22', 45000.00, 'RS William Booth', 7),
(14, 2, 22, '2024-05-28', 180000.00, 'Lab Parahita', 8),
(7, 1, 400, '2024-06-01', 24000.00, 'Distributor Farmasi Utama', 5),
(8, 3, 200, '2024-06-05', 46000.00, 'RS Immanuel', 10),
(2, 2, 8, '2024-06-10', 250000.00, 'Dr. Hartono, Sp.JP', 3), -- Oleh Manajer
(7, 3, 180, '2024-06-15', 26000.00, 'Apotek Pasuketan', 9),
(8, 1, 350, '2024-06-18', 45000.00, 'RS Pondok Indah', 6),
(15, 3, 30, '2024-06-22', 160000.00, 'Lab Klinik Pramita', 10),
(5, 2, 300, '2024-06-28', 12500.00, 'Puskesmas Jagir', 7),
(7, 1, 350, '2024-07-02', 25000.00, 'RS Cipto Mangunkusumo', 5),
(8, 2, 320, '2024-07-05', 45500.00, 'RS Adi Husada', 8),
(1, 1, 20, '2024-07-10', 78000.00, 'Klinik 24 Jam', 6),
(7, 2, 280, '2024-07-15', 25000.00, 'Apotek Kimia Farma SBY', 7),
(8, 3, 180, '2024-07-18', 46000.00, 'RS Melinda', 9),
(12, 1, 100, '2024-07-22', 62000.00, 'Klinik Vaksinasi', 5),
(4, 1, 250, '2024-07-28', 7500.00, 'Toko Obat Sejahtera', 6),
(7, 3, 200, '2024-08-01', 26500.00, 'RSUD Kota Bandung', 10),
(8, 1, 400, '2024-08-05', 45000.00, 'RS Fatmawati', 5),
(10, 2, 80, '2024-08-10', 31000.00, 'Praktek Dokter Bersama', 8),
(7, 1, 380, '2024-08-15', 25000.00, 'RS Persahabatan', 6),
(8, 2, 350, '2024-08-18', 45000.00, 'RS Darmo', 7),
(18, 3, 100, '2024-08-22', 28500.00, 'Apotek Pasteur', 9),
(6, 3, 80, '2024-08-28', 36000.00, 'Toko Vitamin Sehat', 10),
(7, 2, 320, '2024-09-02', 25500.00, 'RS PHC Surabaya', 8),
(8, 3, 220, '2024-09-05', 46000.00, 'RS Al Islam', 9),
(19, 1, 80, '2024-09-10', 18500.00, 'Apotek Guardian', 5),
(7, 1, 450, '2024-09-15', 24500.00, 'RS Gatot Soebroto', 6),
(8, 1, 420, '2024-09-18', 45000.00, 'RS Abdi Waluyo', 5),
(3, 1, 10, '2024-09-22', 460000.00, 'RS Jantung Harapan Kita', 2), -- Oleh Manajer
(9, 3, 60, '2024-09-28', 15500.00, 'Klinik Luka Modern', 10),
(7, 3, 250, '2024-10-02', 26000.00, 'RS Bungsu', 9),
(8, 2, 400, '2024-10-05', 45000.00, 'RSAL Dr. Ramelan', 7),
(17, 1, 25, '2024-10-10', 125000.00, 'PT Sejahtera Medika', 6),
(7, 2, 380, '2024-10-15', 25000.00, 'RS Bhayangkara Surabaya', 8),
(8, 1, 450, '2024-10-18', 44800.00, 'RS Mayapada', 5),
(13, 1, 30, '2024-10-22', 155000.00, 'Lab Klinik Utama', 6),
(5, 2, 400, '2024-10-28', 12000.00, 'Dinas Kesehatan Surabaya', 7),
(7, 1, 500, '2024-11-02', 24000.00, 'Tender Kemenkes', 2), -- Oleh Manajer
(8, 3, 280, '2024-11-05', 46000.00, 'RSUD Ujung Berung', 10),
(11, 2, 50, '2024-11-10', 21000.00, 'Klinik Olahraga', 8),
(7, 3, 280, '2024-11-15', 26000.00, 'RS Rajawali', 9),
(8, 2, 420, '2024-11-18', 45000.00, 'RS Manyar Medical Center', 7),
(20, 3, 30, '2024-11-22', 255000.00, 'RS Hermina Arcamanik', 10),
(4, 1, 300, '2024-11-28', 7600.00, 'Apotek Generik', 5),
(7, 2, 400, '2024-12-02', 25000.00, 'RS Islam Surabaya', 8),
(8, 1, 500, '2024-12-05', 45000.00, 'RS Metropolitan Medical Center', 6),
(16, 2, 50, '2024-12-10', 22500.00, 'Apotek Viva', 7),
(7, 1, 480, '2024-12-15', 25000.00, 'RSUD Koja', 5),
(8, 3, 300, '2024-12-18', 46500.00, 'RSIA Limijati', 9),
(14, 2, 25, '2024-12-22', 185000.00, 'Lab Diagnostika', 8),
(1, 1, 15, '2024-12-28', 80000.00, 'Puskesmas Kecamatan Gambir', 6),
(7, 3, 300, '2025-01-03', 26000.00, 'RS Cahya Kawaluyan', 10),
(8, 2, 450, '2025-01-06', 45000.00, 'RS Gotong Royong', 7),
(12, 1, 120, '2025-01-10', 61000.00, 'Klinik Estetika', 5),
(7, 2, 420, '2025-01-15', 25500.00, 'RS Siti Khodijah', 8),
(8, 1, 520, '2025-01-18', 45000.00, 'RS Medika Permata Hijau', 6),
(15, 3, 35, '2025-01-22', 165000.00, 'Lab Ultra Medika', 9),
(2, 2, 10, '2025-01-28', 255000.00, 'RS Bedah Surabaya', 7),
(7, 1, 550, '2025-02-02', 25000.00, 'RSUD Cengkareng', 5),
(8, 3, 320, '2025-02-05', 46000.00, 'RS Santo Yusuf', 10),
(10, 2, 100, '2025-02-10', 30000.00, 'Klinik Sunat Modern', 8),
(7, 3, 310, '2025-02-15', 26000.00, 'RS Pindad', 9),
(8, 2, 480, '2025-02-18', 45000.00, 'RS Graha Amerta', 7),
(18, 3, 120, '2025-02-22', 28000.00, 'Apotek Bima', 10),
(4, 1, 350, '2025-02-28', 7500.00, 'PBF Sinar Sehat', 6),
(7, 2, 450, '2025-03-03', 25000.00, 'RS Wiyung Sejahtera', 8),
(8, 1, 580, '2025-03-06', 45000.00, 'RS Husada', 5),
(6, 3, 100, '2025-03-10', 35500.00, 'Apotek Cihampelas', 9),
(7, 1, 600, '2025-03-15', 24500.00, 'RS Pelni', 6),
(8, 3, 350, '2025-03-18', 46000.00, 'RS Kebon Jati', 10),
(19, 1, 100, '2025-03-22', 18000.00, 'Apotek Roxy Square', 5),
(9, 3, 80, '2025-03-28', 15000.00, 'RSKIA Harapan Kita BDG', 9),
(7, 3, 330, '2025-04-02', 26000.00, 'RS Lanud Sulaiman', 10),
(8, 2, 500, '2025-04-05', 45000.00, 'RS National Hospital', 7),
(17, 1, 30, '2025-04-10', 122000.00, 'PT Alat Medis Nusantara', 6),
(7, 2, 480, '2025-04-15', 25500.00, 'RS Mitra Keluarga Waru', 8),
(8, 1, 620, '2025-04-18', 45000.00, 'RS Gading Pluit', 5),
(13, 1, 40, '2025-04-22', 152000.00, 'Lab Intibios', 6),
(5, 2, 500, '2025-04-25', 12000.00, 'Apotek Healty Farma', 7),
(7, 1, 650, '2025-04-28', 25000.00, 'RSUD Pasar Minggu', 5),
(8, 3, 380, '2025-04-29', 46000.00, 'RS Avisena', 4), -- Oleh Manajer
(1, 1, 25, '2025-04-30', 80000.00, 'Klinik Medika Utama', 6),
(7, 2, 500, '2025-04-30', 25000.00, 'Pengadaan Pemkot Surabaya', 3); -- Oleh Manajer
```

**8. Tabel `transfer` (DIMODIFIKASI)**
```sql
-- Memasukkan data untuk tabel: transfer (user_id disesuaikan dengan urutan baru)
INSERT INTO `transfer` (`barang_id`, `dari_gudang_id`, `ke_gudang_id`, `jumlah`, `tanggal`, `user_id`) VALUES
(7, 1, 3, 2000, '2024-03-15', 2), -- Manajer JKT
(8, 1, 2, 1500, '2024-04-01', 2), -- Manajer JKT
(4, 1, 3, 1000, '2024-05-20', 2), -- Manajer JKT
(5, 2, 1, 800, '2024-06-10', 3), -- Manajer SBY
(12, 1, 2, 500, '2024-07-05', 2), -- Manajer JKT
(10, 2, 1, 300, '2024-08-11', 3), -- Manajer SBY
(1, 1, 3, 50, '2024-09-02', 2), -- Manajer JKT
(14, 2, 1, 100, '2024-10-18', 3), -- Manajer SBY
(6, 3, 1, 200, '2024-11-22', 4), -- Manajer BDG
(7, 2, 3, 1500, '2025-01-30', 3), -- Manajer SBY
(8, 3, 1, 1000, '2025-02-12', 4), -- Manajer BDG
(18, 3, 1, 500, '2025-03-01', 4), -- Manajer BDG
(17, 1, 2, 40, '2025-04-01', 5), -- Oleh Staf JKT
(9, 3, 2, 200, '2025-04-12', 9), -- Oleh Staf BDG
(16, 2, 3, 150, '2025-04-20', 8); -- Oleh Staf SBY
```

---

### **BAGIAN 3: DATA AGREGAT (Tidak Ada Perubahan)**

Karena jumlah barang dalam setiap transaksi tidak diubah, hasil akhir pada tabel `stok` akan tetap sama.

**9. Tabel `stok`**
```sql
-- Memasukkan data untuk tabel: stok (hasil kalkulasi akhir)
-- Formula: Stok Akhir = (Total Restock + Total Transfer Masuk) - (Total Penjualan + Total Transfer Keluar)
INSERT INTO `stok` (`barang_id`, `gudang_id`, `jumlah`, `tanggal_kadaluarsa`) VALUES
-- Gudang 1 (Jakarta)
(1, 1, 405, '2028-11-09'), (3, 1, 235, '2028-11-10'), (4, 1, 6700, '2025-11-14'), (5, 1, 800, '2025-11-17'), (6, 1, 200, '2025-11-24'), (7, 1, 11850, '2026-11-19'), (8, 1, 9150, '2026-11-19'), (10, 1, 300, '2025-12-01'), (12, 1, 4500, '2027-11-30'), (13, 1, 910, '2025-06-04'), (14, 1, 100, '2025-06-07'), (17, 1, 310, '2028-12-05'), (18, 1, 500, '2026-12-09'), (19, 1, 2770, '2025-12-06'),
-- Gudang 2 (Surabaya)
(2, 2, 282, '2028-11-11'), (5, 2, 5650, '2025-11-17'), (7, 2, 11190, '2026-11-21'), (8, 2, 8150, '2026-11-21'), (9, 2, 200, '2027-12-02'), (10, 2, 3670, '2025-12-01'), (11, 2, 1915, '2027-12-02'), (12, 2, 500, '2027-11-30'), (14, 2, 653, '2025-06-07'), (16, 2, 1270, '2025-12-08'), (17, 2, 40, '2028-12-05'),
-- Gudang 3 (Bandung)
(1, 3, 40, '2028-11-09'), (4, 3, 1000, '2025-11-14'), (6, 3, 2660, '2025-11-24'), (7, 3, 9340, '2026-11-27'), (8, 3, 4290, '2026-11-28'), (9, 3, 2120, '2027-12-02'), (15, 3, 650, '2025-06-10'), (16, 3, 150, '2025-12-08'), (18, 3, 3210, '2026-12-09'), (20, 3, 445, '2025-06-11');
```