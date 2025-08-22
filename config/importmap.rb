pin "application"
pin "bootstrap",  to: "bootstrap.bundle.min.js"

pin "@hotwired/turbo-rails",      to: "turbo.min.js", preload: true
pin "@hotwired/stimulus",         to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
