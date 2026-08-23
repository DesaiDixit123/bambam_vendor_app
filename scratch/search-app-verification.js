const fs = require('fs');
const path = require('path');

const rootDir = 'c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS';
const apps = ['bam_bam_driver', 'bam_bam_vendor-main 3'];

function search(currentDir) {
    let files;
    try {
        files = fs.readdirSync(currentDir);
    } catch (e) {
        return;
    }
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === '.dart_tool' || file === 'build') continue;
        const fullPath = path.join(currentDir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            search(fullPath);
        } else if (file.endsWith('.dart')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            if (content.includes('verify/pan') || content.includes('verify/gst') || content.includes('verify/bank') || content.includes('verify/aadhaar') || content.includes('aadhaar-otp')) {
                console.log(`Found in: ${fullPath}`);
                const lines = content.split('\n');
                lines.forEach((line, index) => {
                    if (line.includes('verify') || line.includes('pan') || line.includes('aadhar') || line.includes('gst')) {
                        if (line.length < 150) {
                            console.log(`  Line ${index + 1}: ${line.trim()}`);
                        }
                    }
                });
            }
        }
    }
}

apps.forEach(app => {
    console.log(`Searching in ${app}...`);
    search(path.join(rootDir, app));
});
console.log('Search finished.');
