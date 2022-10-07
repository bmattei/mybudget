import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "toggleable" ]

  toggle() {
    console.log("toggle me  Targets: ")
    console.log(this.toggleableTarget)
    console.log("-------------------------")


    this.toggleableTarget.classList.toggle('hidden')
  }
}
