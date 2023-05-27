


library(shiny)
library(mongolite)
library(shinyAuthX)

## default mongodb database server for testing: works only with `mtcars`
con <- mongo("mtcars", url = "mongodb+srv://readwrite:test@cluster0-84vdt.mongodb.net/test")
## remove any existing rows
con$drop()
## check
con$count()

# add users_base to con
create_dummy_users() |>
	dplyr::add_row(username = "myo", email = "dr.myominnoo@gmail.com", name = "Myo Minn Oo") |>
	con$insert()
con$count()


# create email template with outlook credential
template <- email_template(
	creds_file = blastula::creds_file("../outlook_creds"), ## to delete this later
	# creds_file = blastula::creds_file("path/outlook_creds"),
	from = "budgetbuddy4myo@outlook.com"
	# from = "admin@email.com",
)



ui <- fluidPage(
	# add signout button UI
	div(class = "pull-right", signoutUI(id = "signout")),

	# add signin panel UI function with signup panel
	signinUI(id = "signin", .add_forgotpw = TRUE, .add_btn_signup = TRUE),
	# add signup panel
	signupUI("signup"),
	# add password-reset panel
	forgotpwUI("pw-reset"),

	# setup output to show user info after signin
	verbatimTextOutput("user_data")
)

server <- function(input, output, session) {
	# Export reactive values for testing
	exportTestValues(
		auth_status = credentials()$user_auth,
		auth_info   = credentials()$info
	)

	# call the signout module with reactive trigger to hide/show
	signout_init <- signoutServer(
		id = "signout",
		active = reactive(credentials()$user_auth)
	)

	# call signin module supplying data frame,
	credentials <- signinServer(
		id = "signin",
		users_db = con$find('{}'), ## add mongodb connection instead of tibble
		sodium_hashed = TRUE,
		reload_on_signout = FALSE,
		signout = reactive(signout_init())
	)

	# call signup module supplying credentials() reactive
	signupServer(
		id = "signup", credentials = credentials, mongodb = con, email = template
	)
	# call password-reset module supplying credentials() reactive and mongodb
	forgotpwServer(
		id = "pw-reset", credentials = credentials, mongodb = con, email = template
	)

	output$user_data <- renderPrint({
		# use req to only render results when credentials()$user_auth is TRUE
		req(credentials()$user_auth)
		str(credentials())
	})
}

if (interactive()) shinyApp(ui = ui, server = server)
