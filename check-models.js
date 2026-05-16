// Script to check available Gemini models
require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function listModels() {
  console.log('🔍 Checking available Gemini models...\n');
  
  try {
    // Try different model names
    const modelsToTry = [
      'gemini-pro',
      'gemini-1.5-pro',
      'gemini-1.5-pro-latest',
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-2.0-flash-exp',
      'models/gemini-pro',
      'models/gemini-1.5-pro'
    ];

    for (const modelName of modelsToTry) {
      try {
        const model = genAI.getGenerativeModel({ model: modelName });
        const result = await model.generateContent('Say hello');
        console.log(`✅ ${modelName} - WORKS!`);
        console.log(`   Response: ${result.response.text().substring(0, 50)}...`);
      } catch (error) {
        console.log(`❌ ${modelName} - NOT AVAILABLE`);
        if (error.message.includes('404')) {
          console.log(`   Error: Model not found`);
        } else {
          console.log(`   Error: ${error.message.substring(0, 80)}`);
        }
      }
      console.log('');
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
}

listModels();
