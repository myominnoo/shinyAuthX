
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyAuthX <img src="man/figures/logo.png" align="right" height="138" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/shinyAuthX)](https://CRAN.R-project.org/package=shinyAuthX)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

## Simplify User Authentication in Shiny Apps with `ShinyAuthX`

`ShinyAuthX` is a powerful R package specifically designed for user
authentication within Shiny apps. It provides a comprehensive suite of
authentication features including user sign-in, sign-up, sign-out, and
password recovery, seamlessly integrating user-friendly UI and Server
components. It empowers shiny app developers to create secure and
user-friendly authentication systems.

**Authentication Modules**: The sign-in module (`signinUI`,
`signinServer`) enables users to authenticate themselves securely, while
the sign-up feature (`signupUI`, `signupServer`) allows for hassle-free
registration and account creation. With the sign-out module
(`signoutUI`, `signoutServer`), users can conveniently sign out from
your application, ensuring their privacy and security. In the event of a
forgotten password, the password recovery module (`forgotpwUI`,
`forgotpwServer`) facilitates a straightforward and efficient recovery
process.

**Password Encryption**: Passwords are hashed using the `sodium`
package, providing an additional layer of protection for user
credentials. The source code of your main application is also protected
until authentication is successful, ensuring that sensitive information
remains secure.

**UI Integration**: `ShinyAuthX`’s modern UI designs are carefully
crafted to provide a visually appealing and intuitive authentication
experience for your users. The compatibility with Bootstrap themes
ensures seamless integration with your existing Shiny app design,
maintaining a consistent and professional look and feel throughout.

**Data integration**: Its flexibility in data storage options, both
local and online database `MongoDB` using the `mongolite` package. This
allows you to choose the database solution that best suits your
application’s needs and infrastructure.

**Verification Code via Email**: To further enhance the authentication
experience, `shinyAuthX` leverages the `blastula` package to send custom
emails, such as code verification during the sign-up process and
password recovery emails. This ensures that users receive personalized
and secure communications during critical steps of their authentication
journey.

It’s important to note that currently, `shinyAuthX` supports only
`MongoDB` for database connection. The signup and password recovery
features are optimized for `MongoDB` usage, providing the best
experience and performance in this setup.

**Let’s Get Started Today**: Experience the power and simplicity of
`ShinyAuthX`, the ultimate suite of modules for user authentication in
Shiny apps. Unlock the full potential of secure and user-friendly
authentication and elevate your Shiny applications to new heights.

Please feel free to reach out to us with any questions or concerns.
We’re here to support you as you incorporate `shinyAuthX` into your
Shiny apps.

## Demo Live!

\[To add later\]

### Installation

You can install the development version of shinyAuthX from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("myominnoo/shinyAuthX")
```

## Run example apps

Code for example apps in various contexts can be found in
[inst/examples](inst/examples). You can launch these example apps with
the `runExample` function.

You can use the following `user`/`password` pairs: - `admin`/`admin` -
`user1`/`pass1` - `user2`/`pass2`

See `?create_dummy_users` for dummy user credentials that are used in
these examples.

``` r
  runExample("basic-signin")
  runExample("basic-signin-mongodb")
  runExample("basic-signin-theme")
  runExample("basic-signup")
  runExample("signup-pw-reset")
  runExample("test-app")
```

## Usage

The package provides four module functions with corresponding UI and
server elements:

- sign-in: `signinUI`, `signinServer`
- sign-out: `signoutUI`, `signoutServer`
- sign-up: `signupUI`, `signupServer`
- password recovery: `forgotpwUI`, `forgotpwServer`

Below is a minimal reproducible example of how to use the `sign-in`
authentication modules in a shiny app.

``` r

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

shinyApp(ui = ui, server = server)
```

## TODO:

1.  add demo shiny apps hosted on shinyapps.io
2.  add runExample().
3.  add examples for each use case
    1.  simple user signin
    2.  user signin with data.frame
    3.  user signin with mongolite
    4.  user signup with mongolite
    5.  user signup with mongolite plus email option \[just codes; not
        run\]

## Credits:

We would like to extend our sincere gratitude and acknowledgments to the
following individuals for their contributions to the development of
`shinyAuthX`:

- Paul Campbell: The author of the `shinyauthr` package, from which we
  borrowed the `login` and `logout` module functions (`loginUI()`,
  `loginServer()`, `logoutUI()`, `logoutServer()`). Paul’s work and
  dedication have significantly influenced the functionality and
  usability of `shinyAuthX`.

We would also like to specifically credit the following individuals for
their contributions to the cookie-based authentication aspect of
`shinyAuthX`:

- Michael Dewar: His expertise and contributions have played a crucial
  role in shaping the implementation of the cookie-based authentication
  mechanism in `shinyAuthX`. His insights have greatly enhanced the
  security and functionality of this feature.

- Calligross: Their valuable input and contributions have contributed to
  the development and improvement of the cookie-based authentication
  functionality in `shinyauthr`.

For further information about their specific roles and contributions, we
recommend visiting the
[`shinyauthr`](https://github.com/PaulC91/shinyauthr) GitHub page, where
you can find additional details about the original package and its
contributors.

## Disclaimer:

It is important to note that the security of any authentication system
is a complex matter, and while we have taken great care in developing
`shinyAuthX`, we cannot guarantee its foolproof security. The
authentication process provided by `shinyAuthX` should be used with
caution, and we strongly recommend implementing additional security
measures based on your specific requirements. We endorse Paul Campbell’s
disclaimer statement regarding the security risks associated with the
package. Please use `shinyAuthX` at your own risk.

We are grateful for the contributions and support from all the
individuals mentioned above, as well as the wider community that has
provided feedback and suggestions to help improve `shinyAuthX`. Thank
you for your valuable contributions and continued support!

## Related work

Both package [`shinyauthr`](https://github.com/PaulC91/shinyauthr) and
[shinymanager](https://github.com/datastorm-open/shinymanager/) provide
a nice shiny module to add an authentication layer to your shiny apps.
