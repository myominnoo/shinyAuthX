

#' Password Recovery or Password Reset UI module
#'
#' Shiny UI module to be used with \link{forgotpwServer}.
#'
#' @param id The ID for the UI module.
#' @param ... Additional arguments to be passed to the shiny::wellPanel function.
#'
#' @return Shiny UI password-reset panel.
#'
#' @example inst/examples/signup-pw-reset/app.R
#' @export
forgotpwUI <- function(id, ...) {
  ns <- shiny::NS(id)

  shinyjs::hidden(
    shiny::wellPanel(
      id = ns("panel"),
      style = "max-width: 400px;
        margin: 50px auto;
        padding: 40px;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);",
      shiny::tags$h2(
        "Find your account",
        class = "text-left",
        style = "font-size:24px;font-weight:600;margin-bottom:20px;"
      ),
      shiny::hr(),
      shiny::textInput(
        ns("email"),
        shiny::tagList(shiny::icon("envelope"), "Email"),
      ),
      shiny::fluidRow(
        shiny::column(
          4,
          offset = 4,
          shiny::actionButton(ns("btn_cancel"), "Cancel",
            width = "100%", class = "btn-secondary"
          )
        ),
        shiny::column(
          4,
          shiny::actionButton(ns("btn_search"), "Search",
            width = "100%", class = "btn-success"
          )
        )
      ),

      ## add shinyjs::hidden components
      shinyjs::hidden(
        shiny::div(
          id = ns("search-group"),
          style = "margin: 20px auto;",
          shiny::hr(),
          shiny::actionLink(ns("getcode"), "Get Verification Code"),
          shinyjs::disabled(
            shiny::textInput(ns("code"), NULL, placeholder = "SISOSUXX"),
            shiny::passwordInput(
              ns("password"),
              shiny::tagList(shiny::icon("unlock-alt"), "Password"),
              placeholder = "Enter your password"
            ),
            shiny::actionButton(ns("btn_reset"), "Reset",
              width = "100%", class = "btn-success"
            )
          )
        )
      ),
      ...,
      shinyjs::hidden(
        shiny::uiOutput(ns("message"), style = "margin: 15px auto;")
      )
    )
  )
}



#' Password Recovery or Password Reset Server module
#'
#' Shiny authentication module to be used with \link{forgotpwUI}. It uses
#' shiny's new \link[shiny]{moduleServer} method.
#'
#' @param id The ID for the server module.
#' @param credentials [reactive] supply the returned reactive from \link{signinServer}
#' here to pass users and `btn_signup` and `btn_forgotpw` infos.
#' @param mongodb A mongodb connection object from [mongolite::mongo].
#' Set to `NULL`: use local storage.
#' @param email A email template. Set to `NULL`: skip code verify step.
#' See [email_template] and [create_email].
#'
#' @example inst/examples/signup-pw-reset/app.R
#' @export
forgotpwServer <- function(id, credentials, mongodb = NULL, email = NULL) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      reset <- shiny::reactiveValues(code = NULL, user = NULL)

      shiny::observeEvent(credentials()$btn_forgotpw, {
        shinyjs::show(id = "panel")
      })

      shiny::observeEvent(input$btn_cancel, {
        session$reload()
      })

      shiny::observeEvent(input$btn_search, {
        if (input$email %in% credentials()$users_db$email) {
          shinyjs::show(id = "search-group")
        } else {
          shinyjs::hide(id = "search-group")
          output$message <- shiny::renderUI(notify_text("Email not found!"))
          show_ui_toggle(id = "message")
        }
      })

      shiny::observeEvent(input$getcode, {
        # store for uploading data
        reset$code <- stringi::stri_rand_strings(1, 8, pattern = "[A-Z0-9]")
        reset$user <- credentials()$users_db[credentials()$users_db$email == input$email, ]

        ## two options to send code
        ## option 1: auto-paste to the textinput
        ## option 2: to send email
        if (is.null(email)) {
          # do option 1
          shiny::updateTextInput(session, "code", value = reset$code)
        } else {
          # TODO: do option 2

          tryCatch(
            {
              blastula::smtp_send(
                email = create_email(
                  body = email$body_getcode,
                  footer = email$footer,
                  username = reset$user$username,
                  name = reset$user$name,
                  code = reset$code
                ),
                to = input$email,
                from = email$from,
                subject = email$subject_getcode,
                cc = email$cc,
                bcc = email$bcc,
                credentials = email$creds_file,
                verbose = FALSE
              )
              message("Sending mail - `new user sign up` success!")

              output$message <- shiny::renderUI(success_text(
              	"Code sent! Check your email!"
              ))
              show_ui_toggle(id = "message")
            },
            error = function(err) {
              message(err, "\n Sending mail - `new user sign up` failed!")
              output$message <- shiny::renderUI(notify_text(sprintf(
                "Failed to send code to `%s`!", input$email
              )))
              show_ui_toggle(id = "message")
            }
          )
        }

        shinyjs::enable(id = "code")
        shinyjs::enable(id = "password")
        shinyjs::enable(id = "btn_reset")
      })

      shiny::observeEvent(input$btn_reset, {
        ## 1. check verification code
        ## 2. send data to users_db database
        if (input$code == "" | input$code != reset$code) {
          output$message <- shiny::renderUI(notify_text("Wrong verification code!"))
          show_ui_toggle(id = "message")
        } else {
          ## check invalid password
          if (input$password == "" | grepl("[[:space:]]", input$password)) {
            output$message <- shiny::renderUI(notify_text("Invalid password!"))
            show_ui_toggle(id = "message")
          } else {
            if (is.null(mongodb)) {
              mongodb_write <- NULL
            } else {
              ## need to supply a mongodb connection object
              # send userinfo to mongoDB
              mongodb_write <- tryCatch(
                {
                  mongodb$update(
                    query = paste0('{"email": "', input$email, '"}'),
                    update = paste0(
                      '{"$set":{"password": "',
                      sodium::password_store(input$password), '"}}'
                    )
                  )
                  message("MongoDB write `forgot password reset` success!")
                },
                error = function(err) {
                  message(err, "\n MongoDB write `forgot password reset` failed!")
                  return(err)
                }
              )
            }

            if (!inherits(mongodb_write, "error")) {
              # redirect to signin
              shiny::showModal(shiny::modalDialog(
                footer = NULL, easyClose = FALSE,
                shiny::div(
                  style = "color: green; text-align: center;",
                  paste0(
                    "Your password has been reset.",
                    " Redirecting you to Sign in ... "
                  )
                )
              ))


            	## send email before signout

            	if (!is.null(email)) {
            		tryCatch({
            			blastula::smtp_send(
            				email = create_email(
            					body = email$body_pw_reset,
            					footer = email$footer,
            					username = reset$user$username,
            					name = reset$user$name
            				),
            				to = reset$user$email,
            				from = email$from,
            				subject = email$subject_pw_reset,
            				cc = email$cc,
            				bcc = email$bcc,
            				credentials = email$creds_file,
            				verbose = FALSE
            			)
            			message("Sending mail - `reset password` success!")
            		}, error = function(err) {
            			message(err, "\n Sending mail - `reset password` failed!")
            		})
            	}

              Sys.sleep(4)
              session$reload()
            }
          }
        }
      })

      shiny::reactive({
        reset$user
      })
    }
  )
}
