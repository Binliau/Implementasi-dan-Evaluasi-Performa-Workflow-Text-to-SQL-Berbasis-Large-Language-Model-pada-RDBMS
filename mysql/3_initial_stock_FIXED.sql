-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - INITIAL STOCK (FIXED)
-- Version: 3.0 - MATCHES mysql_setup_v1.1.sql SCHEMA
-- Description: Initial batch stock and restock transactions
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- SCHEMA REFERENCE:
-- batch_stok (id, barang_id, gudang_id, jumlah, tanggal_kadaluarsa)
-- restock (id, barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id)
-- ============================================================================

-- ============================================================================
-- 1. INITIAL BATCH STOCK - JANUARY 2024
-- ============================================================================

-- Gudang Jakarta (ID 1)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
-- Masker dan Sarung Tangan
(22, 1, 5000, '2027-01-04'),  -- Masker medis
(23, 1, 3000, '2027-01-04'),  -- Sarung tangan latex

-- Obat-obatan
(10, 1, 2000, '2026-01-05'),  -- Paracetamol
(11, 1, 1500, '2025-12-08'),  -- Amoxicillin
(12, 1, 800, '2026-06-10'),   -- Vitamin C

-- Alat medis (no expiry)
(1, 1, 50, NULL),   -- Termometer digital
(3, 1, 30, NULL),   -- Tensimeter digital
(7, 1, 45, NULL),   -- Glukometer

-- BHP
(33, 1, 200, '2028-01-31'),  -- Alkohol 70%
(35, 1, 150, '2026-01-14');  -- Hand sanitizer

-- Gudang Surabaya (ID 2)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
-- Masker dan Sarung Tangan
(22, 2, 3000, '2027-01-07'),
(23, 2, 2000, '2027-01-07'),

-- Obat-obatan
(10, 2, 1500, '2026-01-08'),  -- Paracetamol
(11, 2, 1000, '2025-12-09'),  -- Amoxicillin
(13, 2, 500, '2026-01-10'),   -- Obat batuk

-- Reagen lab
(38, 2, 25, '2024-12-15'),    -- Reagen glukosa
(42, 2, 30, '2025-01-15');    -- Tes kehamilan

-- Gudang Bandung (ID 3)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
-- Vitamin dan BHP
(12, 3, 600, '2026-01-14'),   -- Vitamin C
(35, 3, 200, '2026-01-14'),   -- Hand sanitizer

-- Alat kesehatan
(8, 3, 15, NULL),   -- Kursi roda
(9, 3, 25, NULL),   -- Tongkat ketiak
(2, 3, 12, NULL),   -- Stetoskop
(4, 3, 20, NULL);   -- Pulse oximeter

-- Gudang Medan (ID 4)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
-- Alkohol dan antiseptik
(33, 4, 150, '2028-01-31'),   -- Alkohol 70%
(35, 4, 250, '2027-01-31'),   -- Hand sanitizer

-- BHP medis
(29, 4, 120, '2028-02-04'),   -- Kasa steril
(28, 4, 300, '2028-02-04'),   -- Infus set

-- Masker & gloves
(22, 4, 800, '2027-02-01'),
(23, 4, 600, '2027-02-01');

-- Gudang Makassar (ID 5)
INSERT INTO batch_stok (barang_id, gudang_id, jumlah, tanggal_kadaluarsa) VALUES
-- Obat-obatan
(17, 5, 800, '2028-02-04'),   -- Ibuprofen
(18, 5, 600, '2028-02-04'),   -- Cetirizine
(10, 5, 1000, '2026-02-05'),  -- Paracetamol

-- Reagen
(38, 5, 20, '2024-11-10'),    -- Reagen glukosa
(40, 5, 18, '2024-11-10'),    -- Reagen asam urat

-- Masker & gloves
(22, 5, 1500, '2027-02-05'),
(23, 5, 1200, '2027-02-05');

-- ============================================================================
-- 2. RESTOCK TRANSACTIONS - Q1 2024
-- ============================================================================

-- Jakarta restock - January 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(22, 1, 5000, '2024-01-05', 'MASK2401JKT001', '2027-01-04', 4),
(23, 1, 3000, '2024-01-05', 'GLOVE2401JKT001', '2027-01-04', 4),
(10, 1, 2000, '2024-01-06', 'PARA2401JKT001', '2026-01-05', 4),
(11, 1, 1500, '2024-01-08', 'AMOX2401JKT001', '2025-12-08', 4),
(12, 1, 800, '2024-01-10', 'VITC2401JKT001', '2026-06-10', 4),
(1, 1, 50, '2024-01-12', 'TERM2401JKT001', NULL, 4),
(3, 1, 30, '2024-01-12', 'TENS2401JKT001', NULL, 4),
(7, 1, 45, '2024-01-15', 'GLUK2401JKT001', NULL, 4);

-- Surabaya restock - January 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(22, 2, 3000, '2024-01-08', 'MASK2401SBY001', '2027-01-07', 5),
(23, 2, 2000, '2024-01-08', 'GLOVE2401SBY001', '2027-01-07', 5),
(11, 2, 1000, '2024-01-09', 'AMOX2401SBY001', '2025-12-09', 5),
(13, 2, 500, '2024-01-10', 'OBAT2401SBY001', '2026-01-10', 5),
(38, 2, 25, '2024-01-15', 'GLUK2401SBY001', '2024-12-15', 5),
(42, 2, 30, '2024-01-15', 'HCG2401SBY001', '2025-01-15', 5);

-- Bandung restock - January 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(12, 3, 600, '2024-01-15', 'VITC2401BDG001', '2026-01-14', 6),
(35, 3, 200, '2024-01-15', 'HAND2401BDG001', '2026-01-14', 6),
(8, 3, 15, '2024-01-20', 'KURS2401BDG001', NULL, 6),
(9, 3, 25, '2024-01-20', 'TONG2401BDG001', NULL, 6);

-- Medan restock - February 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(33, 4, 150, '2024-02-01', 'ALKO2401MDN001', '2028-01-31', 7),
(35, 4, 250, '2024-02-01', 'HAND2401MDN001', '2027-01-31', 7),
(29, 4, 120, '2024-02-05', 'KASA2401MDN001', '2028-02-04', 7),
(28, 4, 300, '2024-02-05', 'INFU2401MDN001', '2028-02-04', 7);

-- Makassar restock - February 2024
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(17, 5, 800, '2024-02-05', 'IBUP2401MKS001', '2028-02-04', 8),
(18, 5, 600, '2024-02-05', 'CETI2401MKS001', '2028-02-04', 8),
(38, 5, 20, '2024-02-10', 'GLUK2401MKS001', '2024-11-10', 8),
(40, 5, 18, '2024-02-10', 'URAT2401MKS001', '2024-11-10', 8);

-- ============================================================================
-- 3. ADDITIONAL RESTOCK - Q2 2024
-- ============================================================================

-- Jakarta April restock
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(22, 1, 4000, '2024-04-02', 'MASK2404JKT001', '2027-04-01', 4),
(23, 1, 2500, '2024-04-05', 'GLOVE2404JKT001', '2027-04-04', 4),
(27, 1, 100, '2024-04-10', 'JARU2404JKT001', '2028-04-09', 4);

-- Surabaya April restock
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(36, 2, 80, '2024-04-12', 'JARU2404SBY001', '2028-04-11', 5),
(10, 2, 1200, '2024-04-15', 'PARA2404SBY001', '2026-04-15', 5);

-- Bandung May restock
INSERT INTO restock (barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id) VALUES
(2, 3, 12, '2024-05-01', 'STET2405BDG001', NULL, 6),
(4, 3, 20, '2024-05-01', 'OXIM2405BDG001', NULL, 6);

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================

-- Check batch stock totals
SELECT 
    g.nama_gudang,
    COUNT(*) as total_batches,
    SUM(bs.jumlah) as total_items
FROM batch_stok bs
JOIN gudang g ON bs.gudang_id = g.id
GROUP BY g.id, g.nama_gudang
ORDER BY g.id;

-- Check restock records
SELECT 
    'Restock Transactions' as type,
    g.nama_gudang,
    COUNT(*) as transaction_count,
    SUM(r.jumlah) as total_quantity
FROM restock r
JOIN gudang g ON r.gudang_id = g.id
GROUP BY g.id, g.nama_gudang
ORDER BY g.id;
