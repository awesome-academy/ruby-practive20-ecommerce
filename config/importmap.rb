# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/custom", under: "custom"
pin_all_from "app/javascript/admin", under: "admin"

# Bootstrap 3 dependencies
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js"
pin "bootstrap", to: "https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"
