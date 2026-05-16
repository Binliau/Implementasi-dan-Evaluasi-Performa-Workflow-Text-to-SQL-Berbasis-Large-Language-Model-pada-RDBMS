-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - SCHEMA CLEANUP
-- Version: 2.0
-- Description: Complete cleanup script to remove all tables and database
-- ============================================================================

-- Disable foreign key checks temporarily for easier cleanup
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- DROP TABLES (IN REVERSE DEPENDENCY ORDER)
-- ============================================================================

-- Drop transaction tables first (they have foreign keys to master data)
DROP TABLE IF EXISTS penjualan;
DROP TABLE IF EXISTS transfer;
DROP TABLE IF EXISTS restock;
DROP TABLE IF EXISTS batch_stok;
DROP TABLE IF EXISTS stok;

-- Drop master data tables (they have foreign keys to reference tables)
DROP TABLE IF EXISTS barang;

-- Drop reference/lookup tables (they are referenced by other tables)
DROP TABLE IF EXISTS kategori_barang;
DROP TABLE IF EXISTS gudang;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- DROP DATABASE
-- ============================================================================

-- Drop the entire database (uncomment if you want to completely remove the database)
-- DROP DATABASE IF EXISTS inventory_kesehatan;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show remaining tables (should be empty if cleanup was successful)
SHOW TABLES;

-- Display completion message
SELECT 'Schema cleanup completed successfully!' AS Status;

-- ============================================================================
-- NOTES
-- ============================================================================
-- This script will:
-- 1. Remove all tables in the correct order to avoid foreign key constraint errors
-- 2. Optionally remove the entire database (if uncommented)
-- 3. Verify that cleanup was successful
--
-- To use this script:
-- 1. Execute this script to clean up existing schema
-- 2. Run mysql_setup_v1.1.sql to recreate the schema
-- 3. Run 2_master_data.sql to populate master data
-- 4. Continue with other data files as needed
-- ============================================================================
