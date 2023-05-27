#' Run examples
#'
#' Launch an example shiny app using `shinyAuthX` authentication modules.
#' Use `admin`/`admin`, `user1`/`pass1` or `user2`/`pass2` to sign in.
#'
#' @param example The app to launch. Options are
#' "basic-signin", "basic-signin-mongodb", "basic-signin-theme",
#' "basic-signup", "test-app"
#' @return No return value, a shiny app is launched.
#' @examples
#' ## Only run this example in interactive R sessions
#' if (interactive()) {
#'   runExample("basic-signin")
#'   runExample("basic-signin-mongodb")
#'   runExample("basic-signin-theme")
#' }
#' @export
runExample <- function(example = c(
	"basic-signin", "basic-signin-mongodb", "basic-signin-theme",
	"basic-signup", "test-app"
))
{
	example <- match.arg(example, c(
		"basic-signin", "basic-signin-mongodb", "basic-signin-theme",
		"basic-signup", "test-app"
	), several.ok = FALSE)
	appDir <- system.file("examples", example, package = "shinyAuthX")
	if (appDir == "") {
		stop("Could not find example directory. Try re-installing `shinyAuthX`.", call. = FALSE)
	}
	shiny::runApp(appDir, display.mode = "normal")
}
