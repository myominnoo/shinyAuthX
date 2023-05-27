
#' Create Email Template
#'
#' This function creates an email template for different scenarios
#' using customizable subject lines, body content, and footer.
#' It provides default content for welcome, verification code, and password
#' reset emails, but allows for customization of each part.
#'
#' @details
#'
#' The generated email template is used internally in conjunction
#' with the [create_email] function to compose emails for three scenarios:
#' welcome, verification code, and password reset.
#'
#' Prior to using this function, you need to create an email credential file
#' using the [create_smtp_creds_file] function from the `blastula` package
#' and provide the path to the credential file
#' using the [creds_file] function.
#'
#' @param creds_file The email credential file. See [creds_file].
#' @param from The sender's email address.
#' @param cc (Optional) The email address(es) to be included in the CC field.
#' @param bcc (Optional) The email address(es) to be included in the BCC field.
#' @param subject_welcome The subject line for the welcome email.
#' @param body_welcome The body content for the welcome email.
#' @param subject_getcode The subject line for the verification code email.
#' @param body_getcode The body content for the verification code email.
#' @param subject_pw_reset The subject line for the password reset email.
#' @param body_pw_reset The body content for the password reset email.
#' @param footer The footer content to be included in all emails.
#'
#' @return A named list containing the email template
#' with customizable subject lines, body content,
#' and footer for various scenarios.
#'
#' @examples
#'
#' \dontrun{
#' # Create an email template
#' template <- email_template(
#'   creds_file = "path/to/creds/file",
#'   from = "sender@example.com",
#'   cc = "cc@example.com",
#'   bcc = "bcc@example.com",
#'   subject_welcome = "Welcome to shinyAuthX!",
#'   body_welcome = "Custom welcome email content",
#'   subject_getcode = "Verify your code",
#'   body_getcode = "Custom verification code email content",
#'   subject_pw_reset = "Password reset",
#'   body_pw_reset = "Custom password reset email content",
#'   footer = "Custom footer content"
#' )
#'
#' # internal use inside the package
#' blastula::smtp_send(
#' 	email = create_email(
#' 		body = template$body_getcode,
#' 		footer = template$footer,
#' 		username = "user1",
#' 		name = "User One",
#' 		code = "XXAAMMRR"
#' 	),
#' 	to = input$email,
#' 	from = email$from,
#' 	subject = email$subject_getcode,
#' 	cc = email$cc,
#' 	bcc = email$bcc,
#' 	credentials = email$creds_file,
#' 	verbose = FALSE
#' )
#' }
#'
#' @export
email_template <- function(creds_file,
                           from,
                           cc = NULL,
                           bcc = NULL,
                           subject_welcome = NULL,
                           body_welcome = NULL,
                           subject_getcode = NULL,
                           body_getcode = NULL,
                           subject_pw_reset = NULL,
                           body_pw_reset = NULL,
                           footer = NULL) {
  ## default email message
  if (is.null(body_welcome)) {
    body_welcome <- "
## Hi {name}!

I hope this email finds you well! I wanted to personally extend a warm welcome to `shinyAuthX`. We're thrilled to have you join us, and we can't wait to witness the incredible projects you'll create with `shinyAuthX`.

`shinyAuthX` is an exceptional R package that offers a cost-effective and powerful solution for user authentication in your Shiny applications. It provides a comprehensive set of features including sign-in, sign-up, sign-out, and password recovery, seamlessly integrated through user-friendly UI and Server components.

While `shinyAuthX` enhances convenience, it's crucial to prioritize web security by consulting professionals and implementing appropriate measures. Protecting user data is of utmost importance. Therefore, we encourage you to evaluate and implement the necessary security measures to ensure the privacy and security of your application. ***Please be aware that the use of `shinyAuthX` is at your own risk, and it is your responsibility to secure your application and safeguard user privacy.***

Once again, welcome to our package! We're excited to have you on board and can't wait to see the amazing things you'll accomplish with `shinyAuthX`.

Best regards,
Cheers,

Myo
*Creator of the package*
"
  }

  if (is.null(body_getcode)) {
    body_getcode <- '
Hi {name},

<div>Your username is {username}.</div>

Please use the following code to verify your email:

<div style="color:navy; font-size:40px;"><strong>{code}</strong></div>

If this wasn\\\'t you, please reset your email password to secure your account.

Regards,

The `shinyAuthX` Team
'
  }

  if (is.null(body_pw_reset)) {
    body_pw_reset <- "
Hi {name},

We have reset the password for the account {username}.

Regards,

The `shinyAuthX` Team
"
  }

  if (is.null(subject_welcome)) {
    subject_welcome <- paste0(
      "Welcome to our `shinyAuthX` package! ",
      emojifont::emoji("rainbow")
    )
  }
  if (is.null(subject_getcode)) {
    subject_getcode <- "Verify your code!"
  }
  if (is.null(subject_pw_reset)) {
    subject_pw_reset <- "Password Reset!"
  }

  if (is.null(footer)) {
    footer <- "
sent via the [shinyAuthX](https://github.com/myominnoo/shinyAuthX) package
on {blastula::add_readable_time()}
"
  }

  list(
    creds_file = creds_file,
    from = from,
    cc = cc,
    bcc = bcc,
    subject_welcome = subject_welcome,
    body_welcome = body_welcome,
    subject_getcode = subject_getcode,
    body_getcode = body_getcode,
    subject_pw_reset = subject_pw_reset,
    body_pw_reset = body_pw_reset,
    footer = footer
  )
}



#' Create Email
#'
#' This function creates an email using the `blastula` package by composing the email body and footer.
#'
#' @param body The body content of the email.
#' @param footer The footer content of the email.
#' @param username (Optional) The username associated with the email.
#' @param name (Optional) The name of the recipient.
#' @param code (Optional) A code or verification token to be included in the email.
#' @param ... Additional arguments to be passed to the [blastula::compose_email] function.
#'
#' @return An email object created using the `blastula` package.
#'
#' @examples
#' # Create an email
#' email <- create_email(
#'   body = "Hello {name}, your username is {username}.",
#'   footer = "Please contact support if you have any questions.",
#'   username = "john123",
#'   name = "John Doe"
#' )
#'
#' @export
create_email <- function(body, footer, username = NULL,
                         name = NULL, code = NULL, ...) {
  blastula::compose_email(
    body = blastula::md(glue::glue(body)),
    footer = blastula::md(glue::glue(footer)),
    ...
  )
}
