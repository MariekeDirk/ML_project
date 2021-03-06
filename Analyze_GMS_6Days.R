#############################################################################################################


              # Analyse 6 day selection for 3rd run


#############################################################################################################

rm(list=ls())

load("/usr/people/kleingel/Projects/MLProject/Six_Days.Rda")

# Add a day column
library(lubridate)
Six_Days_3$Date <- as.Date(Six_Days_3$TIMESTAMP)

# Make LOCATION a factor variable
Six_Days_3$LOCATION <- as.factor(Six_Days_3$LOCATION)

# Add a column which combines LOCATION and SENSOR
Six_Days_3$LOCSENS <-  interaction(Six_Days_3$LOCATION, Six_Days_3$SENSOR)

# Plot TEMP per day for a given station
library(ggplot2)
plotStation <- function(Station_number){

for (i in (unique(Six_Days_3$Date))){
    The_plot <-ggplot(data = (Six_Days_3[Six_Days_3$Date == i & Six_Days_3$LOCATION == Station_number, ]), 
         aes(x = TIMESTAMP, y = TEMP, color = SENSOR)) +  geom_point() + geom_line()
  print(The_plot)
}
  }

# Example of how the function works
plotStation(412)

########################## start multiplot function

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


########################### end multiplot function

Dates <- unique(Six_Days_3$Date)

# Plot a histogram, boxplots (split up by quality ), and boxplots of the temperature split up by LOCATION
for (i in seq_along(Dates)){
  print(i)
  print(Dates[i])
  
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  Hist_plot <- ggplot(data = Subset_Day, aes(x = TEMP)) + geom_histogram(color="black", fill = "lightblue") +
  ggtitle(paste("Date:", Dates[i]))
  Box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TEMP,  fill = QUALITY))+ 
         geom_boxplot()
  Big_box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TEMP,  fill = LOCATION))+ 
   geom_boxplot() + guides(fill=FALSE)
  
  multiplot(Hist_plot, Box_plot, Big_box_plot, cols = 1)
}

# In order to test if the TEMP data is normally distibuted you can do a Shapiro-Wilk test of normality,
# and plot a Q-Q plot
# However, Shapiro-Wilk does not work because there is too much data. Instead, make a Q-Q plot
# For each day in the data set:

for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  qqnorm(Subset_Day$TEMP, main = paste("Normal Q-Q plot of day", Dates[i]))
}

# For the whole 6-day period:
qqnorm(Six_Days_3$TEMP, main = "Q-Q plot of Road Temperature")

# Do the same for TL and TD
qqnorm(Six_Days_3$TL, main = "Q-Q plot of Air Temperature")
qqnorm(Six_Days_3$TD, main = "Q-Q plot of Dew Point Temperature")

qqnorm(Six_Days_3$Unix_Time, main = "Time distribution") 

# Test the skewness of TEMP data
library(e1071)
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(skewness(Subset_Day$TEMP))
}

# Test the kurtosis of the TEMP data
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(kurtosis(Subset_Day$TEMP))
}

# Histogram of TL and TD
hist(Six_Days_3$TL)
hist(Six_Days_3$TD)

# Plot a histogram, boxplots (split up by quality ), and boxplots of the TD and TL split up by LOCATION
# TL
for (i in seq_along(Dates)){
  print(i)
  print(Dates[i])
  
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  Hist_plot <- ggplot(data = Subset_Day, aes(x = TL)) + geom_histogram(color="black", fill = "lightblue") +
    ggtitle(paste("Date:", Dates[i]))
  Box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TL,  fill = QUALITY))+ 
    geom_boxplot()
  Big_box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TL,  fill = LOCATION))+ 
    geom_boxplot() + guides(fill=FALSE)
  
  multiplot(Hist_plot, Box_plot, Big_box_plot, cols = 1)
}

for (i in seq_along(Dates)){
  print(i)
  print(Dates[i])
  
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  Hist_plot <- ggplot(data = Subset_Day, aes(x = TD)) + geom_histogram(color="black", fill = "lightblue") +
    ggtitle(paste("Date:", Dates[i]))
  Box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TD,  fill = QUALITY))+ 
    geom_boxplot()
  Big_box_plot <- ggplot(data = Subset_Day, aes(x = Date, y = TD,  fill = LOCATION))+ 
    geom_boxplot() + guides(fill=FALSE)
  
  multiplot(Hist_plot, Box_plot, Big_box_plot, cols = 1)
}



# Test the skewness and kurtosis of the TL and TD data 
# skewness TL, all days
skewness(Six_Days_3$TL, na.rm = TRUE)

# skewness TL, per day
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(skewness(Subset_Day$TL, na.rm = TRUE))
}

# skewness TD, all days
skewness(Six_Days_3$TL, na.rm = TRUE)

# skewness TD, per day
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(skewness(Subset_Day$TD, na.rm = TRUE))
}

# kurtosis TL, all days
kurtosis(Six_Days_3$TL, na.rm = TRUE)

# kurtosis TL, per day
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(kurtosis(Subset_Day$TL, na.rm = TRUE))
}

# kurtosis TD, all days
kurtosis(Six_Days_3$TL, na.rm = TRUE)

# kurtosis TD, per day
for (i in seq_along(Dates)){
  print(Dates[i])
  Subset_Day <- Six_Days_3[Six_Days_3$Date == Dates[i], ]
  print(kurtosis(Subset_Day$TD, na.rm = TRUE))
}











































































