
#Function to download the data
dowload_data <- function() {

#data Url
Url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"

temp <- tempfile()
download.file(Url, temp)

unzip(temp, "activity.csv")
df <- read.csv("activity.csv")
unlink(temp)

#output Dataframe
result <- df

}

df <- dowload_data()
