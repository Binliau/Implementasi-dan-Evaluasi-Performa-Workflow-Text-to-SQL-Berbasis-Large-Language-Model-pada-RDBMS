# ⚡ QUICK START - SQL Query Generation API

## 🎯 LANGKAH CEPAT (5 Menit)

### 1️⃣ Setup Password MySQL di server.js
Edit file `server.js` baris 24:
```javascript
password: '',  // Ganti dengan password MySQL Anda (atau kosongkan jika tidak ada password)
```

### 2️⃣ Pastikan Database Sudah Ada
Buka MySQL Command Line:
```sql
USE inventory_kesehatan;
SHOW TABLES;
```
Jika belum ada, copy-paste file SQL ini satu-satu:
1. `mysql_setup_v1.1.sql`
2. `2_master_data.sql`
3. `3_initial_stock.sql`

### 3️⃣ Install Dependencies (Sudah Selesai ✅)
```bash
npm install
```

### 4️⃣ Jalankan Server
```bash
node server.js
```

Jika sukses akan muncul:
```
✅ Database connected
🚀 Server started!
📡 URL: http://localhost:3000
```

### 5️⃣ Test API (Buka PowerShell Baru)
```bash
node test-api.js
```

---

## 📡 ENDPOINT API

### 1. Generate Query
```bash
POST http://localhost:3000/api/generate-query
Body: { "question": "Tampilkan semua gudang" }
```

### 2. Summarize Data  
```bash
POST http://localhost:3000/api/summarize-data
Body: { "query_description": "Berapa total barang?" }
```

### 3. Health Check
```bash
GET http://localhost:3000/api/health
```

---

## 🐛 TROUBLESHOOTING

**Error: Access denied for user 'root'**
→ Edit password di `server.js` baris 24

**Error: Database 'inventory_kesehatan' not found**
→ Buat database dengan run file `mysql_setup_v1.1.sql`

**Error: Cannot find module**
→ Run `npm install`

---

## 📝 CONTOH REQUEST

### Test dengan cURL (PowerShell):
```powershell
# Health check
curl http://localhost:3000/api/health

# Generate query
curl -X POST http://localhost:3000/api/generate-query `
  -H "Content-Type: application/json" `
  -d '{\"question\": \"Tampilkan 5 gudang pertama\"}'

# Summarize data
curl -X POST http://localhost:3000/api/summarize-data `
  -H "Content-Type: application/json" `
  -d '{\"query_description\": \"Total barang per gudang\"}'
```

---

## ✅ CHECKLIST

- [ ] MySQL running
- [ ] Database `inventory_kesehatan` exists
- [ ] Password di `server.js` sudah benar
- [ ] `npm install` sudah dijalankan
- [ ] Server running dengan `node server.js`
- [ ] Test dengan `node test-api.js`

**Semua checklist ✅ = SIAP UNTUK SKRIPSI! 🎓**