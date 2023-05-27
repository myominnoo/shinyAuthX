
#' Toggle ui element and fade it away
#' @param id An id character that corresponds to UI's id
#'
#' @return no return.
#' @noRd
show_ui_toggle <- function(id)
{
	# if not valid temporarily show error message to user
	shinyjs::toggle(id, anim = TRUE, time = 1, animType = "fade")
	shinyjs::delay(5000, shinyjs::toggle(id, anim = TRUE, time = 1, animType = "fade"))
}


#' Warning or Failure notification
#'
#' @param msg message
#'
#' @return Shiny UI div
#' @noRd
notify_text <- function(msg)
{
	shiny::div(
		shiny::tags$p(
			msg,
			style = "color: red; font-weight: bold; padding-top: 5px;",
			class = "text-center"
		)
	)
}


#' Success notification
#'
#' @param msg message
#'
#' @return Shiny UI div
#' @noRd
success_text <- function(msg)
{
	shiny::div(
		shiny::tags$p(
			msg,
			style = "color: green; font-weight: bold; padding-top: 5px;",
			class = "text-center"
		)
	)
}



#' Create dummy users database in tibble format
#'
#' @return a tibble with five columns:  `date_created`,
#' `username`, `password`, `name`, `email`, and `permissions`.
#'
#' @examples
#'
#' users_base <- create_dummy_users()
#' str(users_base)
#'
#' @export
create_dummy_users <- function() {
	dplyr::tibble(
		date_created = Sys.time(),
		username = c("admin", "user1", "user2"),
		password = sapply(
			c("admin", "pass1", "pass2"),
			sodium::password_store,
			USE.NAMES = FALSE
		),
		name = c("Admin", "User One", "User Two"),
		email = c("admin@email.com", "user1@email.com", "user2@email.com"),
		permissions = c("admin", "standard", "standard")
	)
}



#' Check user info during sign up
#'
#' @param signup_user a named character vector of `username`, `password`, `name`, `email`.
#' @param existing_user a named list of character vectors: `username`, `email`
#'
#' @return a character for failure or `NULL` for success
#' @noRd
check_signup_userinfo <- function(signup_user, existing_user)
{
	## check user input info
	if (signup_user["username"] == "" |
			grepl("[[:space:]]", signup_user["username"])) {
		"Invalid username!"
	} else if (signup_user["password"] == "" |
						 grepl("[[:space:]]", signup_user["password"])) {
		"Invalid password!"
	} else if (signup_user["email"] == "" |
						 !grepl("@", signup_user["email"])) {
		"Invalid email address!"
	} else if (signup_user["name"] %in% c("", " ")) {
		"Invalid name!"
	} else if (any(signup_user["username"] == existing_user[["username"]])) {
		"Username already taken!"
	} else if (any(signup_user["email"] == existing_user[["email"]])) {
		"Email already used!"
	} else {
		NULL
	}
}

