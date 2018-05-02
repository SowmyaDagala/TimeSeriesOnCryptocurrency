set.seed(123)
setwd("E:/Datathon/")

library(forecast)
library(tseries)
library(lubridate)
library(dplyr)


dr <- read.csv("Final_Cleaned.csv", stringsAsFactors = F)
colnames(dr)
dr <- dr[,-1]

drts <- ts(dr[which(dr$month == 1),c("bitcoin","ripple")], start = c(1,1), end = c(14,288), frequency = 288)



#=================== Model Creation =================#

orderFun <- function(tser){
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
  lagVal_Acf <- io[which(abs(io$B) == max(abs(io$B)) & abs(io$B) > mean(abs(io$B))),"A"]
  
  
  flag2 <- 1 
  yu <- Pacf(tser3, lag.max = 20, plot = FALSE)
  iol <- data.frame("A" = yu$lag, "B" = yu$acf)
  iol <- iol[-c(10:20),]
  lagVal_Pacf <- iol[which(abs(iol$B) == max(abs(iol$B)) & abs(iol$B) > mean(abs(iol$B))),"A"]

  armodel <- c(lagVal_Pacf,k,lagVal_Acf)
  return(armodel)
}

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
ariList <- list()
ariNewList <- list()
holtList <- list()
etsList <- list()
n = 5

for(z in colnames(drts)){
  preari <- vector()
  preariNew <- vector()
  preholt <- vector()
  preEts <- vector()
  k = 7
  l = 288
  for(i in 1:1){
    for(j in 1:288){
      dre <- window(drts[,z], start = c(i,j), end = c(k,l), frequency = 288)
      cat("(",i,j,k,l,")\n")
    
      
      arman <- orderFun(dre)
      ar1 <- Arima(dre,order = arman)
      pred1 <- forecast(ar1,h=1)[4][[1]][1]
      preari <- c(preari,pred1)
    
      armanNew <- orderFun_new(dre)
      ar2 <- Arima(dre, order = armanNew)
      pred2 <- forecast(ar2,h=1)[4][[1]][1]
      preariNew <- c(preariNew,pred2)
    
      etsMod <- ets(dre)
      predets <- forecast(etsMod,h=1)[4][[1]][1]
      preEts <- c(preEts,predets)
      
      holm <- HoltWinters(dre,gamma = F)
      pred2 <- predict(holm, h = 1)[1]
      preholt <- c(preholt, pred2)
      
      if(l == 288){
        l = 1
        k = k + 1
      } else {
        l = l + 1
      }
    }
  }
  ariList[[z]] <- preari
  ariNewList[[z]] <- preariNew
  holtList[[z]] <- preholt
  etsList[[z]] <- preEts
}



#==========Creating the data frame for predicted value of each model=======#
ariDf <- data.frame(ariList)
ariNewDf <- data.frame(ariNewList)
holtDf <- data.frame(holtList)
etsDf <- data.frame(etsList)
names(ariDf) <- colnames(drts)
names(ariNewDf) <- colnames(drts)
names(holtDf) <- colnames(drts)
names(etsDf) <- colnames(drts)

#===========Subsetting the original values of the cryptocurrency bitcoin and ripple===#
main <- dr %>% select(time,bitcoin,ripple,month,day) %>% filter(month == 1 & day == 25) %>% select(bitcoin,ripple)
colnames(main) <- c("OriBit","OriRip")

#===========Joining the values in the model dataframe for further calculations====#
ariDf <- cbind(ariDf,main)
ariNewDf <- cbind(ariNewDf,main)
holtDf <- cbind(holtDf,main)
etsDf <- cbind(etsDf,main)


#============Calculating the Square of Error for each model============#
AlgoList <- list("Arima1" = ariDf, "Arima2" = ariNewDf, "Holt" = holtDf, "Ets" = etsDf)
AlgoNewList <- list()
for(i in 1:length(AlgoList)){
  hg <- data.frame("BitError" = (AlgoList[[i]][,"OriBit"] - AlgoList[[i]][,"bitcoin"])^2,"RipError" = (AlgoList[[i]][,"OriRip"] - AlgoList[[i]][,"ripple"])^2)
  AlgoNewList[[i]] <- cbind(AlgoList[[i]],hg)
}

ariDf <- AlgoNewList[[1]]
ariNewDf <- AlgoNewList[[2]]
holtDf <- AlgoNewList[[3]]
etsDf <- AlgoNewList[[4]]


#==================Getting SSE Sum of Square of Errors=========#
SSE_Arima1_Bitcoin <- sum(ariDf$BitError)
SSE_Arima1_Ripple <- sum(ariDf$RipError)
SSE_Arima2_Bitcoin <- sum(ariNewDf$BitError)
SSE_Arima2_Ripple <- sum(ariNewDf$RipError)
SSE_Holt_Bitcoin <- sum(holtDf$BitError)
SSE_Holt_Ripple <- sum(holtDf$RipError)
SSE_Ets_Bitcoin <- sum(etsDf$BitError)
SSE_Ets_Ripple <- sum(etsDf$RipError)

#==================Sorting the models in ascending order of SSE=====#
sortedModelBitCoin <- sort(c("Arima1"=SSE_Arima1_Bitcoin,"Arima2"=SSE_Arima2_Bitcoin,"Holt"=SSE_Holt_Bitcoin,"Ets"=SSE_Ets_Bitcoin))
sortedModelRipple <- sort(c("Arima1"=SSE_Arima1_Ripple,"Arima2"=SSE_Arima2_Ripple,"Holt"=SSE_Holt_Ripple,"Ets"=SSE_Ets_Ripple))

