// ============================================================================
// utils/queryComplexity.js
// Klasifikasi kompleksitas query SQL
// Mengikuti logika Spider benchmark (Yu et al., 2018)
// Referensi: evaluation.py — count_component1, count_component2, count_others
// ============================================================================

function classifyQueryComplexity(sql) {
  if (!sql || typeof sql !== 'string') return 'unknown';

  const u        = sql.toUpperCase();
  const stripped = u.replace(/'[^']*'/g, "''").replace(/"[^"]*"/g, '""');

  // ── count_component1 ────────────────────────────────────────────────────
  // Persis seperti Python Spider:
  //   +1 jika ada WHERE
  //   +1 jika ada GROUP BY
  //   +1 jika ada ORDER BY
  //   +1 jika ada LIMIT
  //   +(jumlah JOIN) — semua varian (LEFT/INNER/dll) mengandung kata JOIN
  //   +(jumlah OR di where/having)
  //   +(jumlah LIKE di where/having)
  // Semua hanya dihitung di level teratas (bukan di dalam subquery/OVER)
  let comp1 = 0;
  if (findTopLevelKeyword(stripped, 'WHERE')    !== -1) comp1 += 1;
  if (findTopLevelKeyword(stripped, 'GROUP BY') !== -1) comp1 += 1;
  if (findTopLevelKeyword(stripped, 'ORDER BY') !== -1) comp1 += 1;
  if (findTopLevelKeyword(stripped, 'LIMIT')    !== -1) comp1 += 1;

  // JOIN: cukup hitung kata JOIN saja — LEFT JOIN, INNER JOIN, dll
  // semuanya mengandung kata JOIN, tidak ada double count
  comp1 += countTopLevelKeyword(stripped, 'JOIN');
  comp1 += countTopLevelKeyword(stripped, 'OR');
  comp1 += countTopLevelKeyword(stripped, 'LIKE');

  // ── count_component2 ────────────────────────────────────────────────────
  // +1 per set operation (UNION, EXCEPT, INTERSECT)
  // +n per nested SELECT sejati (bukan SELECT dari set operation itu sendiri)
  const hasUnion     = findTopLevelKeyword(stripped, 'UNION')     !== -1;
  const hasExcept    = findTopLevelKeyword(stripped, 'EXCEPT')    !== -1;
  const hasIntersect = findTopLevelKeyword(stripped, 'INTERSECT') !== -1;

  let comp2 = (hasUnion ? 1 : 0) + (hasExcept ? 1 : 0) + (hasIntersect ? 1 : 0);

  const totalSelect  = (stripped.match(/\bSELECT\b/g) || []).length;
  const setOpSelects = (hasUnion ? 1 : 0) + (hasExcept ? 1 : 0) + (hasIntersect ? 1 : 0);
  comp2 += Math.max(0, totalSelect - 1 - setOpSelects);

  // ── count_others ────────────────────────────────────────────────────────
  // +1 jika jumlah agregasi (SUM/COUNT/AVG/MAX/MIN) > 1
  // +1 jika kolom SELECT > 1
  // +1 jika kondisi WHERE > 1
  // +1 jika kolom GROUP BY > 1
  let others = 0;

  const aggCount = (stripped.match(/\b(SUM|COUNT|AVG|MAX|MIN)\s*\(/g) || []).length;
  if (aggCount > 1) others += 1;

  const selectClause = extractTopLevelSelectClause(stripped);
  if (countTopLevelCommas(selectClause) + 1 > 1) others += 1;

  const whereClause = extractWhereClause(stripped);
  if (whereClause.length > 0) {
    const andOrCount = countTopLevelKeyword(whereClause, 'AND') + countTopLevelKeyword(whereClause, 'OR');
    if (andOrCount + 1 > 1) others += 1;
  }

  const groupByClause = extractGroupByClause(stripped);
  if (groupByClause.length > 0 && countTopLevelCommas(groupByClause) + 1 > 1) others += 1;

  // ── eval_hardness ───────────────────────────────────────────────────────
  if (comp1 <= 1 && others === 0 && comp2 === 0) return 'easy';

  if ((others <= 2 && comp1 <= 1 && comp2 === 0) ||
      (comp1 <= 2 && others < 2  && comp2 === 0)) return 'medium';

  if ((others > 2  && comp1 <= 2 && comp2 === 0)                ||
      (comp1 > 2   && comp1 <= 3 && others <= 2 && comp2 === 0) ||
      (comp1 <= 1  && others === 0 && comp2 <= 1))               return 'hard';

  return 'extra';
}

// ── Utilitas internal ────────────────────────────────────────────────────────

// Cari posisi pertama keyword di level teratas (depth kurung = 0)
function findTopLevelKeyword(sql, keyword, startFrom = 0) {
  let depth = 0, i = startFrom;
  while (i < sql.length) {
    if (sql[i] === '(') { depth++; i++; continue; }
    if (sql[i] === ')') { depth--; i++; continue; }
    if (depth === 0 && sql.startsWith(keyword, i)) {
      const before = i === 0 || /\W/.test(sql[i - 1]);
      const after  = i + keyword.length >= sql.length || /\W/.test(sql[i + keyword.length]);
      if (before && after) return i;
    }
    i++;
  }
  return -1;
}

// Hitung jumlah kemunculan keyword di level teratas
function countTopLevelKeyword(sql, keyword, startFrom = 0) {
  let count = 0, pos = startFrom;
  while (true) {
    const idx = findTopLevelKeyword(sql, keyword, pos);
    if (idx === -1) break;
    count++;
    pos = idx + keyword.length;
  }
  return count;
}

// Hitung koma di level teratas
function countTopLevelCommas(str) {
  let depth = 0, count = 0;
  for (const ch of str) {
    if (ch === '(')      depth++;
    else if (ch === ')') depth--;
    else if (ch === ',' && depth === 0) count++;
  }
  return count;
}

// Ekstrak isi antara SELECT dan FROM level teratas
function extractTopLevelSelectClause(sql) {
  const fromIdx = findTopLevelKeyword(sql, 'FROM');
  if (fromIdx === -1) return sql;
  const selectIdx = sql.indexOf('SELECT');
  return selectIdx === -1 ? '' : sql.slice(selectIdx + 6, fromIdx).trim();
}

// Ekstrak klausa WHERE level teratas
function extractWhereClause(sql) {
  const whereIdx = findTopLevelKeyword(sql, 'WHERE');
  if (whereIdx === -1) return '';
  let endIdx = sql.length;
  for (const term of ['GROUP BY', 'ORDER BY', 'HAVING', 'LIMIT', 'UNION', 'INTERSECT', 'EXCEPT']) {
    const idx = findTopLevelKeyword(sql, term, whereIdx + 5);
    if (idx !== -1 && idx < endIdx) endIdx = idx;
  }
  return sql.slice(whereIdx + 5, endIdx).trim();
}

// Ekstrak klausa GROUP BY level teratas
function extractGroupByClause(sql) {
  const groupIdx = findTopLevelKeyword(sql, 'GROUP BY');
  if (groupIdx === -1) return '';
  let endIdx = sql.length;
  for (const term of ['ORDER BY', 'HAVING', 'LIMIT', 'UNION', 'INTERSECT', 'EXCEPT']) {
    const idx = findTopLevelKeyword(sql, term, groupIdx + 8);
    if (idx !== -1 && idx < endIdx) endIdx = idx;
  }
  return sql.slice(groupIdx + 8, endIdx).trim();
}

module.exports = { classifyQueryComplexity };


// ── TEST ─────────────────────────────────────────────────────────────────────
// Jalankan: node utils/queryComplexity.js
if (require.main === module) {
  const cases = [
    // [deskripsi, sql, expected]
    ['1 kolom, tanpa kondisi',
      `SELECT gudang_id FROM gudang`, 'easy'],

    ['COUNT + WHERE 1 kondisi',
      `SELECT COUNT(*) FROM barang WHERE aktif = TRUE`, 'easy'],

    ['LIMIT saja',
      `SELECT * FROM penjualan LIMIT 10`, 'easy'],

    ['2 kolom + WHERE',
      `SELECT gudang_id, nama_gudang FROM gudang WHERE aktif = TRUE`, 'medium'],

    ['GROUP BY + 1 JOIN',
      `SELECT k.nama_kategori, COUNT(*) FROM barang b JOIN kategori_barang k ON b.kategori_id = k.kategori_id GROUP BY k.kategori_id`, 'medium'],

    ['Window RANK() — ORDER BY di dalam OVER() tidak terhitung',
      `SELECT gudang_id, SUM(jumlah) AS total, RANK() OVER (ORDER BY SUM(jumlah) DESC) FROM batch_stok GROUP BY gudang_id`, 'medium'],

    ['WHERE + LIKE',
      `SELECT nama_barang FROM barang WHERE nama_barang LIKE '%masker%' AND aktif = TRUE`, 'medium'],

    ['Subquery NOT IN',
      `SELECT nama_barang FROM barang WHERE barang_id NOT IN (SELECT DISTINCT barang_id FROM penjualan)`, 'hard'],

    ['UNION ALL',
      `SELECT nama_barang FROM barang WHERE aktif = TRUE UNION ALL SELECT nama_barang FROM barang WHERE aktif = FALSE`, 'hard'],

    ['GROUP BY + HAVING + 2 JOIN',
      `SELECT g.nama_gudang, COUNT(p.penjualan_id) FROM penjualan p JOIN gudang g ON p.gudang_id = g.gudang_id JOIN barang b ON p.barang_id = b.barang_id GROUP BY g.gudang_id HAVING COUNT(*) > 10`, 'hard'],
  ];

  console.log('=== TEST queryComplexity.js ===\n');
  let pass = 0;
  for (const [desc, sql, expected] of cases) {
    const result = classifyQueryComplexity(sql);
    const ok     = result === expected;
    if (ok) pass++;
    console.log(`${ok ? '✅' : '❌'} [${result.padEnd(6)} | exp: ${expected}] ${desc}`);
    if (!ok) console.log(`   SQL: ${sql.slice(0, 80)}`);
  }
  console.log(`\n${pass}/${cases.length} passed`);
}