import CopyAction from './copy_action.js';

export default class ConvertAction extends CopyAction {
  constructor(src, dest, config) {
    super(src, dest);
    this.config = config;
    this.message = `Convert ${src} using ${config.template} to ${dest}`;
  }

  check() {
    // check if conversion process has everything needed

    // check if the converted file can be copied to dest
    super.check();
  }

  execute() {
    // convert, create a temporary src file with converted content and run copy
    // action

    super.execute();
  }
}
