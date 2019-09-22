## ---------------------------
##
## Script name: Packages_Install_Load
##
## Purpose of script: Install and/or load packages
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

packFn <- function(list) {
    
    packs <- installed.packages()[,1]
    for (i in list) {
        if (is.element(i,packs)) {
            print(paste0(i, " installed"))
        } else {
            print(paste0(i, " not installed"))
            install.packages(i)
        }
        print(i)
        eval(parse(text=paste0("library(",i,")")))
    }
    
}
