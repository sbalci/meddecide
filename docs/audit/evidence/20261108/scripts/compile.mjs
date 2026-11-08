// Invoke installed jamovi compiler and UI compiler on disposable copies.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const compilerDir = process.argv[2];
const compile = (await import(pathToFileURL(path.join(compilerDir, 'compiler.js')))).default;
const ui = (await import(pathToFileURL(path.join(compilerDir, 'uicompiler.js')))).default;
const out = path.dirname(new URL(import.meta.url).pathname);
const names = fs.readFileSync(path.join(out, 'names.txt'), 'utf8').trim().split('\n');
const stage = fs.mkdtempSync(path.join(os.tmpdir(), 'meddecide-compiler-'));
fs.mkdirSync(path.join(stage, 'js'));
const results = [];
try {
  for (const name of names) {
    const row = {name};
    for (const ext of ['a', 'r', 'u']) fs.copyFileSync(`jamovi/${name}.${ext}.yaml`, path.join(stage, `${name}.${ext}.yaml`));
    for (const file of fs.readdirSync('jamovi/js')) fs.copyFileSync(path.join('jamovi/js', file), path.join(stage, 'js', file));
    try {
      compile('meddecide', path.join(stage, `${name}.a.yaml`), path.join(stage, `${name}.r.yaml`), path.join(compilerDir, 'header.template'), path.join(stage, `${name}.h.R`));
      row.schema = 'PASS';
      row.header_identical = fs.readFileSync(`R/${name}.h.R`, 'utf8') === fs.readFileSync(path.join(stage, `${name}.h.R`), 'utf8');
    } catch (error) { row.schema = String(error); }
    try {
      ui(path.join(stage, `${name}.a.yaml`), path.join(stage, `${name}.u.yaml`), path.join(stage, 'js', `${name}.js`), name, path.join(compilerDir, 'src.template'), path.join(stage, `${name}.src.js`));
      row.ui = 'PASS';
      row.ui_unchanged = fs.readFileSync(`jamovi/${name}.u.yaml`, 'utf8') === fs.readFileSync(path.join(stage, `${name}.u.yaml`), 'utf8');
    } catch (error) { row.ui = String(error); }
    results.push(row);
    console.log(JSON.stringify(row));
  }
} finally {
  fs.writeFileSync(path.join(out, 'compiler.json'), JSON.stringify(results, null, 2));
  fs.rmSync(stage, {recursive: true, force: true});
}
process.exitCode = results.some(x => x.schema !== 'PASS' || x.ui !== 'PASS') ? 1 : 0;
