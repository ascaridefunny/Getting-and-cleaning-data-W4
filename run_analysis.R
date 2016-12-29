#You should create one R script called run_analysis.R that does the following.

#Download, unzip and connect
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

setwd("D:/Program Files/RStudio/data/UCI HAR Dataset")
#Read data
features <- read.table('./features.txt',header=FALSE) 
activityType <- read.table('./activity_labels.txt',header=FALSE)
subjectTrain <- read.table('./train/subject_train.txt',header=FALSE) 
xTrain <- read.table('./train/x_train.txt',header=FALSE) 
yTrain <- read.table('./train/y_train.txt',header=FALSE) 
subjectTest <- read.table('./test/subject_test.txt',header=FALSE)
xTest <- read.table('./test/x_test.txt',header=FALSE)
yTest <- read.table('./test/y_test.txt',header=FALSE)

#give name to column
colnames(activityType)<- c("V1","Activity")
colnames(subjectTrain)<-c("subject")
colnames(subjectTest)<-c("subject")
colnames(xTrain)<-features[,2]
colnames(xTest)<-features[,2]

#1 Merges the training and the test sets to create one data set.
Subject <- rbind(subjectTrain, subjectTest)
dataActivity<- rbind(yTrain, yTest)
dataFeatures<- rbind(xTrain, xTest)

dataCombine <- cbind(Subject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#2 Extracts only the measurements on the mean and standard deviation for each measurement.
library(dplyr)
dt1<-Data[, !duplicated(colnames(Data))]
dt2<-tbl_df(dt1)
dt3<-select(dt1, contains("mean()"), contains("std()"), subject, V1)
str(dt3)

#3 Uses descriptive activity names to name the activities in the data set
dt4<-merge(dt3, activityType, by = "V1")
head(dt4)

#4 Appropriately labels the data set with descriptive variable names.
names(dt4)<-gsub("^t", "time", names(dt4))
names(dt4)<-gsub("^f", "frequency", names(dt4))
names(dt4)<-gsub("Acc", "Accelerometer", names(dt4))
names(dt4)<-gsub("Gyro", "Gyroscope", names(dt4))
names(dt4)<-gsub("Mag", "Magnitude", names(dt4))
names(dt4)<-gsub("BodyBody", "Body", names(dt4))
names(dt4)
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
tidy.dt<-aggregate(. ~subject + Activity, dt4, mean)
tidy.dt<-tidy.dt[order(tidy.dt$subject,tidy.dt$Activity),]
write.csv(tidy.dt, "tidy.csv", row.names=FALSE)
