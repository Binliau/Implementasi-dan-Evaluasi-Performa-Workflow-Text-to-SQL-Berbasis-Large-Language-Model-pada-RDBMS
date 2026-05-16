-- ============================================================================
-- MASTER EXECUTION SCRIPT - COMPLETE DATABASE SETUP (FIXED VERSION)
-- ============================================================================
-- This script loads ALL data files in the correct order
-- USE THIS VERSION - It references the FIXED SQL files that match your schema
-- ============================================================================

-- Note: You cannot run this directly with SOURCE in MySQL
-- Use this as a reference for the correct order to run files

-- ============================================================================
-- STEP 1: CLEANUP
-- ============================================================================
SOURCE 1_schema_cleanup.sql;

-- ============================================================================
-- STEP 2: CREATE SCHEMA
-- ============================================================================
SOURCE mysql_setup_v1.1.sql;

-- ============================================================================
-- STEP 3: LOAD MASTER DATA
-- ============================================================================
SOURCE 2_master_data.sql;
-- Expected: 7 roles, 24 users, 7 gudang, 7 kategori_barang, 45 barang

-- ============================================================================
-- STEP 4: LOAD INITIAL STOCK (FIXED VERSION)
-- ============================================================================
SOURCE 3_initial_stock_FIXED.sql;
-- Expected: ~40+ batch_stok records, ~40+ restock records

-- ============================================================================
-- STEP 5: LOAD TRANSFER DATA (FIXED VERSION)
-- ============================================================================
SOURCE 4_transfer_data_FIXED.sql;
-- Expected: ~60+ transfer records

-- ============================================================================
-- STEP 6: LOAD SALES DATA PART 1 (FIXED VERSION)
-- ============================================================================
SOURCE 5_sales_data_part1_FIXED.sql;
-- Expected: 69 sales records

-- ============================================================================
-- STEP 7: LOAD SALES DATA PART 2 (FIXED VERSION)
-- ============================================================================
SOURCE 5_sales_data_part2_FIXED.sql;
-- Expected: Additional sales records

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

USE inventory_kesehatan;

-- Count all records in all tables
SELECT 'roles' as table_name, COUNT(*) as record_count FROM roles
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'gudang', COUNT(*) FROM gudang
UNION ALL SELECT 'kategori_barang', COUNT(*) FROM kategori_barang
UNION ALL SELECT 'barang', COUNT(*) FROM barang
UNION ALL SELECT 'batch_stok', COUNT(*) FROM batch_stok
UNION ALL SELECT 'restock', COUNT(*) FROM restock
UNION ALL SELECT 'transfer', COUNT(*) FROM transfer
UNION ALL SELECT 'penjualan', COUNT(*) FROM penjualan;

-- Check latest transactions
SELECT 'Latest Sales' as type, MAX(tanggal) as last_date FROM penjualan
UNION ALL SELECT 'Latest Transfer', MAX(tanggal) FROM transfer
UNION ALL SELECT 'Latest Restock', MAX(tanggal) FROM restock;

-- Check stock levels per warehouse
SELECT 
    g.nama_gudang,
    COUNT(DISTINCT bs.barang_id) as unique_items,
    SUM(bs.jumlah) as total_quantity
FROM batch_stok bs
JOIN gudang g ON bs.gudang_id = g.id
GROUP BY g.id, g.nama_gudang
ORDER BY g.id;

SELECT '✅ Database setup complete!' as status;
