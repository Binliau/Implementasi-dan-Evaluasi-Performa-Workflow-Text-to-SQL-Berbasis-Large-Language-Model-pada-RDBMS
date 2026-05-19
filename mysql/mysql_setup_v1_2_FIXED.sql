-- ============================================================================
-- INVENTORY KESEHATAN - SCHEMA v1.2 (TEXT-TO-SQL OPTIMIZED)
-- ============================================================================
-- CATATAN NAMING CONVENTION UNTUK LLM:
--   - Kolom PRIMARY KEY di semua tabel bernama "id" (bukan barang_id, roles_id, dsb)
--   - Kolom FOREIGN KEY di tabel lain sudah eksplisit: barang_id, gudang_id, user_id, dll
--   - Di dalam VIEW, semua kolom "id" di-alias agar tidak ambigu:
--     contoh: b.barang_id, g.gudang_id, p.penjualan_id
--   - Saat query langsung ke tabel, gunakan alias tabel:
--     contoh: SELECT b.barang_id, b.nama_barang FROM barang b (bukan SELECT id FROM barang)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS inventory_kesehatan
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE inventory_kesehatan;

-- ============================================================================
-- TABEL REFERENSI
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (
    role_id          INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel roles. Di tabel lain dirujuk sebagai role_id',
    nama_role   VARCHAR(50) NOT NULL           COMMENT 'Nama peran. Nilai valid: Super Admin, Admin, Manajer Gudang, Supervisor, Staf Gudang, Kasir, Viewer',
    deskripsi   TEXT                           COMMENT 'Penjelasan hak akses peran ini'
) COMMENT = 'Daftar peran pengguna. Hierarki akses: Super Admin > Admin > Manajer Gudang > Supervisor > Staf Gudang / Kasir > Viewer';

CREATE TABLE IF NOT EXISTS kategori_barang (
    kategori_id              INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel kategori_barang. Di tabel lain dirujuk sebagai kategori_id',
    nama_kategori   VARCHAR(100) NOT NULL          COMMENT 'Nama kategori. Nilai: Alat Medis(1), Obat-obatan(2), Bahan Habis Pakai(3), Reagen Laboratorium(4), Vitamin & Suplemen(5), Kosmetik Medis(6), Alat Kesehatan(7)',
    deskripsi       TEXT                           COMMENT 'Penjelasan kategori'
) COMMENT = 'Pengelompokan jenis barang. JOIN ke tabel barang via barang.kategori_id = kategori_barang.kategori_id';

-- ============================================================================
-- TABEL MASTER DATA
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    user_id              INT AUTO_INCREMENT PRIMARY KEY      COMMENT 'Primary key tabel users. Di tabel lain dirujuk sebagai user_id',
    username        VARCHAR(50)  NOT NULL UNIQUE        COMMENT 'Username login, harus unik di seluruh sistem',
    password_hash   VARCHAR(255) NOT NULL               COMMENT 'Password di-hash dengan bcrypt. Tidak bisa dibaca langsung',
    nama_lengkap    VARCHAR(100) NOT NULL               COMMENT 'Nama lengkap pengguna untuk tampilan laporan',
    role_id         INT NOT NULL                        COMMENT 'Foreign key ke roles.role_id. Menentukan hak akses pengguna',
    aktif           BOOLEAN DEFAULT TRUE                COMMENT 'Status akun. TRUE(1)=aktif bisa login, FALSE(0)=dinonaktifkan. Filter: WHERE aktif = 1',
    dibuat_pada     TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu pembuatan akun (YYYY-MM-DD HH:MM:SS)',
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
) COMMENT = 'Akun pengguna sistem. Untuk pengguna aktif: WHERE aktif = 1. Untuk pengguna nonaktif: WHERE aktif = 0';

CREATE TABLE IF NOT EXISTS gudang (
    gudang_id          INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel gudang. Di tabel lain dirujuk sebagai gudang_id, dari_gudang_id, atau ke_gudang_id',
    nama_gudang VARCHAR(100) NOT NULL          COMMENT 'Nama gudang. Contoh: Gudang Utama Jakarta, Gudang Regional Surabaya',
    alamat      TEXT                           COMMENT 'Alamat fisik gudang lengkap',
    keterangan  TEXT                           COMMENT 'Info kapasitas, fasilitas, dan area distribusi gudang',
    aktif       BOOLEAN DEFAULT TRUE           COMMENT 'Status operasional. TRUE(1)=gudang beroperasi, FALSE(0)=gudang tutup. SELALU filter WHERE aktif = 1 untuk transaksi aktif'
) COMMENT = 'Daftar gudang penyimpanan. Gudang nonaktif (aktif=0) tidak digunakan untuk transaksi baru. Query gudang aktif: WHERE aktif = 1';

CREATE TABLE IF NOT EXISTS barang (
    barang_id          INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel barang. Di tabel lain dirujuk sebagai barang_id',
    kode_barang VARCHAR(50)  NOT NULL UNIQUE   COMMENT 'Kode unik barang. Format: [SINGKATAN_KATEGORI]-[NAMA]-[NOMOR]. Contoh: OBT-PARA-500=Paracetamol 500mg, BHP-MASK-001=Masker',
    nama_barang VARCHAR(255) NOT NULL          COMMENT 'Nama lengkap barang termasuk merek dan spesifikasi',
    kategori_id INT NOT NULL                   COMMENT 'Foreign key ke kategori_barang.kategori_id. 1=Alat Medis, 2=Obat-obatan, 3=Bahan Habis Pakai, 4=Reagen Laboratorium, 5=Vitamin & Suplemen, 6=Kosmetik Medis, 7=Alat Kesehatan',
    satuan      VARCHAR(50)  NOT NULL          COMMENT 'Satuan jual. Nilai yang ada: pcs, strip (isi 10 tablet/kapsul), botol, box (isi banyak), roll, pasang, set, unit, kit',
    deskripsi   TEXT                           COMMENT 'Spesifikasi teknis dan keterangan lengkap barang',
    aktif       BOOLEAN DEFAULT TRUE           COMMENT 'Status barang. TRUE(1)=aktif dijual, FALSE(0)=diskontinyu/tidak aktif. SELALU filter WHERE aktif = 1 untuk katalog produk tersedia'
) COMMENT = 'Katalog barang. Barang diskontinyu tidak dihapus, hanya diset aktif=0 (soft delete). Barang tersedia: WHERE aktif = 1';

-- ============================================================================
-- TABEL STOK
-- ============================================================================

CREATE TABLE IF NOT EXISTS batch_stok (
    batch_stok_id                  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel batch_stok. Satu baris = satu batch pengiriman barang ke gudang',
    barang_id           INT NOT NULL                   COMMENT 'Foreign key ke barang.barang_id',
    gudang_id           INT NOT NULL                   COMMENT 'Foreign key ke gudang.gudang_id. Lokasi penyimpanan batch ini',
    jumlah              INT NOT NULL                   COMMENT 'Jumlah unit tersedia dalam batch ini (satuan sesuai barang.satuan)',
    tanggal_kadaluarsa  DATE                           COMMENT 'Tanggal kedaluwarsa batch. NULL = tidak kedaluwarsa (umumnya alat medis/alat kesehatan). Batch kedaluwarsa: tanggal_kadaluarsa < CURDATE()',
    FOREIGN KEY (barang_id) REFERENCES barang(barang_id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(gudang_id)
) COMMENT = 'Stok fisik per batch di gudang. PANDUAN LLM: 1) Total fisik keseluruhan = SUM(jumlah). 2) Stok Valid (layak jual/belum expired) = SUM(jumlah) WHERE tanggal_kadaluarsa IS NULL OR tanggal_kadaluarsa >= CURDATE(). 3) Stok Kedaluwarsa (tidak bisa dijual) = SUM(jumlah) WHERE tanggal_kadaluarsa < CURDATE()';

-- ============================================================================
-- TABEL TRANSAKSI
-- ============================================================================

CREATE TABLE IF NOT EXISTS restock (
    restock_id                  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel restock',
    barang_id           INT NOT NULL                   COMMENT 'Foreign key ke barang.barang_id. Barang yang diterima dari supplier',
    gudang_id           INT NOT NULL                   COMMENT 'Foreign key ke gudang.gudang_id. Gudang penerima barang',
    jumlah              INT NOT NULL                   COMMENT 'Jumlah unit barang yang diterima (satuan sesuai barang.satuan)',
    tanggal             DATE NOT NULL                  COMMENT 'Tanggal barang diterima di gudang (YYYY-MM-DD)',
    nomor_batch         VARCHAR(100)                   COMMENT 'Nomor batch supplier. Format: [KODE][TAHUN][BULAN][KODE_GUDANG][URUT]. Contoh: MASK2401JKT001',
    tanggal_kadaluarsa  DATE                           COMMENT 'Kedaluwarsa barang yang diterima. NULL jika barang tidak kedaluwarsa',
    user_id             INT                            COMMENT 'Foreign key ke users.user_id. Pengguna yang mencatat penerimaan barang',
    FOREIGN KEY (barang_id) REFERENCES barang(barang_id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(gudang_id),
    FOREIGN KEY (user_id)   REFERENCES users(user_id)
) COMMENT = 'Riwayat pengadaan barang masuk dari supplier. Setiap baris = satu transaksi penerimaan barang ke gudang';

CREATE TABLE IF NOT EXISTS transfer (
    transfer_id              INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel transfer',
    barang_id       INT NOT NULL                   COMMENT 'Foreign key ke barang.barang_id. Barang yang dipindahkan',
    dari_gudang_id  INT NOT NULL                   COMMENT 'Foreign key ke gudang.gudang_id. Gudang PENGIRIM (asal barang)',
    ke_gudang_id    INT NOT NULL                   COMMENT 'Foreign key ke gudang.gudang_id. Gudang PENERIMA (tujuan barang)',
    jumlah          INT NOT NULL                   COMMENT 'Jumlah unit yang dipindahkan antar gudang',
    tanggal         DATE NOT NULL                  COMMENT 'Tanggal pelaksanaan transfer (YYYY-MM-DD)',
    user_id         INT                            COMMENT 'Foreign key ke users.user_id. Pengguna yang mencatat transfer',
    FOREIGN KEY (barang_id)      REFERENCES barang(barang_id),
    FOREIGN KEY (dari_gudang_id) REFERENCES gudang(gudang_id),
    FOREIGN KEY (ke_gudang_id)   REFERENCES gudang(gudang_id),
    FOREIGN KEY (user_id)        REFERENCES users(user_id)
) COMMENT = 'Log perpindahan barang antar gudang. dari_gudang_id = pengirim, ke_gudang_id = penerima. Tidak mengubah total stok sistem, hanya lokasi';

CREATE TABLE IF NOT EXISTS penjualan (
    penjualan_id           INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key tabel penjualan',
    barang_id    INT NOT NULL                   COMMENT 'Foreign key ke barang.barang_id. Barang yang dijual',
    gudang_id    INT NOT NULL                   COMMENT 'Foreign key ke gudang.gudang_id. Gudang asal barang yang dijual',
    jumlah       INT NOT NULL                   COMMENT 'Jumlah unit terjual dalam satu transaksi',
    tanggal      DATE NOT NULL                  COMMENT 'Tanggal transaksi penjualan (YYYY-MM-DD)',
    harga_satuan DECIMAL(12,2)                  COMMENT 'Harga jual per unit dalam Rupiah (IDR). NULL jika harga belum tercatat. Total nilai = jumlah * harga_satuan',
    nama_pembeli VARCHAR(255)                   COMMENT 'Nama pembeli: bisa nama rumah sakit, klinik, apotek, puskesmas, atau nama individu',
    user_id      INT                            COMMENT 'Foreign key ke users.user_id. Kasir atau staf yang mencatat transaksi',
    FOREIGN KEY (barang_id) REFERENCES barang(barang_id),
    FOREIGN KEY (gudang_id) REFERENCES gudang(gudang_id),
    FOREIGN KEY (user_id)   REFERENCES users(user_id)
) COMMENT = 'Transaksi penjualan barang keluar dari gudang. Pendapatan per transaksi = jumlah * harga_satuan (Rupiah). Total pendapatan = SUM(jumlah * harga_satuan)';

-- ============================================================================
-- VIEW (TEXT-TO-SQL FRIENDLY)
-- Tujuan: menyederhanakan JOIN kompleks dan menghilangkan ambiguitas kolom "id"
-- Semua kolom "id" di-alias eksplisit: barang_id, gudang_id, penjualan_id, dll
-- ============================================================================

-- View 1: Stok per batch lengkap dengan status kedaluwarsa
-- Gunakan untuk: "stok masker di Jakarta", "barang yang hampir kedaluwarsa"
CREATE OR REPLACE VIEW v_stok_per_gudang AS
SELECT
    bs.batch_stok_id                  AS batch_id,
    b.barang_id,
    b.kode_barang,
    b.nama_barang,
    kb.kategori_id,
    kb.nama_kategori,
    b.satuan,
    g.gudang_id,
    g.nama_gudang,
    bs.jumlah              AS stok_tersedia,
    bs.tanggal_kadaluarsa,
    CASE
        WHEN bs.tanggal_kadaluarsa IS NULL                                  THEN 'Tidak Kedaluwarsa'
        WHEN bs.tanggal_kadaluarsa < CURDATE()                              THEN 'Kedaluwarsa'
        WHEN bs.tanggal_kadaluarsa <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)  THEN 'Hampir Kedaluwarsa'
        ELSE 'Masih Baik'
    END                    AS status_kedaluwarsa
FROM      batch_stok      bs
JOIN      barang          b  ON bs.barang_id  = b.barang_id
JOIN      kategori_barang kb ON b.kategori_id = kb.kategori_id
JOIN      gudang          g  ON bs.gudang_id  = g.gudang_id
WHERE     b.aktif = TRUE
  AND     g.aktif = TRUE
;

-- View 2: Total stok valid vs kedaluwarsa per barang per gudang
-- Gunakan untuk: "total stok paracetamol", "gudang mana stok masker paling banyak"
CREATE OR REPLACE VIEW v_total_stok AS
SELECT
    b.barang_id,
    b.kode_barang,
    b.nama_barang,
    kb.kategori_id,
    kb.nama_kategori,
    b.satuan,
    g.gudang_id,
    g.nama_gudang,
    SUM(bs.jumlah)                                                            AS total_stok,
    SUM(CASE WHEN bs.tanggal_kadaluarsa IS NULL
              OR  bs.tanggal_kadaluarsa >= CURDATE() THEN bs.jumlah
             ELSE 0 END)                                                      AS stok_valid,
    SUM(CASE WHEN bs.tanggal_kadaluarsa IS NOT NULL
             AND  bs.tanggal_kadaluarsa <  CURDATE() THEN bs.jumlah
             ELSE 0 END)                                                      AS stok_kedaluwarsa
FROM      batch_stok      bs
JOIN      barang          b  ON bs.barang_id  = b.barang_id
JOIN      kategori_barang kb ON b.kategori_id = kb.kategori_id
JOIN      gudang          g  ON bs.gudang_id  = g.gudang_id
WHERE     b.aktif = TRUE
  AND     g.aktif = TRUE
GROUP BY  b.barang_id, b.kode_barang, b.nama_barang,
          kb.kategori_id, kb.nama_kategori, b.satuan,
          g.gudang_id, g.nama_gudang
;

-- View 3: Penjualan lengkap dengan nilai transaksi dalam Rupiah
-- Gunakan untuk: "total penjualan bulan ini", "penjualan per kategori", "pembeli terbesar"
CREATE OR REPLACE VIEW v_penjualan_lengkap AS
SELECT
    p.penjualan_id,
    p.tanggal,
    DATE_FORMAT(p.tanggal, '%Y-%m') AS bulan,
    DATE_FORMAT(p.tanggal, '%Y')    AS tahun,
    b.barang_id,
    b.kode_barang,
    b.nama_barang,
    kb.kategori_id,
    kb.nama_kategori,
    b.satuan,
    g.gudang_id,
    g.nama_gudang,
    p.jumlah                        AS jumlah_terjual,
    p.harga_satuan,
    (p.jumlah * p.harga_satuan)     AS total_nilai,
    p.nama_pembeli,
    u.user_id,
    u.nama_lengkap                  AS nama_user,
    r.nama_role                     AS role_user
FROM      penjualan       p
JOIN      barang          b  ON p.barang_id  = b.barang_id
JOIN      kategori_barang kb ON b.kategori_id = kb.kategori_id
JOIN      gudang          g  ON p.gudang_id  = g.gudang_id
LEFT JOIN users           u  ON p.user_id    = u.user_id
LEFT JOIN roles           r  ON u.role_id    = r.role_id
;

-- View 4: Restock lengkap
-- Gunakan untuk: "kapan terakhir restock amoxicillin", "total pengadaan per bulan"
CREATE OR REPLACE VIEW v_restock_lengkap AS
SELECT
    rs.restock_id,
    rs.tanggal,
    DATE_FORMAT(rs.tanggal, '%Y-%m') AS bulan,
    DATE_FORMAT(rs.tanggal, '%Y')    AS tahun,
    b.barang_id,
    b.kode_barang,
    b.nama_barang,
    kb.kategori_id,
    kb.nama_kategori,
    b.satuan,
    g.gudang_id,
    g.nama_gudang,
    rs.jumlah                        AS jumlah_restock,
    rs.nomor_batch,
    rs.tanggal_kadaluarsa,
    u.user_id,
    u.nama_lengkap                   AS dicatat_oleh
FROM      restock         rs
JOIN      barang          b  ON rs.barang_id  = b.barang_id
JOIN      kategori_barang kb ON b.kategori_id = kb.kategori_id
JOIN      gudang          g  ON rs.gudang_id  = g.gudang_id
LEFT JOIN users           u  ON rs.user_id    = u.user_id
;

-- View 5: Transfer lengkap dengan nama gudang asal dan tujuan yang eksplisit
-- Gunakan untuk: "transfer dari Jakarta ke Surabaya", "barang paling sering ditransfer"
CREATE OR REPLACE VIEW v_transfer_lengkap AS
SELECT
    t.transfer_id,
    t.tanggal,
    DATE_FORMAT(t.tanggal, '%Y-%m') AS bulan,
    DATE_FORMAT(t.tanggal, '%Y')    AS tahun,
    b.barang_id,
    b.kode_barang,
    b.nama_barang,
    kb.kategori_id,
    kb.nama_kategori,
    b.satuan,
    g_dari.gudang_id                       AS dari_gudang_id,
    g_dari.nama_gudang              AS gudang_asal,
    g_ke.gudang_id                         AS ke_gudang_id,
    g_ke.nama_gudang                AS gudang_tujuan,
    t.jumlah                        AS jumlah_transfer,
    u.user_id,
    u.nama_lengkap                  AS dicatat_oleh
FROM      transfer        t
JOIN      barang          b      ON t.barang_id      = b.barang_id
JOIN      kategori_barang kb     ON b.kategori_id    = kb.kategori_id
JOIN      gudang          g_dari ON t.dari_gudang_id = g_dari.gudang_id
JOIN      gudang          g_ke   ON t.ke_gudang_id   = g_ke.gudang_id
LEFT JOIN users           u      ON t.user_id        = u.user_id
;

-- ============================================================================
-- SELESAI - SCHEMA v1.2
-- ============================================================================
