-- ============================================================================
-- INVENTORY KESEHATAN - SCHEMA CLEANUP v2.1
-- Untuk digunakan sebelum menjalankan mysql_setup_v1_2_FIXED.sql
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Hapus VIEW dulu
DROP VIEW IF EXISTS v_stok_per_gudang;
DROP VIEW IF EXISTS v_total_stok;
DROP VIEW IF EXISTS v_penjualan_lengkap;
DROP VIEW IF EXISTS v_restock_lengkap;
DROP VIEW IF EXISTS v_transfer_lengkap;

-- Hapus tabel transaksi
DROP TABLE IF EXISTS penjualan;
DROP TABLE IF EXISTS transfer;
DROP TABLE IF EXISTS restock;
DROP TABLE IF EXISTS batch_stok;
DROP TABLE IF EXISTS stok;         -- tabel lama, dihapus di v1.2

-- Hapus tabel master
DROP TABLE IF EXISTS barang;
DROP TABLE IF EXISTS kategori_barang;
DROP TABLE IF EXISTS gudang;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

SHOW TABLES;
SELECT 'Cleanup selesai. Siap jalankan mysql_setup_v1_2_FIXED.sql' AS Status;
