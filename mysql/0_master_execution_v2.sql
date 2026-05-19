-- ============================================================================
-- MASTER EXECUTION SCRIPT v2.1 - TEXT-TO-SQL OPTIMIZED
-- ============================================================================
-- Jalankan file-file ini secara berurutan di MySQL client:
--   mysql -u root -p < 0_master_execution_v2.sql
-- ATAU jalankan satu per satu via SOURCE di MySQL shell
-- ============================================================================

-- STEP 1: Bersihkan schema lama (drop semua tabel & view)
SOURCE 1_schema_cleanup_v2.sql;

-- STEP 2: Buat schema baru v1.2
--   - Kolom 'aktif' pada barang dan gudang (soft delete)
--   - Semua tabel punya COMMENT kolom yang lengkap
--   - Tabel 'stok' dihapus, digantikan sepenuhnya oleh batch_stok
--   - 5 VIEW: v_stok_per_gudang, v_total_stok, v_penjualan_lengkap,
--             v_restock_lengkap, v_transfer_lengkap
SOURCE mysql_setup_v1_2_FIXED.sql;

-- STEP 3: Master data v2.1
--   - roles, kategori_barang, gudang (+ kolom aktif, gudang Denpasar nonaktif)
--   - users (+ kolom aktif, viewer.management nonaktif)
--   - barang (+ kolom aktif, 1 barang diskontinyu sebagai contoh soft delete)
--   Expected: 7 roles | 24 users (23 aktif) | 7 gudang (6 aktif) | 7 kategori | 46 barang (45 aktif)
SOURCE 2_master_data_v2_1.sql;

-- STEP 4: Stok awal & restock Q1-Q2 2024 (gudang 1-5, tidak termasuk gudang 7)
--   Expected: ~69 batch_stok | ~38 restock
SOURCE 3_initial_stock_v2.sql;

-- STEP 5: Transfer antar gudang Jan 2024 - Feb 2025 (gudang 1-5)
--   Expected: ~54 transfer
SOURCE 4_transfer_data_FIXED.sql;

-- STEP 6: Penjualan Jan - Feb 2024 (69 transaksi)
SOURCE 5_sales_data_part1_FIXED.sql;

-- STEP 7: Penjualan Mar - Mei 2024 (40 transaksi)
SOURCE 5_sales_data_part2_FIXED.sql;

-- STEP 8: Data tambahan v2.0
--   - Transfer melibatkan Gudang Palembang (11 transaksi)
--   - Penjualan barang yang belum pernah terjual (33 transaksi)
--   - Penjualan Jun 2024 - Feb 2025 semua gudang (98 transaksi)
--   CATATAN: batch_stok + restock sudah semuanya ada di 3_initial_stock_v2.sql
SOURCE 6_data_tambahan.sql;

-- ============================================================================
-- VERIFIKASI AKHIR
-- ============================================================================
USE inventory_kesehatan;

SELECT '=== REKAP JUMLAH DATA ===' AS info;

SELECT tabel, jumlah FROM (
    SELECT 'roles'             AS tabel, COUNT(*) AS jumlah FROM roles
    UNION ALL
    SELECT 'users (total)',               COUNT(*) FROM users
    UNION ALL
    SELECT 'users (aktif)',               COUNT(*) FROM users     WHERE aktif = TRUE
    UNION ALL
    SELECT 'gudang (total)',              COUNT(*) FROM gudang
    UNION ALL
    SELECT 'gudang (aktif)',              COUNT(*) FROM gudang    WHERE aktif = TRUE
    UNION ALL
    SELECT 'kategori_barang',            COUNT(*) FROM kategori_barang
    UNION ALL
    SELECT 'barang (total)',              COUNT(*) FROM barang
    UNION ALL
    SELECT 'barang (aktif)',              COUNT(*) FROM barang    WHERE aktif = TRUE
    UNION ALL
    SELECT 'batch_stok',                 COUNT(*) FROM batch_stok
    UNION ALL
    SELECT 'restock',                    COUNT(*) FROM restock
    UNION ALL
    SELECT 'transfer',                   COUNT(*) FROM transfer
    UNION ALL
    SELECT 'penjualan',                  COUNT(*) FROM penjualan
) rekap;

SELECT '=== CEK SEMUA GUDANG ADA TRANSAKSI ===' AS info;
SELECT g.gudang_id, g.nama_gudang, g.aktif,
       COUNT(DISTINCT p.penjualan_id) AS jml_penjualan,
       COUNT(DISTINCT r.restock_id) AS jml_restock,
       COUNT(DISTINCT t.transfer_id) AS jml_transfer_keluar
FROM gudang g
LEFT JOIN penjualan p ON g.gudang_id = p.gudang_id
LEFT JOIN restock   r ON g.gudang_id = r.gudang_id
LEFT JOIN transfer  t ON g.gudang_id = t.dari_gudang_id
GROUP BY g.gudang_id, g.nama_gudang, g.aktif
ORDER BY g.gudang_id;

SELECT '=== CEK BARANG AKTIF YANG BELUM PERNAH DIJUAL ===' AS info;
SELECT b.barang_id, b.nama_barang
FROM barang b
WHERE b.aktif = TRUE
  AND b.barang_id NOT IN (SELECT DISTINCT barang_id FROM penjualan);

SELECT '=== CEK COVERAGE TANGGAL PENJUALAN ===' AS info;
SELECT DATE_FORMAT(tanggal, '%Y-%m') AS bulan, COUNT(*) AS transaksi
FROM penjualan
GROUP BY DATE_FORMAT(tanggal, '%Y-%m')
ORDER BY bulan;

SELECT '=== CEK VIEW BERFUNGSI ===' AS info;
SELECT COUNT(*) AS v_stok_per_gudang     FROM v_stok_per_gudang;
SELECT COUNT(*) AS v_total_stok          FROM v_total_stok;
SELECT COUNT(*) AS v_penjualan_lengkap   FROM v_penjualan_lengkap;
SELECT COUNT(*) AS v_restock_lengkap     FROM v_restock_lengkap;
SELECT COUNT(*) AS v_transfer_lengkap    FROM v_transfer_lengkap;

SELECT '✅ Setup database Text-to-SQL selesai!' AS status;
