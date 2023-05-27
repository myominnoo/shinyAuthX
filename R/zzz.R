
#' Toggle ui element and fade it away
#' @param id An id character that corresponds to UI's id
#'
#' @export
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
#' @export
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
#' @export
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



