

#next, load the library
library("PraatR")

####### Where do you your audio files that are unnormalized live? ######
#first, make sure your computer is connected to ebergelson2014-1 where the audio files all live!

#this tells the script where your files are
FullPath = function(FileName){
  DataDirectory = "~/Documents/repo/manybabies_norming/wavs/original/" ### CHECK THAT THIS IS WHERE THEY ARE
  return( paste(DataDirectory,FileName,sep="") )
}
# this tells the script to look for things in that same place you just set as the DataDirectory
setwd("~/Documents/repo/manybabies_norming/wavs/original/")### CHECK THIS LINE EVERY TIME

# This saves the list of the filenames within Rs memory
# note: you need to have this be a folder with *only* .wav files in it, or you might need the commented out line below
FileList = list.files()
FileList # this will show you what the files are that you are about to change

#FileList <- FileList[substring(FileList,first=nchar(FileList)-3,last=nchar(FileList)) == ".wav"]#ignore this line

##########################################
## MAKING THE STEREO 72 DB FILES############
##########################################

####### Where will the stereo_rightsilent_72db files you make go? ######
#next, tell the computer where the new files it makes should go
# this should be the  temp_stereo_rightsilent_72db folder within seedlings_stimuli

# if you don't change this correctly you may overwrite your original recordings!#
FullPathNewFiles_rightsilent72db = function(FileName){
  DataDirectory = "~/Documents/repo/manybabies_norming/wavs/normed/" ### CHECK THAT THIS IS WHERE THEY SHOULD GO
  return( paste(DataDirectory,FileName,sep="") )
}


#This loop goes through each file you've made that is stereo with one silent channel, in the folder you specified,
#and normalizes the volume to an average of 72db in the file
for(File in 1:length(FileList)){
  TargetFile <- FileList[File]
  praat("Scale intensity...", arguments=list(72),
        input=FullPath(TargetFile),
        output=FullPathNewFiles_rightsilent72db(TargetFile),
        filetype="WAV") 
}

