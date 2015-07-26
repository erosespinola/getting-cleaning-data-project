# Getting and Cleaning data project
# Eros Espi­nola Gonzalez

require("data.table")
require("reshape2")

# Get data from web
dataSetFile <- "analysis_dataset.zip"
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, dataSetFile)
unzip(dataSetFile)

# Get activity labels and features
activities <- read.table("UCI HAR Dataset/activity_labels.txt")[, 2]
features <- read.table("UCI HAR Dataset/features.txt")[, 2]

# Extract mean and std
featuresWanted.ids <- grep(".*(mean|std)\\(\\).*", features)
featuresWanted.names <- features[featuresWanted.ids]

#########################################################################

# Get train datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")
train.activities <- read.table("UCI HAR Dataset/train/y_train.txt")
train.subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
names(train) <- features

# Get just wanted train dataset features
train <- train[, featuresWanted.ids]
train.activities[, 2] <- activities[train.activities[, 1]]

# Name train dataset features
names(train.activities) <- c("Activity_ID", "Activity_Label")
names(train.subjects) <- "Subject"

# Bind train dataset
train_dataset <- cbind(train.subjects, train.activities, train)

#########################################################################

# Get test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")
test.activities <- read.table("UCI HAR Dataset/test/y_test.txt")
test.subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(test) <- features

# Get just wanted test dataset features
test <- test[, featuresWanted.ids]
test.activities[, 2] <- activities[test.activities[, 1]]

# Name test dataset features
names(test.activities) <- c("Activity_ID", "Activity_Label")
names(test.subjects) <- "Subject"

# Bind test dataset data
test_dataset <- cbind(test.subjects, test.activities, test)

#########################################################################

# Merge test and train data
data <- rbind(test_dataset, train_dataset)

id_labels <- c("Subject", "Activity_ID", "Activity_Label")
data_labels <- setdiff(colnames(data), id_labels)
merge_data <- melt(data, id = id_labels, measure.vars = data_labels)

# Use dcast function to create tidy data
tidy_data <- dcast(merge_data, Subject + Activity_Label ~ variable, mean)

write.table(tidy_data, row.name=FALSE, quote = FALSE, file = "./tidy_data.txt")