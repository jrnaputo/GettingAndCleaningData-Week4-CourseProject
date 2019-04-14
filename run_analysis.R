# Loading the necessary packages
library(data.table)
library(dplyr)

# Downloading the file from the web
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip")
# Unzipping the zip file
unzip("./data/Dataset.zip")
# Setting the working directory
setwd("./UCI HAR Dataset")

# Reading Features
features <- read.table("./features.txt", header = FALSE)

# Reading Activity Labels
activity_labels <- read.table("./activity_labels.txt", header = FALSE)

# Reading Training Data
x_train <- read.table("./train/X_train.txt", header = FALSE)
y_train <- read.table("./train/y_train.txt", header = FALSE) # Labels
subject_train <- read.table("./train/subject_train.txt", header = FALSE)

# Merging training labels to the activity labels
y_trainlabel <- left_join(y_train, activity_labels, by = "V1")[,2]

# Merging Training Subject, Training Label, and Training Data
trainData <- cbind(subject_train,V1 = y_trainlabel, x_train)

# Reading Test Data
x_test <- read.table("./test/X_test.txt", header = FALSE)
y_test <- read.table("./test/y_test.txt", header = FALSE) # Labels
subject_test <- read.table("./test/subject_test.txt", header = FALSE)

# Merging test labels to the activity labels
y_testlabel <- left_join(y_test, activity_labels, by = "V1")[,2]

# Merging Test Subject, Test Label, and Test Data
testData <- cbind(subject_test, V1 = y_testlabel, x_test)

# Merging TrainData and TestData to create one dataset
MergedData <- rbind(trainData, testData)

# Renaming column names
names(MergedData) <- c("Subject", "Activity", as.character(features$V2))

# Creating new dataset by extracting only the measurements 
# on the mean and standard deviation for each measurement
sub_features <- features$V2[grep("mean|std", features$V2)]
NewData_Names <- c("Subject", "Activity", as.character(sub_features))
NewData <- subset(MergedData, select=NewData_Names)

# Renaming the columns of the new dataset
names(NewData) <- gsub("^t", "Time", names(NewData))
names(NewData) <- gsub("^f", "Frequency", names(NewData))
names(NewData) <- gsub("Acc", "Accelerometer", names(NewData))
names(NewData) <- gsub("Gyro", "Gyroscope", names(NewData))
names(NewData) <- gsub("Mag", "Magnitude", names(NewData))
names(NewData) <- gsub("BodyBody", "Body", names(NewData))

# Creating a second, independent tidy dataset with the average 
# of each variable for each activity and each subject
TidyData <- aggregate(. ~Subject + Activity, NewData, mean)
TidyData <- TidyData[order(TidyData$Subject, TidyData$Activity),]

#Saving this tidy dataset
write.table(TidyData, file = "tidydata.txt", row.name = FALSE)