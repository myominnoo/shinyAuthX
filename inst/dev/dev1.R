


library(shiny)
source(here::here("R", "codes-shinyauthr.R"))



signinUI <- function(id,
										 ...,
										 .header = NULL,
										 .add_forgotpw = TRUE,
										 .add_btn_signup = TRUE,
										 cookie_expiry = 7) {
	ns <- shiny::NS(id)

	if (is.null(.header)) {
		.header <- tagList(
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
			# shinyjs::useShinyjs(),
			jscookie_script(),
			# shinyjs::extendShinyjs(text = js_cookie_to_r_code(ns("jscookie"), expire_days = cookie_expiry), functions = c("getcookie", "setcookie", "rmcookie")),
			# shinyjs::extendShinyjs(text = js_return_click(ns("password"), ns("btn_signin")), functions = c()),

			.header,

			tagList(
				shiny::textInput(
					ns("username"),
					tagList(shiny::icon("user"), "Username"),
					placeholder = "Enter your username"
				),
				shiny::passwordInput(
					ns("password"),
					tagList(shiny::icon("unlock-alt"), "Password"),
					placeholder = "Enter your password"
				),
				shiny::actionButton(ns("btn_signin"), "Sign in", width = "100%", class = "btn-success")
			),


			if (.add_forgotpw) {
				shiny::actionLink(ns("btn_forgotpw"), "Forgot password?",
													style = "float:right;margin:10px auto;")
			} else {shiny::tagList()},

			if (.add_btn_signup) {
				shiny::tagList(
					shiny::hr(),
					shiny::actionButton(ns("btn_signup"), "Create new account", width = "100%", class = "btn-default")
				)
			} else {shiny::tagList()},

			...,

			shinyjs::hidden(
				shiny::uiOutput(ns("message"), style = "margin: 15px auto;")
			)
		)
	)
}





# dataframe that holds usernames, passwords and other user data
users_base <- dplyr::tibble(
	date_created = Sys.time(),
	username = c("admin", "user1", "user2"),
	password = sapply(c("admin", "pass1", "pass2"),
										sodium::password_store),
	name = c("Admin", "User One", "User Two"),
	email = c("admin@email.com", "user1@email.com", "user2@email.com")
)


ui <- fluidPage(
	# add signin panel UI function
	signinUI(id = "signin"),
	# setup table output to show user info after signin
	verbatimTextOutput("user_table")
)

server <- function(input, output, session) {
	# # call signin module supplying data frame,
	# credentials <- signinServer(
	# 	id = "signin",
	# 	users_db = users_base,
	# 	sodium_hashed = TRUE
	# )
	#
	# output$user_table <- renderPrint({
	# 	print(str(credentials()))
	# 	# use req to only render results when credentials()$user_auth is TRUE
	# 	req(credentials()$user_auth)
	# 	str(credentials()$info)
	# })
}

shinyApp(ui, server)
