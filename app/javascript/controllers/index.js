// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import { Application } from '@hotwired/stimulus'
import RailsNestedForm from '@stimulus-components/rails-nested-form'

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

// const application = Application.start()
application.register('nested-form', RailsNestedForm)
