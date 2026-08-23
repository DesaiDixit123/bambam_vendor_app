const fs = require('fs');
const path = require('path');

const dir = 'c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS\\BAMBAMCABS_BACKEND';

function search(currentDir) {
    let files;
    try {
        files = fs.readdirSync(currentDir);
    } catch (e) {
        return;
    }
    for (const file of files) {
        if (file === 'node_modules' || file === '.git') continue;
        const fullPath = path.join(currentDir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            search(fullPath);
        } else if (file.endsWith('.js')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            if (content.includes('verifyDrivingLicense')) {
                console.log(`Found in: ${fullPath}`);
            }
        }
    }
}

search(dir);
console.log('Search finished.');
