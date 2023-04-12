rm(list=ls())
cat("\014") 

library(haven)

setwd("C:/Users/msovan01/Box/Paper 1/Data/Temperature")

######Wave 1#####

#Bring in lat long LSMS dataset
wave1_indivhhtemperature <- read_dta("C:/Users/msovan01/Box/Paper 1/Data/Wave 1/New Files/wave1_indivtemperature.dta")
#View(wave1_indivhhtemperature)

#Bring in survey date dataset
wave1_hhsurveydate <- read_dta("C:/Users/msovan01/Box/Paper 1/Data/Wave 1/NGA_2010_GHSP-W1_v03_M_STATA/Post Harvest Wave 1/Household/secta_harvestw1_temp.dta")
#View(wave1_hhsurveydate)

#Merge datasets: LSMS with survey date dataset
merged.data <- merge(wave1_indivhhtemperature, wave1_hhsurveydate, by="hhid")
View(merged.data)

#Keep relevant columns
keeps <- c("hhid", "lat", "lon", "date1", "date2", "between")
merged.data = merged.data[keeps]

#Create a new column for temperature
merged.data[ , 'temperature'] <- NA
merged.data[ , 'temperature_7daymean'] <- NA
#merged.data[ , 'temperature_daysover31'] <- NA 


#Bring in temperature dataset
tempfile.data <-read.csv("C:/Users/msovan01/Box/Paper 1/Data/Temperature/tmax.2011.csv")
View(tempfile.data)


for(i in 1:nrow(merged.data)) {       # for-loop over rows
  if(is.na(merged.data[i,3])) next #skip if lon/lat is NA
  lon<-merged.data[i, 3]  #longitude from lsms dataset
  lat<-merged.data[i, 2]  #latitude from lsms dataset
  colno<-merged.data[i,6]+2 #data of survey
  for(j in 1:nrow(tempfile.data)){
    if(lon==tempfile.data[j,1] & lat==tempfile.data[j,2]){ #if latitude and longitude of hh match to temp dataset
      if(is.na(merged.data[i,6])) next #skip if date of survey is NA
      merged.data[i,7]<-tempfile.data[j,colno] #fill in temperature column
      merged.data[i,8]<-rowMeans(tempfile.data[ j, c(colno-6:colno)], na.rm=TRUE)
    }
    
  }
}

#write combined dataset into csv file
csvfile <- paste("wave1tempfile", ".csv", sep = "")
write.table(merged.data, csvfile, row.names = FALSE, sep = ",")	


######Wave 2#####

#Bring in lat long LSMS dataset
wave2_indivhhtemperature <- read_dta("C:/Users/msovan01/Box/Paper 1/Data/Wave 2/New Files/wave2_indivtemperature.dta")
#View(wave2_indivhhtemperature)

#Bring in survey date dataset
wave2_hhsurveydate <- read_dta("C:/Users/msovan01/Box/Paper 1/Data/Wave 2/NGA_2012_GHSP-W2_v02_M_STATA/Post Harvest Wave 2/Household/secta_harvestw2_temp.dta")
#View(wave2_hhsurveydate)

#Merge datasets: LSMS with survey date dataset
merged.data <- merge(wave2_indivhhtemperature, wave2_hhsurveydate, by="hhid")
View(merged.data)

#Keep relevant columns
keeps <- c("hhid", "lat", "lon", "date1", "date2", "between")
merged.data = merged.data[keeps]

#Create a new column for temperature
merged.data[ , 'temperature'] <- NA
merged.data[ , 'temperature_7daymean'] <- NA


#Bring in temperature dataset
tempfile.data <-read.csv("C:/Users/msovan01/Box/Paper 1/Data/Temperature/tmax.2013.csv")
View(tempfile.data)

i<-1
j<-1

for(i in 1:nrow(merged.data)) {       # for-loop over rows
  if(is.na(merged.data[i,3])) next #skip if lon/lat is NA
  lon<-merged.data[i, 3]  #longitude from lsms dataset
  lat<-merged.data[i, 2]  #latitude from lsms dataset
  colno<-merged.data[i,6]+2 #data of survey
  for(j in 1:nrow(tempfile.data)){
    if(lon==tempfile.data[j,1] & lat==tempfile.data[j,2]){ #if latitude and longitude of hh match to temp dataset
      if(is.na(merged.data[i,6])) next #skip if date of survey is NA
      merged.data[i,7]<-tempfile.data[j,colno] #fill in temperature column
      merged.data[i,8]<-rowMeans(tempfile.data[ j, c(colno-6:colno)], na.rm=TRUE)
    }
    
  }
}

#write combined dataset into csv file
csvfile <- paste("wave2tempfile", ".csv", sep = "")
write.table(merged.data, csvfile, row.names = FALSE, sep = ",")	
View(merged.data)
