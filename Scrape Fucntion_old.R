## ---------------------------
##
## Script name: Scrape Function
##
## Purpose of script:
##
## Author: Henry Letton
##
## Date Created: 2019-08-07
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------



TPscrape <- function(data=data) {
    
    webpage = tryCatch({
        read_html("https://queue-times.com/parks/2/queue_times")
    }, warning = function(w) {
        NULL
    }, error = function(e) {
        NULL
    }, finally = {
        NULL
    })
    
    if (!is.null(webpage)) {
    
    fulllist <- webpage %>% html_nodes(".is-half span") %>%
        html_text()
    
    count <- 0
    timey <- as.POSIXct(Sys.time())
    rides <- c()
    times <- c()
    
    
    for (i in fulllist){
        if (grepl("^\n",i) & substr(i,2,2)!="(") {
            x = strsplit(i,"\n")[[1]][2]
            if (grepl("^[0-9]",x)) {
                y = strsplit(x," ")[[1]][1]
                times[count] <- as.integer(y)
            } else if (x=="Delayed") {
                times[count] <- -2
            } else if (x=="Closed") {
                times[count] <- -1
            } else {
                count <- count+1
                rides[count] <- x
            }
        }
    }
    
    data.frame(Date=timey,
               Ride=rides,
               Wait=times)
    } else {
        data.frame(Date=as.numeric(), Ride=as.character(), Wait=as.numeric())
    }
}

TPscrape()



