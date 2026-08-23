const fs = require('fs');
const path = require('path');

const rootDir = 'c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS\\BB_Admin_React';

function search(currentDir) {
    let files;
    try {
        files = fs.readdirSync(currentDir);
    } catch (e) {
        return;
    }
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === 'build' || file === 'dist') continue;
        const fullPath = path.join(currentDir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            search(fullPath);
        } else if (file.endsWith('.js') || file.endsWith('.jsx') || file.endsWith('.tsx') || file.endsWith('.ts')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            if (
                content.includes('verifyPANApi') || 
                content.includes('verifyGSTApi') || 
                content.includes('verifyBankApi') || 
                content.includes('requestAadhaarOtpApi') || 
                content.includes('verifyAadhaarOtpApi')
            ) {
                console.log(`Found in: ${fullPath}`);
                const lines = content.split('\n');
                lines.forEach((line, index) => {
                    if (
                        line.includes('verifyPANApi') || 
                        line.includes('verifyGSTApi') || 
                        line.includes('verifyBankApi') || 
                        line.includes('requestAadhaarOtpApi') || 
                        line.includes('verifyAadhaarOtpApi') ||
                        line.includes('otp') ||
                        line.includes('verify')
                    ) {
                        if (line.length < 200) {
                            console.log(`  Line ${index + 1}: ${line.trim()}`);
                        }
                    }
                });
            }
        }
    }
}

search(rootDir);
console.log('Search finished.');
