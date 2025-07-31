import { Controller } from "@hotwired/stimulus";
import "bootstrap" 

export default class extends Controller {
  static targets = ["modal", "frame"];

  connect() {
    console.log("connect() called");
    console.trace();
    this.modal = bootstrap.Modal.getOrCreateInstance(this.modalTarget)

    this.isClosed = false;
    this.modalTarget.addEventListener(
      "hidden.bs.modal",
      () => { this.isClosed = true; }
    );
  }
  open() {
    this.isClosed = false;

    console.log("open() START at", performance.now());
    fetch("/status")
      .then(r => r.text())
      .then(html => {
        console.log("fetch resolved at", performance.now());
        console.trace();

        if (this.isClosed) {
          console.log("fetch finished but modal already closed – skip show()");
          return;
        }

        this.frameTarget.innerHTML = html;
        this.modal.show();
      });
  }
}
