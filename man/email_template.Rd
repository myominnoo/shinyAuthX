% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/email.R
\name{email_template}
\alias{email_template}
\title{Create Email Template}
\usage{
email_template(
  creds_file,
  from,
  cc = NULL,
  bcc = NULL,
  subject_welcome = NULL,
  body_welcome = NULL,
  subject_getcode = NULL,
  body_getcode = NULL,
  subject_pw_reset = NULL,
  body_pw_reset = NULL,
  footer = NULL
)
}
\arguments{
\item{creds_file}{The email credential file. See \link{creds_file}.}

\item{from}{The sender's email address.}

\item{cc}{(Optional) The email address(es) to be included in the CC field.}

\item{bcc}{(Optional) The email address(es) to be included in the BCC field.}

\item{subject_welcome}{The subject line for the welcome email.}

\item{body_welcome}{The body content for the welcome email.}

\item{subject_getcode}{The subject line for the verification code email.}

\item{body_getcode}{The body content for the verification code email.}

\item{subject_pw_reset}{The subject line for the password reset email.}

\item{body_pw_reset}{The body content for the password reset email.}

\item{footer}{The footer content to be included in all emails.}
}
\value{
A named list containing the email template
with customizable subject lines, body content,
and footer for various scenarios.
}
\description{
This function creates an email template for different scenarios
using customizable subject lines, body content, and footer.
It provides default content for welcome, verification code, and password
reset emails, but allows for customization of each part.
}
\details{
The generated email template is used internally in conjunction
with the \link{create_email} function to compose emails for three scenarios:
welcome, verification code, and password reset.

Prior to using this function, you need to create an email credential file
using the \link{create_smtp_creds_file} function from the \code{blastula} package
and provide the path to the credential file
using the \link{creds_file} function.
}
\examples{

\dontrun{
# Create an email template
template <- email_template(
  creds_file = "path/to/creds/file",
  from = "sender@example.com",
  cc = "cc@example.com",
  bcc = "bcc@example.com",
  subject_welcome = "Welcome to shinyAuthX!",
  body_welcome = "Custom welcome email content",
  subject_getcode = "Verify your code",
  body_getcode = "Custom verification code email content",
  subject_pw_reset = "Password reset",
  body_pw_reset = "Custom password reset email content",
  footer = "Custom footer content"
)

# internal use inside the package
blastula::smtp_send(
	email = create_email(
		body = template$body_getcode,
		footer = template$footer,
		username = "user1",
		name = "User One",
		code = "XXAAMMRR"
	),
	to = input$email,
	from = email$from,
	subject = email$subject_getcode,
	cc = email$cc,
	bcc = email$bcc,
	credentials = email$creds_file,
	verbose = FALSE
)
}

}
