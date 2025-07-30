import { Controller } from "@hotwired/stimulus";
import "bootstrap" 

export default class extends Controller {
  static targets = ["modal", "frame"];

  connect() {
    this.modal = bootstrap.Modal.getOrCreateInstance(this.modalTarget)
  }
  open() {
    console.log("▶️ status#open fired")
    fetch("/status")
      .then(r => r.text())
      .then(html => {
        this.frameTarget.innerHTML = html;
        this.modal.show();
      });
  }
}
