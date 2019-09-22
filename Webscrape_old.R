## ---------------------------
##
## Script name: Webscrape
##
## Purpose of script: Extact Wait times
##
## Author: Henry Letton
##
## Date Created: 2019-08-03
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

library(tidyverse)
library(rvest)
library(stringr) 
library(rebus)
library(lubridate)
library(xml2)

#Data <- data.frame(Date=as.numeric(),
                    #Ride=as.character(),
                    #Wait=as.numeric())

numb <- 0
time <- as.numeric(Sys.time())
while (numb<2400) {
    if (format(as.POSIXct(Sys.time()),'%H')<10) {
        Sys.sleep(30)
        time <- as.numeric(Sys.time())
    } else if (format(as.POSIXct(Sys.time()-5*60),'%H')>19) {
        Sys.sleep(30)
    } else if (as.numeric(Sys.time())>=time) {
        time <- time + 5*60
        Data <- rbind(Data,TPscrape())
        numb <- numb+1
    } else {Sys.sleep(30)}
}




#dateF <- as.POSIXct('2019-08-08 19:55:01')
#Data <- Data[Data$Date<=dateF+1000,]

table(Data$Ride,Data$Wait)

DataSaw <- Data[Data$Ride=="SAW - The Ride",]
DataSwarm <- Data[Data$Ride=="Swarm",]
DataColossus <- Data[Data$Ride=="Colossus",]
DataStealth <- Data[Data$Ride=="Stealth",]
DataNemesis <- Data[Data$Ride=="Nemesis Inferno",]
DataDerren <- Data[Data$Ride=="Derren Brown",]
DataStorm <- Data[Data$Ride=="Storm Surge",]
DataFlying <- Data[Data$Ride=="Flying Fish",]
DataRumba <- Data[Data$Ride=="Rumba Rapids",]


plot(DataSaw$Date,DataSaw$Wait)
plot(DataNemesis$Date,DataNemesis$Wait)
plot(DataFlying$Date,DataFlying$Wait)
plot(DataDerren$Date,DataDerren$Wait)
plot(DataSwarm$Date,DataSwarm$Wait)
plot(DataStealth$Date,DataStealth$Wait)
plot(DataRumba$Date,DataRumba$Wait)
plot(DataColossus$Date,DataColossus$Wait)



#one ride, each day as different colour
#one day, all rides dif colours
#each day as sum of wait times - treatment of delays
#likelihood of delays and closures
#extra info: areas, ride length, age, popularity, weather
#day of week
#averaging of wait times
#location in park - heat map

#Other Test+

webpage2<- read_html("https://queue-times.com/parks/2/queue_times")


gsub("^\n(.*?)\n","\\1",fulllist[8],perl=TRUE)


test <- regexec("^\n(.*?)\\",fulllist[8])
test[[1]]
regmatches(fulllist[8],test)[[1]][2]

test2 <- strsplit(fulllist[8],"\n")
test2



str_extract(fulllist[7],"^\n(.*)\n")

xml_name(webpage)

xml_children(webpage)

baz <- xml_find_all(webpage, ".//span")
baz
