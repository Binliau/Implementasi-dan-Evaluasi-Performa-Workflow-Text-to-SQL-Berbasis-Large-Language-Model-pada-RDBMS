-- ============================================================================
-- INVENTORY KESEHATAN - INITIAL STOCK v2.0 (KONSISTEN DENGAN TRANSAKSI)
-- ============================================================================
-- Perbaikan dari v1.0:
--   - batch_stok dihitung ulang agar stok tidak negatif setelah semua
--     transaksi (penjualan + transfer) dijalankan
--   - Setiap gudang hanya menyimpan barang yang relevan dengan wilayahnya
--   - Semua barang yang pernah dijual/ditransfer pasti punya batch_stok
--   - Stok akhir (batch_stok - terjual - transfer_keluar + transfer_masuk)
--     selalu >= 0 untuk semua kombinasi barang+gudang
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- 1. BATCH_STOK AWAL - JANUARI 2024
--    Nilai sudah disesuaikan agar konsisten dengan seluruh transaksi
-- ============================================================================

-- Gudang Jakarta (id=1)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(1, 1, 20, NULL),  -- Termometer Digital Infrared
(3, 1, 20, NULL),  -- Tensimeter Digital Omron HEM-7120
(4, 1, 20, NULL),  -- Pulse Oximeter CONTEC CMS50DL
(5, 1, 20, NULL),  -- Nebulizer Omron NE-C801
(6, 1, 20, NULL),  -- Timbangan Digital Camry BR9012
(7, 1, 30, NULL),  -- Glukometer Accu-Chek Active
(8, 1, 15, NULL),  -- Kursi Roda Standar GEA FS809
(10, 1, 2500, '2026-06-30'),  -- Paracetamol 500mg
(11, 1, 500, '2026-03-31'),  -- Amoxicillin 500mg
(12, 1, 700, '2026-06-30'),  -- Vitamin C 500mg
(14, 1, 20, '2027-06-30'),  -- Loratadine 10mg
(17, 1, 900, '2028-06-30'),  -- Ibuprofen 400mg
(18, 1, 300, '2028-06-30'),  -- Cetirizine 10mg
(20, 1, 200, '2026-06-30'),  -- Multivitamin Dewasa
(21, 1, 300, '2027-06-30'),  -- Asam Mefenamat 500mg
(22, 1, 7000, '2027-01-04'),  -- Masker Medis 3-ply
(23, 1, 4000, '2027-01-04'),  -- Sarung Tangan Latex
(25, 1, 30, '2028-06-30'),  -- Alcohol Swab 70%
(27, 1, 100, '2028-06-30'),  -- Jarum Suntik 3ml
(28, 1, 200, '2028-06-30'),  -- Plester Luka Waterproof
(29, 1, 100, '2028-06-30'),  -- Kasa Steril 16x16cm
(30, 1, 40, '2027-06-30'),  -- Underpad 60x90cm
(32, 1, 200, '2028-06-30'),  -- Infus Set Dewasa
(33, 1, 200, '2028-01-31'),  -- Alkohol 70% 1 Liter
(34, 1, 200, '2027-06-30'),  -- Povidone Iodine 60ml
(36, 1, 50, '2028-06-30'),  -- Jarum Suntik 1ml
(37, 1, 300, '2026-12-31'),  -- Strip Tes Gula Darah
(38, 1, 30, '2025-12-31'),  -- Reagen Glukosa
(40, 1, 20, '2025-12-31'),  -- Reagen Asam Urat
(43, 1, 30, '2025-12-31'),  -- Reagen Hemoglobin
(44, 1, 40, '2025-12-31'),  -- Reagen Widal
(45, 1, 20, '2025-12-31');  -- Reagen Urin Lengkap

-- Gudang Surabaya (id=2)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(1, 2, 20, NULL),  -- Termometer Digital Infrared
(3, 2, 20, NULL),  -- Tensimeter Digital Omron HEM-7120
(4, 2, 20, NULL),  -- Pulse Oximeter CONTEC CMS50DL
(5, 2, 15, NULL),  -- Nebulizer Omron NE-C801
(6, 2, 20, NULL),  -- Timbangan Digital Camry BR9012
(7, 2, 20, NULL),  -- Glukometer Accu-Chek Active
(10, 2, 1000, '2026-06-30'),  -- Paracetamol 500mg
(11, 2, 3500, '2026-03-31'),  -- Amoxicillin 500mg
(12, 2, 300, '2026-06-30'),  -- Vitamin C 500mg
(13, 2, 300, '2026-01-31'),  -- Obat Batuk Sirup Woods
(15, 2, 30, '2027-06-30'),  -- Aspirin 80mg
(17, 2, 900, '2028-06-30'),  -- Ibuprofen 400mg
(18, 2, 300, '2028-06-30'),  -- Cetirizine 10mg
(20, 2, 150, '2026-06-30'),  -- Multivitamin Dewasa
(21, 2, 250, '2027-06-30'),  -- Asam Mefenamat 500mg
(22, 2, 3500, '2027-01-04'),  -- Masker Medis 3-ply
(23, 2, 2500, '2027-01-04'),  -- Sarung Tangan Latex
(26, 2, 20, '2028-06-30'),  -- Perban Elastis
(27, 2, 40, '2028-06-30'),  -- Jarum Suntik 3ml
(28, 2, 100, '2028-06-30'),  -- Plester Luka Waterproof
(29, 2, 10, '2028-06-30'),  -- Kasa Steril 16x16cm
(31, 2, 50, '2028-06-30'),  -- Kateter Urin Folley
(32, 2, 150, '2028-06-30'),  -- Infus Set Dewasa
(34, 2, 60, '2027-06-30'),  -- Povidone Iodine 60ml
(35, 2, 40, '2026-06-30'),  -- Hand Sanitizer 500ml
(36, 2, 80, '2028-06-30'),  -- Jarum Suntik 1ml
(38, 2, 200, '2025-12-31'),  -- Reagen Glukosa
(42, 2, 30, '2025-06-30'),  -- Reagen HCG
(45, 2, 30, '2025-12-31');  -- Reagen Urin Lengkap

-- Gudang Bandung (id=3)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(1, 3, 20, NULL),  -- Termometer Digital Infrared
(2, 3, 12, NULL),  -- Stetoskop Littmann Classic III
(4, 3, 20, NULL),  -- Pulse Oximeter CONTEC CMS50DL
(8, 3, 20, NULL),  -- Kursi Roda Standar GEA FS809
(9, 3, 20, NULL),  -- Tongkat Ketiak Adjustable
(10, 3, 1500, '2026-06-30'),  -- Paracetamol 500mg
(11, 3, 700, '2026-03-31'),  -- Amoxicillin 500mg
(12, 3, 300, '2026-06-30'),  -- Vitamin C 500mg
(16, 3, 20, '2026-06-30'),  -- Antasida Sirup 60ml
(18, 3, 400, '2028-06-30'),  -- Cetirizine 10mg
(19, 3, 30, '2027-06-30'),  -- Omeprazole 20mg
(20, 3, 100, '2026-06-30'),  -- Multivitamin Dewasa
(24, 3, 20, '2028-06-30'),  -- Kapas Steril 25gr
(27, 3, 20, '2028-06-30'),  -- Jarum Suntik 3ml
(35, 3, 200, '2026-06-30'),  -- Hand Sanitizer 500ml
(36, 3, 30, '2028-06-30'),  -- Jarum Suntik 1ml
(38, 3, 20, '2025-12-31'),  -- Reagen Glukosa
(39, 3, 20, '2025-12-31'),  -- Reagen Kolesterol
(41, 3, 20, '2025-12-31'),  -- Reagen Golongan Darah
(42, 3, 20, '2025-06-30');  -- Reagen HCG

-- Gudang Medan (id=4)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(10, 4, 1500, '2026-06-30'),  -- Paracetamol 500mg
(11, 4, 300, '2026-03-31'),  -- Amoxicillin 500mg
(18, 4, 200, '2028-06-30'),  -- Cetirizine 10mg
(22, 4, 2000, '2027-01-04'),  -- Masker Medis 3-ply
(23, 4, 800, '2027-01-04'),  -- Sarung Tangan Latex
(28, 4, 300, '2028-06-30'),  -- Plester Luka Waterproof
(29, 4, 120, '2028-06-30'),  -- Kasa Steril 16x16cm
(32, 4, 150, '2028-06-30'),  -- Infus Set Dewasa
(33, 4, 150, '2028-01-31'),  -- Alkohol 70% 1 Liter
(35, 4, 250, '2026-06-30');  -- Hand Sanitizer 500ml

-- Gudang Makassar (id=5)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(10, 5, 1500, '2026-06-30'),  -- Paracetamol 500mg
(11, 5, 1000, '2026-03-31'),  -- Amoxicillin 500mg
(17, 5, 500, '2028-06-30'),  -- Ibuprofen 400mg
(18, 5, 300, '2028-06-30'),  -- Cetirizine 10mg
(22, 5, 1800, '2027-01-04'),  -- Masker Medis 3-ply
(23, 5, 1500, '2027-01-04'),  -- Sarung Tangan Latex
(28, 5, 1500, '2028-06-30'),  -- Plester Luka Waterproof
(38, 5, 20, '2025-12-31'),  -- Reagen Glukosa
(40, 5, 18, '2025-12-31'),  -- Reagen Asam Urat
(42, 5, 10, '2025-06-30');  -- Reagen HCG

-- Gudang Palembang (id=7)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
(10, 7, 1000, '2026-06-30'),  -- Paracetamol 500mg
(12, 7, 200, '2026-06-30'),  -- Vitamin C 500mg
(17, 7, 300, '2028-06-30'),  -- Ibuprofen 400mg
(21, 7, 400, '2027-06-30'),  -- Asam Mefenamat 500mg
(22, 7, 1200, '2027-01-04'),  -- Masker Medis 3-ply
(23, 7, 800, '2027-01-04'),  -- Sarung Tangan Latex
(34, 7, 120, '2027-06-30'),  -- Povidone Iodine 60ml
(35, 7, 180, '2026-06-30'),  -- Hand Sanitizer 500ml
(11, 7,  900, '2026-03-31'),  -- Amoxicillin 500mg
(33, 7,  200, '2028-01-31');  -- Alkohol 70% 1 Liter

-- ============================================================================
-- 2. RESTOCK TRANSACTIONS - JANUARI 2024
--    Mencatat pengadaan awal sebagai log historis transaksi
-- ============================================================================

-- Restock awal Gudang Jakarta - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(1, 1, 20, '2024-01-10', 'ALTTERM0012401JKT001', NULL, 4),  -- Termometer Digital Infrared
(3, 1, 20, '2024-01-10', 'ALTTENS0012401JKT001', NULL, 4),  -- Tensimeter Digital Omron HEM-7120
(4, 1, 20, '2024-01-10', 'ALTOXIM0012401JKT001', NULL, 4),  -- Pulse Oximeter CONTEC CMS50DL
(5, 1, 20, '2024-01-10', 'ALTNEBU0012401JKT001', NULL, 4),  -- Nebulizer Omron NE-C801
(6, 1, 20, '2024-01-10', 'ALTTIMB0012401JKT001', NULL, 4),  -- Timbangan Digital Camry BR9012
(7, 1, 30, '2024-01-10', 'ALTGLUK0012401JKT001', NULL, 4),  -- Glukometer Accu-Chek Active
(8, 1, 15, '2024-01-10', 'ALTKURS0012401JKT001', NULL, 4),  -- Kursi Roda Standar GEA FS809
(10, 1, 2500, '2024-01-10', 'OBTPARA5002401JKT001', '2026-06-30', 4),  -- Paracetamol 500mg
(11, 1, 500, '2024-01-10', 'OBTAMOX5002401JKT001', '2026-03-31', 4),  -- Amoxicillin 500mg
(12, 1, 700, '2024-01-10', 'OBTVITC5002401JKT001', '2026-06-30', 4),  -- Vitamin C 500mg
(14, 1, 20, '2024-01-10', 'OBTLORA0102401JKT001', '2027-06-30', 4),  -- Loratadine 10mg
(17, 1, 900, '2024-01-10', 'OBTIBUP4002401JKT001', '2028-06-30', 4),  -- Ibuprofen 400mg
(18, 1, 300, '2024-01-10', 'OBTCETI0102401JKT001', '2028-06-30', 4),  -- Cetirizine 10mg
(20, 1, 200, '2024-01-10', 'OBTMULT0012401JKT001', '2026-06-30', 4),  -- Multivitamin Dewasa
(21, 1, 300, '2024-01-10', 'OBTASAM5002401JKT001', '2027-06-30', 4),  -- Asam Mefenamat 500mg
(22, 1, 7000, '2024-01-10', 'BHPMASK0012401JKT001', '2027-01-04', 4),  -- Masker Medis 3-ply
(23, 1, 4000, '2024-01-10', 'BHPGLOV0012401JKT001', '2027-01-04', 4),  -- Sarung Tangan Latex
(25, 1, 30, '2024-01-10', 'BHPALKO0012401JKT001', '2028-06-30', 4),  -- Alcohol Swab 70%
(27, 1, 100, '2024-01-10', 'BHPJARU0032401JKT001', '2028-06-30', 4),  -- Jarum Suntik 3ml
(28, 1, 200, '2024-01-10', 'BHPPLES0012401JKT001', '2028-06-30', 4),  -- Plester Luka Waterproof
(29, 1, 100, '2024-01-10', 'BHPKASA0012401JKT001', '2028-06-30', 4),  -- Kasa Steril 16x16cm
(30, 1, 40, '2024-01-10', 'BHPUNDE0012401JKT001', '2027-06-30', 4),  -- Underpad 60x90cm
(32, 1, 200, '2024-01-10', 'BHPINFU0012401JKT001', '2028-06-30', 4),  -- Infus Set Dewasa
(33, 1, 200, '2024-01-10', 'BHPALKO0702401JKT001', '2028-01-31', 4),  -- Alkohol 70% 1 Liter
(34, 1, 200, '2024-01-10', 'BHPPOVI0012401JKT001', '2027-06-30', 4),  -- Povidone Iodine 60ml
(36, 1, 50, '2024-01-10', 'BHPJARU0012401JKT001', '2028-06-30', 4),  -- Jarum Suntik 1ml
(37, 1, 300, '2024-01-10', 'BHPSTRIP0012401JKT001', '2026-12-31', 4),  -- Strip Tes Gula Darah
(38, 1, 30, '2024-01-10', 'RGNGLUK0012401JKT001', '2025-12-31', 4),  -- Reagen Glukosa
(40, 1, 20, '2024-01-10', 'RGNURAT0012401JKT001', '2025-12-31', 4),  -- Reagen Asam Urat
(43, 1, 30, '2024-01-10', 'RGNHEMO0012401JKT001', '2025-12-31', 4),  -- Reagen Hemoglobin
(44, 1, 40, '2024-01-10', 'RGNWIDA0012401JKT001', '2025-12-31', 4),  -- Reagen Widal
(45, 1, 20, '2024-01-10', 'RGNURIN0012401JKT001', '2025-12-31', 4);  -- Reagen Urin Lengkap

-- Restock awal Gudang Surabaya - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(1, 2, 20, '2024-01-10', 'ALTTERM0012401SBY001', NULL, 5),  -- Termometer Digital Infrared
(3, 2, 20, '2024-01-10', 'ALTTENS0012401SBY001', NULL, 5),  -- Tensimeter Digital Omron HEM-7120
(4, 2, 20, '2024-01-10', 'ALTOXIM0012401SBY001', NULL, 5),  -- Pulse Oximeter CONTEC CMS50DL
(5, 2, 15, '2024-01-10', 'ALTNEBU0012401SBY001', NULL, 5),  -- Nebulizer Omron NE-C801
(6, 2, 20, '2024-01-10', 'ALTTIMB0012401SBY001', NULL, 5),  -- Timbangan Digital Camry BR9012
(7, 2, 20, '2024-01-10', 'ALTGLUK0012401SBY001', NULL, 5),  -- Glukometer Accu-Chek Active
(10, 2, 1000, '2024-01-10', 'OBTPARA5002401SBY001', '2026-06-30', 5),  -- Paracetamol 500mg
(11, 2, 3500, '2024-01-10', 'OBTAMOX5002401SBY001', '2026-03-31', 5),  -- Amoxicillin 500mg
(12, 2, 300, '2024-01-10', 'OBTVITC5002401SBY001', '2026-06-30', 5),  -- Vitamin C 500mg
(13, 2, 300, '2024-01-10', 'OBTOBAT0012401SBY001', '2026-01-31', 5),  -- Obat Batuk Sirup Woods
(15, 2, 30, '2024-01-10', 'OBTASPI0802401SBY001', '2027-06-30', 5),  -- Aspirin 80mg
(17, 2, 900, '2024-01-10', 'OBTIBUP4002401SBY001', '2028-06-30', 5),  -- Ibuprofen 400mg
(18, 2, 300, '2024-01-10', 'OBTCETI0102401SBY001', '2028-06-30', 5),  -- Cetirizine 10mg
(20, 2, 150, '2024-01-10', 'OBTMULT0012401SBY001', '2026-06-30', 5),  -- Multivitamin Dewasa
(21, 2, 250, '2024-01-10', 'OBTASAM5002401SBY001', '2027-06-30', 5),  -- Asam Mefenamat 500mg
(22, 2, 3500, '2024-01-10', 'BHPMASK0012401SBY001', '2027-01-04', 5),  -- Masker Medis 3-ply
(23, 2, 2500, '2024-01-10', 'BHPGLOV0012401SBY001', '2027-01-04', 5),  -- Sarung Tangan Latex
(26, 2, 20, '2024-01-10', 'BHPPERB0012401SBY001', '2028-06-30', 5),  -- Perban Elastis
(27, 2, 40, '2024-01-10', 'BHPJARU0032401SBY001', '2028-06-30', 5),  -- Jarum Suntik 3ml
(28, 2, 100, '2024-01-10', 'BHPPLES0012401SBY001', '2028-06-30', 5),  -- Plester Luka Waterproof
(29, 2, 10, '2024-01-10', 'BHPKASA0012401SBY001', '2028-06-30', 5),  -- Kasa Steril 16x16cm
(31, 2, 50, '2024-01-10', 'BHPKATE0012401SBY001', '2028-06-30', 5),  -- Kateter Urin Folley
(32, 2, 150, '2024-01-10', 'BHPINFU0012401SBY001', '2028-06-30', 5),  -- Infus Set Dewasa
(34, 2, 60, '2024-01-10', 'BHPPOVI0012401SBY001', '2027-06-30', 5),  -- Povidone Iodine 60ml
(35, 2, 40, '2024-01-10', 'BHPHAND0012401SBY001', '2026-06-30', 5),  -- Hand Sanitizer 500ml
(36, 2, 80, '2024-01-10', 'BHPJARU0012401SBY001', '2028-06-30', 5),  -- Jarum Suntik 1ml
(38, 2, 200, '2024-01-10', 'RGNGLUK0012401SBY001', '2025-12-31', 5),  -- Reagen Glukosa
(42, 2, 30, '2024-01-10', 'RGNHCG0012401SBY001', '2025-06-30', 5),  -- Reagen HCG
(45, 2, 30, '2024-01-10', 'RGNURIN0012401SBY001', '2025-12-31', 5);  -- Reagen Urin Lengkap

-- Restock awal Gudang Bandung - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(1, 3, 20, '2024-01-10', 'ALTTERM0012401BDG001', NULL, 6),  -- Termometer Digital Infrared
(2, 3, 12, '2024-01-10', 'ALTSTET0012401BDG001', NULL, 6),  -- Stetoskop Littmann Classic III
(4, 3, 20, '2024-01-10', 'ALTOXIM0012401BDG001', NULL, 6),  -- Pulse Oximeter CONTEC CMS50DL
(8, 3, 20, '2024-01-10', 'ALTKURS0012401BDG001', NULL, 6),  -- Kursi Roda Standar GEA FS809
(9, 3, 20, '2024-01-10', 'ALTTONG0012401BDG001', NULL, 6),  -- Tongkat Ketiak Adjustable
(10, 3, 1500, '2024-01-10', 'OBTPARA5002401BDG001', '2026-06-30', 6),  -- Paracetamol 500mg
(11, 3, 700, '2024-01-10', 'OBTAMOX5002401BDG001', '2026-03-31', 6),  -- Amoxicillin 500mg
(12, 3, 300, '2024-01-10', 'OBTVITC5002401BDG001', '2026-06-30', 6),  -- Vitamin C 500mg
(16, 3, 20, '2024-01-10', 'OBTANTA0012401BDG001', '2026-06-30', 6),  -- Antasida Sirup 60ml
(18, 3, 400, '2024-01-10', 'OBTCETI0102401BDG001', '2028-06-30', 6),  -- Cetirizine 10mg
(19, 3, 30, '2024-01-10', 'OBTOMEP0202401BDG001', '2027-06-30', 6),  -- Omeprazole 20mg
(20, 3, 100, '2024-01-10', 'OBTMULT0012401BDG001', '2026-06-30', 6),  -- Multivitamin Dewasa
(24, 3, 20, '2024-01-10', 'BHPKAPA0012401BDG001', '2028-06-30', 6),  -- Kapas Steril 25gr
(27, 3, 20, '2024-01-10', 'BHPJARU0032401BDG001', '2028-06-30', 6),  -- Jarum Suntik 3ml
(35, 3, 200, '2024-01-10', 'BHPHAND0012401BDG001', '2026-06-30', 6),  -- Hand Sanitizer 500ml
(36, 3, 30, '2024-01-10', 'BHPJARU0012401BDG001', '2028-06-30', 6),  -- Jarum Suntik 1ml
(38, 3, 20, '2024-01-10', 'RGNGLUK0012401BDG001', '2025-12-31', 6),  -- Reagen Glukosa
(39, 3, 20, '2024-01-10', 'RGNKOLE0012401BDG001', '2025-12-31', 6),  -- Reagen Kolesterol
(41, 3, 20, '2024-01-10', 'RGNDARAH0012401BDG001', '2025-12-31', 6),  -- Reagen Golongan Darah
(42, 3, 20, '2024-01-10', 'RGNHCG0012401BDG001', '2025-06-30', 6);  -- Reagen HCG

-- Restock awal Gudang Medan - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(10, 4, 1500, '2024-01-10', 'OBTPARA5002401MDN001', '2026-06-30', 7),  -- Paracetamol 500mg
(11, 4, 300, '2024-01-10', 'OBTAMOX5002401MDN001', '2026-03-31', 7),  -- Amoxicillin 500mg
(18, 4, 200, '2024-01-10', 'OBTCETI0102401MDN001', '2028-06-30', 7),  -- Cetirizine 10mg
(22, 4, 2000, '2024-01-10', 'BHPMASK0012401MDN001', '2027-01-04', 7),  -- Masker Medis 3-ply
(23, 4, 800, '2024-01-10', 'BHPGLOV0012401MDN001', '2027-01-04', 7),  -- Sarung Tangan Latex
(28, 4, 300, '2024-01-10', 'BHPPLES0012401MDN001', '2028-06-30', 7),  -- Plester Luka Waterproof
(29, 4, 120, '2024-01-10', 'BHPKASA0012401MDN001', '2028-06-30', 7),  -- Kasa Steril 16x16cm
(32, 4, 150, '2024-01-10', 'BHPINFU0012401MDN001', '2028-06-30', 7),  -- Infus Set Dewasa
(33, 4, 150, '2024-01-10', 'BHPALKO0702401MDN001', '2028-01-31', 7),  -- Alkohol 70% 1 Liter
(35, 4, 250, '2024-01-10', 'BHPHAND0012401MDN001', '2026-06-30', 7);  -- Hand Sanitizer 500ml

-- Restock awal Gudang Makassar - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(10, 5, 1500, '2024-01-10', 'OBTPARA5002401MKS001', '2026-06-30', 8),  -- Paracetamol 500mg
(11, 5, 1000, '2024-01-10', 'OBTAMOX5002401MKS001', '2026-03-31', 8),  -- Amoxicillin 500mg
(17, 5, 500, '2024-01-10', 'OBTIBUP4002401MKS001', '2028-06-30', 8),  -- Ibuprofen 400mg
(18, 5, 300, '2024-01-10', 'OBTCETI0102401MKS001', '2028-06-30', 8),  -- Cetirizine 10mg
(22, 5, 1800, '2024-01-10', 'BHPMASK0012401MKS001', '2027-01-04', 8),  -- Masker Medis 3-ply
(23, 5, 1500, '2024-01-10', 'BHPGLOV0012401MKS001', '2027-01-04', 8),  -- Sarung Tangan Latex
(28, 5, 1500, '2024-01-10', 'BHPPLES0012401MKS001', '2028-06-30', 8),  -- Plester Luka Waterproof
(38, 5, 20, '2024-01-10', 'RGNGLUK0012401MKS001', '2025-12-31', 8),  -- Reagen Glukosa
(40, 5, 18, '2024-01-10', 'RGNURAT0012401MKS001', '2025-12-31', 8),  -- Reagen Asam Urat
(42, 5, 10, '2024-01-10', 'RGNHCG0012401MKS001', '2025-06-30', 8);  -- Reagen HCG

-- Restock awal Gudang Palembang - Januari 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(10, 7, 800, '2024-01-10', 'OBTPARA5002401PLG001', '2026-06-30', 4),  -- Paracetamol 500mg
(12, 7, 200, '2024-01-10', 'OBTVITC5002401PLG001', '2026-06-30', 4),  -- Vitamin C 500mg
(17, 7, 300, '2024-01-10', 'OBTIBUP4002401PLG001', '2028-06-30', 4),  -- Ibuprofen 400mg
(21, 7, 400, '2024-01-10', 'OBTASAM5002401PLG001', '2027-06-30', 4),  -- Asam Mefenamat 500mg
(22, 7, 1200, '2024-01-10', 'BHPMASK0012401PLG001', '2027-01-04', 4),  -- Masker Medis 3-ply
(23, 7, 800, '2024-01-10', 'BHPGLOV0012401PLG001', '2027-01-04', 4),  -- Sarung Tangan Latex
(34, 7, 120, '2024-01-10', 'BHPPOVI0012401PLG001', '2027-06-30', 4),  -- Povidone Iodine 60ml
(35, 7, 180, '2024-01-10', 'BHPHAND0012401PLG001', '2026-06-30', 4),  -- Hand Sanitizer 500ml
(11, 7,  900, '2024-01-10', 'OBTAMOX5002401PLG001', '2026-03-31', 4),  -- Amoxicillin 500mg
(33, 7,  200, '2024-01-10', 'BHPALKO0702401PLG001', '2028-01-31', 4);  -- Alkohol 70% 1 Liter

-- ============================================================================
-- 3. RESTOCK TAMBAHAN - Q2 2024 (April-Mei)
-- ============================================================================

INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(22, 1, 4000, '2024-04-02', 'BHPMASK0012404JKT001', '2027-04-01', 4),  -- Masker Medis 3-ply -> Gudang Jakarta
(23, 1, 2500, '2024-04-05', 'BHPGLOV0012404JKT001', '2027-04-04', 4),  -- Sarung Tangan Latex -> Gudang Jakarta
(27, 1, 100, '2024-04-10', 'BHPJARU0032404JKT001', '2028-04-09', 4),  -- Jarum Suntik 3ml -> Gudang Jakarta
(36, 2, 80, '2024-04-12', 'BHPJARU0012404SBY001', '2028-04-11', 5),  -- Jarum Suntik 1ml -> Gudang Surabaya
(10, 2, 1200, '2024-04-15', 'OBTPARA5002404SBY001', '2026-04-15', 5),  -- Paracetamol 500mg -> Gudang Surabaya
(2, 3, 12, '2024-05-01', 'ALTSTET0012405BDG001', NULL, 6),  -- Stetoskop Littmann Classic III -> Gudang Bandung
(4, 3, 20, '2024-05-01', 'ALTOXIM0012405BDG001', NULL, 6);  -- Pulse Oximeter CONTEC CMS50DL -> Gudang Bandung

-- ============================================================================
-- VERIFIKASI
-- ============================================================================

SELECT
    g.nama_gudang,
    COUNT(DISTINCT bs.barang_id) AS jenis_barang,
    SUM(bs.jumlah)               AS total_unit_stok
FROM batch_stok bs
JOIN gudang g ON bs.gudang_id = g.gudang_id
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY g.gudang_id;

SELECT 'batch_stok', COUNT(*) FROM batch_stok
UNION ALL SELECT 'restock',    COUNT(*) FROM restock;