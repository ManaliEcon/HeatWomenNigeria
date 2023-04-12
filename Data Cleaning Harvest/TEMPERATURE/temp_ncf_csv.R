rm(list=ls())
cat("\014")  

setwd("C:/Users/msovan01/Box/Paper 1/Data/Temperature")
#install.packages('ncdf4')   ##loading package
#install.packages('RNetCDF')
#install.packages('plyr') 

library(ncdf4)
library(RNetCDF)
library(plyr) 

##2011 wave 1 temperature data

ncname <- "tmax.2011"
ncfname <- paste(ncname, ".nc", sep = "")
dname <- "tmax"
print(ncfname)

# open a NetCDF file
ncin <- nc_open(ncfname)
print(ncin)

# Lon, Lat, Level Info
lon <- ncvar_get(ncin, "lon")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin, "lat")
nlat <- dim(lat)
head(lat)

print(c(nlon,nlat))

# Time Variable
t <- ncvar_get(ncin, "time")
tunits <- ncatt_get(ncin, "time", "units")
nt <- dim(t)

# Get the variable
tmp.array <- ncvar_get(ncin, dname)
dlname <- ncatt_get(ncin, dname, "long_name")
dunits <- ncatt_get(ncin, dname, "units")
fillvalue <- ncatt_get(ncin, dname, "missing_value")  ##missing value
dim(tmp.array)

# Close NetCDF file
nc_close(ncin)

# Convert the time variable
date <- utcal.nc('days since 1900-1-1', t, type = 'c')
month_date_year <- format(as.Date(date), "%B%d%Y")

# Replace NetCDF fillvalues with R NAs
tmp.array[tmp.array == fillvalue$value] <- NA
length(na.omit(as.vector(tmp.array[, , 1])))

tmp.vec.long <- as.vector(tmp.array)
length(tmp.vec.long)

tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
dim(tmp.mat)
#head(na.omit(tmp.mat))

#Create the data frame from the tmp.mat matrix
#Note this matrix of having dates in columns keep the data smallest
lonlat <- expand.grid(lon, lat)
tmp.df <- data.frame(cbind(lonlat, tmp.mat))
dim(na.omit(tmp.df))

#Limit observations to Nigeria
tempo.df<-tmp.df[tmp.df$Var1 >= 3, ]
tempo.df<-tempo.df[tempo.df$Var1 <= 14, ]
tempo.df<-tempo.df[tempo.df$Var2 <= 14, ]
tempo.df<-tempo.df[tempo.df$Var2 >= 4, ]

#tempo.df[is.na(tempo.df)] <- -999

colnames(tempo.df)[1] = "lon"
colnames(tempo.df)[2] = "lat"

# Write .csv file
csvfile <- paste("tmax.2011", ".csv", sep = "")
write.table(tempo.df, csvfile, row.names = FALSE, sep = ",")	
View(tempo.df)



##2013 wave 1 temperature data

ncname <- "tmax.2013"
ncfname <- paste(ncname, ".nc", sep = "")
dname <- "tmax"
print(ncfname)

# open a NetCDF file
ncin <- nc_open(ncfname)
print(ncin)

# Lon, Lat, Level Info
lon <- ncvar_get(ncin, "lon")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin, "lat")
nlat <- dim(lat)
head(lat)

print(c(nlon,nlat))

# Time Variable
t <- ncvar_get(ncin, "time")
tunits <- ncatt_get(ncin, "time", "units")
nt <- dim(t)

# Get the variable
tmp.array <- ncvar_get(ncin, dname)
dlname <- ncatt_get(ncin, dname, "long_name")
dunits <- ncatt_get(ncin, dname, "units")
fillvalue <- ncatt_get(ncin, dname, "missing_value")  ##missing value
dim(tmp.array)

# Close NetCDF file
nc_close(ncin)

# Convert the time variable
date <- utcal.nc('days since 1900-1-1', t, type = 'c')
month_date_year <- format(as.Date(date), "%B%d%Y")

# Replace NetCDF fillvalues with R NAs
tmp.array[tmp.array == fillvalue$value] <- NA
length(na.omit(as.vector(tmp.array[, , 1])))

tmp.vec.long <- as.vector(tmp.array)
length(tmp.vec.long)

tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
dim(tmp.mat)
#head(na.omit(tmp.mat))

#Create the data frame from the tmp.mat matrix
#Note this matrix of having dates in columns keep the data smallest
lonlat <- expand.grid(lon, lat)
tmp.df <- data.frame(cbind(lonlat, tmp.mat))
dim(na.omit(tmp.df))

#Limit observations to Nigeria
tempo.df<-tmp.df[tmp.df$Var1 >= 3, ]
tempo.df<-tempo.df[tempo.df$Var1 <= 14, ]
tempo.df<-tempo.df[tempo.df$Var2 <= 14, ]
tempo.df<-tempo.df[tempo.df$Var2 >= 4, ]

#tempo.df[is.na(tempo.df)] <- -999

colnames(tempo.df)[1] = "lon"
colnames(tempo.df)[2] = "lat"

# Write .csv file
csvfile <- paste("tmax.2013", ".csv", sep = "")
write.table(tempo.df, csvfile, row.names = FALSE, sep = ",")	
View(tempo.df)