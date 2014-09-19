#merge training set with test set to create a single dataset
#extract mean and SD for each measurement
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#Please upload the tidy data set created in step 5 of the instructions. Please upload your data set as a txt file created with write.table() using row.name=FALSE


#temp <- tempfile()
#download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
#unzip(temp)
##this downlaods and unzips the file into the cwd.  Well it technically downloads into a temp folder and then unzips to the wd..whatever, more temp clutter.
xt<-read.table("UCI HAR Dataset/test/X_test.txt")
yt<-read.table("UCI HAR Dataset/test/Y_test.txt")
st<-read.table("UCI HAR Dataset/test/subject_test.txt")
xr<-read.table("UCI HAR Dataset/train/X_train.txt")
yr<-read.table("UCI HAR Dataset/train/Y_train.txt")
sr<-read.table("UCI HAR Dataset/train/subject_train.txt")
##reads in some data
merged<-cbind(st,yt,xt)
merged<-rbind(merged,cbind(sr,yr,xr))
rm(xt,yt,st,xr,yr,sr)
#merges the data and removes the original files to keep workspace clean
features<-read.table("UCI HAR Dataset//features.txt")
colnames(merged)<-c("Subject","Activity",as.character(features$V2))
rm(features)#again cleanup because of that silly V2 thing.  I could probably figure out a neater way.
require(dplyr)
merged<-tbl_df(merged)
##hopefully this is where i bring it into dplyr and magic happens.
fieldsiwant<-select(merged,Subject,Activity,contains("mean"),contains("std"),-contains("angle")) # piping doesnt work here, i have to use multiple selects, that's how that syntax works.  This is not an effective comment.
#labels the activities with more effective things
activitylabels<-read.table("UCI HAR Dataset//activity_labels.txt")
#something clever that replaces the activity levels?  Orrrrr... just a gsub.
for(I in 1:6){fieldsiwant$Activity<-gsub(pattern = I,replacement = activitylabels$V2[I],x=fieldsiwant$Activity)}
fieldsiwant$Activity<-as.factor(fieldsiwant$Activity)
fieldsiwant<-tbl_df(fieldsiwant) #seems to not really still be a proper dplyr df after i do my manipulations
select(fieldsiwant,Activity=Activity)
#clean up the names
names(fieldsiwant)<-gsub("\\(\\)","",names(fieldsiwant))
#fieldsiwant<-select(fieldsiwant,-Activity)#get rid of that silly old Y variable
names(fieldsiwant)<-gsub("^t","Time",names(fieldsiwant))
names(fieldsiwant)<-gsub("^f","Freq",names(fieldsiwant))
names(fieldsiwant)<-gsub("BodyBody","2Body",names(fieldsiwant))
names(fieldsiwant)<-tolower(names(fieldsiwant))#decided that capitals aren't fun
#yay names are understandable now (except BodyBody, but the readme doesn't explain that either...)
moltuci<-melt(fieldsiwant,id.vars = c("activity","subject"))
rm(fieldsiwant,merged,activitylabels)
###THIS RESULT DATAFRAME IS THE STEP 5 RESULT### #everything else has been removed from the environment for cleanliness purposes###
result<-dcast(moltuci, activity + subject ~ variable, mean)
#writes the text file for upload
write.table(file="JPUPCCP.txt",x = result,row.names=FALSE)