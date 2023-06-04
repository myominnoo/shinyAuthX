#' Sign-out UI module
#'
#' Shiny UI module to be used with \link{signoutServer}.
#'
#' @param id The ID for the UI module.
#' @param label button label
#' @param icon button icon
#' @param class bootstrap class for the button
#' @param style css styling for the button
#'
#' @return Shiny UI action button
#'
#' @example inst/examples/basic-signin/app.R
#' @export
signoutUI <- function(id, label = "Sign out", icon = NULL,
                      class = "btn-danger", ...) {
  ns <- shiny::NS(id)

  shinyjs::hidden(
    shiny::actionButton(ns("btn_signout"), label, icon = icon,
      class = class, ...)
  )
}

#' Sign-out Server module
#'
#' Shiny authentication module to be used with \link{signoutUI}. It uses
#' shiny's new \link[shiny]{moduleServer} method.
#'
#' @param id The ID for the Server module.
#' @param active \code{reactive} supply the returned \code{user_auth} boolean reactive from \link{signinServer}
#'   here to hide/show the logout button
#' @param ... arguments passed to \link[shinyjs]{toggle}
#'
#' @return Reactive boolean, to be supplied as the \code{signout} argument of the
#'   \link{signinServer} module to trigger the signout process
#'
#' @example inst/examples/basic-signin/app.R
#' @export
signoutServer <- function(id, active, ...) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      shiny::observe({
        shinyjs::toggle(id = "btn_signout", condition = active(), ...)
      })

      # return reactive Sign out button tracker
      shiny::reactive({
        input$btn_signout
      })
    }
  )
}
