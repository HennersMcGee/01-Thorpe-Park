## ---------------------------
##
## Script name: Data Clean and Engineer
##
## Purpose of script:
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

library(RMySQL); library(plyr); library(dplyr); library(chron)

##Gets data from sql server

password <- readline(prompt="Enter password: ")

mydb = dbConnect(MySQL(), 
                 user='u235764393_HL', 
                 password=password, 
                 dbname='u235764393_HLDB', 
                 host='sql134.main-hosting.eu',
                 trusted_connection="True")

ThorpePark_Data <- dbGetQuery(mydb, "select * from ThorpePark_Data")


for (i in dbListConnections(MySQL())) {dbDisconnect(i)}

#Remove times outside openming hours

ThorpePark_Data <- ThorpePark_Data %>%
    dplyr::mutate(Time=format(as.POSIXct(Scrape_Date),format="%H:%M:%S")) %>%
    dplyr::mutate(Date=as.Date(as.POSIXct(Scrape_Date))) %>%
    dplyr::mutate(Problem=ifelse(Wait<0,1,0)) %>%
    dplyr::filter(Time>="10:00:00" & Time<="20:00:00")

## Get list of rides to drop (never open or not a ride)

dtDropRides <- ThorpePark_Data %>%
    dplyr::group_by_at(c("Ride","Wait")) %>%
    dplyr::summarise(Count=n()) %>%
    dplyr::group_by_at(c("Ride")) %>%
    dplyr::mutate(Percwait =Count/sum(Count)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Wait==-1 & Percwait>0.8)

## Get list of days where all rides are closed

dtDropDays <- ThorpePark_Data %>%
    dplyr::group_by_at(c("Date","Wait")) %>%
    dplyr::summarise(Count=n()) %>%
    dplyr::group_by_at(c("Date")) %>%
    dplyr::mutate(Percwait =Count/sum(Count)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Wait==-1 & Percwait>0.9)

## Get list of ride days where it's closed more than half of the day, and less than 80 obs from day

dtDropRideDays <- ThorpePark_Data %>%
    mutate(Date=as.Date(as.POSIXct(Scrape_Date))) %>%
    dplyr::group_by_at(c("Date","Ride","Wait")) %>%
    dplyr::summarise(Count=n()) %>%
    dplyr::group_by_at(c("Date","Ride")) %>%
    dplyr::mutate(Percwait =Count/sum(Count)) %>%
    dplyr::mutate(DateRideCount =sum(Count)) %>%
    dplyr::ungroup() %>%
    dplyr::filter((Wait==-1 & Percwait>0.5) | 
                      (Wait==-2 & Percwait>0.5) |
                      DateRideCount<80) %>%
    dplyr::mutate(Cond=paste0(Date,Ride))

## Remove unwanted data

dt2 <- ThorpePark_Data %>%
    dplyr::mutate(Cond=paste0(Date,Ride)) %>%
    dplyr::filter(!(Cond %in% dtDropRideDays$Cond)) %>%
    dplyr::select(-Cond) %>%
    dplyr::filter(!(Ride %in% dtDropRides$Ride)) %>%
    dplyr::filter(!(Date %in% dtDropDays$Date))

## Extrapolate delayed/closed times - Unused

# TimeList <- unique(dt2$Time)
# 
# RideDay <- dt2[dt2$Ride=="Swarm" & dt2$Date=="2019-08-08",]
# 
# plot(factor(RideDay$Time),RideDay$Wait)
# 
# for (i in TimeList) {
#     tryCatch({
#         
# }

## Create "All" rides rows

test3 <- dt2[1:1000,]

DatetimeList <- unique(dt2$Scrape_Date)
RideList <- unique(dt2$Ride)

AllDt <- dt2 %>% 
    dplyr::filter(Wait>=0) %>%
    dplyr::group_by_at(c("Scrape_Date")) %>%
    dplyr::summarise(RideCount=n(), Wait=sum(Wait)) %>%
    dplyr::mutate(Problem=25-RideCount, Ride="All")
    
dt3 <- rbind.fill(dt2,AllDt) %>%
    dplyr::arrange(Scrape_Date,Ride) %>%
    dplyr::select(Data_ID, HTML_ID, Ride, Wait, Scrape_Date, Problem)

## Save data to SQL data base

NumRows <- round_any(length(dt3$Ride)/1000,1,f = ceiling)

for (j in 1:NumRows) {
    
    if (j==NumRows){
        dtPart <- dt3[((j-1)*1000+1):length(dt3$Ride),]
    } else {
        dtPart <- dt3[((j-1)*1000+1):(j*1000),]   
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
                CREATE TABLE IF NOT EXISTS ThorpePark_DataClean (
                DataClean_ID INT AUTO_INCREMENT PRIMARY KEY,
                HTML_ID INT,
                Data_ID INT,
                Ride TEXT,
                Wait INT,
                Problem INT,
                Scrape_Date TIMESTAMP,
                DateTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ")

    dbSendQuery(mydb, paste0("INSERT INTO `ThorpePark_DataClean`
                             (`Data_ID`,`HTML_ID`,`Ride`,`Wait`,`Scrape_Date`,`Problem`) VALUES ",
                             valueList, sep=""))
    
    for (i in dbListConnections(MySQL())) {dbDisconnect(i)}
    
}




