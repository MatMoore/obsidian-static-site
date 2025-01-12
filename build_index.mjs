import lunr from 'lunr'
import process from 'node:process'

const stdout = process.stdout

const idx = lunr(function() {
  this.ref('slug');
  this.field('title');
  this.field('html');
  this.add({ 'slug': '/foo', 'title': 'Test document', 'html': 'hello' });
})

stdout.write(JSON.stringify(idx));
