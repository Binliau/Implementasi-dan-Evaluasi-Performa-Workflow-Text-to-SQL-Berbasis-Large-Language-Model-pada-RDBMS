const fs = require('fs');

// Read the original file
const data = fs.readFileSync('5_sales_data_part2.sql', 'utf8');
const lines = data.split('\n');

const output = [];
for (const line of lines) {
    // Match INSERT statement
    if (line.includes('INSERT INTO penjualan')) {
        output.push('INSERT INTO penjualan (barang_id, gudang_id, jumlah, tanggal, harga_satuan, nama_pembeli, user_id) VALUES');
    }
    // Match data lines: ('INV/...', barang_id, gudang_id, jumlah, harga, tanggal, nama, kontak, alamat, user_id, status, catatan),
    else if (line.trim().startsWith("('INV")) {
        // Extract: nomor_faktur, barang_id, gudang_id, jumlah, harga, tanggal, nama, kontak, alamat, user_id, status, catatan
        const match = line.match(/'INV[^']+',\s*(\d+),\s*(\d+),\s*(\d+),\s*([\d.]+),\s*'([^']+)',\s*'([^']+)',\s*'[^']*',\s*'[^']*',\s*(\d+),\s*'[^']*',\s*'[^']*'/);
        
        if (match) {
            const [, barang_id, gudang_id, jumlah, harga, tanggal, nama, user_id] = match;
            const suffix = line.trim().endsWith('),') ? ',' : line.trim().endsWith(');') ? ';' : '';
            output.push(`(${barang_id}, ${gudang_id}, ${jumlah}, '${tanggal}', ${harga}, '${nama}', ${user_id})${suffix}`);
        } else {
            // Keep original line if no match
            output.push(line);
        }
    }
    else {
        output.push(line);
    }
}

fs.writeFileSync('5_sales_data_part2_FIXED.sql', output.join('\n'), 'utf8');
console.log('✅ Created 5_sales_data_part2_FIXED.sql');
