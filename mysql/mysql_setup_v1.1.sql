-- Membuat database inventory
CREATE DATABASE IF NOT EXISTS inventory_kesehatan
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE inventory_kesehatan;

-- Tabel: roles
-- Menyimpan daftar peran pengguna dalam sistem
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk tabel peran',
    nama_role VARCHAR(50) NOT NULL COMMENT 'Nama peran, misalnya admin, manajer gudang, staf',
    deskripsi TEXT COMMENT 'Penjelasan tentang hak akses dari peran ini'
) COMMENT='Daftar peran atau hak akses pengguna dalam sistem inventory';

-- Tabel: users
-- Menyimpan akun pengguna sistem
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk tabel pengguna',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Username login pengguna',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hash dari password pengguna',
    nama_lengkap VARCHAR(100) NOT NULL COMMENT 'Nama lengkap pengguna',
    role_id INT NOT NULL COMMENT 'Foreign key ke peran pengguna',
    aktif BOOLEAN DEFAULT TRUE COMMENT 'Status aktif atau non-aktif pengguna',
    dibuat_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu pembuatan akun',
    FOREIGN KEY (role_id) REFERENCES roles(id)
) COMMENT='Data akun pengguna sistem dan hak aksesnya';

-- Tabel: gudang
-- Menyimpan informasi lokasi gudang
CREATE TABLE IF NOT EXISTS gudang (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk gudang',
    nama_gudang VARCHAR(100) NOT NULL COMMENT 'Nama gudang atau lokasi',
    alamat TEXT COMMENT 'Alamat fisik gudang',
    keterangan TEXT COMMENT 'Catatan tambahan tentang gudang'
) COMMENT='Daftar gudang tempat penyimpanan barang';

-- Tabel: kategori_barang
-- Menyimpan kategori barang
CREATE TABLE IF NOT EXISTS kategori_barang (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk kategori',
    nama_kategori VARCHAR(100) NOT NULL COMMENT 'Nama kategori barang',
    deskripsi TEXT COMMENT 'Penjelasan tentang kategori ini'
) COMMENT='Kategori barang (misal: alat, bahan habis pakai, reagen, dll)';

-- Tabel: barang
-- Menyimpan daftar semua barang yang dikelola
CREATE TABLE IF NOT EXISTS barang (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk barang',
    kode_barang VARCHAR(50) NOT NULL UNIQUE COMMENT 'Kode unik untuk barang',
    nama_barang VARCHAR(255) NOT NULL COMMENT 'Nama barang',
    kategori_id INT NOT NULL COMMENT 'Foreign key ke kategori barang',
    satuan VARCHAR(50) NOT NULL COMMENT 'Satuan pengukuran (misal: box, pcs, botol)',
    deskripsi TEXT COMMENT 'Penjelasan lebih lanjut tentang barang',
    FOREIGN KEY (kategori_id) REFERENCES kategori_barang(id)
) COMMENT='Daftar barang yang dikelola oleh sistem inventory';

-- Tabel: stok
-- Menyimpan jumlah stok barang di masing-masing gudang
CREATE TABLE IF NOT EXISTS stok (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk stok',
    barang_id INT NOT NULL COMMENT 'Foreign key ke barang',
    gudang_id INT NOT NULL COMMENT 'Foreign key ke gudang',
    jumlah INT NOT NULL DEFAULT 0 COMMENT 'Jumlah barang yang tersedia',
    tanggal_kadaluarsa DATE COMMENT 'Tanggal kedaluwarsa jika relevan (untuk bahan)',
    terakhir_diupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu terakhir data stok diperbarui',
    FOREIGN KEY (barang_id) REFERENCES barang(id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(id)
) COMMENT='Data stok barang per gudang, termasuk tanggal kedaluwarsa jika ada';

-- Tabel: restock
-- Mencatat aktivitas penambahan stok dari luar
CREATE TABLE IF NOT EXISTS restock (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk restock',
    barang_id INT NOT NULL COMMENT 'Barang yang direstock',
    gudang_id INT NOT NULL COMMENT 'Gudang tujuan restock',
    jumlah INT NOT NULL COMMENT 'Jumlah barang yang ditambahkan',
    tanggal DATE NOT NULL COMMENT 'Tanggal restock dilakukan',
    nomor_batch VARCHAR(100) COMMENT 'Nomor batch barang (jika ada)',
    tanggal_kadaluarsa DATE COMMENT 'Tanggal kedaluwarsa barang (jika ada)',
    user_id INT COMMENT 'Pengguna yang mencatat restock',
    FOREIGN KEY (barang_id) REFERENCES barang(id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT='Riwayat restock barang ke dalam gudang dari supplier atau produksi';

-- Tabel: transfer
-- Mencatat perpindahan barang antar gudang
CREATE TABLE IF NOT EXISTS transfer (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk transfer',
    barang_id INT NOT NULL COMMENT 'Barang yang dipindahkan',
    dari_gudang_id INT NOT NULL COMMENT 'Gudang asal',
    ke_gudang_id INT NOT NULL COMMENT 'Gudang tujuan',
    jumlah INT NOT NULL COMMENT 'Jumlah barang yang ditransfer',
    tanggal DATE NOT NULL COMMENT 'Tanggal transfer dilakukan',
    user_id INT COMMENT 'Pengguna yang mencatat transfer',
    FOREIGN KEY (barang_id) REFERENCES barang(id),
    FOREIGN KEY (dari_gudang_id) REFERENCES gudang(id),
    FOREIGN KEY (ke_gudang_id) REFERENCES gudang(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT='Log perpindahan barang antar gudang';

-- Tabel: penjualan
-- Mencatat barang yang keluar dari gudang untuk penjualan
CREATE TABLE IF NOT EXISTS penjualan (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk penjualan',
    barang_id INT NOT NULL COMMENT 'Barang yang dijual',
    gudang_id INT NOT NULL COMMENT 'Gudang asal barang',
    jumlah INT NOT NULL COMMENT 'Jumlah barang yang dijual',
    tanggal DATE NOT NULL COMMENT 'Tanggal penjualan',
    harga_satuan DECIMAL(12,2) COMMENT 'Harga jual per unit',
    nama_pembeli VARCHAR(255) COMMENT 'Nama pembeli atau institusi tujuan',
    user_id INT COMMENT 'Pengguna yang mencatat penjualan',
    FOREIGN KEY (barang_id) REFERENCES barang(id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT='Transaksi barang keluar karena penjualan atau distribusi';

-- Tabel : batch_stok
-- Mencatat stok barang secara batch dan menunjukkan tanggal kadaluarsa tiap batch
CREATE TABLE IF NOT EXISTS batch_stok (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key untuk batch_stok',
    barang_id INT NOT NULL COMMENT 'Barang yang dimiliki batch',
    gudang_id INT NOT NULL COMMENT 'Letak Gudang penyimpanan batch barang',
    jumlah INT NOT NULL COMMENT 'Jumlah barang ada dalam Batch',
    tanggal_kadaluarsa DATE COMMENT 'Tanggal kadaluarsa batch',
    FOREIGN KEY (barang_id) REFERENCES barang(id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(id)
) COMMENT='Mencatat stok barang secara batch dan menunjukkan tanggal kadaluarsa tiap batch';

