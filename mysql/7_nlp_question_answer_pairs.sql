-- ============================================================================
-- INVENTORY KESEHATAN - NLP QUESTION-ANSWER PAIRS (TEXT-TO-SQL REFERENCE)
-- ============================================================================
-- File ini berisi contoh pasangan pertanyaan bahasa Indonesia dan SQL-nya
-- Gunakan sebagai:
--   1. Ground truth untuk evaluasi model Text-to-SQL
--   2. Few-shot examples saat prompting LLM
--   3. Referensi kompleksitas query (sesuai Spider benchmark — Yu et al., 2018)
--
-- Kategorisasi kesulitan mengikuti Spider eval_hardness:
--   EASY   : comp1 ≤ 1, others = 0, comp2 = 0
--   MEDIUM : (comp1 ≤ 2 & others < 2) atau (others ≤ 2 & comp1 ≤ 1), tanpa comp2
--   HARD   : (comp1 2-3 & others ≤ 2) atau (others > 2 & comp1 ≤ 2), tanpa comp2
--            atau (comp1 ≤ 1 & others = 0 & comp2 = 1)
--   EXTRA  : semua sisanya
--
-- Komponen yang dihitung (queryComplexity.js):
--   comp1  = WHERE + GROUP BY + ORDER BY + LIMIT + JOIN(tiap kata JOIN) + OR + LIKE
--   comp2  = UNION/EXCEPT/INTERSECT + nested SELECT
--   others = (agg>1) + (SELECT col>1) + (WHERE cond>1) + (GROUP BY col>1)
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- SPIDER LEVEL: EASY  (3 query)
-- ============================================================================

-- [EASY-01]
-- Spider: easy  (comp1=0, comp2=0, others=0)
-- Pertanyaan: "Berapa jumlah total transaksi penjualan yang pernah terjadi?"
SELECT COUNT(*) AS total_transaksi_penjualan
FROM penjualan;

-- [EASY-02]
-- Spider: easy  (comp1=1, comp2=0, others=0)
-- Pertanyaan: "Berapa jumlah barang yang masih aktif?"
SELECT COUNT(*) AS jumlah_barang_aktif
FROM barang
WHERE aktif = TRUE;

-- [EASY-03]
-- Spider: easy  (comp1=1, comp2=0, others=0)
-- Pertanyaan: "Berapa jumlah transfer yang terjadi di tahun 2024?"
SELECT COUNT(*) AS jumlah_transfer_2024
FROM transfer
WHERE YEAR(tanggal) = 2024;

-- ============================================================================
-- SPIDER LEVEL: MEDIUM  (9 query)
-- ============================================================================

-- [MEDIUM-01]
-- Spider: medium  (comp1=1, comp2=0, others=1)
-- Pertanyaan: "Tampilkan semua gudang yang aktif"
SELECT gudang_id, nama_gudang, alamat
FROM gudang
WHERE aktif = TRUE;

-- [MEDIUM-02]
-- Spider: medium  (comp1=1, comp2=0, others=1)
-- Pertanyaan: "Tampilkan semua kategori barang beserta deskripsinya"
SELECT kategori_id, nama_kategori, deskripsi
FROM kategori_barang
ORDER BY kategori_id;

-- [MEDIUM-03]
-- Spider: medium  (comp1=1, comp2=0, others=1)
-- Pertanyaan: "Siapa saja pengguna yang sudah tidak aktif?"
SELECT username, nama_lengkap
FROM users
WHERE aktif = FALSE;

-- [MEDIUM-04]
-- Spider: medium  (comp1=1, comp2=0, others=2)
-- Pertanyaan: "Tampilkan daftar barang dengan satuan 'strip'"
SELECT kode_barang, nama_barang, satuan
FROM barang
WHERE satuan = 'strip'
  AND aktif = TRUE;

-- [MEDIUM-05]
-- Spider: medium  (comp1=2, comp2=0, others=1)
-- Pertanyaan: "Tampilkan 10 penjualan terbaru"
SELECT penjualan_id, tanggal, nama_pembeli, jumlah, harga_satuan
FROM penjualan
ORDER BY tanggal DESC
LIMIT 10;

-- [MEDIUM-06]
-- Spider: medium  (comp1=2, comp2=0, others=1)
-- Pertanyaan: "Berapa total pendapatan penjualan per bulan di tahun 2024?"
SELECT DATE_FORMAT(tanggal, '%Y-%m') AS bulan,
       SUM(jumlah * harga_satuan)     AS total_pendapatan
FROM penjualan
WHERE YEAR(tanggal) = 2024
GROUP BY DATE_FORMAT(tanggal, '%Y-%m');

-- [MEDIUM-07]
-- Spider: medium  (comp1=1, comp2=0, others=1)
-- Pertanyaan: "Siapa saja pembeli dan total belanja mereka?"
SELECT nama_pembeli,
       SUM(jumlah * harga_satuan) AS total_belanja
FROM penjualan
GROUP BY nama_pembeli;

-- [MEDIUM-08]
-- Spider: medium  (comp1=1, comp2=0, others=1)
-- Pertanyaan: "Berapa transaksi yang dicatat per user?"
SELECT user_id,
       COUNT(penjualan_id) AS jumlah_transaksi
FROM penjualan
GROUP BY user_id;

-- [MEDIUM-09]
-- Spider: medium  (comp1=2, comp2=0, others=1)
-- Pertanyaan: "Tampilkan total stok valid per kategori" (via VIEW)
-- Catatan: VIEW menyembunyikan JOIN — surface query tetap medium
SELECT kategori_id,
       SUM(stok_belum_kadaluarsa) AS total_stok_valid
FROM v_total_stok
GROUP BY kategori_id
ORDER BY total_stok_valid DESC;

-- ============================================================================
-- SPIDER LEVEL: HARD  (7 query)
-- ============================================================================

-- [HARD-01]
-- Spider: hard  (comp1=3, comp2=0, others=2)
-- Pertanyaan: "Berapa jumlah pengguna per role?"
SELECT r.nama_role,
       COUNT(u.user_id) AS jumlah_pengguna
FROM roles r
LEFT JOIN users u ON r.role_id = u.role_id
GROUP BY r.role_id, r.nama_role
ORDER BY jumlah_pengguna DESC;

-- [HARD-02]
-- Spider: hard  (comp1=3, comp2=0, others=1)
-- Pertanyaan: "Tampilkan semua barang yang tidak kedaluwarsa (alat medis)"
SELECT b.nama_barang, g.nama_gudang, bs.jumlah
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa IS NULL;

-- [HARD-03]
-- Spider: hard  (comp1=3, comp2=0, others=2)
-- Pertanyaan: "Barang apa yang paling banyak ditransfer? (frekuensi dan total unit)"
SELECT b.nama_barang,
       COUNT(*) AS frekuensi_transfer,
       SUM(t.jumlah) AS total_unit_transfer
FROM transfer t
JOIN barang b ON t.barang_id = b.barang_id
GROUP BY b.barang_id
ORDER BY total_unit_transfer DESC;

-- [HARD-04]
-- Spider: hard  (comp1=3, comp2=0, others=2)
-- Pertanyaan: "Gudang mana yang paling banyak mengirimkan barang ke gudang lain?"
SELECT g.nama_gudang AS gudang_pengirim,
       COUNT(*) AS frekuensi_kirim,
       SUM(t.jumlah) AS total_unit_dikirim
FROM transfer t
JOIN gudang g ON t.dari_gudang_id = g.gudang_id
GROUP BY g.gudang_id
ORDER BY total_unit_dikirim DESC;

-- [HARD-05]
-- Spider: hard  (comp1=3, comp2=0, others=2)
-- Pertanyaan: "Berapa rata-rata dan harga tertinggi per kategori barang?"
SELECT k.nama_kategori,
       AVG(p.harga_satuan) AS rata_harga,
       MAX(p.harga_satuan) AS harga_max
FROM penjualan p
JOIN barang b ON p.barang_id = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
GROUP BY k.kategori_id
ORDER BY rata_harga DESC;

-- [HARD-06]
-- Spider: hard  (comp1=2, comp2=0, others=1)
-- Pertanyaan: "Tampilkan penjualan bulan Januari 2025 lengkap dengan kategori" (via VIEW)
-- Catatan: hard karena banyak SELECT col (9 col → others≥1) meski query surface sederhana
SELECT penjualan_id, tanggal, nama_barang, nama_kategori,
       nama_gudang, jumlah_terjual, harga_satuan, total_nilai, nama_pembeli
FROM v_penjualan_lengkap
WHERE bulan = '2025-01'
ORDER BY tanggal;

-- [HARD-07]
-- Spider: hard  (comp1=2, comp2=0, others=1)
-- Pertanyaan: "Tampilkan semua barang dengan status stok kedaluwarsa" (via VIEW)
SELECT nama_barang, nama_kategori, nama_gudang,
       stok_tersedia, tanggal_kadaluarsa, status_kedaluwarsa
FROM v_stok_per_gudang
WHERE status_kedaluwarsa = 'Kedaluwarsa'
ORDER BY tanggal_kadaluarsa;

-- ============================================================================
-- SPIDER LEVEL: EXTRA  (19 query)
-- ============================================================================

-- [EXTRA-01]
-- Spider: extra  (comp1=6, comp2=0, others=3)
-- Pertanyaan: "Tampilkan total stok masker medis di setiap gudang"
SELECT g.nama_gudang, SUM(bs.jumlah) AS total_stok_masker
FROM batch_stok bs
JOIN barang b  ON bs.barang_id = b.barang_id
JOIN gudang g  ON bs.gudang_id = g.gudang_id
WHERE b.nama_barang LIKE '%Masker%'
  AND b.aktif = TRUE
  AND g.aktif = TRUE
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY total_stok_masker DESC;

-- [EXTRA-02]
-- Spider: extra  (comp1=4, comp2=0, others=3)
-- Pertanyaan: "Gudang mana yang paling banyak melakukan penjualan?"
SELECT g.nama_gudang,
       COUNT(p.penjualan_id)   AS jumlah_transaksi,
       SUM(p.jumlah)           AS total_unit_terjual
FROM penjualan p
JOIN gudang g ON p.gudang_id = g.gudang_id
GROUP BY g.gudang_id, g.nama_gudang
ORDER BY jumlah_transaksi DESC
LIMIT 1;

-- [EXTRA-03]
-- Spider: extra  (comp1=4, comp2=0, others=2)
-- Pertanyaan: "Tampilkan stok barang yang hampir kedaluwarsa dalam 30 hari ke depan"
SELECT b.nama_barang, g.nama_gudang, bs.jumlah, bs.tanggal_kadaluarsa
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa IS NOT NULL
  AND bs.tanggal_kadaluarsa BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND b.aktif = TRUE
  AND g.aktif = TRUE
ORDER BY bs.tanggal_kadaluarsa;

-- [EXTRA-04]
-- Spider: extra  (comp1=6, comp2=0, others=3)
-- Pertanyaan: "Berapa total barang yang masuk (restock) ke Gudang Jakarta di tahun 2024?"
SELECT b.nama_barang, SUM(r.jumlah) AS total_masuk
FROM restock r
JOIN barang b  ON r.barang_id = b.barang_id
JOIN gudang g  ON r.gudang_id = g.gudang_id
WHERE g.nama_gudang LIKE '%Jakarta%'
  AND YEAR(r.tanggal) = 2024
GROUP BY b.barang_id, b.nama_barang
ORDER BY total_masuk DESC;

-- [EXTRA-05]
-- Spider: extra  (comp1=4, comp2=0, others=2)
-- Pertanyaan: "Tampilkan barang yang stoknya sudah kedaluwarsa"
SELECT b.nama_barang, g.nama_gudang, bs.jumlah, bs.tanggal_kadaluarsa
FROM batch_stok bs
JOIN barang b ON bs.barang_id = b.barang_id
JOIN gudang g ON bs.gudang_id = g.gudang_id
WHERE bs.tanggal_kadaluarsa < CURDATE()
  AND b.aktif = TRUE
ORDER BY bs.tanggal_kadaluarsa;

-- [EXTRA-06]
-- Spider: extra  (comp1=5, comp2=0, others=2)
-- Pertanyaan: "Tampilkan penjualan obat-obatan di bulan Februari 2024"
SELECT p.tanggal, b.nama_barang, g.nama_gudang,
       p.jumlah, p.harga_satuan, p.nama_pembeli
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
JOIN gudang g          ON p.gudang_id  = g.gudang_id
WHERE k.nama_kategori = 'Obat-obatan'
  AND DATE_FORMAT(p.tanggal, '%Y-%m') = '2024-02'
ORDER BY p.tanggal;

-- [EXTRA-07]
-- Spider: extra  (comp1=5, comp2=0, others=2)
-- Pertanyaan: "Tampilkan staf gudang yang paling banyak mencatat penjualan (dengan role)"
SELECT u.nama_lengkap, r.nama_role,
       COUNT(p.penjualan_id) AS jumlah_transaksi_dicatat
FROM penjualan p
JOIN users u ON p.user_id  = u.user_id
JOIN roles r ON u.role_id  = r.role_id
GROUP BY u.user_id, u.nama_lengkap, r.nama_role
ORDER BY jumlah_transaksi_dicatat DESC
LIMIT 10;

-- [EXTRA-08]
-- Spider: extra  (comp1=4, comp2=0, others=3)
-- Pertanyaan: "Berapa rata-rata harga jual (rata, min, max) per kategori barang?"
SELECT k.nama_kategori,
       ROUND(AVG(p.harga_satuan), 0) AS rata_harga_satuan,
       MIN(p.harga_satuan)           AS harga_terendah,
       MAX(p.harga_satuan)           AS harga_tertinggi
FROM penjualan p
JOIN barang b          ON p.barang_id  = b.barang_id
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
GROUP BY k.kategori_id, k.nama_kategori
ORDER BY rata_harga_satuan DESC;

-- [EXTRA-09]
-- Spider: extra  (comp1=3, comp2=1, others=2)
-- Pertanyaan: "Barang apa yang ada di stok tapi belum pernah terjual sama sekali?"
SELECT b.kode_barang, b.nama_barang, k.nama_kategori, b.satuan
FROM barang b
JOIN kategori_barang k ON b.kategori_id = k.kategori_id
WHERE b.aktif = TRUE
  AND b.barang_id NOT IN (SELECT DISTINCT barang_id FROM penjualan)
ORDER BY k.nama_kategori, b.nama_barang;

-- [EXTRA-10]
-- Spider: extra  (comp1=2, comp2=1, others=2)
-- Pertanyaan: "Tampilkan gudang yang tidak pernah menerima transfer masuk"
SELECT g.gudang_id, g.nama_gudang
FROM gudang g
WHERE g.aktif = TRUE
  AND g.gudang_id NOT IN (SELECT DISTINCT ke_gudang_id FROM transfer)
ORDER BY g.gudang_id;

-- [EXTRA-11]
-- Spider: extra  (comp1=6, comp2=0, others=2)
-- Pertanyaan: "Berapa total pendapatan per kategori barang di setiap gudang tahun 2024?"
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

-- [EXTRA-12]
-- Spider: extra  (comp1=3, comp2=1, others=2)
-- Pertanyaan: "Tampilkan bulan dengan penjualan tertinggi untuk setiap gudang"
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

-- [EXTRA-13]
-- Spider: extra  (comp1=7, comp2=0, others=3)
-- Pertanyaan: "Barang mana yang paling cepat habis terjual dibanding stok awalnya?"
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

-- [EXTRA-14]
-- Spider: extra  (comp1=4, comp2=0, others=4)
-- Pertanyaan: "Tampilkan tren penjualan bulanan masker medis dan sarung tangan sepanjang 2024"
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

-- [EXTRA-15]
-- Spider: extra  (comp1=4, comp2=2, others=2)
-- Pertanyaan: "Gudang mana yang paling efisien? (rasio penjualan terhadap stok tertinggi)"
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

-- [EXTRA-16]
-- Spider: extra  (comp1=15, comp2=2, others=1)
-- Pertanyaan: "Tampilkan riwayat lengkap pergerakan masker medis (restock, transfer, penjualan)"
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

-- [EXTRA-17]
-- Spider: extra  (comp1=6, comp2=1, others=3)
-- Pertanyaan: "Kategori barang mana yang menghasilkan pendapatan tertinggi per bulan
--              secara konsisten sepanjang 2024?"
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

-- [EXTRA-18]
-- Spider: extra  (comp1=4, comp2=0, others=3)
-- Pertanyaan: "Tampilkan perbandingan penjualan semester 1 vs semester 2 tahun 2024
--              untuk setiap gudang"
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

-- [EXTRA-19]
-- Spider: extra  (comp1=4, comp2=0, others=3)
-- Pertanyaan: "Gudang mana yang mengirim paling banyak ke Gudang Medan?" (via VIEW)
SELECT gudang_asal,
       COUNT(transfer_id)    AS frekuensi,
       SUM(jumlah_transfer)  AS total_unit
FROM v_transfer_lengkap
WHERE gudang_tujuan LIKE '%Medan%'
GROUP BY dari_gudang_id, gudang_asal
ORDER BY total_unit DESC;

-- [EXTRA-20]
-- Spider: extra  (comp1=3, comp2=0, others=3)
-- Pertanyaan: "Siapa yang paling banyak mencatat restock di tahun 2024?" (via VIEW)
SELECT dicatat_oleh,
       COUNT(restock_id)     AS jumlah_restock,
       SUM(jumlah_restock)   AS total_unit_direstock
FROM v_restock_lengkap
WHERE tahun = '2024'
GROUP BY user_id, dicatat_oleh
ORDER BY jumlah_restock DESC;

-- ============================================================================
-- RINGKASAN DISTRIBUSI QUERY (Spider benchmark)
-- ============================================================================
-- Total query  : 38
-- EASY         :  3  — EASY-01 s/d EASY-03
-- MEDIUM       :  9  — MEDIUM-01 s/d MEDIUM-09
-- HARD         :  7  — HARD-01 s/d HARD-07
-- EXTRA        : 20  — EXTRA-01 s/d EXTRA-20 (termasuk subquery, UNION, window func, VIEW)
--
-- Catatan penyesuaian dari versi sebelumnya (domain label → Spider label):
-- • Query 1-tabel multi-kolom dengan WHERE/ORDER → MEDIUM (bukan EASY)
-- • Query GROUP BY + SUM/COUNT saja (1 tabel) → MEDIUM
-- • Query 1-2 JOIN + GROUP + ORDER + 2 agg → HARD
-- • Query 2+ JOIN + WHERE AND/LIKE + GROUP + ORDER → EXTRA
-- • Query dengan subquery, UNION ALL, atau derived table → EXTRA
-- • VIEW-based query mengikuti surface complexity (bukan kompleksitas di dalam VIEW)
--
-- Fitur SQL yang dicakup:
-- SELECT, WHERE, GROUP BY, ORDER BY, LIMIT
-- COUNT, SUM, AVG, MIN, MAX, ROUND, COALESCE, NULLIF
-- JOIN (INNER, LEFT), multi-JOIN (3-4 tabel), self-JOIN (alias FK berbeda)
-- Subquery (NOT IN, FROM subquery / derived table)
-- HAVING, CASE WHEN, IS NULL, IS NOT NULL, IN
-- DATE_FORMAT, YEAR(), MONTH(), CURDATE(), DATE_ADD(), BETWEEN
-- LIKE, AND, OR
-- UNION ALL
-- RANK() OVER PARTITION BY (window function)
-- Soft delete pattern (WHERE aktif = TRUE)
-- Computed column (jumlah * harga_satuan)
-- VIEW usage (v_total_stok, v_penjualan_lengkap, v_stok_per_gudang,
--             v_transfer_lengkap, v_restock_lengkap)
-- ============================================================================