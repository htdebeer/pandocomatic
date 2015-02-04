import Action from '../lib/pandocomatic/action.js';
import CopyAction from '../lib/pandocomatic/copy_action.js';

let a = new Action('test_action.js');
console.log(a.message);

let c = new CopyAction('test_action.js', '../test.js');
console.log(c.message);

if (c.check()) {
  console.log('ready to exec');
} else {
  console.log(`Problem with action: ${c.error}`);
}
