library(shiny)
# devtools::load_all()


# dataframe that holds usernames, passwords and other user data
users_base <- dplyr::tibble(
  date_created = Sys.time(),
  username = c("admin", "user1", "user2"),
  password = sapply(
    c("admin", "pass1", "pass2"),
    sodium::password_store
  ),
  name = c("Admin", "User One", "User Two"),
  email = c("admin@email.com", "user1@email.com", "user2@email.com")
)


ui <- fluidPage(
  # add signin panel UI function without signup or password recovery panel
  signinUI(id = "signin", .add_forgotpw = FALSE, .add_btn_signup = FALSE),
  # setup table output to show user info after signin
  verbatimTextOutput("user_table")
)

server <- function(input, output, session) {
  # call signin module supplying data frame,
  credentials <- signinServer(
    id = "signin",
    users_db = users_base,
    sodium_hashed = TRUE
  )

  output$user_table <- renderPrint({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    str(credentials())
  })
}

if (interactive()) shinyApp(ui = ui, server = server)
