## The required packages
library(data.table)

## Downloading and extracting the zip folder

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(fileUrl,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

## Reading the features file

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

## Building the train data frame with 'X_train.txt', 'y_train.txt' and 'subject_train.txt' files

xTrain <- read.table('./UCI HAR Dataset/train/X_train.txt')
yTrain <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
subjectTain <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')
mainparam <- c('subject', 'activity')

train <- data.frame(subjectTain,yTrain, xTrain)
names(train) <- c(mainparam, features)

## Building the test data frame with 'X_test.txt', 'y_test.txt' and 'subject_test.txt' files

xTest <- read.table('./UCI HAR Dataset/test/X_test.txt')
yTest <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
subjectTest <- read.csv('./UCI HAR Dataset/test/subject_test.txt',header = FALSE, sep = ' ')

test <- data.frame(subjectTest,yTest, xTest)
names(test) <- c(mainparam, features)

## Merging the Training and testing sets

completeData <- rbind(train, test)

## Getting a subset of the data that has only the mean and standard deviation measurements
## The position of features with 'mean" and 'std' is used to do so

mstdData <- completeData[,c(1,2,grep('mean|std', features) + 2)]

## Getting the activity names 

activities <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activities <- as.character(activities[,2])

## Describing each activity by its name

mstdData$activity <- activities[mstdData$activity]

## Renaming the variables by substituting unclear or inappropriate values

rename <-  names(mstdData)
rename <- gsub("[(][)]", "", rename)
rename <- gsub("^t", "Time_", rename)
rename <- gsub("^f", "Frequency_", rename)
rename <- gsub("Acc", "Accelerometer", rename)
rename <- gsub("Gyro", "Gyroscope", rename)
rename <- gsub("Mag", "Magnitude", rename)
rename <- gsub("-mean-", "_Mean_", rename)
rename <- gsub("-std-", "_StandardDeviation_", rename)
rename <- gsub("-", "_", rename)
names(mstdData) <- rename

## Creating the tidy data with average per activity and subject

tData <- aggregate(mstdData[,3:81], by = list(activity = mstdData$activity, subject = mstdData$subject),FUN = mean)
write.table(tData, file = "tidy_data.txt", row.names = FALSE)

