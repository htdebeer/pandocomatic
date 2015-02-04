// Default action is the non-action, or skip.
export default class Action {
  constructor(src) {
    this.src = src;
    this.message = `Skip file: ${src}`;
  }

  check() {
    return true;
  }

  execute() {
  }

}
