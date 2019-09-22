## ---------------------------
##
## Script name: Password
##
## Purpose of script:
##
## Author: Henry Letton
##
## Date Created: 2019-09-22
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

pwFn <- function() {
    password <- readline(prompt="Enter password: ")
    save(password, file="pw.Rda")
}

pwFn()



# pwLoop <- function() {
#     passW <- function() {readline(prompt="Enter password: ")}
#     password <- passW()
# }
# 
# pwLoop()
# 
# 
# load("pw.Rda")


