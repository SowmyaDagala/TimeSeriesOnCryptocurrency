# TimeSeriesOnCryptocurrency
The case is financial time-series prediction with cryptocurrencies and it integrates knowledge from various sources - Crypto Currencies, Quantitative Finance, and Machine learning. The data consists of time-series of various cryptocurrencies with open, high, low, close prices and volumes from different crypto exchanges, but it could also be enriched during the Datathon by the teams. The goal is to build a successful investing/trading model on the cryptocurrency markets.

# Team Members:
Mervyn V. Akash @mervynakash 
Tanuj Maithani @noir976 
Tamma Ravindra Reddy @ravindrareddytamma 
Sowmya Dyagala @SowmyaDagala
Vijay Joseph @vijaybabyjoseph

# Business Understanding and Objective: 
There is need to predict the price variations of crypto-currencies such as bitcoin over time to understand the trend and to compare the variation in trends of different crypto-currencies. Another objective is trading crypto-currencies predicting the variation pattern in the next time points. We use the past trend history of cryptocurrencies, analyze them to forecast the future values by building a prediction model with the best possible of accuracy.

# Data Understanding: 
The data was provided in the format of .csv files. The data contains the information regarding the 687 cryptocurrencies, whose individual parameters such as opening value, closing value, low, high, volume are provided as individual files. There are 2 Consolidated files that have the summary information regarding the price of each bitcoin captured for every 5 minutes interval from 17th Jan 2018 to 23rd Mar 2018. The ID’s of each crypto-currenciy and the names of each crypto-currency are provided in another consolidated file.

# Data Preparation: 
The data provided in form of the .csv file should be qualified to be a time series. But if we observe the data, it has lot of missing observations that are not captured at regular intervals of time. The main and basic requirement of Time Series is data should be captured at regular intervals of time which are equally spaced. So we need to impute the missing values to get the best prediction model.

# Identifying the Missing Values: 
First we have created a vector having the sequence of timestamps from the starting time in data to the ending time in data with a equal spaced interval of five 5 minutes. Now we have performed the outer join of the vector with the actual data set. When we perform this operation, if there is match of timestamps in both the vector and data set then the values in data set are considered, but for the timestamps, which is present in the vector but not present in the data set, we will have an empty value for the all columns in the row. In the next section, we deal with filling these Missing Values.

# Imputing the Missing Values: 
Now we have designed a trivial approach in filling the missing values for the empty rows. Let X(t) be the missing value then, it will be imputed by AVG(X(t-1),X(t+1)). Let us consider another scenario. Let X(t),X(t+1),X(t+2) be the sequential missing values then we will compare the values at X(t-1) and X(t+3), If there is increase in value from X(t-1) to X(t+3) then the amount of increment will be proportionally distributed among all the missing values. Suppose if there is a K amount of increment the K/5 is for first missing value , 2K/5 is for next missing value and 3K/5 is for the last missing value. The same logic is applied even in the case of Decrements.

# DataModelling: 
We have used ARIMA Model to forecast the time series data. Auto Regression (AR) will determine the relation between the previous values and the current value in the time series. Moving Average (MA) summarizes the relation of the error term that appear in each observation. Integrated in ARIMA refers to the order of differencing that need to be performed to make the time series stationary. To build the model we have started in this way.
To Predict values of Y(t) (which is the first data-point in a day), we use all the data from Y(0) to Y(t-1) and form a time series with them, and next we find the order of AR, order of MA & d-value that best fit for the time series. We check the ACF and PACF values to determine the the parameters for the ARIMA(p,d,q) model and passed the ARIMA model to forecast the future values. After that we take Y(1) to Y(t) to predict Y(t+1) and we carry on these activities till all 288 data-points in a day are predicted. 

# Evaluation: 
We have divided the data into  2 parts namely training and test data set. we have fed the model with the train data set that helped the model to learn something about the data. Now we have predicted the values present in the train data set. We have compared the Predicted values with the Observed values and calculated the RMSE( Root Mean Square Error). We have selected the model which has the least RMSE Value and higher Accuracy.

# Files Uploaded Details:
Final_Cleaned.csv - This file is the cleaned dataset which doesn't contain any missing values. This file has been used to work on the BestNinjaModel.R to get which model is best for getting the prediction.

BestNinjaModel.R - This file contains the code which gave us the idea as to which model we should use when actually predicting the cryptocurrency data. 4 models were taken into consideration - HoltWinters, ETS, 2 different ARIMA models in which one model the p and q value contained the lag containing max autocorrelation value and another model which in which the lag after which the autocorrelation value showed "cutoff". Out of these HoltWinter and ARIMA-2 model showed least SSE values (Sum of Squared Errors).

NinjaModel-Modified.R - This file contains the whole code for predicting the values of 20 cryptocurrency from 25th Jan 2018 to 23th March 2018. We are applying ARIMA-2 model which was concluded to be a good model for prediction in BestNinjaModel.R above. In this file all the cleaning part of the dataframe has been done. Click the link below to get the file on which the analysis has been done. At the end of the code we are writing the data frames into files.

https://drive.google.com/open?id=11lQJtKlJXRYBAR6v2d27QqWQmLCa478X - Click this google drive link to get the file in which the modified code was run. (Please note that the file is huge)
