
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
#' `username`, `password`, `name`, `email`.
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
			sodium::password_store
		),
		name = c("Admin", "User One", "User Two"),
		email = c("admin@email.com", "user1@email.com", "user2@email.com")
	)
}



