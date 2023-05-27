

#' Sign-up UI module
#'
#' Shiny UI module to be used with \link{signupServer}.
#'
#' @param id An ID character that corresponds with that of the server module.
#' @param ... additional shiny UIs.
#' @param .header header for the sign-in panel, defaults to `NULL`.
#'
#' @return Shiny UI sign-up panel with text inputs for `username` and `password`,
#' `name`, `email`, as well as two action buttons, `btn_signup` and `btn_sigin`.
#'
#' @example inst/examples/basic-signup/app.R
#' @export
signupUI <- function(id, ..., .header = NULL) {
	ns <- shiny::NS(id)

	if (is.null(.header)) {
		.header <- shiny::tagList(
			shiny::tags$h2("Sign up", class = "text-center", style = "font-size: 24px;
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

			.header,

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
			shiny::textInput(
				ns("email"),
				shiny::tagList(shiny::icon("envelope"), "Email",
											 placeholder = "Enter your email"),
			),
			shiny::textInput(
				ns("name"),
				shiny::tagList(shiny::icon("signature"), "Your Name",
											 placeholder = "Enter your name"),
			),

			shiny::actionLink(ns("getcode"), "Get Verification Code"),
			shinyjs::disabled(
				shiny::textInput(ns("code"), NULL, placeholder = "SISOSUXX")
			),
			shiny::hr(),

			shinyjs::disabled(
				shiny::actionButton(ns("btn_signup"), "Sign up",
														width = "100%", class = "btn-success")
			),

			shiny::actionButton(ns("btn_signin"), "Cancel",
													width = "100%", class = "btn-secondary",
													style = "margin: 10px auto;"),
			...,

			shinyjs::hidden(
				shiny::uiOutput(ns("message"), style = "margin: 15px auto;")
			)

		)
	)

}



#' Sign-up Server module
#'
#' Shiny authentication module to be used with \link{signupUI}. It uses
#' shiny's new \link[shiny]{moduleServer} method.
#'
#' @param id An ID character that corresponds with that of the server module.
#' @param credentials [reactive] supply the returned reactive from \link{signinServer}
#' here to pass users and `btn_signup` and `btn_forgotpw` infos.
#' @param mongodb A mongodb connection object from [mongolite::mongo].
#' @param email A email template.
#'
#' @return a data.frame with six columns, containing newly signed-up user.
#'
#' @example inst/examples/basic-signup/app.R
#' @export
signupServer <- function(id, credentials, mongodb = NULL, email = NULL) {
	shiny::moduleServer(
		id,
		function(input, output, session) {

			signup_info <- shiny::reactiveValues(new_user = NULL, signup_code = NULL)

			shiny::observeEvent(credentials()$btn_signup, {
				shinyjs::show(id = "panel")
			})

			shiny::observeEvent(input$btn_signin, {
				session$reload()
			})

			# signup getcode event
			shiny::observeEvent(input$getcode, {
				signup_check <- check_signup_userinfo(
					c(username = input$username,
						password = input$password,
						name = input$name,
						email = input$email),
					list(username = credentials()$users_db$username,
							 email = credentials()$users_db$email)
				)

				if (is.null(signup_check)) {
					# store for uploading data
					signup_info$signup_code <- stringi::stri_rand_strings(1, 8, pattern = "[A-Z0-9]")

					## two options to send code
					## option 1: auto-paste to the textinput
					## option 2: to send email
					if (is.null(email)) {
						# do option 1
						shiny::updateTextInput(session, "code", value = signup_info$signup_code)
					} else {
						# do option 2 send email

						tryCatch({
							blastula::smtp_send(
								email = create_email(
									body = email$body_getcode,
									footer = email$footer,
									username = input$username,
									name = input$name,
									code = signup_info$signup_code
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

							output$message <- shiny::renderUI(success_text("Code sent! Check your email!"))
							show_ui_toggle(id = "message")
						}, error = function(err) {
							message(err, "\n Sending mail - `new user sign up` failed!")
							output$message <- shiny::renderUI(notify_text(sprintf(
								"Failed to send code to `%s`!", input$email
							)))
							show_ui_toggle(id = "message")
						})

					}

					shinyjs::enable("code")
					shinyjs::enable("btn_signup")
				} else {
					output$message <- shiny::renderUI(notify_text(signup_check))
					show_ui_toggle(id = "message")
				}

			})

			shiny::observeEvent(input$btn_signup, {
				## 1. check verification code
				## 2. send data to users_db database
				if (input$code == "" | input$code != signup_info$signup_code ) {
					output$message <- shiny::renderUI(notify_text("Wrong verification code!"))
					show_ui_toggle(id = "message")
				} else {
					signup_info$new_user <- data.frame(
						date_created = Sys.time(),
						username = input$username,
						password = sodium::password_store(input$password),
						name = input$name,
						email = input$email,
						permissions = "standard"
					)

					if (is.null(mongodb)) {

						mongodb_write <- NULL
					} else {
						## need to supply a mongodb connection object
						# send userinfo to mongoDB
						mongodb_write <- tryCatch({
							mongodb$insert(signup_info$new_user)
							message("MongoDB write `new user sign up` success!")
						}, error = function(err) {
							message(err, "\n MongoDB write `new user sign up` failed!")
							return(err)
						})
					}

					if (!inherits(mongodb_write, "error")) {
						# redirect to signin
						shiny::showModal(shiny::modalDialog(
							footer = NULL, easyClose = FALSE,
							shiny::div(
								style = "color: green; text-align: center;",
								paste0(
									"Your account has been created.",
									" Redirecting you to Sign in ... "
								)
							)
						))

						## send email before signout

						if (!is.null(email)) {
							tryCatch({
								blastula::smtp_send(
									email = create_email(
										body = email$body_welcome,
										footer = email$footer,
										name = input$name,
									),
									to = input$email,
									from = email$from,
									subject = email$subject_welcome,
									cc = email$cc,
									bcc = email$bcc,
									credentials = email$creds_file,
									verbose = FALSE
								)
								message("Sending mail - `greeting new user` success!")
							}, error = function(err) {
								message(err, "\n Sending mail - `greeting new user` failed!")
							})
						}

						Sys.sleep(4)
						session$reload()
					}
				}

			})

			shiny::reactive({signup_info$new_user})
		}
	)
}
