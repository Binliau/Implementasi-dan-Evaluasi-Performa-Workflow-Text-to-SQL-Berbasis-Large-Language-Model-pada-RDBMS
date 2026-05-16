-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - SALES TRANSACTIONS (PART 2) - NO DISCOUNTS
-- Version: 2.1
-- Description: Continuation of sales transactions without discount system (March 2024 - December 2025)
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- MARCH 2024 SALES - CONTINUED STRONG DEMAND
-- ============================================================================

-- Continuing sales transactions from Part 1 (starting from invoice 070)
INSERT INTO penjualan (barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id) VALUES

-- Major hospital and institutional sales
(28, 5, 1000, '2024-03-01', 18000.00, 'RS Akademis UMI Makassar', 19),
(17, 2, 300, '2024-03-05', 16000.00, 'RS Bedah Surabaya', 14),

(22, 1, 500, '2024-03-05', 24500.00, 'Dinas Kesehatan DKI Jakarta', 4),
(23, 1, 400, '2024-03-06', 44500.00, 'RS Premier Jatinegara', 11),

-- Smaller clinical purchases
(22, 1, 50, '2024-03-07', 24500.00, 'Klinik Prodia Kuningan', 11),
(23, 1, 40, '2024-03-07', 44500.00, 'Klinik Prodia Kuningan', 12),

(22, 2, 60, '2024-03-08', 25000.00, 'Apotek Healthy Farma', 13),
(23, 2, 50, '2024-03-08', 45000.00, 'Apotek Healthy Farma', 14),

(22, 3, 30, '2024-03-09', 25500.00, 'RS Bungsu Bandung', 15),
(23, 3, 25, '2024-03-09', 45500.00, 'RS Bungsu Bandung', 16),

-- Laboratory supply expansion
(33, 1, 50, '2024-03-10', 25000.00, 'Lab Pramita Kemayoran', 12),

-- Individual retail sales
(22, 1, 1, '2024-03-12', 25000.00, 'Bapak Rahmat Hidayat', 21),
(23, 1, 1, '2024-03-12', 45000.00, 'Bapak Rahmat Hidayat', 21),

(22, 2, 2, '2024-03-13', 25500.00, 'Ibu Joko Susilo', 22),
(23, 2, 2, '2024-03-13', 45500.00, 'Ibu Joko Susilo', 22),

(22, 3, 3, '2024-03-14', 26000.00, 'Bapak Wawan Hendrawan', 23),
(23, 3, 3, '2024-03-14', 46000.00, 'Bapak Wawan Hendrawan', 23),

-- Hotel industry supply
(35, 3, 100, '2024-03-15', 32000.00, 'Hotel Hilton Bandung', 15),

-- Medical facility restocking
(22, 4, 4, '2024-03-15', 24000.00, 'Apotek Melati Medan', 17),
(23, 4, 4, '2024-03-15', 46000.00, 'Apotek Melati Medan', 18),

(22, 5, 5, '2024-03-16', 26500.00, 'Toko Sehat Makassar', 19),
(23, 5, 5, '2024-03-16', 44000.00, 'Toko Sehat Makassar', 20),

-- ============================================================================
-- APRIL 2024 SALES - SEASONAL PEAK
-- ============================================================================

-- Government health department orders
(37, 1, 200, '2024-04-01', 45000.00, 'Puskesmas Senen', 4),
(38, 2, 150, '2024-04-02', 35000.00, 'Puskesmas Wonokromo', 5),

-- Corporate medical programs
(22, 1, 200, '2024-04-03', 24000.00, 'PT Astra International', 11),
(23, 1, 180, '2024-04-03', 44000.00, 'PT Astra International', 12),

-- Educational institution purchases
(22, 3, 100, '2024-04-04', 25000.00, 'Universitas Padjadjaran', 15),
(23, 3, 80, '2024-04-04', 45000.00, 'Universitas Padjadjaran', 16),

-- Individual purchases continue
(22, 1, 3, '2024-04-05', 25000.00, 'Ibu Maria Theresa', 21),
(23, 1, 3, '2024-04-05', 45000.00, 'Ibu Maria Theresa', 21),

(22, 2, 4, '2024-04-06', 25500.00, 'Bapak Ahmad Subagyo', 22),
(23, 2, 4, '2024-04-06', 45500.00, 'Bapak Ahmad Subagyo', 22),

-- ============================================================================
-- MAY 2024 SALES - CONTINUED DEMAND
-- ============================================================================

-- Healthcare network expansion
(22, 4, 150, '2024-05-01', 23500.00, 'RS Columbia Asia Medan', 17),
(23, 4, 120, '2024-05-01', 45500.00, 'RS Columbia Asia Medan', 18),

-- Laboratory network orders
(44, 1, 20, '2024-05-02', 90000.00, 'Lab Parahita Jakarta', 12),
(45, 2, 15, '2024-05-03', 120000.00, 'Lab Klinik Surabaya', 13),

-- Pharmaceutical chain orders
(10, 3, 500, '2024-05-04', 7500.00, 'Guardian Pharmacy Bandung', 15),
(11, 5, 400, '2024-05-05', 12000.00, 'Apotek K-24 Makassar', 19),

-- Individual medical device sales
(4, 1, 3, '2024-05-06', 120000.00, 'Bapak Hendro Susanto', 21),
(6, 2, 1, '2024-05-07', 350000.00, 'Ibu Sari Dewi', 22);

-- Continuing with additional sales through December 2024 and into 2025...
-- NOTE: This file can be extended to include the full 500+ transactions as needed

-- End of current batch - additional entries would continue the pattern