## ---------------------------
##
## Script name: Webcrape
##
## Purpose of script: 
##
## Author: Henry Letton
##
## Date Created: 2019-09-21
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

#Load in required packages
library(odbc)
library(DBI)
library(dbplyr)
library(plyr)
library(RMySQL)
library(xml2)

#Run scrape function script
source("Scrape Function.R")

#Ask user for SQL password
password <- readline(prompt="Enter password: ")

    
# Scrape Thorpe Park data every 5 mins between 10am and 8pm inclusive
while (TRUE) {
    #When it is before 10am check time every 60 minute
    if (format(as.POSIXct(Sys.time()+60),'%H')<10) {
        Sys.sleep(60)
    #When it is after 8pm, sleep for 10 hours
    } else if (format(as.POSIXct(Sys.time()-360),'%H')>19) {
        #At most, sleep until 30 seconds before 10am
        Sys.sleep(10*60*60-30)
    #When it is between 10am and 8pm, check if time is multiple of 5 mins
    } else if (
        #-30 as spotted 1 second out between R and SQL server so giving gap of 30 seconds for any future deviation
        round_any(as.numeric(Sys.time())-30,1, f = ceiling)==round_any(as.numeric(Sys.time())-30,300, f = ceiling)
        ) {
        #Whn multiple of 5 mins, extract html using function
        HTMLfn(password)
        #Sleep once extacted until near next 5 mins time 
        #(250 seconds to allow for any run times or delays) 
        Sys.sleep(250)
    }
}




