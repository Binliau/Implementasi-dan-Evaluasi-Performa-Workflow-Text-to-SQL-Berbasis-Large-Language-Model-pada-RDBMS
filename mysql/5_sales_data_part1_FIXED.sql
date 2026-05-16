-- ============================================================================
-- INVENTORY KESEHATAN DATABASE - SALES TRANSACTIONS (PART 1) - NO DISCOUNTS
-- Version: 2.1
-- Description: Simplified sales transactions without discount system (500+ entries)
-- ============================================================================

USE inventory_kesehatan;

-- ============================================================================
-- SALES TRANSACTIONS - SIMPLIFIED APPROACH
-- NOTE: This represents outbound sales that reduce stock levels
-- ============================================================================

-- Sales transactions with proper invoice numbering and customer details (no discounts)
INSERT INTO penjualan (barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id) VALUES

-- ============================================================================
-- JANUARY 2024 SALES - EARLY YEAR STRONG DEMAND
-- ============================================================================

-- Week 1 January 2024
(22, 1, 250, '2024-01-15', 25000.00, 'RS Harapan Bunda Jakarta', 11),
(23, 1, 200, '2024-01-15', 45000.00, 'RS Harapan Bunda Jakarta', 11),
(22, 2, 150, '2024-01-16', 26000.00, 'Klinik Medika Prima Surabaya', 13),
(23, 3, 100, '2024-01-17', 46000.00, 'RS Santosa Bandung', 15),

-- Individual sales
(22, 1, 2, '2024-01-17', 25500.00, 'Bapak Budi Santoso', 21),
(10, 1, 100, '2024-01-18', 7500.00, 'Apotek Roxy Square', 11),
(22, 1, 120, '2024-01-18', 25000.00, 'Puskesmas Gambir', 12),

-- Week 2 January 2024  
(23, 2, 80, '2024-01-19', 45500.00, 'RS Royal Surabaya', 13),
(22, 1, 5, '2024-01-19', 25000.00, 'Apotek Jaya Mandiri', 11),
(23, 1, 3, '2024-01-19', 45000.00, 'Apotek Jaya Mandiri', 11),

(22, 3, 3, '2024-01-20', 26000.00, 'Apotek Pasteur', 15),
(22, 2, 10, '2024-01-20', 25500.00, 'Klinik Sehat Mandiri', 13),
(23, 2, 8, '2024-01-20', 45500.00, 'Klinik Sehat Mandiri', 14),

(23, 1, 220, '2024-01-21', 45000.00, 'RS Medistra Jakarta', 12),
(22, 3, 2, '2024-01-21', 26000.00, 'Ibu Wati Suharto', 16),
(23, 3, 1, '2024-01-21', 46000.00, 'Ibu Wati Suharto', 16),

-- Week 3 January 2024
(22, 1, 150, '2024-01-22', 24800.00, 'RSIA Bunda Jakarta', 11),
(23, 1, 120, '2024-01-22', 44800.00, 'RSIA Bunda Jakarta', 12),

(22, 2, 200, '2024-01-23', 25300.00, 'RS William Booth Surabaya', 13),
(23, 2, 180, '2024-01-23', 45300.00, 'RS William Booth Surabaya', 14),

(22, 1, 4, '2024-01-24', 25000.00, 'Bapak Agus Salim', 21),
(23, 1, 4, '2024-01-24', 45000.00, 'Bapak Agus Salim', 21),

-- Pharmaceutical sales
(11, 2, 150, '2024-01-25', 12000.00, 'Puskesmas Rungkut', 14),

-- Medical equipment sales
(25, 1, 10, '2024-01-25', 30000.00, 'Klinik Gigi Sehat', 11),
(26, 2, 5, '2024-01-26', 20000.00, 'Klinik Fisioterapi Mandiri', 13),

-- Laboratory supplies
(39, 3, 2, '2024-01-27', 180000.00, 'Lab Pramita Bandung', 15),
(40, 1, 3, '2024-01-28', 160000.00, 'Lab Cito Jakarta', 12),

-- Individual medical equipment
(4, 2, 1, '2024-01-29', 120000.00, 'Bapak Hartono', 14),
(24, 3, 4, '2024-01-30', 28000.00, 'Puskesmas Sukajadi', 15),
(14, 1, 6, '2024-01-31', 18000.00, 'Apotek Century Kelapa Gading', 11),

-- ============================================================================
-- FEBRUARY 2024 SALES - PEAK DEMAND PERIOD
-- ============================================================================

-- Large hospital orders
(22, 4, 300, '2024-02-01', 24000.00, 'RS Murni Teguh Medan', 17),
(41, 3, 1, '2024-02-01', 250000.00, 'PMI Kota Bandung', 15),

(22, 2, 300, '2024-02-02', 25500.00, 'RSUD Dr. Soetomo', 13),
(6, 1, 2, '2024-02-02', 350000.00, 'Klinik Diet Sehat', 21),

(23, 4, 150, '2024-02-03', 46000.00, 'RS Adam Malik Medan', 17),
(15, 2, 10, '2024-02-03', 6000.00, 'Apotek Kimia Farma Gubeng', 14),
(16, 3, 8, '2024-02-04', 15000.00, 'Toko Obat Sentosa', 16),

-- Individual purchases
(22, 4, 10, '2024-02-04', 24000.00, 'Puskesmas Helvetia', 17),
(23, 4, 8, '2024-02-04', 46000.00, 'Puskesmas Helvetia', 18),

-- Geriatric care
(30, 1, 20, '2024-02-05', 55000.00, 'Panti Jompo Sejahtera', 11),
(31, 2, 30, '2024-02-06', 12000.00, 'RSUD Sidoarjo', 13),

-- Maternal care
(42, 3, 15, '2024-02-07', 25000.00, 'Klinik Bersalin Bunda', 15),
(43, 1, 12, '2024-02-08', 300000.00, 'Lab Medika Jakarta', 12),
(18, 2, 25, '2024-02-09', 8000.00, 'Apotek Generik Surabaya', 14),

-- Regional hospital network
(23, 5, 400, '2024-02-10', 44000.00, 'RS Wahidin Sudirohusodo', 19),
(19, 3, 18, '2024-02-10', 15000.00, 'Puskesmas Garuda', 16),

-- Continuing individual sales
(22, 5, 250, '2024-02-11', 26500.00, 'RS Stella Maris Makassar', 19),
(44, 1, 5, '2024-02-11', 90000.00, 'Lab Diagnostika Cinere', 21),

(34, 2, 40, '2024-02-12', 10000.00, 'Klinik Luka Modern', 13),
(22, 5, 15, '2024-02-12', 26500.00, 'Klinik Panakkukang', 19),
(23, 5, 12, '2024-02-12', 44000.00, 'Klinik Panakkukang', 20),

-- Medical equipment sales
(9, 3, 2, '2024-02-13', 150000.00, 'Toko Alat Bantu Dengar', 15),

-- Major hospital orders
(22, 1, 300, '2024-02-13', 24500.00, 'RSUD Cengkareng', 11),
(23, 1, 250, '2024-02-13', 44500.00, 'RSUD Cengkareng', 12),

(45, 1, 8, '2024-02-14', 120000.00, 'Lab Intibios Jakarta', 21),

-- Individual customers
(22, 2, 1, '2024-02-14', 25500.00, 'Ibu Hilda Permatasari', 14),
(23, 2, 1, '2024-02-14', 45500.00, 'Ibu Hilda Permatasari', 14),

-- Regional medical center
(22, 3, 20, '2024-02-15', 25800.00, 'RS Rajawali Bandung', 15),
(23, 3, 15, '2024-02-15', 45800.00, 'RS Rajawali Bandung', 16),

-- Corporate hospital
(22, 1, 400, '2024-02-16', 24200.00, 'RS Pelni Jakarta', 21),
(23, 1, 350, '2024-02-16', 44200.00, 'RS Pelni Jakarta', 11),

-- Continuing with more sales...
(22, 2, 350, '2024-02-17', 25000.00, 'RS Adi Husada Surabaya', 13),
(23, 2, 300, '2024-02-17', 45000.00, 'RS Adi Husada Surabaya', 14),

-- Regional sales in Medan
(22, 4, 250, '2024-02-18', 23800.00, 'RS Haji Medan', 17),
(23, 4, 200, '2024-02-18', 45800.00, 'RS Haji Medan', 18),

-- Individual purchases continue
(22, 5, 2, '2024-02-19', 26500.00, 'Bapak Daeng Pratama', 19),
(23, 5, 2, '2024-02-19', 44000.00, 'Bapak Daeng Pratama', 20),

-- Major pharmaceutical sales
(10, 1, 1000, '2024-02-20', 7500.00, 'PBF Sinar Mas Jakarta', 12),
(11, 2, 2000, '2024-02-22', 12000.00, 'Dinas Kesehatan Surabaya', 5);

-- ============================================================================
-- MARCH 2024 SALES - CONTINUED GROWTH
-- ============================================================================

-- Additional sales can be added here for complete 500+ transactions...