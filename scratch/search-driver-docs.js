const fs = require('fs');
const path = require('path');

const dir = 'c:\\Users\\kyada\\OneDrive\\Desktop\\BAMBAM_CABS\\bam_bam_driver\\bam_bam_driver\\lib';

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
            if (content.includes('aadhar') || content.includes('pan_number') || content.includes('panNumber') || content.includes('DL_number')) {
                console.log(`Found in: ${fullPath}`);
                const lines = content.split('\n');
                lines.forEach((line, index) => {
                    if (line.includes('aadhar') || line.includes('pan') || line.includes('DL_number') || line.includes('controller.')) {
                        if (line.length < 150) {
                            console.log(`  Line ${index + 1}: ${line.trim()}`);
                        }
                    }
                });
            }
        }
    }
}

search(dir);
console.log('Search finished.');
