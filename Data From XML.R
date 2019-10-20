## ---------------------------
##
## Script name: Data From XML
##
## Purpose of script: Gets data out form stored XMLs
##
## Author: Henry Letton
##
## Date Created: 2019-10-13
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------


library(RMySQL); library(dplyr); library(rvest); library(plyr); library(XML)

##Gets data from sql server

password <- readline(prompt="Enter password: ")

mydb = dbConnect(MySQL(), 
                 user='u235764393_HL', 
                 password=password, 
                 dbname='u235764393_HLDB', 
                 host='sql134.main-hosting.eu',
                 trusted_connection="True")

ThorpePark_HTML <- dbGetQuery(mydb, "select * from ThorpePark_HTML")


for (i in dbListConnections(MySQL())) {dbDisconnect(i)}

##Extracts ride times

dt <- data.frame(Date=as.numeric(), Ride=as.character(), 
                 Wait=as.numeric(), HTML_ID=as.numeric())

for (j in 1:length(ThorpePark_HTML[,2])) {
    
    ThorpePark_HTML1 <- read_html(ThorpePark_HTML[j,2])
    PrimaryKey <- ThorpePark_HTML[j,1]
    
    fulllist <- ThorpePark_HTML1 %>% html_nodes(".is-half span") %>%
        html_text()
    
    count <- 0
    rides <- c()
    times <- c()
    timey <- as.POSIXct(round_any(as.numeric(as.POSIXct(
        ThorpePark_HTML[j,3], tz="UTC"))+60,300, f = floor)
        ,origin="1970-01-01 00:00.00 UTC", tz="GB")
    
    dtTemp <- data.frame(Date=as.numeric(), Ride=as.character(), 
                         Wait=as.numeric(), HTML_ID=as.numeric())
    dt1 <- data.frame(Date=as.numeric(""), Ride=as.character(""), 
                      Wait=as.numeric(""), HTML_ID=as.numeric(""))
    
    for (i in fulllist){
        if (grepl("^\n",i) & substr(i,2,2)!="(") {
            x = strsplit(i,"\n")[[1]][2]
            if (grepl("^[0-9]",x)) {
                y = strsplit(x," ")[[1]][1]
                dt1$Wait <- as.integer(y)
                dtTemp <- rbind(dtTemp,dt1)
            } else if (x=="Delayed") {
                dt1$Wait <- -2
                dtTemp <- rbind(dtTemp,dt1)
            } else if (x=="Closed") {
                dt1$Wait <- -1
                dtTemp <- rbind(dtTemp,dt1)
            } else {
                dt1$Ride <- x
            }
        }
        
    }
    
    
    dtTemp$Date <- timey; dtTemp$HTML_ID <- PrimaryKey
    
    dt <- rbind(dt,dtTemp)
    
}

##Filters by date if needed

dt <- dt %>% filter(Date>0)

##Writes to SQL data base

NumRows <- round_any(length(dtAll4$Ride)/1000,1,f = ceiling)

for (j in 1:NumRows) {
    
    if (j==NumRows){
        dtPart <- dt[((j-1)*1000+1):length(dtAll4$Ride),]
    } else {
        dtPart <- dt[((j-1)*1000+1):(j*1000),]   
    }
    
    valueList <- paste0(apply(dtPart, 1, function(x) paste0("('",
                                                               paste0(x, collapse = "', '"), "')")), collapse = ", ")
    
    mydb = dbConnect(MySQL(), 
                     user='u235764393_HL', 
                     password=password, 
                     dbname='u235764393_HLDB', 
                     host='sql134.main-hosting.eu',
                     trusted_connection="True")
    
    dbSendQuery(mydb, "
                CREATE TABLE IF NOT EXISTS ThorpePark_Data (
                Data_ID INT AUTO_INCREMENT PRIMARY KEY,
                HTML_ID INT,
                Ride TEXT,
                Wait INT,
                Scrape_Date TIMESTAMP,
                DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ")

dbSendQuery(mydb, paste0("INSERT INTO `ThorpePark_Data`
                         (`Scrape_Date`,`Ride`,`Wait`,`HTML_ID`) VALUES ",
                         valueList, sep=""))

for (i in dbListConnections(MySQL())) {dbDisconnect(i)}

}



