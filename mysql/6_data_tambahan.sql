-- ============================================================================
-- INVENTORY KESEHATAN - DATA TAMBAHAN v2.0
-- Jalankan SETELAH: 3_initial_stock_v2.sql, 4_transfer_data_FIXED.sql,
--                   5_sales_data_part1_FIXED.sql, 5_sales_data_part2_FIXED.sql
-- ============================================================================
-- Isi file ini:
--   1. Transfer melibatkan Gudang Palembang (id=7)
--   2. Penjualan barang yang belum pernah terjual (alat medis, dll)
--   3. Penjualan Juni 2024 - Februari 2025 semua gudang
-- CATATAN: batch_stok dan restock sudah ada di 3_initial_stock_v2.sql
-- ============================================================================

USE inventory_kesehatan;

-- BAGIAN 3: TRANSFER MELIBATKAN GUDANG PALEMBANG (id=7)
-- ============================================================================

INSERT INTO transfer (barang_id, dari_gudang_id, ke_gudang_id, jumlah, tanggal, user_id) VALUES
-- Supply awal dari Jakarta ke Palembang
(22, 1, 7, 300, '2024-03-20', 4),
(23, 1, 7, 200, '2024-03-20', 4),
(29, 1, 7,  80, '2024-03-25', 4),
(34, 1, 7, 120, '2024-03-25', 4),
-- Palembang <-> Medan (sesama wilayah Sumatera)
(10, 7, 4, 150, '2024-06-10', 4),
(33, 7, 4,  30, '2024-06-15', 4),
(28, 4, 7,  60, '2024-08-20', 7),
(35, 4, 7,  50, '2024-09-05', 7),
-- Supply Q4 ke Palembang
(22, 1, 7, 400, '2024-10-10', 4),
(17, 1, 7, 200, '2024-11-05', 4),
(21, 2, 7, 100, '2024-12-10', 5);

-- ============================================================================
-- BAGIAN 4: PENJUALAN BARANG YANG BELUM PERNAH DIJUAL
-- Barang id=1,2,3,5,7,8,13,20,21,27,32,36 harus ada riwayat penjualannya
-- ============================================================================

INSERT INTO penjualan (barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id) VALUES
-- id=1  Termometer Digital Infrared
(1,  1,  5, '2024-02-05', 350000.00,  'Klinik Pratama Senen Jakarta',      21),
(1,  2,  3, '2024-04-12', 355000.00,  'Puskesmas Wonokromo Surabaya',      22),
(1,  3,  2, '2024-07-20', 360000.00,  'RS Santosa Bandung',                23),
-- id=2  Stetoskop Littmann Classic III
(2,  3,  4, '2024-03-08', 950000.00,  'Fakultas Kedokteran UNPAD',         15),
(2,  3,  2, '2024-09-15', 960000.00,  'RS Hasan Sadikin Bandung',          16),
-- id=3  Tensimeter Digital Omron
(3,  1,  6, '2024-02-18', 420000.00,  'Klinik Hipertensi Jakarta',         21),
(3,  2,  4, '2024-05-22', 425000.00,  'Apotek Roxy Surabaya',              22),
(3,  1,  3, '2024-11-10', 430000.00,  'Panti Jompo Sejahtera Depok',       21),
-- id=5  Nebulizer Omron NE-C801
(5,  1,  3, '2024-03-14', 580000.00,  'Klinik Asma Jakarta Pusat',         21),
(5,  2,  2, '2024-08-25', 585000.00,  'RS Paru-Paru Surabaya',             22),
-- id=7  Glukometer Accu-Chek Active
(7,  1,  8, '2024-02-28', 280000.00,  'Klinik Diabetes Tebet',             21),
(7,  1,  5, '2024-06-17', 285000.00,  'Puskesmas Menteng Jakarta',         11),
(7,  2,  4, '2024-10-03', 290000.00,  'RS Mitra Keluarga Surabaya',        22),
-- id=8  Kursi Roda Standar GEA
(8,  3,  3, '2024-04-22', 1250000.00, 'Panti Rehabilitasi Bandung',        23),
(8,  1,  2, '2024-09-08', 1260000.00, 'RS Ortopedi Jakarta',               21),
-- id=13 Obat Batuk Sirup Woods
(13, 2, 80, '2024-03-19', 18000.00,   'Apotek Generik Surabaya',           14),
(13, 2, 60, '2024-07-11', 18500.00,   'Puskesmas Rungkut Surabaya',        13),
(13, 4, 50, '2024-10-28', 18000.00,   'Toko Obat Sehat Medan',             17),
-- id=20 Multivitamin Dewasa
(20, 1,120, '2024-03-25', 42000.00,   'Guardian Pharmacy Grand Indonesia', 21),
(20, 2, 80, '2024-06-30', 42000.00,   'Century Healthcare Surabaya',       22),
(20, 3, 60, '2024-09-20', 43000.00,   'Apotek K-24 Bandung',               23),
-- id=21 Asam Mefenamat 500mg
(21, 1,200, '2024-03-30', 9500.00,    'Apotek Kimia Farma Senen',          11),
(21, 2,150, '2024-07-16', 9500.00,    'Puskesmas Sawahan Surabaya',        13),
(21, 7,100, '2024-09-24', 9800.00,    'Apotek Melati Palembang',            4),
-- id=27 Jarum Suntik 3ml Disposable
(27, 1, 30, '2024-04-08', 48000.00,   'Klinik Vaksin Jakarta',             12),
(27, 2, 20, '2024-07-30', 49000.00,   'Puskesmas Gubeng Surabaya',         14),
(27, 3, 15, '2024-11-18', 49000.00,   'Klinik Bersalin Bandung',           15),
-- id=32 Infus Set Dewasa
(32, 1, 80, '2024-04-15', 22000.00,   'RSUP Dr. Cipto Mangunkusumo',       12),
(32, 2, 60, '2024-08-06', 22000.00,   'RSUD Dr. Soetomo Surabaya',         13),
(32, 4, 40, '2024-11-22', 22500.00,   'RS Haji Adam Malik Medan',          17),
-- id=36 Jarum Suntik 1ml (Insulin)
(36, 1, 25, '2024-05-10', 52000.00,   'Klinik Diabetes Kemayoran',         21),
(36, 2, 20, '2024-08-19', 53000.00,   'Puskesmas Simokerto Surabaya',      14),
(36, 3, 15, '2024-12-09', 53000.00,   'RS Hasan Sadikin Bandung',          15);

-- ============================================================================
-- BAGIAN 5: PENJUALAN JUNI 2024 - FEBRUARI 2025 (GUDANG 1-5 DAN 7)
-- ============================================================================

INSERT INTO penjualan (barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id) VALUES

-- ======= JUNI 2024 =======
(22, 1, 300, '2024-06-02', 24500.00,  'RS Tarakan Jakarta',                11),
(23, 1, 250, '2024-06-02', 44500.00,  'RS Tarakan Jakarta',                12),
(10, 2, 400, '2024-06-05', 7500.00,   'Apotek K-24 Surabaya Pusat',        13),
(11, 3, 200, '2024-06-08', 12000.00,  'Puskesmas Coblong Bandung',         15),
(22, 4, 180, '2024-06-10', 24000.00,  'RS Pirngadi Medan',                 17),
(23, 4, 130, '2024-06-10', 45000.00,  'RS Pirngadi Medan',                 18),
(38, 1,  10, '2024-06-12', 185000.00, 'Lab Kimia Farma Jakarta',           12),
(17, 5, 120, '2024-06-15', 16000.00,  'Apotek Century Makassar',           19),
(22, 5, 200, '2024-06-20', 26500.00,  'RS Labuang Baji Makassar',          20),
(10, 1, 500, '2024-06-25', 7200.00,   'Dinas Kesehatan DKI Jakarta',        4),
(12, 3, 150, '2024-06-28', 34000.00,  'Guardian Pharmacy Cihampelas',      15),
-- Palembang mulai aktif
(22, 7, 200, '2024-06-05', 24500.00,  'RS Siti Khadijah Palembang',         4),
(10, 7, 300, '2024-06-12', 7500.00,   'Puskesmas Plaju Palembang',          4),
(11, 7, 200, '2024-06-20', 12000.00,  'Apotek Kimia Farma Palembang',       4),

-- ======= JULI 2024 =======
(22, 1, 350, '2024-07-03', 24500.00,  'RSUD Koja Jakarta',                 11),
(23, 1, 300, '2024-07-03', 44500.00,  'RSUD Koja Jakarta',                 12),
(11, 2, 250, '2024-07-07', 12000.00,  'RS Premier Surabaya',               13),
(18, 3, 100, '2024-07-10', 8500.00,   'Apotek Generik Bandung',            16),
(22, 4, 200, '2024-07-12', 24000.00,  'RS Columbia Asia Medan',            17),
(10, 5, 300, '2024-07-15', 7500.00,   'Puskesmas Tamalate Makassar',       19),
(22, 2, 150, '2024-07-22', 25500.00,  'RS Husada Utama Surabaya',          14),
(17, 1, 200, '2024-07-25', 16500.00,  'RS Fatmawati Jakarta',              11),
(22, 7, 100, '2024-07-08', 25000.00,  'RS RK Charitas Palembang',           4),
(17, 7, 150, '2024-07-20', 16000.00,  'RS Pusri Palembang',                 4),

-- ======= AGUSTUS 2024 =======
(22, 1, 400, '2024-08-02', 24000.00,  'RSUP Persahabatan Jakarta',         11),
(23, 1, 350, '2024-08-02', 44000.00,  'RSUP Persahabatan Jakarta',         12),
(10, 2, 500, '2024-08-05', 7500.00,   'PBF Enseval Surabaya',               5),
(11, 4, 300, '2024-08-08', 12000.00,  'RSUD Dr. Pirngadi Medan',           17),
(22, 3, 120, '2024-08-10', 25500.00,  'RS Santo Yusup Bandung',            15),
(18, 5, 150, '2024-08-14', 8500.00,   'Apotek Roxy Makassar',              19),
(28, 1,  60, '2024-08-18', 18500.00,  'RSPAD Gatot Soebroto',              12),
(22, 4, 250, '2024-08-20', 24000.00,  'RS Advent Medan',                   18),
(12, 2, 200, '2024-08-24', 34000.00,  'Guardian Pharmacy Tunjungan',       13),
(22, 7,  50, '2024-08-14', 25000.00,  'Klinik Medika Palembang',            4),

-- ======= SEPTEMBER 2024 =======
(22, 1, 280, '2024-09-03', 24500.00,  'RS Carolus Jakarta',                11),
(23, 1, 240, '2024-09-03', 44500.00,  'RS Carolus Jakarta',                12),
(10, 5, 400, '2024-09-05', 7800.00,   'Dinas Kesehatan Sulsel',             8),
(11, 2, 180, '2024-09-08', 12500.00,  'RS William Booth Surabaya',         14),
(22, 4, 160, '2024-09-12', 24000.00,  'Puskesmas Helvetia Medan',          17),
(38, 3,   8, '2024-09-15', 185000.00, 'Lab Pramita Bandung',               15),
(22, 2, 200, '2024-09-22', 25500.00,  'RS Bersalin Permata Surabaya',      13),
(17, 1, 150, '2024-09-25', 16500.00,  'RS Sentra Medika Cikarang',         21),
(22, 7,  30, '2024-09-18', 25500.00,  'Apotek Sehat Palembang',             4),

-- ======= OKTOBER 2024 =======
(22, 1, 320, '2024-10-02', 24500.00,  'RS Husada Jakarta',                 11),
(23, 1, 280, '2024-10-02', 44500.00,  'RS Husada Jakarta',                 12),
(10, 3, 300, '2024-10-05', 7500.00,   'Apotek Century Bandung',            15),
(18, 2, 200, '2024-10-08', 8500.00,   'RS Mitra Keluarga Surabaya',        13),
(22, 5, 220, '2024-10-10', 26500.00,  'RS Haji Makassar',                  19),
(11, 1, 350, '2024-10-14', 12000.00,  'RSUP Dr. Cipto Mangunkusumo',       12),
(22, 4, 190, '2024-10-20', 24000.00,  'RS Bunda Thamrin Medan',            17),
(17, 2, 100, '2024-10-25', 16000.00,  'Apotek Kimia Farma Darmo',          22),
(10, 7, 200, '2024-10-22', 7800.00,   'Dinas Kesehatan Palembang',          4),

-- ======= NOVEMBER 2024 =======
(22, 1, 400, '2024-11-02', 24000.00,  'RS Medistra Jakarta',               11),
(23, 1, 350, '2024-11-02', 44000.00,  'RS Medistra Jakarta',               12),
(10, 4, 500, '2024-11-05', 7500.00,   'Dinas Kesehatan Sumut',              7),
(22, 2, 250, '2024-11-08', 25500.00,  'RS National Hospital Surabaya',     13),
(11, 5, 200, '2024-11-10', 12000.00,  'RS Siloam Makassar',                19),
(18, 3, 120, '2024-11-13', 8500.00,   'Apotek K-24 Bandung',               15),
(22, 4, 180, '2024-11-17', 24000.00,  'RS Martha Friska Medan',            18),
(28, 2,  80, '2024-11-20', 18500.00,  'RSUD Dr. Soetomo Surabaya',         14),
(17, 1, 180, '2024-11-24', 16500.00,  'RS Pelni Jakarta',                  21),
(22, 7, 250, '2024-11-14', 25000.00,  'RS Islam Siti Rahmah Palembang',     4),
(23, 7, 180, '2024-11-14', 45000.00,  'RS Islam Siti Rahmah Palembang',     4),

-- ======= DESEMBER 2024 =======
(22, 1, 500, '2024-12-02', 24000.00,  'RS Pluit Jakarta',                  11),
(23, 1, 450, '2024-12-02', 44000.00,  'RS Pluit Jakarta',                  12),
(10, 2, 600, '2024-12-05', 7500.00,   'PBF Mensa Surabaya',                 5),
(11, 3, 300, '2024-12-08', 12000.00,  'RS Boromeus Bandung',               15),
(22, 4, 300, '2024-12-10', 24000.00,  'RS Advent Medan',                   17),
(22, 5, 280, '2024-12-12', 26500.00,  'RS Stella Maris Makassar',          19),
(17, 2, 200, '2024-12-15', 16000.00,  'Klinik Sumber Waras Surabaya',      22),
(18, 1, 250, '2024-12-18', 8500.00,   'Apotek Guardian Sudirman',          21),
(10, 4, 400, '2024-12-20', 7500.00,   'RSUD Haji Adam Malik Medan',         7),
(22, 1, 600, '2024-12-26', 24000.00,  'Dinas Kesehatan DKI Jakarta',        4),
(23, 2, 500, '2024-12-28', 44000.00,  'Dinas Kesehatan Jawa Timur',         5),
(17, 7,  80, '2024-12-05', 16000.00,  'Klinik Pratama Palembang',           4),

-- ======= JANUARI 2025 =======
(22, 1, 350, '2025-01-06', 25000.00,  'RS Harapan Bunda Jakarta',          11),
(23, 1, 300, '2025-01-06', 45000.00,  'RS Harapan Bunda Jakarta',          12),
(10, 2, 450, '2025-01-09', 7800.00,   'Apotek Kimia Farma Surabaya',       13),
(11, 3, 200, '2025-01-12', 12500.00,  'Puskesmas Sukasari Bandung',        15),
(22, 4, 220, '2025-01-14', 24500.00,  'RS Columbia Asia Medan',            17),
(17, 5, 180, '2025-01-16', 16500.00,  'RS Wahidin Sudirohusodo Makassar',  19),
(12, 1, 300, '2025-01-20', 35000.00,  'Guardian Pharmacy Senayan',         21),
(22, 2, 280, '2025-01-22', 25500.00,  'RS Premier Surabaya',               14),
(18, 4, 150, '2025-01-25', 8800.00,   'Apotek Melati Medan',               18),
(10, 5, 350, '2025-01-28', 7800.00,   'Puskesmas Tamalate Makassar',       20),
(12, 7, 120, '2025-01-10', 35000.00,  'Puskesmas Gandus Palembang',         4),

-- ======= FEBRUARI 2025 =======
(22, 1, 400, '2025-02-03', 25000.00,  'RSUD Pasar Minggu Jakarta',         11),
(23, 1, 350, '2025-02-03', 45000.00,  'RSUD Pasar Minggu Jakarta',         12),
(10, 3, 500, '2025-02-06', 7800.00,   'Dinas Kesehatan Jawa Barat',         6),
(11, 5, 250, '2025-02-09', 12500.00,  'RS Siloam Makassar',                19),
(22, 4, 200, '2025-02-12', 24500.00,  'RS Murni Teguh Medan',              17),
(17, 2, 150, '2025-02-14', 16500.00,  'RS Adi Husada Surabaya',            13),
(12, 1, 250, '2025-02-18', 35000.00,  'Apotek Century Kelapa Gading',      21),
(22, 5, 300, '2025-02-20', 26500.00,  'RS Labuang Baji Makassar',          20),
(18, 3, 100, '2025-02-24', 8800.00,   'Klinik Sehat Bandung',              16),
(10, 4, 400, '2025-02-27', 7800.00,   'Puskesmas Sunggal Medan',           18),
(22, 7, 200, '2025-02-03', 25000.00,  'RS Bhayangkara Palembang',           4),
(10, 7, 250, '2025-02-15', 7800.00,   'Dinas Kesehatan Sumsel',             4);

-- ============================================================================
-- VERIFIKASI
-- ============================================================================

SELECT g.nama_gudang, COUNT(p.penjualan_id) AS jml_penjualan
FROM gudang g
LEFT JOIN penjualan p ON g.gudang_id = p.gudang_id
GROUP BY g.gudang_id, g.nama_gudang ORDER BY g.gudang_id;

SELECT DATE_FORMAT(tanggal,'%Y-%m') AS bulan, COUNT(*) AS transaksi
FROM penjualan
GROUP BY DATE_FORMAT(tanggal,'%Y-%m') ORDER BY bulan;

-- Stok akhir harus selalu >= 0
SELECT b.nama_barang, g.nama_gudang, SUM(bs.jumlah) AS stok_sisa
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
GROUP BY bs.barang_id, bs.gudang_id, b.nama_barang, g.nama_gudang
HAVING stok_sisa <= 0;