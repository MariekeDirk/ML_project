#############################################################################################################


                  # This is the script in which the GMS data for the skected days for the 2nd and 3rd model
                  # are put into dataframes with the right input format for the ML scripts


#############################################################################################################

# Empty environment
rm(list=ls()) 

## Load GMS data files of the relevant days 
Col_Classes_1 <- c("integer", "POSIXct", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "factor", "factor", "factor", "numeric", "logical", "logical", "character")

Data_2013_12_03 <- read.csv("/data/project/GMS/data/GMSraw/2013-12-03.csv", colClasses = Col_Classes_1)
Data_2013_12_03$TIMESTAMP <- as.POSIXct(Data_2013_12_03$TIMESTAMP, tz = "GMT")

Data_2016_01_09 <- read.csv("/data/project/GMS/data/GMSraw/2016-01-09.csv", colClasses = Col_Classes_1)
Data_2016_01_09$TIMESTAMP <- as.POSIXct(Data_2016_01_09$TIMESTAMP, tz = "GMT")

Data_2014_12_28 <- read.csv("/data/project/GMS/data/GMSraw/2014-12-28.csv", colClasses = Col_Classes_1)
Data_2014_12_28$TIMESTAMP <- as.POSIXct(Data_2014_12_28$TIMESTAMP, tz = "GMT")

Data_2015_03_24 <- read.csv("/data/project/GMS/data/GMSraw/2015-03-24.csv", colClasses = Col_Classes_1)
Data_2015_03_24$TIMESTAMP <- as.POSIXct(Data_2015_03_24$TIMESTAMP, tz = "GMT")

Data_2015_03_08 <- read.csv("/data/project/GMS/data/GMSraw/2015-03-08.csv", colClasses = Col_Classes_1)
Data_2015_03_08$TIMESTAMP <- as.POSIXct(Data_2015_03_08$TIMESTAMP, tz = "GMT")

Data_2009_11_24 <- read.csv("/data/project/GMS/data/GMSraw/2009-11-24.csv", colClasses = Col_Classes_1)
Data_2009_11_24$TIMESTAMP <- as.POSIXct(Data_2009_11_24$TIMESTAMP, tz = "GMT")


# Make a data frame containing all the selected days
Six_Days <- rbind.data.frame(Data_2009_11_24, Data_2013_12_03, Data_2014_12_28, Data_2015_03_08,
                             Data_2015_03_24, Data_2016_01_09)

## Drop variables that are not of intrest by specifying columns you wish to keep
Keep <- c( "LOCATION", "TIMESTAMP", "TW_1","TW_2", "TW_3", "TW_4", "TW_5", 
           "TW_6", "TW_7", "TW_8", "TW_9", "TW_10", "TW_11", "TW_12", "TL", "TD")

Six_Days <- Six_Days[Keep]

## Melt the dataframe
# ID vars are LOCATION and TIMESTAMP, TL & TD
library(reshape2)

Six_Days <- melt(Six_Days, id.vars = c("LOCATION", "TIMESTAMP", "TL", "TD"))
colnames(Six_Days)[5] <- "SENSOR"
colnames(Six_Days)[6] <- c("TEMP")

# Make the sensor data a character column
Six_Days$SENSOR <- as.character(Six_Days$SENSOR)

## Download days with filtered GMS data
Col_Classes_2 <- c("integer", "numeric", "character", "POSIXct", "character")
Data_filtered_09_11_24 <- read.csv("/data/project/GMS/data/GMSfiltered/2009-11-24.csv", 
                          header = FALSE, colClasses = Col_Classes_2)
Data_filtered_16_01_09 <- read.csv("/data/project/GMS/data/GMSfiltered/2016-01-09.csv", 
                                   header = FALSE, colClasses = Col_Classes_2)
Data_filtered_14_12_28 <- read.csv("/data/project/GMS/data/GMSfiltered/2014-12-28.csv", 
                                   header = FALSE, colClasses = Col_Classes_2)
Data_filtered_15_03_24 <- read.csv("/data/project/GMS/data/GMSfiltered/2015-03-24.csv", 
                                   header = FALSE, colClasses = Col_Classes_2)
Data_filtered_15_03_08 <- read.csv("/data/project/GMS/data/GMSfiltered/2015-03-08.csv", 
                                   header = FALSE, colClasses = Col_Classes_2)
Data_filtered_13_12_03 <- read.csv("/data/project/GMS/data/GMSfiltered/2013-12-03.csv", 
                                   header = FALSE, colClasses = Col_Classes_2)

# Merge all these filtered days into one dataframe
Data_filtered <- rbind.data.frame(Data_filtered_09_11_24, Data_filtered_16_01_09, Data_filtered_14_12_28,
                                  Data_filtered_15_03_24, Data_filtered_15_03_08, Data_filtered_13_12_03)

colnames(Data_filtered) <- c("LOCATION", "TEMP","SENSOR", "TIMESTAMP", "QUALITY")

## Merge GMS Data & Filtered data by common columns 
# Because the filtered subset contains no NA's for the sensors the merged data frame also contains no NA's
library(dplyr)
Six_Days_3 <- right_join(x = Six_Days, y = Data_filtered, by = c("LOCATION", "TIMESTAMP", "SENSOR", "TEMP"))


#Add in a Day of Year (DOY) and Hour of Day (HOD) column
library(lubridate)

# Build a DOY column
DOY_Days <-  as.numeric(strftime(Six_Days_3$TIMESTAMP, format = "%j"))

# The selected days run from, for example 24-11-09 01:00:00 until 01:00:00 25-11-09 which means that there are 12 unique DOY values for six days of data
length(unique(DOY_Days)) 

# Build a HOD column
HOD_Days <- hour(Six_Days_3$TIMESTAMP) + minute(Six_Days_3$TIMESTAMP)/60

# Add the columns to the start of the Six_Days_3 data frame
Six_Days_3 <- cbind(DOY_Days, HOD_Days, Six_Days_3)

# Check if there are any 'bad' stations 
# (either test stations from RWS or stations which have been moved) in the dataframe.

bad_stations <- c("108", "422", "818", "1015", "1501", "1502", "1503")

for(i in bad_stations){
  print(i)
  print(any(Six_Days_3$LOCATION == i))
}

# Remove the 'bad' stations
Six_Days_3 <- Six_Days_3[!(Six_Days_3$LOCATION == 108|
                           Six_Days_3$LOCATION == 422|
                           Six_Days_3$LOCATION == 818|
                           Six_Days_3$LOCATION == 1015|
                           Six_Days_3$LOCATION == 1501|
                           Six_Days_3$LOCATION == 1502|
                           Six_Days_3$LOCATION == 1503),]


# Store the GMS six days data frame as .csv
write.csv(x = Six_Days_3, file = "/usr/people/kleingel/Projects/MLProject/Six_Days.csv")

# Store the GMS six days data frame as R data
save(x = Six_Days_3, file = "/usr/people/kleingel/Projects/MLProject/Six_Days.Rda")



























