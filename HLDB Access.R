## ---------------------------
##
## Script name: HLDB Access
##
## Purpose of script:
##
## Author: Henry Letton
##
## Date Created: 2019-09-18
##
## ---------------------------
##
#m # Notes:
##   
##
## ---------------------------

library(odbc)
library(DBI)
library(dbplyr)
library(plyr)
library(RMySQL)
library(xml2)

mydb = dbConnect(MySQL(), 
                 user='u235764393_HL', 
                 password=password, 
                 dbname='u235764393_HLDB', 
                 host='sql134.main-hosting.eu',
                 trusted_connection="True")

dbGetQuery(mydb,'
  select * from data1
')

dbListTables(mydb)

dbSendQuery(mydb, "select * from data1")

dbSendQuery(mydb, "INSERT INTO `data1` (`name`, `number`) VALUES ('Tom', '7');")

xml1 <- dbGetQuery(mydb, "select * from ThorpePark_HTML")

dbRemoveTable(mydb, "table_name")

dbDisconnect(mydb)


#Code for Thorpe Park

HTMLfn <- function() {

mydb = dbConnect(MySQL(), 
                 user='u235764393_HL', 
                 password=password, 
                 dbname='u235764393_HLDB', 
                 host='sql134.main-hosting.eu',
                 trusted_connection="True")

dbSendQuery(mydb, "
            CREATE TABLE IF NOT EXISTS ThorpePark_HTML (
            HTML_ID INT AUTO_INCREMENT PRIMARY KEY,
            HTML TEXT,
            DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ")


HTML <- tryCatch({
    read_html("https://queue-times.com/parks/2/queue_times")
}, warning = function(w) {
    "Website warning"
}, error = function(e) {
    "Website error"
}, finally = {
    "Website other"
})

if (HTML[1]=="Website warning") {print(HTML)}
if (HTML[1]=="Website error") {print(HTML)}
if (HTML[1]=="Website other") {print(HTML)}

HTML2 <- gsub("'","''",HTML)[1:10]


Query <- paste0("INSERT INTO ``ThorpePark_HTML` (`HTML`) VALUES ('`'",
                HTML2,"'`');",sep="")

dbSendQuery(mydb, paste0("INSERT INTO `ThorpePark_HTML` (`HTML`) VALUES ('",HTML2,"');",sep=""))

for (i in dbListConnections(MySQL())) {dbDisconnect(i)}

}

HTMLfn()




