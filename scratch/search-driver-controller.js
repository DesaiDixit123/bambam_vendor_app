const fs = require('fs');
const content = fs.readFileSync('c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS\\BAMBAMCABS_BACKEND\\controllers\\Drivers\\drivers.controller.js', 'utf8');

const lines = content.split('\n');
lines.forEach((line, index) => {
    if (line.includes('verifyDrivingLicense') || line.includes('sandboxService') || line.includes('verify')) {
        if (line.length < 200) {
            console.log(`Line ${index + 1}: ${line.trim()}`);
        }
    }
});
