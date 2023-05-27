
library(shiny)
library(shinyAuthX)

# dataframe that holds usernames, passwords and other user data
users_base <- create_dummy_users()

ui <- fluidPage(
	# add signout button UI
	div(class = "pull-right", signoutUI(id = "signout")),

  # add signin panel UI function without signup or password recovery panel
  signinUI(id = "signin", .add_forgotpw = FALSE, .add_btn_signup = FALSE),

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
    users_db = users_base,
    sodium_hashed = TRUE,
    reload_on_signout = FALSE,
    signout = reactive(signout_init())
  )

  output$user_data <- renderPrint({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    str(credentials())
  })
}

if (interactive()) shinyApp(ui = ui, server = server)
