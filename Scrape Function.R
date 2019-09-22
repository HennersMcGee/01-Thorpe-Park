## ---------------------------
##
## Script name: Scrape Function
##
## Purpose of script:
##
## Author: Henry Letton
##
## Date Created: 2019-09-21
##
## ---------------------------
##
## Notes: Script is just a function, 
##        which can be run from another script.
##
## ---------------------------



# 'password' needs to be given

HTMLfn <- function(password) {
    
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
