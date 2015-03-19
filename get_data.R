dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip_file <- "dataset.zip"

download.file(dataset_url, destfile = zip_file, method = "curl")
unzip(zip_file)
file.remove(zip_file)
