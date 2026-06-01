// ============================================================================
// NL2SQL SMART ASSISTANT - BACKEND
// Skripsi: Implementasi dan Evaluasi Performa Workflow Text-to-SQL
//          Berbasis Large Language Model pada Basis Data Relasional
// ============================================================================

const express = require('express');
const cors    = require('cors');
const mysql   = require('mysql2/promise');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs   = require('fs');
const path = require('path');
require('dotenv').config();

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// ============================================================================
// DATABASE CONNECTION (READ ONLY)
// ============================================================================

const pool = mysql.createPool({
  host:             process.env.DB_HOST     || 'localhost',
  user:             process.env.DB_USER     || 'root',
  password:         process.env.DB_PASSWORD || '',
  database:         process.env.DB_NAME     || 'inventory_kesehatan',
  port:             process.env.DB_PORT     || 3306,
  waitForConnections: true,
  connectionLimit:  5,
});

// ============================================================================
// AI SETUP
// ============================================================================

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({
  model: process.env.GEMINI_MODEL || 'gemini-2.5-flash',
});

// ============================================================================
// SCHEMA DESCRIPTION
// ============================================================================

let DATABASE_SCHEMA = '';

function loadSchema() {
  const schemaPath = path.join(__dirname, 'schema_description.txt');
  if (fs.existsSync(schemaPath)) {
    DATABASE_SCHEMA = fs.readFileSync(schemaPath, 'utf8');
    console.log('✅ Schema loaded:', DATABASE_SCHEMA.length, 'karakter');
  } else {
    console.error('❌ schema_description.txt tidak ditemukan!');
    process.exit(1);
  }
}

loadSchema();

// ============================================================================
// LOGGING EKSPERIMEN
// ============================================================================

function logExperiment(entry) {
  const logPath = path.join(__dirname, 'experiment_log.jsonl');
  fs.appendFileSync(logPath, JSON.stringify(entry) + '\n', 'utf8');
}

// ============================================================================
// HELPER: Hitung cost per tahap secara terpisah
// Harga Gemini 2.5 Flash (Mei 2025):
//   Input : $0.15 / 1M token
//   Output: $1.25 / 1M token
//
// Dipisah per tahap agar bisa menjawab pertanyaan riset:
//   - Apakah cost didominasi jumlah data di-query? → lihat summarize_answer.input_tokens
//     (makin banyak rows_to_llm, makin besar token input Summarize Answer)
//   - Apakah cost didominasi kompleksitas query?   → lihat generate_sql.output_tokens
//     (query kompleks → SQL lebih panjang → output token Generate SQL lebih besar)
//   - Apakah cost didominasi jumlah data ditampilkan? → bandingkan
//     rows_fetched vs rows_to_llm vs summarize_answer.input_tokens
// ============================================================================

const INPUT_PRICE_PER_M  = 0.15;
const OUTPUT_PRICE_PER_M = 1.25;

function calcCost(inputTokens, outputTokens) {
  return parseFloat((
    (inputTokens  / 1_000_000) * INPUT_PRICE_PER_M +
    (outputTokens / 1_000_000) * OUTPUT_PRICE_PER_M
  ).toFixed(8));
}

function buildTokenCostBreakdown(t1Input, t1Output, t3Input, t3Output) {
  const generate_sql = {
    input_tokens:  t1Input,
    output_tokens: t1Output,
    cost_usd:      calcCost(t1Input, t1Output),
  };
  const summarize_answer = {
    input_tokens:  t3Input,
    output_tokens: t3Output,
    cost_usd:      calcCost(t3Input, t3Output),
  };
  const total = {
    input_tokens:  t1Input  + t3Input,
    output_tokens: t1Output + t3Output,
    cost_input_usd:  parseFloat(((t1Input  + t3Input)  / 1_000_000 * INPUT_PRICE_PER_M ).toFixed(8)),
    cost_output_usd: parseFloat(((t1Output + t3Output) / 1_000_000 * OUTPUT_PRICE_PER_M).toFixed(8)),
    cost_usd:      calcCost(t1Input + t3Input, t1Output + t3Output),
  };
  return { generate_sql, summarize_answer, total };
}

// ============================================================================
// HELPER: Klasifikasi kompleksitas query
// Berdasarkan standar Spider benchmark (Yu et al., 2018)
// ============================================================================

const { classifyQueryComplexity } = require('./classifyQueryComplexity'); 

// ============================================================================
// ENDPOINT UTAMA: POST /api/ask
// ============================================================================

app.post('/api/ask', async (req, res) => {
  const requestStart = Date.now();
  const { question } = req.body;

  if (!question || question.trim() === '') {
    return res.status(400).json({ success: false, error: 'Pertanyaan tidak boleh kosong.' });
  }

  console.log('\n─────────────────────────────────────');
  console.log('Pertanyaan :', question);

  const timing = {};

  // Token dipisah per tahap — ini yang menjawab pertanyaan riset dosen
  let t1InputTokens  = 0, t1OutputTokens  = 0;
  let t3InputTokens  = 0, t3OutputTokens  = 0;

  let generatedSql   = '';
  let sqlExplanation = '';
  let queryRows      = [];
  let rowsFetched    = 0;
  let finalAnswer    = '';
  let dbError        = null;

  try {

    // ─────────────────────────────────────────────────────────────────────
    // TAHAP 1: GENERATE SQL  (LLM Call #1)
    // Token yang dicatat di sini mencerminkan biaya "memahami pertanyaan
    // + schema + menghasilkan SQL". Kompleksitas query yang lebih tinggi
    // akan menghasilkan output_tokens yang lebih besar di tahap ini.
    // ─────────────────────────────────────────────────────────────────────

    const sqlPrompt =
`Anda adalah generator SQL untuk sistem inventaris alat kesehatan.
Baca skema berikut dengan teliti sebelum membuat query.

${DATABASE_SCHEMA}

Pertanyaan pengguna: "${question}"

Aturan ketat:
1. Hanya boleh membuat SELECT query. Dilarang INSERT, UPDATE, DELETE, DROP.
2. Selalu gunakan alias tabel (FROM barang b, bukan FROM barang).
3. JOIN harus simetris sesuai skema: ON b.kategori_id = kb.kategori_id
4. Untuk barang/gudang aktif, tambahkan: WHERE b.aktif = TRUE / g.aktif = TRUE
5. Gunakan VIEW (v_total_stok, v_penjualan_lengkap, dll) jika pertanyaan
   menyangkut stok sekarang, penjualan lengkap, atau transfer antar gudang.
6. Gunakan nama kolom PERSIS seperti di skema.

Jawab HANYA dengan JSON berikut, tanpa teks tambahan, tanpa markdown:
{"sql": "SELECT ...", "explanation": "penjelasan singkat dalam Bahasa Indonesia"}`;

    const t1Start  = Date.now();
    const sqlResult = await model.generateContent(sqlPrompt);
    timing.llm_sql_ms = Date.now() - t1Start;

    // Catat token TAHAP 1 ke variabel terpisah
    const sqlUsage    = sqlResult.response.usageMetadata;
    t1InputTokens     = sqlUsage?.promptTokenCount     || 0;
    t1OutputTokens    = sqlUsage?.candidatesTokenCount || 0;

    const sqlText  = sqlResult.response.text().trim();
    const sqlMatch = sqlText.match(/\{[\s\S]*\}/);
    if (!sqlMatch) throw new Error('LLM tidak menghasilkan JSON valid untuk SQL.');

    let parsed;
    try   { parsed = JSON.parse(sqlMatch[0]); }
    catch (e) { throw new Error('Gagal parse JSON dari LLM: ' + e.message); }

    if (!parsed.sql) throw new Error('LLM tidak menghasilkan kolom "sql".');

    generatedSql   = parsed.sql.trim();
    sqlExplanation = parsed.explanation || '';

    // Pastikan diawali dengan SELECT
    if (!generatedSql.toUpperCase().startsWith('SELECT')) {
      throw new Error('LLM menghasilkan query non-SELECT: ' + generatedSql);
    }

    // Cegah Multiple Statements dan DML/DDL (SQL Injection Guardrail)
    // Regex ini mencari apakah ada perintah berbahaya setelah spasi atau titik koma
    const forbiddenKeywords = /;\s*(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE|REPLACE)\b/i;
    if (forbiddenKeywords.test(generatedSql)) {
      throw new Error('Keamanan: Terdeteksi percobaan modifikasi data (SQL Injection). Query ditolak!');
    }

    const complexity = classifyQueryComplexity(generatedSql);
    console.log('SQL        :', generatedSql);
    console.log('Kompleksitas:', complexity);
    console.log('T1 tokens  : input=%d output=%d', t1InputTokens, t1OutputTokens);

    // ─────────────────────────────────────────────────────────────────────
    // TAHAP 2: EKSEKUSI QUERY KE DATABASE
    // rows_fetched vs rows_to_llm adalah variabel kunci untuk menjawab:
    // "apakah cost didominasi jumlah data yang di-query atau yang ditampilkan?"
    // ─────────────────────────────────────────────────────────────────────

    const t2Start = Date.now();
    try {
      const [rows] = await pool.execute(generatedSql);
      queryRows   = rows;
      rowsFetched = rows.length;
    } catch (err) {
      dbError = err.message;
      console.error('DB Error   :', err.message);
    }
    timing.db_query_ms = Date.now() - t2Start;
    console.log('Rows fetched:', rowsFetched);

    // ─────────────────────────────────────────────────────────────────────
    // TAHAP 3: GENERATE JAWABAN  (LLM Call #2)
    // Token input Tahap 3 sangat dipengaruhi oleh rows_to_llm:
    //   - rows_fetched = 1   → input_tokens kecil  → cost kecil
    //   - rows_fetched = 50+ → input_tokens besar  → cost lebih besar
    // Ini memungkinkan analisis: "apakah cost naik proporsional dengan data?"
    // ─────────────────────────────────────────────────────────────────────

    const MAX_ROWS_TO_LLM = 50;
    const dataForSummary  = queryRows.slice(0, MAX_ROWS_TO_LLM);
    const rowsToLlm       = dataForSummary.length;
    const isTruncated     = rowsFetched > MAX_ROWS_TO_LLM;

    let summaryPrompt;
    if (dbError) {
      summaryPrompt =
`Pengguna bertanya: "${question}"
Query SQL yang dihasilkan: ${generatedSql}
Terjadi error saat eksekusi: ${dbError}

Jelaskan dalam Bahasa Indonesia bahwa terjadi kesalahan teknis.
Sarankan cara pertanyaan yang lebih spesifik jika memungkinkan.`;
    } else {
      summaryPrompt =
`Pengguna bertanya: "${question}"

Query SQL yang digunakan:
${generatedSql}

Jumlah baris data: ${rowsFetched}${isTruncated ? ` (ditampilkan ${MAX_ROWS_TO_LLM} baris pertama)` : ''}
Data hasil query:
${JSON.stringify(dataForSummary, null, 2)}

Jawab pertanyaan pengguna dalam Bahasa Indonesia yang jelas dan ringkas
berdasarkan data di atas. Jika data kosong, sampaikan tidak ada data yang sesuai.`;
    }

    const t3Start = Date.now();
    const summaryResult = await model.generateContent(summaryPrompt);
    timing.llm_summary_ms = Date.now() - t3Start;

    // Catat token TAHAP 3 ke variabel terpisah
    const summaryUsage = summaryResult.response.usageMetadata;
    t3InputTokens      = summaryUsage?.promptTokenCount     || 0;
    t3OutputTokens     = summaryUsage?.candidatesTokenCount || 0;

    finalAnswer = summaryResult.response.text().trim();

    console.log('T3 tokens  : input=%d output=%d', t3InputTokens, t3OutputTokens);

    // ─────────────────────────────────────────────────────────────────────
    // KALKULASI FINAL — dipisah per tahap dan per jenis (input vs output)
    // ─────────────────────────────────────────────────────────────────────

    timing.total_ms  = Date.now() - requestStart;
    const tokenCost  = buildTokenCostBreakdown(t1InputTokens, t1OutputTokens, t3InputTokens, t3OutputTokens);

    console.log('Timing     :', timing);
    console.log('Cost total :', tokenCost.total.cost_usd, 'USD');

    // ─────────────────────────────────────────────────────────────────────
    // LOG KE FILE — struktur lengkap untuk analisis Bab 4
    //
    // Variabel yang bisa dianalisis korelasi-nya:
    //   complexity      vs generate_sql.output_tokens  → kompleksitas query
    //   rows_fetched    vs summarize_answer.input_tokens   → jumlah data di-query
    //   rows_to_llm     vs summarize_answer.input_tokens   → jumlah data ditampilkan
    //   total.cost_usd  vs semua faktor di atas  → dominasi biaya
    // ─────────────────────────────────────────────────────────────────────

    logExperiment({
      timestamp:       new Date().toISOString(),
      question,
      sql:             generatedSql,
      sql_explanation: sqlExplanation,
      complexity,
      rows_fetched:    rowsFetched,
      rows_to_llm:     rowsToLlm,
      timing_ms:       timing,
      tokens:          tokenCost,   // DIPISAH per tahap
      db_error:        dbError || null,
    });

    // ─────────────────────────────────────────────────────────────────────
    // RESPONSE KE FRONTEND
    // ─────────────────────────────────────────────────────────────────────

    res.json({
      success:      true,
      question,
      answer:       finalAnswer,
      sql:          generatedSql,
      explanation:  sqlExplanation,
      rows_fetched: rowsFetched,
      data:         dataForSummary,
      metrics: {
        timing_ms:  timing,
        tokens:     tokenCost,
        complexity,
      },
    });

  } catch (error) {
    timing.total_ms  = Date.now() - requestStart;
    console.error('ERROR      :', error.message);

    const tokenCost = buildTokenCostBreakdown(t1InputTokens, t1OutputTokens, t3InputTokens, t3OutputTokens);

    logExperiment({
      timestamp:    new Date().toISOString(),
      question,
      sql:          generatedSql || null,
      complexity:   classifyQueryComplexity(generatedSql),
      rows_fetched: rowsFetched,
      rows_to_llm:  0,
      timing_ms:    timing,
      tokens:       tokenCost,
      error:        error.message,
    });

    res.status(500).json({
      success: false,
      error:   error.message,
      metrics: { timing_ms: timing, tokens: tokenCost },
    });
  }
});

// ============================================================================
// ENDPOINT: GET /api/health
// ============================================================================

app.get('/api/health', async (req, res) => {
  try {
    await pool.execute('SELECT 1');
    res.json({
      success:      true,
      message:      'Server berjalan dengan baik',
      database:     'Connected',
      model:        process.env.GEMINI_MODEL || 'gemini-2.5-flash',
      schema_chars: DATABASE_SCHEMA.length,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// ENDPOINT: GET /api/logs
// ============================================================================

app.get('/api/logs', (req, res) => {
  const logPath = path.join(__dirname, 'experiment_log.jsonl');
  if (!fs.existsSync(logPath)) return res.json({ success: true, count: 0, logs: [] });
  const logs = fs.readFileSync(logPath, 'utf8')
    .split('\n').filter(l => l.trim())
    .map(l => JSON.parse(l));
  res.json({ success: true, count: logs.length, logs });
});

// ============================================================================
// ENDPOINT: DELETE /api/logs  (reset sebelum eksperimen baru)
// ============================================================================

app.delete('/api/logs', (req, res) => {
  const logPath = path.join(__dirname, 'experiment_log.jsonl');
  if (fs.existsSync(logPath)) fs.unlinkSync(logPath);
  res.json({ success: true, message: 'Log berhasil dihapus.' });
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, async () => {
  console.log('─────────────────────────────────────');
  console.log(`Server    : http://localhost:${PORT}`);
  console.log('Endpoints :');
  console.log('  GET    /api/health');
  console.log('  POST   /api/ask       ← endpoint utama');
  console.log('  GET    /api/logs      ← lihat log eksperimen');
  console.log('  DELETE /api/logs      ← reset log');
  console.log('─────────────────────────────────────');
  try {
    await pool.execute('SELECT 1');
    console.log('Database  : ✅ Terhubung');
  } catch (error) {
    console.error('Database  : ❌ Gagal —', error.message);
  }
  console.log('─────────────────────────────────────');
});