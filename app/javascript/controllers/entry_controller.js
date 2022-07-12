import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("entry controller")
  }

  on_set_payee() {
    console.log("on_set_payee")

    if (document.getElementById("entry_payee").value.trim().length > 0) {
      document.getElementById("entry_transfer_account_id").value = ""

    }
  }
  on_set_transfer() {
    console.log("on_set_transfer")
    if (document.getElementById("entry_transfer_account_id").value.trim().length > 0) {
      document.getElementById("entry_payee").value = ""
      document.getElementById("entry_category_id").value = ""
    }
  }
  on_set_category() {
    console.log("on_set_category")
    if (document.getElementById("entry_category_id").value.trim().length > 0) {
      document.getElementById("entry_transfer_account_id").value = ""
      document.getElementById('entry_transfer_account_id').classList.add("hidden")
      document.getElementById("entry_payee").classList.remove("hidden")
    }
    else {
      document.getElementById('entry_transfer_account_id').classList.remove("hidden")
      document.getElementById("entry_payee").classList.add("hidden")

    }
  }
  on_set_inflow() {
    console.log("on_set_inflow")
    if (document.getElementById("entry_inflow").value.trim().length > 0) {
      document.getElementById("entry_outflow").value = ""
    }
  }
  on_set_outflow() {
    console.log("on_set_outflow")
    if (document.getElementById("entry_outflow").value.trim().length > 0) {
      document.getElementById("entry_inflow").value = ""
    }
  }

}
