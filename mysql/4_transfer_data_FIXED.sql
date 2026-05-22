-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - TRANSFER TRANSACTIONS (FIXED)
-- Version: 3.0 - MATCHES mysql_setup_v1.1.sql SCHEMA
-- Description: Inter-warehouse transfer transactions (2024-2025)
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- SCHEMA REFERENCE:
-- transfer (id, barang_id, dari_gudang_id, ke_gudang_id, jumlah, tanggal, user_id)
-- ============================================================================

-- ============================================================================
-- TRANSFER TRANSACTIONS - OPTIMIZING DISTRIBUTION
-- ============================================================================

-- January 2024 - Redistribusi awal tahun
INSERT INTO transfer (barang_id, dari_gudang_id, ke_gudang_id, jumlah, tanggal, user_id) VALUES
(22, 1, 3, 500, '2024-01-20', 4),  -- Masker Jakarta -> Bandung
(23, 1, 4, 300, '2024-01-22', 4),  -- Sarung tangan Jakarta -> Medan
(22, 2, 5, 400, '2024-01-25', 5),  -- Masker Surabaya -> Makassar

-- February 2024 - Transfer untuk kebutuhan mendesak
(10, 1, 2, 200, '2024-02-01', 4),  -- Paracetamol Jakarta -> Surabaya
(11, 2, 3, 150, '2024-02-15', 5),  -- Amoxicillin Surabaya -> Bandung
(17, 5, 2, 80, '2024-02-20', 8),   -- Ibuprofen Makassar -> Surabaya

-- March 2024 - Penyesuaian stok regional
(33, 4, 1, 25, '2024-03-01', 7),   -- Alkohol Medan -> Jakarta
(35, 4, 3, 40, '2024-03-05', 7),   -- Hand sanitizer Medan -> Bandung
(38, 1, 2, 5, '2024-03-10', 4),    -- Reagen glukosa Jakarta -> Surabaya
(38, 1, 3, 5, '2024-03-11', 4),    -- Reagen glukosa Jakarta -> Bandung

-- April 2024 - Optimasi distribusi Q2
(42, 2, 5, 8, '2024-03-15', 5),    -- Tes kehamilan Surabaya -> Makassar
(8, 3, 1, 2, '2024-03-20', 6),     -- Kursi roda Bandung -> Jakarta
(22, 1, 4, 600, '2024-04-15', 4),  -- Masker Jakarta -> Medan
(23, 2, 5, 300, '2024-04-18', 5),  -- Sarung tangan Surabaya -> Makassar

-- May 2024 - Transfer maintenance dan support
(27, 1, 2, 15, '2024-04-25', 4),   -- Jarum suntik Jakarta -> Surabaya
(36, 2, 1, 10, '2024-04-28', 5),   -- Jarum insulin Surabaya -> Jakarta
(22, 1, 5, 400, '2024-05-05', 4),  -- Masker Jakarta -> Makassar
(23, 2, 4, 200, '2024-05-10', 5),  -- Sarung tangan Surabaya -> Medan

-- June 2024 - Transfer untuk kebutuhan musim
(10, 1, 3, 100, '2024-05-15', 4),  -- Paracetamol Jakarta -> Bandung
(11, 2, 1, 80, '2024-05-20', 5),   -- Amoxicillin Surabaya -> Jakarta
(12, 3, 4, 50, '2024-06-01', 6),   -- Vitamin C Bandung -> Medan
(35, 3, 2, 30, '2024-06-05', 6),   -- Hand sanitizer Bandung -> Surabaya

-- July 2024 - Transfer peak season  
(28, 5, 4, 50, '2024-06-10', 8),   -- Infus set Makassar -> Medan
(29, 4, 2, 40, '2024-06-15', 7),   -- Kasa steril Medan -> Surabaya
(22, 1, 2, 500, '2024-07-01', 4),  -- Masker Jakarta -> Surabaya
(23, 1, 3, 400, '2024-07-05', 4),  -- Sarung tangan Jakarta -> Bandung

-- August 2024 - Mid year redistribution
(10, 2, 5, 150, '2024-07-10', 5),  -- Paracetamol Surabaya -> Makassar
(17, 1, 4, 120, '2024-07-15', 4),  -- Ibuprofen Jakarta -> Medan
(18, 5, 3, 100, '2024-07-20', 8),  -- Cetirizine Makassar -> Bandung
(33, 1, 5, 30, '2024-08-01', 4),   -- Alkohol Jakarta -> Makassar

-- September 2024 - Seasonal transfer
(35, 2, 4, 50, '2024-08-05', 5),   -- Hand sanitizer Surabaya -> Medan
(22, 2, 3, 350, '2024-08-10', 5),  -- Masker Surabaya -> Bandung
(23, 5, 1, 250, '2024-08-15', 8),  -- Sarung tangan Makassar -> Jakarta
(12, 1, 2, 100, '2024-09-01', 4),  -- Vitamin C Jakarta -> Surabaya

-- October 2024 - Q4 preparation
(11, 1, 5, 120, '2024-09-05', 4),  -- Amoxicillin Jakarta -> Makassar
(13, 2, 4, 80, '2024-09-10', 5),   -- Obat batuk Surabaya -> Medan
(27, 2, 3, 20, '2024-09-15', 5),   -- Jarum suntik Surabaya -> Bandung
(36, 1, 4, 15, '2024-10-01', 4),   -- Jarum insulin Jakarta -> Medan

-- November 2024 - End of year distribution
(38, 2, 1, 8, '2024-10-05', 5),    -- Reagen glukosa Surabaya -> Jakarta
(40, 5, 2, 10, '2024-10-10', 8),   -- Reagen asam urat Makassar -> Surabaya
(42, 2, 3, 12, '2024-10-15', 5),   -- Tes kehamilan Surabaya -> Bandung
(22, 1, 5, 600, '2024-11-01', 4),  -- Masker Jakarta -> Makassar

-- December 2024 - Year-end optimization
(23, 2, 1, 350, '2024-11-05', 5),  -- Sarung tangan Surabaya -> Jakarta
(28, 1, 3, 45, '2024-11-10', 4),   -- Infus set Jakarta -> Bandung
(29, 2, 5, 35, '2024-11-15', 5),   -- Kasa steril Surabaya -> Makassar
(33, 4, 2, 40, '2024-12-01', 7),   -- Alkohol Medan -> Surabaya

-- January 2025 - New year redistribution
(35, 3, 1, 45, '2024-12-05', 6),   -- Hand sanitizer Bandung -> Jakarta
(10, 5, 3, 130, '2024-12-10', 8),  -- Paracetamol Makassar -> Bandung
(22, 2, 4, 450, '2025-01-05', 5),  -- Masker Surabaya -> Medan
(23, 1, 5, 380, '2025-01-10', 4),  -- Sarung tangan Jakarta -> Makassar

-- February 2025 - Continuing operations
(17, 2, 1, 90, '2025-01-15', 5),   -- Ibuprofen Surabaya -> Jakarta
(18, 3, 5, 75, '2025-01-20', 6),   -- Cetirizine Bandung -> Makassar
(11, 5, 4, 110, '2025-02-01', 8),  -- Amoxicillin Makassar -> Medan
(12, 2, 1, 95, '2025-02-05', 5);   -- Vitamin C Surabaya -> Jakarta

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================

-- Check transfer statistics by warehouse
SELECT 
    g1.nama_gudang as from_warehouse,
    g2.nama_gudang as to_warehouse,
    COUNT(*) as transfer_count,
    SUM(t.jumlah) as total_quantity
FROM transfer t
JOIN gudang g1 ON t.dari_gudang_id = g1.gudang_id
JOIN gudang g2 ON t.ke_gudang_id = g2.gudang_id
GROUP BY g1.gudang_id, g1.nama_gudang, g2.gudang_id, g2.nama_gudang
ORDER BY transfer_count DESC;

-- Monthly transfer summary
SELECT 
    DATE_FORMAT(tanggal, '%Y-%m') as month,
    COUNT(*) as transaction_count,
    SUM(jumlah) as total_items_transferred
FROM transfer
GROUP BY DATE_FORMAT(tanggal, '%Y-%m')
ORDER BY month;
