/**
 * Test script for KYC flow
 * Run with: node test-kyc-flow.js
 */

const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://localhost:5001/api';

let authToken = null;
let userId = null;

// Test user credentials
const testUser = {
    name: 'Test User',
    email: `test${Date.now()}@example.com`,
    password: 'test123456'
};

console.log('🧪 Starting KYC Flow Test\n');

async function testRegister() {
    console.log('1️⃣ Testing Registration...');
    try {
        const response = await axios.post(`${BASE_URL}/auth/register`, testUser);
        authToken = response.data.token;
        userId = response.data.data._id;
        console.log('✅ Registration successful');
        console.log('   Token:', authToken.substring(0, 20) + '...');
        console.log('   User ID:', userId);
        return true;
    } catch (error) {
        console.error('❌ Registration failed:', error.response?.data || error.message);
        return false;
    }
}

async function testLogin() {
    console.log('\n2️⃣ Testing Login...');
    try {
        const response = await axios.post(`${BASE_URL}/auth/login`, {
            email: testUser.email,
            password: testUser.password
        });
        authToken = response.data.token;
        console.log('✅ Login successful');
        console.log('   Token:', authToken.substring(0, 20) + '...');
        return true;
    } catch (error) {
        console.error('❌ Login failed:', error.response?.data || error.message);
        return false;
    }
}

async function testKycStatus() {
    console.log('\n3️⃣ Testing KYC Status...');
    try {
        const response = await axios.get(`${BASE_URL}/kyc/status`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        console.log('✅ KYC Status retrieved');
        console.log('   Status:', response.data.data.status);
        console.log('   Step:', response.data.data.step);
        return true;
    } catch (error) {
        console.error('❌ KYC Status failed:', error.response?.data || error.message);
        return false;
    }
}

async function testDocumentUpload() {
    console.log('\n4️⃣ Testing Document Upload...');
    
    // Check if test image exists
    const testImagePath = path.join(__dirname, '../Bill_Testing/demo_bill_1.png');
    if (!fs.existsSync(testImagePath)) {
        console.log('⚠️ Test image not found, skipping document upload test');
        return true;
    }

    try {
        const formData = new FormData();
        formData.append('document', fs.createReadStream(testImagePath));
        formData.append('documentType', 'pan');

        const response = await axios.post(`${BASE_URL}/kyc/upload-document`, formData, {
            headers: {
                'Authorization': `Bearer ${authToken}`,
                ...formData.getHeaders()
            }
        });
        console.log('✅ Document uploaded successfully');
        console.log('   Valid:', response.data.data.isValid);
        return true;
    } catch (error) {
        console.error('❌ Document upload failed:', error.response?.data || error.message);
        return false;
    }
}

async function testMfaRequest() {
    console.log('\n5️⃣ Testing MFA Request...');
    try {
        const response = await axios.post(`${BASE_URL}/kyc/mfa/request`, {}, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        console.log('✅ MFA request successful');
        console.log('   Message:', response.data.message);
        console.log('   ⚠️ Check server console for OTP');
        return true;
    } catch (error) {
        console.error('❌ MFA request failed:', error.response?.data || error.message);
        return false;
    }
}

async function runTests() {
    console.log('='.repeat(50));
    console.log('Testing Backend KYC Flow');
    console.log('='.repeat(50));
    
    const results = {
        register: await testRegister(),
        login: await testLogin(),
        kycStatus: await testKycStatus(),
        documentUpload: await testDocumentUpload(),
        mfaRequest: await testMfaRequest()
    };

    console.log('\n' + '='.repeat(50));
    console.log('Test Results Summary');
    console.log('='.repeat(50));
    
    Object.entries(results).forEach(([test, passed]) => {
        console.log(`${passed ? '✅' : '❌'} ${test}`);
    });

    const allPassed = Object.values(results).every(r => r);
    console.log('\n' + (allPassed ? '🎉 All tests passed!' : '⚠️ Some tests failed'));
}

// Run tests
runTests().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
});
