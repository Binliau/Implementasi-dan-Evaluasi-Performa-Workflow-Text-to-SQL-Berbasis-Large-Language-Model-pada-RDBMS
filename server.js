// ============================================================================
// SIMPLE SQL QUERY GENERATION API - BASIC VERSION
// Skripsi: Natural Language to SQL Query Generation
// ============================================================================

const express = require('express');
const mysql = require('mysql2/promise');
const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const app = express();
const PORT = 3000;

// Middleware untuk parse JSON
app.use(express.json());

// ============================================================================
// DATABASE CONNECTION (Local MySQL)
// ============================================================================

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'rootpassword',
  database: process.env.DB_NAME || 'inventory_kesehatan',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 5
});

// ============================================================================
// AI SETUP (Google Gemini)
// ============================================================================

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ 
  model: "gemini-2.5-flash"  // Latest stable version
});

// ============================================================================
// SCHEMA DATABASE (untuk context AI)
// ============================================================================

const DATABASE_INFO = `
Database: inventory_kesehatan (Healthcare Inventory Management)

Tables and Columns:
1. gudang (id, nama_gudang, alamat, keterangan)
2. barang (id, kode_barang, nama_barang, kategori_id, satuan, deskripsi)
3. kategori_barang (id, nama_kategori, deskripsi)
4. batch_stok (id, barang_id, gudang_id, jumlah, tanggal_kadaluarsa)
5. restock (id, barang_id, gudang_id, jumlah, tanggal, nomor_batch, tanggal_kadaluarsa, user_id)
6. penjualan (id, barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id)
7. transfer (id, barang_id, dari_gudang_id, ke_gudang_id, jumlah, tanggal, user_id)
8. users (id, username, nama_lengkap, role_id, password)
9. roles (id, nama_role, deskripsi)

Important relationships:
- barang.kategori_id → kategori_barang.id
- users.role_id → roles.id
- batch_stok.barang_id → barang.id
- batch_stok.gudang_id → gudang.id
- restock.barang_id → barang.id
- restock.gudang_id → gudang.id
- restock.user_id → users.id
- penjualan.barang_id → barang.id
- penjualan.gudang_id → gudang.id
- penjualan.user_id → users.id
- transfer.barang_id → barang.id
- transfer.dari_gudang_id → gudang.id
- transfer.ke_gudang_id → gudang.id
- transfer.user_id → users.id
`;

// ============================================================================
// ENDPOINT 1: GENERATE QUERY
// ============================================================================

app.post('/api/generate-query', async (req, res) => {
  try {
    const { question } = req.body;

    if (!question) {
      return res.status(400).json({
        success: false,
        error: 'Pertanyaan tidak boleh kosong'
      });
    }

    console.log('📝 Question:', question);

    // Prompt untuk AI
    const prompt = `Anda adalah SQL query generator untuk sistem inventory alat kesehatan.

${DATABASE_INFO}

Pertanyaan User: "${question}"

Buatlah SQL query MySQL yang menjawab pertanyaan tersebut.
Response dalam format JSON berikut:
{
  "sql": "SELECT ... FROM ... WHERE ...",
  "explanation": "Penjelasan singkat dalam Bahasa Indonesia"
}

Aturan:
- Hanya SELECT query
- Gunakan JOIN jika perlu menggabungkan tabel
- Gunakan nama tabel/kolom yang sesuai schema di atas

Response JSON:`;

    // Kirim ke Gemini AI
    const result = await model.generateContent(prompt);
    const aiResponse = result.response.text();
    console.log('AI Response:', aiResponse);

    // Parse JSON dari response AI
    const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
    const parsedResponse = jsonMatch ? JSON.parse(jsonMatch[0]) : null;

    if (!parsedResponse || !parsedResponse.sql) {
      throw new Error('AI tidak menghasilkan SQL yang valid');
    }

    // Eksekusi SQL ke database
    let data = [];
    let row_count = 0;
    try {
      const [rows] = await pool.execute(parsedResponse.sql);
      data = rows;
      row_count = rows.length;
      console.log(`Query executed, ${row_count} rows found`);
    } catch (dbErr) {
      console.error('SQL Execution Error:', dbErr.message);
      // Tetap kembalikan SQL dan explanation, tapi data kosong dan error info
      return res.json({
        success: false,
        question: question,
        sql: parsedResponse.sql,
        explanation: parsedResponse.explanation,
        error: 'SQL execution error: ' + dbErr.message
      });
    }

    res.json({
      success: true,
      question: question,
      sql: parsedResponse.sql,
      explanation: parsedResponse.explanation,
      data: data,
      row_count: row_count
    });

  } catch (error) {
    console.error('ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// ============================================================================
// ENDPOINT 2: SUMMARIZE DATA
// ============================================================================

app.post('/api/summarize-data', async (req, res) => {
  try {
    const { query_description } = req.body;

    if (!query_description) {
      return res.status(400).json({
        success: false,
        error: 'Deskripsi query tidak boleh kosong'
      });
    }

    console.log('Summarize request:', query_description);

    // Step 1: Generate SQL menggunakan AI
    const sqlPrompt = `${DATABASE_INFO}

Pertanyaan: "${query_description}"

Buatlah SELECT query MySQL. Response format JSON:
{
  "sql": "SELECT ... FROM ..."
}`;

    const sqlResult = await model.generateContent(sqlPrompt);
    const sqlText = sqlResult.response.text();
    const sqlMatch = sqlText.match(/\{[\s\S]*\}/);
    const sqlParsed = sqlMatch ? JSON.parse(sqlMatch[0]) : null;

    if (!sqlParsed || !sqlParsed.sql) {
      throw new Error('Gagal generate SQL');
    }

    const generatedSQL = sqlParsed.sql;
    console.log('Generated SQL:', generatedSQL);

    // Step 2: Execute SQL ke database
    const [rows] = await pool.execute(generatedSQL);
    console.log(`Query executed, ${rows.length} rows found`);

    // Step 3: Summarize data dengan AI
    const summaryPrompt = `Berikut adalah hasil query database:

SQL Query: ${generatedSQL}
Data (${rows.length} rows): ${JSON.stringify(rows.slice(0, 10))}

Buatlah ringkasan data dalam Bahasa Indonesia yang mudah dipahami.
Jelaskan apa yang ditunjukkan oleh data ini.

Ringkasan:`;

    const summaryResult = await model.generateContent(summaryPrompt);
    const summary = summaryResult.response.text();

    res.json({
      success: true,
      sql: generatedSQL,
      data: rows,
      row_count: rows.length,
      summary: summary
    });

  } catch (error) {
    console.error('ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// ============================================================================
// ENDPOINT: Health Check
// ============================================================================

app.get('/api/health', async (req, res) => {
  try {
    // Test database
    await pool.execute('SELECT 1');
    
    res.json({
      success: true,
      message: 'Server berjalan dengan baik',
      database: 'Connected',
      ai: 'Gemini 2.0 Flash'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, async () => {
  try {
    // Test database connection
    await pool.execute('SELECT 1');
    console.log('Database connected');
    
    console.log('Server started!');
    console.log(`URL: http://localhost:${PORT}`);
    console.log('');
    console.log('Available Endpoints:');
    console.log('   GET  /api/health');
    console.log('   POST /api/generate-query');
    console.log('   POST /api/summarize-data');
    console.log('');
  } catch (error) {
    console.error('Database connection failed:', error.message);
    console.log('Make sure MySQL is running and database exists!');
  }
});