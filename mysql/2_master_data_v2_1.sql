-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - MASTER DATA v2.1
-- Perubahan dari v2.0:
--   - Kolom aktif ditambahkan ke INSERT barang dan gudang (soft delete support)
--   - Semua barang dan gudang diset aktif = TRUE secara default
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- 1. ROLES
-- ============================================================================
INSERT INTO roles (role_id, nama_role, deskripsi) VALUES
(1, 'Super Admin', 'Memiliki akses penuh ke semua fitur sistem, termasuk manajemen pengguna, konfigurasi sistem, dan semua transaksi.'),
(2, 'Admin', 'Memiliki akses ke sebagian besar fitur kecuali manajemen pengguna tingkat tinggi dan konfigurasi sistem.'),
(3, 'Manajer Gudang', 'Bertanggung jawab atas manajemen stok di satu atau beberapa gudang, termasuk restock, transfer, dan laporan.'),
(4, 'Supervisor', 'Mengawasi operasional harian dan dapat approve transaksi tertentu.'),
(5, 'Staf Gudang', 'Memiliki akses untuk mencatat transaksi harian seperti penjualan, transfer, dan melihat stok.'),
(6, 'Kasir', 'Fokus pada transaksi penjualan dan customer service.'),
(7, 'Viewer', 'Hanya dapat melihat laporan dan data stok, tidak dapat melakukan transaksi.');

-- ============================================================================
-- 2. GUDANG - dengan kolom aktif (soft delete)
-- ============================================================================
INSERT INTO gudang (gudang_id, nama_gudang, alamat, keterangan, aktif) VALUES
(1, 'Gudang Utama Jakarta',      'Jl. Industri Raya No. 1, Pulo Gadung, Jakarta Timur 13260',   'Gudang pusat untuk distribusi nasional. Kapasitas 5000 m². Dilengkapi cold storage.',          TRUE),
(2, 'Gudang Regional Surabaya',  'Jl. Rungkut Industri V No. 8, Rungkut, Surabaya 60293',       'Melayani distribusi untuk wilayah Indonesia Timur. Kapasitas 3000 m².',                         TRUE),
(3, 'Gudang Klinik Bandung',     'Jl. Pasteur No. 28, Pasteur, Bandung 40161',                  'Gudang pendukung untuk klinik-klinik di area Jawa Barat. Kapasitas 1500 m².',                  TRUE),
(4, 'Gudang Regional Medan',     'Jl. Medan-Belawan Km. 10, Medan Belawan, Medan 20411',        'Melayani distribusi untuk wilayah Sumatera. Kapasitas 2500 m².',                                TRUE),
(5, 'Gudang Utama Makassar',     'Jl. Kima Raya 1 No. 15, Biringkanaya, Makassar 90241',        'Gudang pusat baru untuk Indonesia Timur. Kapasitas 4000 m².',                                   TRUE),
(6, 'Gudang Cabang Denpasar',    'Jl. Bypass Ngurah Rai No. 123, Denpasar 80361',               'Melayani wilayah Bali dan Nusa Tenggara. Kapasitas 1000 m². Saat ini tidak beroperasi.',        FALSE),  -- Contoh gudang tidak aktif (soft delete)
(7, 'Gudang Regional Palembang', 'Jl. Soekarno Hatta Km. 8, Palembang 30961',                  'Melayani wilayah Sumatera Selatan. Kapasitas 1800 m².',                                         TRUE);

-- ============================================================================
-- 3. KATEGORI BARANG
-- ============================================================================
INSERT INTO kategori_barang (kategori_id, nama_kategori, deskripsi) VALUES
(1, 'Alat Medis',           'Peralatan yang digunakan untuk diagnosis, pemantauan, atau perawatan medis. Termasuk alat bantu medis.'),
(2, 'Obat-obatan',          'Sediaan farmasi termasuk obat bebas, obat bebas terbatas, dan obat keras yang memerlukan resep dokter.'),
(3, 'Bahan Habis Pakai',    'Barang sekali pakai yang digunakan dalam prosedur medis atau perawatan pasien.'),
(4, 'Reagen Laboratorium',  'Bahan kimia dan kit yang digunakan untuk melakukan tes atau analisis di laboratorium medis.'),
(5, 'Vitamin & Suplemen',   'Produk vitamin, mineral, dan suplemen makanan untuk kesehatan.'),
(6, 'Kosmetik Medis',       'Produk perawatan kulit dan kosmetik yang direkomendasikan secara medis.'),
(7, 'Alat Kesehatan',       'Alat-alat penunjang kesehatan seperti kursi roda, tongkat, dan alat bantu lainnya.');

-- ============================================================================
-- 4. USERS
-- ============================================================================
INSERT INTO users (user_id, username, password_hash, nama_lengkap, role_id, aktif) VALUES
(1,  'superadmin',          '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Administrator Sistem', 1, TRUE),
(2,  'admin.jakarta',       '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Admin Jakarta',        2, TRUE),
(3,  'admin.surabaya',      '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Admin Surabaya',       2, TRUE),
(4,  'manajer.jkt',         '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Budi Santoso',         3, TRUE),
(5,  'manajer.sby',         '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Citra Lestari',        3, TRUE),
(6,  'manajer.bdg',         '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Asep Sunandar',        3, TRUE),
(7,  'manajer.mdn',         '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Siti Nurhaliza',       3, TRUE),
(8,  'manajer.mks',         '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Daeng Pratama',        3, TRUE),
(9,  'supervisor.jkt',      '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Eko Prasetyo',         4, TRUE),
(10, 'supervisor.sby',      '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Fitriani Sari',        4, TRUE),
(11, 'staf.jkt.001',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Rahmat Hidayat',       5, TRUE),
(12, 'staf.jkt.002',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Lina Marlina',         5, TRUE),
(13, 'staf.sby.001',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Gunawan Susilo',       5, TRUE),
(14, 'staf.sby.002',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Hilda Permatasari',    5, TRUE),
(15, 'staf.bdg.001',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Dewi Anggraini',       5, TRUE),
(16, 'staf.bdg.002',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Irfan Maulana',        5, TRUE),
(17, 'staf.mdn.001',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Putri Melayu',         5, TRUE),
(18, 'staf.mdn.002',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Bambang Pamungkas',    5, TRUE),
(19, 'staf.mks.001',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Andi Mappatunru',      5, TRUE),
(20, 'staf.mks.002',        '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Rini Wulandari',       5, TRUE),
(21, 'kasir.jkt.001',       '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Maya Sari',            6, TRUE),
(22, 'kasir.sby.001',       '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Joko Susilo',          6, TRUE),
(23, 'kasir.bdg.001',       '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Wawan Hendrawan',      6, TRUE),
-- Contoh user nonaktif (untuk test query "tampilkan user aktif")
(24, 'viewer.management',   '$2y$12$LKMnXD8tT9Xj6YrHs2Kp6uJLQ4R2vYwZ8qN3mP5sE7hF9rL1oV6bC', 'Director View',        7, FALSE);  -- akun dinonaktifkan

-- ============================================================================
-- 5. BARANG - dengan kolom aktif (soft delete)
-- ============================================================================
INSERT INTO barang (barang_id, kode_barang, nama_barang, kategori_id, satuan, deskripsi, aktif) VALUES
-- Alat Medis (Kategori 1) - semua aktif
(1,  'ALT-TERM-001', 'Termometer Digital Infrared',       1, 'pcs',   'Termometer digital non-kontak dengan akurasi ±0.2°C, LCD display, auto power off',                                        TRUE),
(2,  'ALT-STET-001', 'Stetoskop Littmann Classic III',    1, 'pcs',   'Stetoskop profesional dual-sided chestpiece, tunable diaphragm, 27 inch length',                                           TRUE),
(3,  'ALT-TENS-001', 'Tensimeter Digital Omron HEM-7120', 1, 'pcs',   'Tensimeter digital otomatis dengan memory 14 kali pengukuran, manset 22-32cm',                                             TRUE),
(4,  'ALT-OXIM-001', 'Pulse Oximeter CONTEC CMS50DL',     1, 'pcs',   'Pulse oximeter fingertip dengan OLED display, SpO2 dan pulse rate, alarm setting',                                         TRUE),
(5,  'ALT-NEBU-001', 'Nebulizer Omron NE-C801',           1, 'pcs',   'Kompressor nebulizer dengan virtual valve technology, noise level rendah <60dB',                                           TRUE),
(6,  'ALT-TIMB-001', 'Timbangan Digital Camry BR9012',    1, 'pcs',   'Timbangan badan digital kapasitas 180kg, akurasi 100g, LCD display besar',                                                 TRUE),
(7,  'ALT-GLUK-001', 'Glukometer Accu-Chek Active',       1, 'set',   'Alat cek gula darah dengan 10 strip test, lancet, carrying case, buku panduan',                                            TRUE),
(8,  'ALT-KURS-001', 'Kursi Roda Standar GEA FS809',      1, 'unit',  'Kursi roda lipat dengan rem hand brake, footrest removable, kapasitas 100kg',                                              TRUE),
(9,  'ALT-TONG-001', 'Tongkat Ketiak Adjustable',         1, 'pasang','Tongkat ketiak aluminium adjustable 96-119cm, non-slip rubber tips, underarm pad',                                         TRUE),

-- Obat-obatan (Kategori 2)
(10, 'OBT-PARA-500', 'Paracetamol 500mg',                 2, 'strip', 'Tablet paracetamol 500mg per strip isi 10 tablet, analgesik antipiretik',                                                  TRUE),
(11, 'OBT-AMOX-500', 'Amoxicillin 500mg',                 2, 'strip', 'Kapsul amoxicillin 500mg per strip isi 10 kapsul, antibiotik golongan penisilin',                                          TRUE),
(12, 'OBT-VITC-500', 'Vitamin C 500mg',                   2, 'botol', 'Tablet Vitamin C 500mg per botol isi 30 tablet, antioksidan untuk daya tahan tubuh',                                       TRUE),
(13, 'OBT-OBAT-001', 'Obat Batuk Sirup Woods 60ml',       2, 'botol', 'Sirup obat batuk herbal dengan madu dan jahe, untuk batuk berdahak dan batuk kering',                                      TRUE),
(14, 'OBT-LORA-010', 'Loratadine 10mg',                   2, 'strip', 'Tablet loratadine 10mg per strip isi 10 tablet, antihistamin untuk alergi',                                                TRUE),
(15, 'OBT-ASPI-080', 'Aspirin 80mg',                      2, 'strip', 'Tablet aspirin 80mg per strip isi 10 tablet, antiplatelet untuk jantung',                                                  TRUE),
(16, 'OBT-ANTA-001', 'Antasida Sirup 60ml',               2, 'botol', 'Sirup antasida untuk mengatasi asam lambung berlebih, rasa mint',                                                          TRUE),
(17, 'OBT-IBUP-400', 'Ibuprofen 400mg',                   2, 'strip', 'Tablet ibuprofen 400mg per strip isi 10 tablet, NSAID antiinflamasi',                                                      TRUE),
(18, 'OBT-CETI-010', 'Cetirizine 10mg',                   2, 'strip', 'Tablet cetirizine 10mg per strip isi 10 tablet, antihistamin generasi kedua',                                              TRUE),
(19, 'OBT-OMEP-020', 'Omeprazole 20mg',                   2, 'strip', 'Kapsul omeprazole 20mg per strip isi 10 kapsul, proton pump inhibitor',                                                    TRUE),
(20, 'OBT-MULT-001', 'Multivitamin Dewasa',               2, 'botol', 'Tablet multivitamin lengkap per botol isi 30 tablet, vitamin dan mineral harian',                                          TRUE),
(21, 'OBT-ASAM-500', 'Asam Mefenamat 500mg',              2, 'strip', 'Kapsul asam mefenamat 500mg per strip isi 10 kapsul, NSAID untuk nyeri',                                                  TRUE),

-- Bahan Habis Pakai (Kategori 3)
(22, 'BHP-MASK-001', 'Masker Medis 3-ply Disposable',     3, 'box',   'Masker medis 3 layer per box isi 50 pcs, BFE >95%, earloop elastic',                                                       TRUE),
(23, 'BHP-GLOV-001', 'Sarung Tangan Latex Powder Free',   3, 'box',   'Sarung tangan latex size M per box isi 100 pcs, powder free, non-sterile',                                                 TRUE),
(24, 'BHP-KAPA-001', 'Kapas Steril 25gr',                 3, 'roll',  'Kapas steril medis 25gr per roll, 100% cotton, highly absorbent',                                                          TRUE),
(25, 'BHP-ALKO-001', 'Alcohol Swab 70%',                  3, 'box',   'Alcohol swab 70% per box isi 100 pcs, individual pack, sterile',                                                           TRUE),
(26, 'BHP-PERB-001', 'Perban Elastis 10cm x 4.5m',        3, 'roll',  'Perban elastis lebar 10cm panjang 4.5m, high stretch, dengan clips',                                                       TRUE),
(27, 'BHP-JARU-003', 'Jarum Suntik 3ml Disposable',       3, 'box',   'Spuit 3ml dengan jarum 23G per box isi 100 pcs, sterile, disposable',                                                     TRUE),
(28, 'BHP-PLES-001', 'Plester Luka Waterproof',           3, 'box',   'Plester luka waterproof berbagai ukuran per box isi 100 pcs, breathable',                                                  TRUE),
(29, 'BHP-KASA-001', 'Kasa Steril 16x16cm',               3, 'box',   'Kasa steril ukuran 16x16cm per box isi 25 pcs, high absorbency',                                                          TRUE),
(30, 'BHP-UNDE-001', 'Underpad 60x90cm',                  3, 'pack',  'Underpad disposable 60x90cm per pack isi 10 pcs, super absorbent',                                                         TRUE),
(31, 'BHP-KATE-001', 'Kateter Urin Folley 2-way',         3, 'pcs',   'Kateter urin folley 2-way size 16FR, silicone, sterile individual pack',                                                   TRUE),
(32, 'BHP-INFU-001', 'Infus Set Dewasa Disposable',       3, 'pcs',   'Infus set dewasa dengan needle 18G, panjang selang 150cm, sterile',                                                        TRUE),
(33, 'BHP-ALKO-070', 'Alkohol 70% 1 Liter',              3, 'botol', 'Alkohol medis 70% per botol 1 liter, untuk desinfektan permukaan dan alat',                                                TRUE),
(34, 'BHP-POVI-001', 'Povidone Iodine 60ml',              3, 'botol', 'Povidone iodine 10% antiseptik per botol 60ml, untuk luka dan desinfeksi kulit',                                          TRUE),
(35, 'BHP-HAND-001', 'Hand Sanitizer 500ml',              3, 'botol', 'Hand sanitizer gel 500ml dengan 70% alcohol, antibacterial, moisturizing',                                                 TRUE),
(36, 'BHP-JARU-001', 'Jarum Suntik 1ml Disposable',       3, 'box',   'Spuit 1ml insulin dengan jarum 29G per box isi 100 pcs, sterile',                                                         TRUE),
(37, 'BHP-STRIP-001','Strip Tes Gula Darah',              3, 'box',   'Strip tes gula darah kompatibel Accu-Chek per box isi 50 strip, akurat',                                                   TRUE),

-- Reagen Laboratorium (Kategori 4)
(38, 'RGN-GLUK-001', 'Reagen Tes Glukosa Enzymatic',      4, 'kit',   'Kit reagen tes glukosa metode GOD-PAP untuk 500 test, include standard dan kontrol',                                       TRUE),
(39, 'RGN-KOLE-001', 'Reagen Tes Kolesterol CHOD-PAP',    4, 'kit',   'Kit reagen kolesterol total metode CHOD-PAP untuk 500 test, ready to use',                                                 TRUE),
(40, 'RGN-URAT-001', 'Reagen Tes Asam Urat Uricase',      4, 'kit',   'Kit reagen asam urat metode uricase untuk 500 test, liquid stable',                                                        TRUE),
(41, 'RGN-DARAH-001','Reagen Tes Golongan Darah ABO/Rh',  4, 'kit',   'Kit antisera golongan darah ABO dan Rh(D) untuk 100 test, monoclonal',                                                     TRUE),
(42, 'RGN-HCG-001',  'Reagen Tes HCG (Kehamilan)',        4, 'kit',   'Kit tes kehamilan HCG urin/serum untuk 25 test, sensitivitas 25 mIU/ml',                                                   TRUE),
(43, 'RGN-HEMO-001', 'Reagen Tes Hemoglobin Cyanmet',     4, 'kit',   'Kit reagen hemoglobin metode cyanmethemoglobin untuk 250 test',                                                            TRUE),
(44, 'RGN-WIDA-001', 'Reagen Tes Widal',                  4, 'kit',   'Kit tes widal untuk demam tifoid S.typhi dan S.paratyphi untuk 50 test',                                                   TRUE),
(45, 'RGN-URIN-001', 'Reagen Tes Urin Lengkap',           4, 'kit',   'Kit reagenstrip urin 11 parameter untuk 100 test, auto-read compatible',                                                   TRUE),

-- Contoh barang tidak aktif / diskontinyu (untuk test query soft delete)
(46, 'OBT-CLOR-250', 'Chloramphenicol 250mg (DISKONTINYU)', 2, 'strip','Kapsul chloramphenicol 250mg - TIDAK AKTIF, sudah tidak diproduksi sejak 2023',                                          FALSE);

-- ============================================================================
-- VERIFIKASI
-- ============================================================================
SELECT 'roles' as tabel, COUNT(*) as jumlah FROM roles
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'users aktif', COUNT(*) FROM users WHERE aktif = TRUE
UNION ALL SELECT 'gudang', COUNT(*) FROM gudang
UNION ALL SELECT 'gudang aktif', COUNT(*) FROM gudang WHERE aktif = TRUE
UNION ALL SELECT 'kategori_barang', COUNT(*) FROM kategori_barang
UNION ALL SELECT 'barang', COUNT(*) FROM barang
UNION ALL SELECT 'barang aktif', COUNT(*) FROM barang WHERE aktif = TRUE;
