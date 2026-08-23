const fs = require('fs');
const path = require('path');

const rootDir = 'c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS';
const webDirs = ['BB_Admin_React', 'BB_Vendor_React', 'BB_Website_React'];

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
            if (content.includes('verify/pan') || content.includes('verify/gst') || content.includes('verify/bank') || content.includes('verify/aadhaar')) {
                console.log(`Found in: ${fullPath}`);
                const lines = content.split('\n');
                lines.forEach((line, index) => {
                    if (line.includes('verify/pan') || line.includes('verify/gst') || line.includes('verify/bank') || line.includes('verify/aadhaar') || line.includes('verify')) {
                        if (line.length < 200) {
                            console.log(`  Line ${index + 1}: ${line.trim()}`);
                        }
                    }
                });
            }
        }
    }
}

webDirs.forEach(dir => {
    console.log(`Searching in ${dir}...`);
    search(path.join(rootDir, dir));
});
console.log('Search finished.');
