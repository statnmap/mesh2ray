# Hide this file from build
usethis::use_build_ignore("devstuff_history.R")
usethis::use_build_ignore("inst/dev")
usethis::use_build_ignore("rsconnect")
usethis::use_build_ignore("reference")
usethis::use_git_ignore("docs/")
usethis::use_git_ignore("rsconnect/")
# usethis::create_package(".")

# description ----
library(desc)
unlink("DESCRIPTION")
my_desc <- description$new("!new")
my_desc$set_version("0.0.0.9000")
my_desc$set(Package = "mesh2ray")
my_desc$set(Title = "Transform mesh3d to ray* objects")
my_desc$set(Description = "Transform mesh3d to objects that can be used with 'rayshader' or 'rayrender'.")
my_desc$set("Authors@R",
            'c(
  person("Sebastien", "Rochette", email = "sebastien@thinkr.fr", role = c("aut", "cre"), comment = c(ORCID = "0000-0002-1565-9313"))
)')
my_desc$set("VignetteBuilder", "knitr")
my_desc$del("Maintainer")
my_desc$del("URL")
my_desc$del("BugReports")
my_desc$write(file = "DESCRIPTION")

# Licence ----
usethis::use_gpl3_license("Sébastien Rochette")
# usethis::use_gpl3_license("ThinkR")

# Pipe ----
usethis::use_pipe()

# Package quality ----

# _Tests
usethis::use_testthat()
usethis::use_test("app")

# _CI
usethis::use_git()
thinkridentity::use_gitlab_ci(image = "thinkr/runnerci", upgrade = "never")
tic::use_tic()
# usethis::use_travis()
# usethis::use_appveyor()
# usethis::use_coverage()

# _rhub
# rhub::check_for_cran()


# Documentation ----
# CoC
usethis::use_code_of_conduct()
# Roxygen
usethis::use_roxygen_md()
# _Readme
usethis::use_readme_rmd()
# _News
usethis::use_news_md()
# _Vignette
usethis::use_vignette("aa-rayshader")
usethis::use_vignette("ab-rayrender")
devtools::build_vignettes()

# _Book
# thinkridentity::install_git_with_pwd(repo = "ThinkR/visualidentity", username, password, host = "git.thinkr.fr")
visualidentity::create_book("inst/report", clean = TRUE)
visualidentity::open_guide_function()
devtools::document()
visualidentity::build_book(clean_rmd = TRUE, clean = TRUE)
# pkg::open_guide()

# _Pkgdown
visualidentity::build_pkgdown(
  # lazy = TRUE,
  yml = system.file("pkgdown/_pkgdown.yml", package = "thinkridentity"),
  favicon = system.file("pkgdown/favicon.ico", package = "thinkridentity"),
  move = TRUE, clean = TRUE
)

visualidentity::open_pkgdown_function(path = "docs")
# pkg::open_pkgdown()

# Dependencies ----
# devtools::install_github("ThinkR-open/attachment")
attachment::att_to_description()
attachment::att_to_description(extra.suggests = c("pkgdown", "magick"))
# attachment::create_dependencies_file()

# Utils for dev ----
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)
# ascii
stringi::stri_trans_general("é", "hex")
