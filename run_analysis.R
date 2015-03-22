library(data.table)
library(dplyr)

setwd("UCI HAR Dataset")

# Returns merged test and train data
# @par {character} location File location. % will be substituted by train/test
mergeTables <- function (location, ...) {
  testLocation <- gsub("%", "test", location, fixed = TRUE)
  trainLocation <- gsub("%", "train", location, fixed = TRUE)
  bind_rows(read.table(testLocation, ...), read.table(trainLocation, ...))
}

formatVariableName <- function (name) {
  name <- gsub("^f", "frequency", name)
  name <- gsub("^t", "time", name)
  name <- gsub("Acc", "Acceleration", name)
  name <- gsub("Mag", "Magnitude", name)
  name <- gsub("BodyBody", "Body", name)
  name <- gsub("-(.)([^\\(]*)\\(\\)", "\\U\\1\\L\\2", name, perl = TRUE)
  name <- gsub("-([0-9]*),([0-9]*)", "\\1to\\2", name, perl = TRUE)
  name <- gsub("-([XYZ])", "\\1", name)
  gsub("[^a-zA-Z0-9]", "", name)
}

# Step 1
subject <- mergeTables("%/subject_%.txt", col.names = c("subject"))
label <- mergeTables("%/y_%.txt", col.names = c("id"))
measurement <- mergeTables("%/X_%.txt")

# Step 2
features <- read.table("features.txt", col.names = c("id", "name"))
features <- mutate(features, extract = grepl("-mean()", name, fixed = TRUE) | grepl("-std()", name, fixed = TRUE))
## We take a shortcut here, to rename the variables as would be expected to be done on step 4
features <- mutate(features, tidyName = formatVariableName(name))
colnames(measurement) <- features$tidyName
## Now we go back to step 2, selecting only the means and standard deviations
extractedMeasurement <- subset(measurement, select = features[features$extract, 1])

# Step 3
activityLabels <- read.table("activity_labels.txt", col.names = c("id", "activity"))
label <- merge(label, activityLabels)
activity <- subset(label, select = activity)

# Step 4
## The dataset variables where renamed on step 2. Now we will just merge all the parts together
mergedData <- bind_cols(subject, activity, extractedMeasurement)

# Step 5
tidyData <- suppressWarnings(aggregate(mergedData, by = list(mergedData$activity, mergedData$subject), FUN = mean))
tidyData <- mutate(tidyData, subject = Group.2, activity = Group.1)
tidyData$Group.1 <- NULL
tidyData$Group.2 <- NULL

# Finished
tidyData