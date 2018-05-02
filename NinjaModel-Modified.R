# Installing the Packages
install.packages("forecast")
install.packages("tseries")
install.packages("lubridate")
install.packages("dplyr")
install.packages("zoo")

# Loading the requried packages
library(forecast)
library(tseries)
library(lubridate)
library(dplyr)
library(zoo)

# Reading the data from the required file.
setwd("C:/Users/Administrator/Desktop/DATATHON")
data <- read.csv("CryptoDataset/matrix_one_file/price_data.csv",stringsAsFactors = F,header = T)

# Data Pre-Processing 
data <- data[,c(1,2:19,24,25)]  # Slecting randomly 20 Cryptocurrencies.
data <- data[1:15258,]
data$time <- strptime(data$time,format = "%d-%m-%Y %H:%M") # Type casting into POSIXlt
data$time <- as.POSIXct(data$time)

# Imputing the missing values already present in the data
for(i in colnames(data)[-1]){
  for(j in 1:length(data[,i])){
    if(is.na(data[j,i]))
    {
      data[j,i] <- (data[j-1,i] + data[j+1,i])/2
    }
  }
}

# Identifying the Missing Values.
reqd.time <- seq(as.POSIXct(strptime("17-01-2018 11:25","%d-%m-%Y %H:%M")), as.POSIXct(strptime("23-03-2018 13:15","%d-%m-%Y %H:%M")), by = 300)

data <- data.frame(time = reqd.time) %>% full_join(data, by = "time")
data$bitcoin = na.approx(data$X1442)
data$ethereum = na.approx(data$X1443)
data$ripple = na.approx(data$X1444)
data$bitcoin_cash = na.approx(data$X1445)
data$cardano = na.approx(data$X1446)
data$nem = na.approx(data$X1447)
data$litecoin = na.approx(data$X1448)
data$neo = na.approx(data$X1449)
data$stellar = na.approx(data$X1450)
data$iota = na.approx(data$X1451)
data$eos = na.approx(data$X1452)
data$dash = na.approx(data$X1453)
data$monero = na.approx(data$X1454)
data$tron = na.approx(data$X1455)
data$bitcoin_gold = na.approx(data$X1456)
data$ethereum_classic = na.approx(data$X1457)
data$qtum = na.approx(data$X1458)
data$icon = na.approx(data$X1459)
data$stratis = na.approx(data$X1464)
data$zcash = na.approx(data$X1465)
data <- data[,-c(2:21)]
data$month <- month(data$time)
data$day <- day(data$time)
data <- data[!(data$day == 17 & data$month == 1),]
data$day <- NULL
data$month <- NULL
#=================== Model Creation =================#
ds <- data
dr <- ds[,-1]

drts <- ts(dr, start = c(1,1),frequency = 288)
#View(drts)



#View(drts)

orderFun_new <- function(tser){
  tser2 <- tser
  k = 0
  repeat{
    test <- adf.test(tser2)
    if(round(test$p.value,2) < 0.05){
      break()
    } else {
      k = k + 1
      tser2 <- diff(tser2, differences = 1)
    }
  }
  
  if(k != 0){
    tser3 <- diff(tser, differences = k)
  } else {
    tser3 <- tser
  }
  
  flag1 <- 1
  po <- Acf(tser3, lag.max = 20, plot = FALSE)
  io <- data.frame("A" = po$lag, "B" = po$acf)
  io <- io[-c(1,10:21),]
  for(i in 1:nrow(io)){
    if(abs(io$B[i] > mean(abs(io$B)))){
      flag1 = i
    }
  }
  lagVal_Acf <- flag1
  
  flag2 <- 1 
  yu <- Pacf(tser3, lag.max = 20, plot = FALSE)
  iol <- data.frame("A" = yu$lag, "B" = yu$acf)
  iol <- iol[-c(10:20),]
  for(i in 1:nrow(iol)){
    if(abs(iol$B[i] > mean(abs(iol$B)))){
      flag2 = i
    }
  }
  lagVal_Pacf <- flag2
  
  armodel <- c(lagVal_Pacf,k,lagVal_Acf)
  return(armodel)
}



#=================== Prediction =====================#

predList <- list()

for(z in colnames(drts)){
  preariNew <- vector()
  k = 7
  l = 288
  for(i in 1:5){
    for(j in 1:288){
      dre <- window(drts[,z], start = c(i,j), end = c(k,l), frequency = 288)
      cat("(",i,j,k,l,")\n")
      armanNew <- orderFun_new(dre)
      ar2 <- Arima(dre, order = armanNew)
      pred2 <- forecast(ar2,h=1)[4][[1]][1]
      preariNew <- c(preariNew,pred2)
    
      
      if(l == 288){
        l = 1
        k = k + 1
      } else {
        l = l + 1
      }
    }
  }
  predList[[z]] <- preariNew
}

predDf <- data.frame(predList)
names(predDf) <- colnames(drts)

#==================== Creating the files for each cryptocurrency =========#
for(i in colnames(predDf)){
  dflk <- data.frame("Original"=data[2018:nrow(dr),i],"Predicted"=predDf[,i])
  write.csv(dflk, file = paste0(i,".csv"))
}
