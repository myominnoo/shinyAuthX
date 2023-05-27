
## test scripts from `shinyauthr` package

library(testthat)
library(shiny)
library(shinyAuthX)

users_base <- create_dummy_users()

test_that("user_auth is FALSE and info is NULL by default", {
	signout <- reactiveVal()
	testServer(
		signinServer,
		args = list(
			users_db = users_base,
			signout = signout
		), {
			# module return value
			credentials <- session$getReturned()
			expect_false(credentials()$user_auth)
			expect_null(credentials()$info)
		})
})


test_that("user1 signin and signout", {
	signout <- reactiveVal()
	testServer(
		signinServer,
		args = list(
			users_db = users_base,
			signout = signout,
			cookie_logins = FALSE
		), {
			# module return value
			credentials <- session$getReturned()

			# login as user 1
			session$setInputs(username = "user1")
			session$setInputs(password = "pass1")
			session$setInputs(btn_signin = 1)
			session$elapse(1000)

			expect_true(session$returned()$user_auth)
			expect_equal(session$returned()$info$username, "user1")
			expect_equal(session$returned()$info$name, "User One")
			expect_equal(session$returned()$info$permissions, "standard")

			# signout
			signout(1)
			session$flushReact()
			session$elapse(1000)
			expect_false(session$returned()$user_auth)
			expect_null(session$returned()$info)
		})
})

test_that("user2 sigin works", {
	signout <- reactiveVal()
	testServer(
		signinServer,
		args = list(
			users_db = users_base,
			signout = signout,
			cookie_logins = FALSE
		), {
			# module return value
			credentials <- session$getReturned()

			# login as user 2
			session$setInputs(
				username = "user2",
				password = "pass2",
				btn_signin = 1
			)
			expect_true(credentials()$user_auth)
			expect_equal(credentials()$info$username, "user2")
			expect_equal(credentials()$info$name, "User Two")
			expect_equal(credentials()$info$permissions, "standard")

			# logout
			signout(1)
			session$flushReact()
			expect_false(credentials()$user_auth)
			expect_null(credentials()$info)
		})
})



test_that("incorrect credentials does not sign in", {
	signout <- reactiveVal()
	testServer(
		signinServer,
		args = list(
			users_db = users_base,
			signout = signout,
			cookie_logins = FALSE
		), {
			# module return value
			credentials <- session$getReturned()

			# test incorrect credentials
			session$setInputs(
				username = "user1",
				password = "wrong_pwd",
				btn_signin = 1
			)
			expect_false(credentials()$user_auth)
			expect_null(credentials()$info)
		})
})



test_that("password without sodium hash works", {
	users_base <- dplyr::tibble(
		username = "user1",
		password = "pass1"
	)
	signout <- reactiveVal()
	testServer(
		signinServer,
		args = list(
			users_db = users_base,
			sodium_hashed = FALSE,
			signout = signout,
			cookie_logins = FALSE
		), {
			# module return value
			credentials <- session$getReturned()

			# login as user 1
			session$setInputs(
				username = "user1",
				password = "pass1",
				btn_signin = 1
			)

			expect_true(credentials()$user_auth)
		})
})



