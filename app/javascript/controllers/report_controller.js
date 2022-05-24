import {
  Controller
} from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello World!")
  }
  select_chart_type() {
    if (document.getElementById("type").value == 'pie_chart') {

      if (document.getElementById("interval").value.length > 0) {
        document.getElementById("interval").value = ""
      }
      document.getElementById("interval").setAttribute('disabled', "")
    } else {
      document.getElementById("interval").removeAttribute('disabled') 
    }
  }

}
