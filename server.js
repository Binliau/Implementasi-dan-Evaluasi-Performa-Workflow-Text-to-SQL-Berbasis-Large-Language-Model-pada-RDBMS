// ============================================================================
// NL2SQL SMART ASSISTANT - ULTIMATE MERGE VERSION
// Skripsi: Natural Language to SQL Query Generation
// ============================================================================

const express = require('express');
const cors = require('cors'); // FIX: Tambahkan CORS agar frontend bisa akses
const mysql = require('mysql2/promise');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// ============================================================================
// DATABASE CONNECTION
// ============================================================================

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'inventory_kesehatan',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 5
});

// ============================================================================
// AI SETUP
// ============================================================================

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ 
  model: process.env.GEMINI_MODEL || 'gemini-2.5-flash'
});

// ============================================================================
// SCHEMA DATABASE (Versi Paling Akurat dari kodemu)
// ============================================================================

const DATABASE_INFO = `
Database: inventory_kesehatan (Sistem Manajemen Inventori Alat Kesehatan)

PENTING - KONVENSI PENAMAAN:
- Primary key di setiap tabel punya nama unik (bukan "id"), contoh: gudang_id, barang_id, dll
- Foreign key di tabel lain mengikuti nama yang sama: barang_id, gudang_id, user_id
- Selalu gunakan alias tabel saat query, contoh: SELECT b.barang_id FROM barang b
- Gunakan WHERE aktif = TRUE untuk filter data aktif (soft delete pattern)

TABEL-TABEL:
1. roles (role_id PK, nama_role, deskripsi)
2. users (user_id PK, username, password_hash, nama_lengkap, role_id FK, aktif, dibuat_pada)
3. gudang (gudang_id PK, nama_gudang, alamat, keterangan, aktif)
4. kategori_barang (kategori_id PK, nama_kategori, deskripsi)
5. barang (barang_id PK, kode_barang, nama_barang, kategori_id FK, satuan, deskripsi, aktif)
6. batch_stok (batch_stok_id PK, barang_id FK, gudang_id FK, jumlah, tanggal_kadaluarsa)
7. restock (restock_id PK, barang_id FK, gudang_id FK, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id FK)
8. transfer (transfer_id PK, barang_id FK, dari_gudang_id FK, ke_gudang_id FK, jumlah, tanggal, user_id FK)
9. penjualan (penjualan_id PK, barang_id FK, gudang_id FK, jumlah, tanggal, harga_satuan, nama_pembeli, user_id FK)

VIEWS TERSEDIA:
- v_stok_per_gudang
- v_total_stok
- v_penjualan_lengkap
- v_restock_lengkap
- v_transfer_lengkap
`;

// ============================================================================
// HELPER: Logging Eksperimen & Hitung Biaya Token
// ============================================================================

function logExperiment(entry) {
  const logPath = path.join(__dirname, 'experiment_log.jsonl');
  const line = JSON.stringify(entry) + '\n';
  fs.appendFileSync(logPath, line, 'utf8');
}

function estimateCost(inputTokens, outputTokens) {
  const INPUT_PRICE = 0.15;   // USD per 1M token
  const OUTPUT_PRICE = 0.60;  // USD per 1M token
  const costUsd = (inputTokens / 1_000_000) * INPUT_PRICE + (outputTokens / 1_000_000) * OUTPUT_PRICE;
  return parseFloat(costUsd.toFixed(8));
}

// ============================================================================
// ENDPOINT UTAMA: /api/ask (Menggabungkan Generate & Summarize + Metrik)
// ============================================================================

app.post('/api/ask', async (req, res) => {
  const requestStart = Date.now();
  const { question } = req.body;

  if (!question) return res.status(400).json({ success: false, error: 'Pertanyaan tidak boleh kosong.' });

  const timing = {};
  const tokens = { input: 0, output: 0 };
  let generatedSql = '';
  let queryRows = [];
  let finalAnswer = '';
  let rowsFetched = 0;

  try {
    // --- TAHAP 1: GENERATE SQL ---
    const sqlPrompt = `Anda adalah SQL query generator.
${DATABASE_INFO}

Pertanyaan User: "${question}"
Aturan: Hanya SELECT. Gunakan alias tabel. Sertakan WHERE aktif = TRUE. Gunakan VIEW jika relevan.
Jawab HANYA dengan format JSON: {"sql": "SELECT ...", "explanation": "alasan query"}`;

    const t1Start = Date.now();
    const sqlResult = await model.generateContent(sqlPrompt);
    timing.llm_sql_ms = Date.now() - t1Start;

    const sqlUsage = sqlResult.response.usageMetadata;
    tokens.input += sqlUsage?.promptTokenCount || 0;
    tokens.output += sqlUsage?.candidatesTokenCount || 0;

    const sqlMatch = sqlResult.response.text().match(/\{[\s\S]*\}/);
    if (!sqlMatch) throw new Error('AI gagal menghasilkan JSON.');
    
    const parsed = JSON.parse(sqlMatch[0]);
    generatedSql = parsed.sql.trim();

    // --- TAHAP 2: EKSEKUSI DATABASE ---
    const t2Start = Date.now();
    let dbError = null;
    try {
      const [rows] = await pool.execute(generatedSql);
      queryRows = rows;
      rowsFetched = rows.length;
    } catch (err) {
      dbError = err.message;
    }
    timing.db_query_ms = Date.now() - t2Start;

    // --- TAHAP 3: GENERATE JAWABAN (SUMMARY) ---
    const MAX_ROWS = 50; // Batasi data agar tidak boros token
    const dataForSummary = queryRows.slice(0, MAX_ROWS);
    
    let summaryPrompt = dbError 
      ? `Query gagal: ${dbError}. Jelaskan kegagalan ini ke user.`
      : `Pertanyaan: "${question}". Data (${rowsFetched} baris): ${JSON.stringify(dataForSummary)}. Buat rangkuman jawaban bahasa Indonesia berdasarkan data ini.`;

    const t3Start = Date.now();
    const summaryResult = await model.generateContent(summaryPrompt);
    timing.llm_summary_ms = Date.now() - t3Start;

    const summaryUsage = summaryResult.response.usageMetadata;
    tokens.input += summaryUsage?.promptTokenCount || 0;
    tokens.output += summaryUsage?.candidatesTokenCount || 0;
    finalAnswer = summaryResult.response.text().trim();

    // --- KALKULASI FINAL & LOGGING ---
    timing.total_ms = Date.now() - requestStart;
    const costUsd = estimateCost(tokens.input, tokens.output);

    logExperiment({
      timestamp: new Date().toISOString(),
      question, sql: generatedSql, rows_fetched: rowsFetched,
      timing_ms: timing, tokens, cost_usd: costUsd, error: dbError
    });

    res.json({
      success: true, question, answer: finalAnswer, sql: generatedSql,
      data: dataForSummary, metrics: { timing_ms: timing, tokens, cost_usd: costUsd }
    });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, async () => {
  console.log(`📡 Server berjalan di http://localhost:${PORT}`);
  try {
    await pool.execute('SELECT 1');
    console.log('✅ Database terhubung');
  } catch (error) {
    console.error('❌ Database gagal terhubung:', error.message);
  }
});