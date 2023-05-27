

#' Sign-in UI module
#'
#' Shiny UI module to be used with \link{signinServer}.
#'
#' @param id An ID character that corresponds with that of the server module.
#' @param ... additional shiny UIs.
#' @param .header header for the sign-in panel, defaults to `NULL`.
#' @param .add_forgotpw logical to add password recovery feature, defaults to `TRUE`.
#' @param .add_btn_signup logical to add sign-up feature, defaults to `FALSE`.
#' @param cookie_expiry number of days to request browser to retain `signin` cookie
#'
#' @return Shiny UI sign-in panel with text inputs for `username` and `password`,
#'  `btn_sigin` action button, and optional features, including `btn_fogortpw`
#'  action link to password recovery panel and `btn_signup` action button to sign-up panel
#'
#' @example inst/examples/basic-signin/app.R
#' @export
signinUI <- function(id,
                     ...,
                     .header = NULL,
                     .add_forgotpw = TRUE,
                     .add_btn_signup = TRUE,
                     cookie_expiry = 7) {
  ns <- shiny::NS(id)

  if (is.null(.header)) {
    .header <- shiny::tagList(
      shiny::tags$h2("Sign in", class = "text-center", style = "font-size: 24px;
        font-weight: 600;
        margin-bottom: 20px;")
    )
  }

  shinyjs::hidden(
    shiny::wellPanel(
      id = ns("panel"),
      style = "max-width: 400px;
        margin: 50px auto;
        padding: 40px;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);",

      # js scripts
      shinyjs::useShinyjs(),
      jscookie_script(),
      shinyjs::extendShinyjs(text = js_cookie_to_r_code(ns("jscookie"), expire_days = cookie_expiry), functions = c("getcookie", "setcookie", "rmcookie")),
      shinyjs::extendShinyjs(text = js_return_click(ns("password"), ns("btn_signin")), functions = c()),
      .header,
      shiny::tagList(
        shiny::textInput(
          ns("username"),
          shiny::tagList(shiny::icon("user"), "Username"),
          placeholder = "Enter your username"
        ),
        shiny::passwordInput(
          ns("password"),
          shiny::tagList(shiny::icon("unlock-alt"), "Password"),
          placeholder = "Enter your password"
        ),
        shiny::actionButton(ns("btn_signin"), "Sign in", width = "100%", class = "btn-success")
      ),
      if (.add_forgotpw) {
        shiny::actionLink(ns("btn_forgotpw"), "Forgot password?",
          style = "float:right;margin:10px auto;"
        )
      } else {
        shiny::tagList()
      },
      if (.add_btn_signup) {
        shiny::tagList(
          shiny::hr(),
          shiny::actionButton(ns("btn_signup"), "Create new account", width = "100%", class = "btn-default")
        )
      } else {
        shiny::tagList()
      },
      ...,
      shinyjs::hidden(
        shiny::uiOutput(ns("message"), style = "margin: 15px auto;")
      )
    )
  )
}





#' Sign-in Server module
#'
#' Shiny authentication module to be used with \link{signinUI}. It uses
#' shiny's new \link[shiny]{moduleServer} method.
#'
#' @param id An ID character that corresponds with that of the server module.
#' @param users_db data.frame or tibble containing five columns: `date_created`,
#' `username`, `password`, `name`, `email`, and `permissions`.
#' See \link{create_dummy_users}.
#' @param sodium_hashed have the passwords been hash encrypted using the `sodium` package? defaults to `TRUE`.
#' @param signout [reactive] supply the returned reactive from \link{signoutServer} here to trigger a user sign-out
#' @param reload_on_signout logical to force a session reload on logout? defaults to `FALSE`.
#' @param cookie_logins enable automatic logins via browser cookies?
#' @param sessionid_col bare (unquoted) or quoted column name containing session ids
#' @param cookie_getter a function that returns a data.frame with at least two columns: user and session
#' @param cookie_setter a function with two parameters: user and session.  The function must save these to a database.
#'
#' @return The module will return a reactive six element list
#' to your main application.
#' 1. \code{user_auth} is a boolean indicating whether there has been
#' a successful login or not.
#'
#' 2. \code{info} will be the data frame provided
#' to the function, filtered to the row matching the successfully
#' logged in username. When \code{user_auth} is FALSE \code{info} is NULL.
#'
#' 3. \code{cookie_already_checked} `TRUE` OR `FALSE`.
#' 4. \code{users_db} to be used in sign-up and password recovery features.
#' 5. \code{btn_signup} to be passed to sign-up module.
#' 6. \code{btn_forgotpw} to be passed to password recovery module.
#'
#'
#' @importFrom rlang :=
#'
#' @example inst/examples/basic-signin/app.R
#' @export
signinServer <- function(id,
                         users_db,
                         sodium_hashed = TRUE,
                         signout = shiny::reactiveVal(),
                         reload_on_signout = FALSE,
                         cookie_logins = FALSE,
                         sessionid_col,
                         cookie_getter,
                         cookie_setter) {
  user_col <- "username"
  pwd_col <- "password"

  # if colnames are strings convert them to symbols
  try_class_uc <- try(class(user_col), silent = TRUE)
  if (try_class_uc == "character") {
    user_col <- rlang::sym(user_col)
  }

  try_class_pc <- try(class(pwd_col), silent = TRUE)
  if (try_class_pc == "character") {
    pwd_col <- rlang::sym(pwd_col)
  }

  if (cookie_logins && (missing(cookie_getter) | missing(cookie_setter) |
    missing(sessionid_col))) {
    stop("if cookie_logins = TRUE, cookie_getter, cookie_setter and sessionid_col must be provided")
  } else {
    try_class_sc <- try(class(sessionid_col), silent = TRUE)
    if (try_class_sc == "character") {
      sessionid_col <- rlang::sym(sessionid_col)
    }
  }

  # ensure all text columns are character class
  users_db <- dplyr::mutate_if(users_db, is.factor, as.character)

  shiny::moduleServer(
    id,
    function(input, output, session) {
      credentials <- shiny::reactiveValues(
        user_auth = FALSE, info = NULL, cookie_already_checked = FALSE,
        users_db = NULL, btn_signup = NULL, btn_forgotpw = NULL
      )

      shiny::observeEvent(signout(), {
        if (cookie_logins) {
          shinyjs::js$rmcookie()
        }

        if (reload_on_signout) {
          session$reload()
        } else {
          shiny::updateTextInput(session, "password", value = "")
          credentials$user_auth <- FALSE
          credentials$info <- NULL
        }
      })

      shiny::observe({
        if (cookie_logins) {
          if (credentials$user_auth) {
            shinyjs::hide(id = "panel")
          } else if (credentials$cookie_already_checked) {
            shinyjs::show(id = "panel")
          }
        } else {
          shinyjs::toggle(id = "panel", condition = !credentials$user_auth)
        }
      })

      if (cookie_logins) {
        # possibility 1: login through a present valid cookie
        # first, check for a cookie once javascript is ready
        shiny::observeEvent(shiny::isTruthy(shinyjs::js$getcookie()), {
          shinyjs::js$getcookie()
        })
        # second, once cookie is found try to use it
        shiny::observeEvent(input$jscookie, {
          credentials$cookie_already_checked <- TRUE

          # if already logged in or cookie missing, ignore change in input$jscookie
          shiny::req(
            credentials$user_auth == FALSE,
            is.null(input$jscookie) == FALSE,
            nchar(input$jscookie) > 0
          )

          cookie_data <- dplyr::filter(
            cookie_getter(), {{ sessionid_col }} == input$jscookie
          )

          if (nrow(cookie_data) != 1) {
            shinyjs::js$rmcookie()
          } else {
            # if valid cookie, we reset it to update expiry date
            .userid <- dplyr::pull(cookie_data, {{ user_col }})
            .sessionid <- randomString()

            shinyjs::js$setcookie(.sessionid)

            cookie_setter(.userid, .sessionid)

            cookie_data <- utils::head(
              dplyr::filter(
                cookie_getter(),
                {{ sessionid_col }} == .sessionid,
                {{ user_col }} == .userid
              )
            )

            credentials$user_auth <- TRUE
            credentials$info <- dplyr::bind_cols(
              dplyr::filter(users_db, {{ user_col }} == .userid),
              dplyr::select(cookie_data, -{{ user_col }})
            )
          }
        })
      }

      # possibility 2: login through login button
      shiny::observeEvent(input$btn_signin, {
        # check for match of input username to username column in users_db
        row_username <- which(dplyr::pull(users_db, {{ user_col }}) == input$username)

        if (length(row_username)) {
          row_password <- dplyr::filter(users_db, dplyr::row_number() == row_username)
          row_password <- dplyr::pull(row_password, {{ pwd_col }})
          if (sodium_hashed) {
            password_match <- sodium::password_verify(row_password, input$password)
          } else {
            password_match <- identical(row_password, input$password)
          }
        } else {
          password_match <- FALSE
        }

        # if user name row and password name row are same, credentials are valid
        if (length(row_username) == 1 && password_match) {
          credentials$user_auth <- TRUE
          credentials$info <- dplyr::filter(
            users_db, {{ user_col }} == input$username
          )

          if (cookie_logins) {
            .sessionid <- randomString()
            shinyjs::js$setcookie(.sessionid)
            cookie_setter(input$username, .sessionid)
            cookie_data <- dplyr::filter(
              dplyr::select(cookie_getter(), -{{ user_col }}),
              {{ sessionid_col }} == .sessionid
            )
            if (nrow(cookie_data) == 1) {
              credentials$info <- dplyr::bind_cols(credentials$info, cookie_data)
            }
          }
        } else {
          output$message <- shiny::renderUI(notify_text("Invalid username or password!"))
          show_ui_toggle(id = "message")
        }
      })

      # goto signup page
      shiny::observeEvent(input$btn_signup, {
        credentials$btn_signup <- input$btn_signup
        credentials$users_db <- users_db
        shinyjs::hide(id = "panel")
      })
      shiny::observeEvent(input$btn_forgotpw, {
        credentials$btn_forgotpw <- input$btn_forgotpw
        credentials$users_db <- users_db
        shinyjs::hide(id = "panel")
      })

      # return reactive list
      # containing auth boolean, user information, user_db, and two buttons
      shiny::reactive({
        shiny::reactiveValuesToList(credentials)
      })
    }
  )
}
