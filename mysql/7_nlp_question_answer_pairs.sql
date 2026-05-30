-- ============================================================================
-- INVENTORY KESEHATAN - NLP QUESTION-ANSWER PAIRS (TEXT-TO-SQL REFERENCE)
-- ============================================================================
-- File ini berisi contoh pasangan pertanyaan bahasa Indonesia dan SQL-nya
-- Gunakan sebagai:
--   1. Ground truth untuk evaluasi model Text-to-SQL
--   2. Few-shot examples saat prompting LLM
--   3. Referensi kompleksitas query (Easy / Medium / Hard)
--
-- Kategorisasi kesulitan:
--   EASY   : 1 tabel, tanpa JOIN, filter sederhana
--   MEDIUM : 2-3 tabel, JOIN, GROUP BY, atau kondisi majemuk
--   HARD   : 4+ tabel / VIEW, subquery, HAVING, window function, atau logika bisnis kompleks
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- KATEGORI: EASY (Query 1-tabel, tanpa atau 1 JOIN sederhana)
-- ============================================================================

-- [EASY-01]
-- Pertanyaan: "Tampilkan semua gudang yang aktif"
-- Tags: soft_delete, filter_boolean
SELECT gudang_id, nama_gudang, alamat
FROM gudang
WHERE aktif = TRUE;

-- [EASY-02]
-- Pertanyaan: "Berapa jumlah barang yang masih aktif?"
-- Tags: COUNT, soft_delete
SELECT COUNT(*) AS jumlah_barang_aktif
FROM barang
WHERE aktif = TRUE;

-- [EASY-03]
-- Pertanyaan: "Tampilkan semua kategori barang beserta deskripsinya"
-- Tags: SELECT_ALL
SELECT kategori_id, nama_kategori, deskripsi
FROM kategori_barang
ORDER BY kategori_id;

-- [EASY-04]
-- Pertanyaan: "Siapa saja pengguna yang sudah tidak aktif?"
-- Tags: soft_delete, filter_boolean
SELECT username, nama_lengkap
FROM users
WHERE aktif = FALSE;

-- [EASY-05]
-- Pertanyaan: "Tampilkan daftar barang dengan satuan 'strip'"
-- Tags: filter_string
SELECT kode_barang, nama_barang, satuan
FROM barang
WHERE satuan = 'strip'
  AND aktif = TRUE;

-- [EASY-06]
-- Pertanyaan: "Berapa total transaksi penjualan yang pernah terjadi?"
-- Tags: COUNT
SELECT COUNT(*) AS total_transaksi_penjualan
FROM penjualan;

-- [EASY-07]
-- Pertanyaan: "Tampilkan 10 penjualan terbaru"
-- Tags: ORDER_BY, LIMIT
SELECT penjualan_id, tanggal, nama_pembeli, jumlah, harga_satuan
FROM penjualan
ORDER BY tanggal DESC
LIMIT 10;

-- [EASY-08]
-- Pertanyaan: "Berapa jumlah pengguna per role?"
-- Tags: GROUP_BY, COUNT, JOIN
SELECT r.nama_role, COUNT(u.user_id) AS jumlah_pengguna
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_id, r.nama_role
ORDER BY jumlah_pengguna DESC;

-- [EASY-09]
-- Pertanyaan: "Tampilkan semua barang yang tidak kedaluwarsa (alat medis)"
-- Tags: filter_null
SELECT b.nama_barang, g.nama_gudang, bs.jumlah
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa IS NULL;

-- [EASY-10]
-- Pertanyaan: "Berapa jumlah transfer yang terjadi di tahun 2024?"
-- Tags: filter_date, COUNT
SELECT COUNT(*) AS jumlah_transfer_2024
FROM transfer
WHERE YEAR(tanggal) = 2024;

-- ============================================================================
-- KATEGORI: MEDIUM (2-3 tabel, GROUP BY, HAVING, kondisi majemuk)
-- ============================================================================

-- [MEDIUM-01]
-- Pertanyaan: "Tampilkan total stok masker medis di setiap gudang"
-- Tags: JOIN, GROUP_BY, SUM, filter_nama
SELECT g.nama_gudang, SUM(bs.jumlah) AS total_stok_masker
FROM batch_stok bs
JOIN barang b  ON bs.barang_id = b.barang_id
JOIN gudang g  ON bs.gudang_id = g.gudang_id
WHERE b.nama_barang LIKE '%Masker%'
  AND b.aktif = TRUE
  AND g.aktif = TRUE
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY total_stok_masker DESC;

-- [MEDIUM-02]
-- Pertanyaan: "Berapa total pendapatan penjualan per bulan di tahun 2024?"
-- Tags: DATE_FORMAT, GROUP_BY, SUM, computed_column
SELECT DATE_FORMAT(tanggal, '%Y-%m') AS bulan,
       COUNT(*)                       AS jumlah_transaksi,
       SUM(jumlah * harga_satuan)     AS total_pendapatan
FROM penjualan
WHERE YEAR(tanggal) = 2024
GROUP BY DATE_FORMAT(tanggal, '%Y-%m')
ORDER BY bulan;

-- [MEDIUM-03]
-- Pertanyaan: "Gudang mana yang paling banyak melakukan penjualan?"
-- Tags: JOIN, GROUP_BY, ORDER_BY, LIMIT
SELECT g.nama_gudang,
       COUNT(p.penjualan_id)               AS jumlah_transaksi,
       SUM(p.jumlah)             AS total_unit_terjual
FROM penjualan p
JOIN gudang g ON p.gudang_id = g.gudang_id
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY jumlah_transaksi DESC
LIMIT 1;

-- [MEDIUM-04]
-- Pertanyaan: "Tampilkan stok barang yang hampir kedaluwarsa dalam 30 hari ke depan"
-- Tags: DATE_ADD, filter_date, JOIN, soft_delete
SELECT b.nama_barang, g.nama_gudang, bs.jumlah, bs.tanggal_kadaluarsa
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa IS NOT NULL
  AND bs.tanggal_kadaluarsa BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND b.aktif = TRUE
  AND g.aktif = TRUE
ORDER BY bs.tanggal_kadaluarsa;

-- [MEDIUM-05]
-- Pertanyaan: "Siapa pembeli dengan total pembelian terbesar?"
-- Tags: GROUP_BY, SUM, ORDER_BY, LIMIT
SELECT nama_pembeli,
       COUNT(*)                   AS jumlah_transaksi,
       SUM(jumlah * harga_satuan) AS total_belanja
FROM penjualan
GROUP BY nama_pembeli
ORDER BY total_belanja DESC
LIMIT 10;

-- [MEDIUM-06]
-- Pertanyaan: "Berapa total barang yang masuk (restock) ke Gudang Jakarta di tahun 2024?"
-- Tags: JOIN, filter_gudang, filter_date, SUM
SELECT b.nama_barang, SUM(r.jumlah) AS total_masuk
FROM restock r
JOIN barang b  ON r.barang_id = b.barang_id
JOIN gudang g  ON r.gudang_id = g.gudang_id
WHERE g.nama_gudang LIKE '%Jakarta%'
  AND YEAR(r.tanggal) = 2024
GROUP BY b.barang_id, b.nama_barang
ORDER BY total_masuk DESC;

-- [MEDIUM-07]
-- Pertanyaan: "Tampilkan barang yang stoknya sudah kedaluwarsa"
-- Tags: filter_date, JOIN, soft_delete
SELECT b.nama_barang, g.nama_gudang, bs.jumlah, bs.tanggal_kadaluarsa
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa < CURDATE()
  AND b.aktif = TRUE
ORDER BY bs.tanggal_kadaluarsa;

-- [MEDIUM-08]
-- Pertanyaan: "Barang apa yang paling banyak ditransfer antar gudang?"
-- Tags: GROUP_BY, SUM, ORDER_BY, JOIN
SELECT b.nama_barang,
       COUNT(t.transfer_id)    AS frekuensi_transfer,
       SUM(t.jumlah)  AS total_unit_transfer
FROM transfer t
JOIN barang b ON t.barang_id = b.barang_id
GROUP BY b.barang_id, b.nama_barang
ORDER BY total_unit_transfer DESC
LIMIT 10;

-- [MEDIUM-09]
-- Pertanyaan: "Tampilkan penjualan obat-obatan di bulan Februari 2024"
-- Tags: JOIN_kategori, filter_date, filter_kategori
SELECT p.tanggal, b.nama_barang, g.nama_gudang,
       p.jumlah, p.harga_satuan, p.nama_pembeli
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
JOIN gudang g          ON p.gudang_id  = g.gudang_id
WHERE k.nama_kategori = 'Obat-obatan'
  AND DATE_FORMAT(p.tanggal, '%Y-%m') = '2024-02'
ORDER BY p.tanggal;

-- [MEDIUM-10]
-- Pertanyaan: "Berapa rata-rata harga jual per kategori barang?"
-- Tags: AVG, GROUP_BY, JOIN_kategori
SELECT k.nama_kategori,
       ROUND(AVG(p.harga_satuan), 0) AS rata_harga_satuan,
       MIN(p.harga_satuan)           AS harga_terendah,
       MAX(p.harga_satuan)           AS harga_tertinggi
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
GROUP BY k.kategori_id, k.nama_kategori
ORDER BY rata_harga_satuan DESC;

-- [MEDIUM-11]
-- Pertanyaan: "Gudang mana yang mengirim paling banyak barang ke gudang lain?"
-- Tags: GROUP_BY, SUM, JOIN, alias_FK
SELECT g.nama_gudang              AS gudang_pengirim,
       COUNT(t.transfer_id)                AS frekuensi_kirim,
       SUM(t.jumlah)              AS total_unit_dikirim
FROM transfer t
JOIN gudang g ON t.dari_gudang_id = g.gudang_id
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY total_unit_dikirim DESC;

-- [MEDIUM-12]
-- Pertanyaan: "Tampilkan staf gudang yang paling banyak mencatat penjualan"
-- Tags: JOIN_users, GROUP_BY, ORDER_BY
SELECT u.nama_lengkap, r.nama_role,
       COUNT(p.penjualan_id)   AS jumlah_transaksi_dicatat
FROM penjualan p
JOIN users u  ON p.user_id  = u.user_id
JOIN roles r  ON u.role_id  = r.role_id
GROUP BY u.user_id, u.nama_lengkap, r.nama_role
ORDER BY jumlah_transaksi_dicatat DESC
LIMIT 10;

-- ============================================================================
-- KATEGORI: HARD (subquery, HAVING, multi-kondisi, logika bisnis kompleks)
-- ============================================================================

-- [HARD-01]
-- Pertanyaan: "Barang apa yang ada di stok tapi belum pernah terjual sama sekali?"
-- Tags: subquery_NOT_IN, soft_delete, business_logic
SELECT b.kode_barang, b.nama_barang, k.nama_kategori, b.satuan
FROM barang b
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
WHERE b.aktif = TRUE
  AND b.barang_id NOT IN (SELECT DISTINCT barang_id FROM penjualan)
ORDER BY k.nama_kategori, b.nama_barang;

-- [HARD-02]
-- Pertanyaan: "Tampilkan gudang yang tidak pernah menerima transfer masuk"
-- Tags: subquery_NOT_IN, JOIN, business_logic
SELECT g.gudang_id, g.nama_gudang
FROM gudang g
WHERE g.aktif = TRUE
  AND g.gudang_id NOT IN (SELECT DISTINCT ke_gudang_id FROM transfer)
ORDER BY g.gudang_id;

-- [HARD-03]
-- Pertanyaan: "Berapa total pendapatan per kategori barang di setiap gudang tahun 2024?"
-- Tags: 4_table_JOIN, GROUP_BY, SUM, computed_column
SELECT k.nama_kategori,
       g.nama_gudang,
       SUM(p.jumlah * p.harga_satuan) AS total_pendapatan
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
JOIN gudang g          ON p.gudang_id  = g.gudang_id
WHERE YEAR(p.tanggal) = 2024
GROUP BY k.kategori_id, k.nama_kategori, g.gudang_id, g.nama_gudang
ORDER BY k.nama_kategori, total_pendapatan DESC;

-- [HARD-04]
-- Pertanyaan: "Tampilkan bulan dengan penjualan tertinggi untuk setiap gudang"
-- Tags: subquery, MAX, GROUP_BY, correlated
SELECT g.nama_gudang, sub.bulan, sub.total_penjualan
FROM gudang g
JOIN (
    SELECT gudang_id,
           DATE_FORMAT(tanggal, '%Y-%m')      AS bulan,
           SUM(jumlah * harga_satuan)         AS total_penjualan,
           RANK() OVER (
               PARTITION BY gudang_id
               ORDER BY SUM(jumlah * harga_satuan) DESC
           ) AS urutan
    FROM penjualan
    GROUP BY gudang_id, DATE_FORMAT(tanggal, '%Y-%m')
) sub ON g.gudang_id = sub.gudang_id
WHERE sub.urutan = 1
ORDER BY sub.total_penjualan DESC;

-- [HARD-05]
-- Pertanyaan: "Barang mana yang paling cepat habis terjual dibanding stok awalnya?"
-- Tags: subquery, computed_ratio, GROUP_BY, multiple_aggregation
SELECT b.nama_barang,
       k.nama_kategori,
       COALESCE(SUM(bs.jumlah), 0)             AS stok_sekarang,
       COALESCE(SUM(p.jumlah), 0)              AS total_terjual,
       CASE WHEN SUM(bs.jumlah) > 0
            THEN ROUND(SUM(p.jumlah) / SUM(bs.jumlah) * 100, 1)
            ELSE NULL END                       AS persen_terjual
FROM barang b
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
LEFT JOIN batch_stok bs ON b.barang_id = bs.barang_id
LEFT JOIN penjualan  p  ON b.barang_id = p.barang_id
WHERE b.aktif = TRUE
GROUP BY b.barang_id, b.nama_barang, k.nama_kategori
HAVING total_terjual > 0
ORDER BY persen_terjual DESC
LIMIT 10;

-- [HARD-06]
-- Pertanyaan: "Tampilkan tren penjualan bulanan masker medis dan sarung tangan sepanjang 2024"
-- Tags: filter_produk, GROUP_BY, ORDER_BY, multiple_items
SELECT DATE_FORMAT(p.tanggal, '%Y-%m')   AS bulan,
       b.nama_barang,
       SUM(p.jumlah)                     AS total_unit_terjual,
       SUM(p.jumlah * p.harga_satuan)    AS total_nilai
FROM penjualan p
JOIN barang b ON p.barang_id = b.barang_id
WHERE b.nama_barang IN ('Masker Medis 3-ply Disposable', 'Sarung Tangan Latex Powder Free')
  AND YEAR(p.tanggal) = 2024
GROUP BY DATE_FORMAT(p.tanggal, '%Y-%m'), b.barang_id, b.nama_barang
ORDER BY bulan, b.nama_barang;

-- [HARD-07]
-- Pertanyaan: "Gudang mana yang paling efisien? (rasio penjualan terhadap stok tertinggi)"
-- Tags: subquery, ratio, multiple_aggregation, business_logic
SELECT g.nama_gudang,
       COALESCE(stok.total_stok, 0)     AS total_stok,
       COALESCE(jual.total_terjual, 0)  AS total_terjual,
       CASE WHEN stok.total_stok > 0
            THEN ROUND(jual.total_terjual / stok.total_stok * 100, 1)
            ELSE 0 END                  AS efisiensi_persen
FROM gudang g
LEFT JOIN (
    SELECT gudang_id, SUM(jumlah) AS total_stok
    FROM batch_stok GROUP BY gudang_id
) stok ON g.gudang_id = stok.gudang_id
LEFT JOIN (
    SELECT gudang_id, SUM(jumlah) AS total_terjual
    FROM penjualan GROUP BY gudang_id
) jual ON g.gudang_id = jual.gudang_id
WHERE g.aktif = TRUE
ORDER BY efisiensi_persen DESC;

-- [HARD-08]
-- Pertanyaan: "Tampilkan riwayat lengkap pergerakan masker medis (restock, transfer, penjualan)"
-- Tags: UNION, multiple_tables, filter_barang, chronological
SELECT 'Restock'   AS jenis_transaksi, r.tanggal, g.nama_gudang AS lokasi,
       r.jumlah,   NULL AS ke_gudang,  u.nama_lengkap AS user
FROM restock r
JOIN gudang g ON r.gudang_id = g.gudang_id
JOIN barang b ON r.barang_id = b.barang_id
LEFT JOIN users u ON r.user_id = u.user_id
WHERE b.nama_barang LIKE '%Masker%'

UNION ALL

SELECT 'Transfer Keluar', t.tanggal, g_dari.nama_gudang,
       -t.jumlah, g_ke.nama_gudang, u.nama_lengkap
FROM transfer t
JOIN gudang g_dari ON t.dari_gudang_id = g_dari.gudang_id
JOIN gudang g_ke   ON t.ke_gudang_id   = g_ke.gudang_id
JOIN barang b      ON t.barang_id      = b.barang_id
LEFT JOIN users u  ON t.user_id        = u.user_id
WHERE b.nama_barang LIKE '%Masker%'

UNION ALL

SELECT 'Penjualan', p.tanggal, g.nama_gudang,
       -p.jumlah, p.nama_pembeli, u.nama_lengkap
FROM penjualan p
JOIN gudang g ON p.gudang_id = g.gudang_id
JOIN barang b ON p.barang_id = b.barang_id
LEFT JOIN users u ON p.user_id = u.user_id
WHERE b.nama_barang LIKE '%Masker%'

ORDER BY tanggal, jenis_transaksi;

-- [HARD-09]
-- Pertanyaan: "Kategori barang mana yang menghasilkan pendapatan tertinggi per bulan
--              secara konsisten sepanjang 2024?"
-- Tags: subquery, HAVING, COUNT, GROUP_BY, business_logic
SELECT k.nama_kategori,
       COUNT(DISTINCT DATE_FORMAT(p.tanggal, '%Y-%m')) AS bulan_aktif,
       SUM(p.jumlah * p.harga_satuan)                  AS total_pendapatan_2024,
       ROUND(AVG(monthly.total), 0)                    AS rata_pendapatan_per_bulan
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
JOIN (
    SELECT b2.kategori_id,
           DATE_FORMAT(p2.tanggal, '%Y-%m') AS bulan,
           SUM(p2.jumlah * p2.harga_satuan) AS total
    FROM penjualan p2
    JOIN barang b2 ON p2.barang_id = b2.barang_id
    WHERE YEAR(p2.tanggal) = 2024
    GROUP BY b2.kategori_id, DATE_FORMAT(p2.tanggal, '%Y-%m')
) monthly ON k.kategori_id = monthly.kategori_id
WHERE YEAR(p.tanggal) = 2024
GROUP BY k.kategori_id, k.nama_kategori
HAVING bulan_aktif >= 6
ORDER BY total_pendapatan_2024 DESC;

-- [HARD-10]
-- Pertanyaan: "Tampilkan perbandingan penjualan semester 1 vs semester 2 tahun 2024
--              untuk setiap gudang"
-- Tags: CASE_WHEN, conditional_aggregation, GROUP_BY, business_logic
SELECT g.nama_gudang,
       SUM(CASE WHEN MONTH(p.tanggal) BETWEEN 1 AND 6
                THEN p.jumlah * p.harga_satuan ELSE 0 END) AS pendapatan_sem1,
       SUM(CASE WHEN MONTH(p.tanggal) BETWEEN 7 AND 12
                THEN p.jumlah * p.harga_satuan ELSE 0 END) AS pendapatan_sem2,
       SUM(p.jumlah * p.harga_satuan)                      AS total_2024,
       ROUND(
           (SUM(CASE WHEN MONTH(p.tanggal) BETWEEN 7 AND 12
                     THEN p.jumlah * p.harga_satuan ELSE 0 END)
            - SUM(CASE WHEN MONTH(p.tanggal) BETWEEN 1 AND 6
                       THEN p.jumlah * p.harga_satuan ELSE 0 END))
           / NULLIF(SUM(CASE WHEN MONTH(p.tanggal) BETWEEN 1 AND 6
                             THEN p.jumlah * p.harga_satuan ELSE 0 END), 0) * 100
       , 1)                                                 AS pertumbuhan_persen
FROM penjualan p
JOIN gudang g ON p.gudang_id = g.gudang_id
WHERE YEAR(p.tanggal) = 2024
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY total_2024 DESC;

-- ============================================================================
-- QUERY MENGGUNAKAN VIEW (demonstrasi manfaat VIEW)
-- ============================================================================

-- [VIEW-01]
-- Pertanyaan: "Tampilkan total stok valid per kategori"
-- Tanpa VIEW butuh 3 JOIN, dengan VIEW langsung 1 baris
SELECT nama_kategori,
       SUM(stok_belum_kadaluarsa)       AS total_stok_valid,
       SUM(stok_kadaluwarsa) AS total_stok_kdaluwarsa
FROM v_total_stok
GROUP BY kategori_id, nama_kategori
ORDER BY total_stok_valid DESC;

-- [VIEW-02]
-- Pertanyaan: "Tampilkan penjualan bulan Januari 2025 lengkap dengan kategori"
SELECT penjualan_id, tanggal, nama_barang, nama_kategori,
       nama_gudang, jumlah_terjual, harga_satuan, total_nilai, nama_pembeli
FROM v_penjualan_lengkap
WHERE bulan = '2025-01'
ORDER BY tanggal;

-- [VIEW-03]
-- Pertanyaan: "Gudang mana yang mengirim paling banyak ke Gudang Medan?"
SELECT gudang_asal,
       COUNT(transfer_id) AS frekuensi,
       SUM(jumlah_transfer) AS total_unit
FROM v_transfer_lengkap
WHERE gudang_tujuan LIKE '%Medan%'
GROUP BY dari_gudang_id, gudang_asal
ORDER BY total_unit DESC;

-- [VIEW-04]
-- Pertanyaan: "Tampilkan semua barang dengan status stok kedaluwarsa"
SELECT nama_barang, nama_kategori, nama_gudang,
       stok_tersedia, tanggal_kadaluarsa, status_kedaluwarsa
FROM v_stok_per_gudang
WHERE status_kedaluwarsa = 'Kedaluwarsa'
ORDER BY tanggal_kadaluarsa;

-- [VIEW-05]
-- Pertanyaan: "Siapa yang paling banyak mencatat restock di tahun 2024?"
SELECT dicatat_oleh,
       COUNT(restock_id)  AS jumlah_restock,
       SUM(jumlah_restock) AS total_unit_direstock
FROM v_restock_lengkap
WHERE tahun = '2024'
GROUP BY user_id, dicatat_oleh
ORDER BY jumlah_restock DESC;

-- ============================================================================
-- RINGKASAN DISTRIBUSI QUERY
-- ============================================================================
-- Total query  : 30
-- EASY         : 10 (EASY-01 s/d EASY-10)
-- MEDIUM       : 12 (MEDIUM-01 s/d MEDIUM-12)
-- HARD         : 10 (HARD-01 s/d HARD-10) - termasuk 5 query VIEW
--
-- Fitur SQL yang dicakup:
-- SELECT, WHERE, GROUP BY, ORDER BY, LIMIT
-- COUNT, SUM, AVG, MIN, MAX, ROUND
-- JOIN (INNER, LEFT), self-JOIN (alias FK berbeda: dari_gudang_id vs ke_gudang_id)
-- Subquery (NOT IN, correlated, FROM subquery)
-- HAVING, CASE WHEN, COALESCE, NULLIF
-- DATE_FORMAT, YEAR(), MONTH(), CURDATE(), DATE_ADD()
-- LIKE, BETWEEN, IS NULL, IS NOT NULL
-- UNION ALL
-- RANK() OVER (window function)
-- Soft delete pattern (WHERE aktif = TRUE)
-- Computed column (jumlah * harga_satuan)
-- VIEW usage
-- ============================================================================