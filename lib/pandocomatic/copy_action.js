import Action from './action.js';
import fs from 'fs';
import path from 'path';

export default class CopyAction extends Action {
  constructor(src, dest) {
    super(src, dest);
    this.dest = dest;
    this.message = `Copy ${src} to ${dest}`;
  }

  check() {
    // Check if src is readable
    let fd;
    try {
      fd = fs.openSync(this.src, 'r');
      fs.closeSync(fd);
    } catch (err) {
      this.error = `Cannot read ${this.src}`;
    }

    // Check if dest is writable
    try {
      fd = fs.openSync(this.dest, 'w');
      fs.closeSync(fd);
    } catch (err) {
      this.error = `Cannot write ${this.dest}`;
    }

    return ! this.error;
  }

  execute() {
  }
}
