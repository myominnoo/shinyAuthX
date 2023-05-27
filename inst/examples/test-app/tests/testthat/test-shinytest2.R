library(shinytest2)

test_that("{shinytest2} recording: test-app", {
  app <- AppDriver$new(variant = platform_variant(), name = "test-app", seed = 123, 
      height = 1289, width = 2259)
  app$set_inputs(`signin-username` = "adm")
  app$set_inputs(`signin-username` = "admin")
  app$set_inputs(`signin-password` = "admin")
  app$click("signin-btn_signin")
  app$click("signout-btn_signout")
  app$expect_values()
  app$expect_screenshot()
})
