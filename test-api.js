// ============================================================================
// TEST API SCRIPT - Simple Testing
// ============================================================================

const http = require('http');

console.log('🧪 Testing SQL Query Generation API...\n');

const API_HOST = 'localhost';
const API_PORT = 3000;

// Helper function untuk HTTP request
function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: API_HOST,
      port: API_PORT,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          resolve(body);
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// ============================================================================
// TEST 1: Health Check
// ============================================================================

async function testHealth() {
  console.log('1️⃣  Testing Health Check...');
  try {
    const data = await makeRequest('GET', '/api/health');
    console.log('✅ Health:', data);
    return true;
  } catch (error) {
    console.log('❌ Health check failed:', error.message);
    return false;
  }
}

// ============================================================================
// TEST 2: Generate Query
// ============================================================================

async function testGenerateQuery() {
  console.log('\n2️⃣  Testing Generate Query...');
  
  const questions = [
    'Tampilkan semua gudang',
    'Berapa total barang di gudang Jakarta?',
    'Siapa saja user yang ada di sistem?'
  ];

  for (const question of questions) {
    console.log(`\n📝 Question: "${question}"`);
    
    try {
      const data = await makeRequest('POST', '/api/generate-query', { question });
      
      if (data.success) {
        console.log('✅ SQL:', data.sql);
        console.log('📖 Explanation:', data.explanation);
      } else {
        console.log('❌ Error:', data.error);
      }
    } catch (error) {
      console.log('❌ Request failed:', error.message);
    }
  }
}

// ============================================================================
// TEST 3: Summarize Data
// ============================================================================

async function testSummarizeData() {
  console.log('\n3️⃣  Testing Summarize Data...');
  
  const query = 'Tampilkan 5 gudang pertama';
  console.log(`\n📊 Query: "${query}"`);
  
  try {
    const data = await makeRequest('POST', '/api/summarize-data', { 
      query_description: query 
    });
    
    if (data.success) {
      console.log('✅ SQL:', data.sql);
      console.log('📊 Row Count:', data.row_count);
      console.log('📝 Summary:', data.summary.substring(0, 200) + '...');
    } else {
      console.log('❌ Error:', data.error);
    }
  } catch (error) {
    console.log('❌ Request failed:', error.message);
  }
}

// ============================================================================
// RUN ALL TESTS
// ============================================================================

async function runTests() {
  const healthOk = await testHealth();
  
  if (!healthOk) {
    console.log('\n❌ Server not running! Please start server first:');
    console.log('   node server.js');
    return;
  }
  
  await testGenerateQuery();
  await testSummarizeData();
  
  console.log('\n✅ All tests completed!\n');
}

runTests();
