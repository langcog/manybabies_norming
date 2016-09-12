#Load up packages
library(dplyr)
library(stringr)
library(reshape2)
library(seewave)
library(tuneR)

#Load 3 songs by Duke Ellington into R as Wave Files
song1 <- readMP3("~/Desktop/03 A Little Max (Alternate Take).mp3")
song2 <- readMP3("~/Desktop/05 Rem Blues.mp3")
song3 <- readMP3("~/Desktop/06 Wig Wise.mp3")

fadeBetween <- 0.5 #Length of time (in seconds) for speech clips to crossfade between each other
samplingRate <- 44100 #Sampling rate for all clips
fadeLength.song <- 5 #Length of time for song clips to crossfade
fadeBits <- fadeLength.song*samplingRate #Number of samples to crossfade

newfilter_and_normed <- read.csv("filtered_and_normed.csv") #read in data about the speech clips
newfilter_and_normed.shared_objects <- subset(newfilter_and_normed, newfilter_and_normed$object != "flag" & newfilter_and_normed$object!="sieve") #create a copied dataset without the files with objects flag or sieve (only the ADS files had these objects, no possible IDS matches)

wavFileLocation <- "~/Documents/repo/wavs/manybabies_norming/wavs/normed/" #Folder of speech clips stored

# Create Jazz Mix ---------------------------------------------------------


rawJazz <- list(mono(song1, "both"), mono(song2, "both"), mono(song3, "both")) #Make a list of the 3 songs and convert each song from stereo to mono (makes manipulations easier)

for (i in 1:length(rawJazz)) { #for each song
  left.amplitude <- max(abs(min(rawJazz[[i]]@left)),abs(max(rawJazz[[i]]@left))) #determine the amplitude of the song (used for later amplitude adjustment)
  
  rawJazz[[i]] <- noSilence(rawJazz[[i]], zero = 0, level = 0.05*left.amplitude, where = c("both")) #get rid of any silence/low noise at the beginning and end of each song
  
  rawJazz[[i]] <- fadew(rawJazz[[i]], din=fadeLength.song, dout=fadeLength.song,output="Wave") #Fade ends of clip so there is a 5s ramp up and 5s ramp down on either side of clip. This adjusts the amplitude to range from -1 to 1
  rawJazz[[i]]@left <- rawJazz[[i]]@left * left.amplitude #To correct amplitude adjustment, numbers were multiplied by the original amplitude
  
}

jazzMix.length <- length(rawJazz[[1]]@left) + length(rawJazz[[2]]@left) + length(rawJazz[[3]]@left) - (2*fadeBits) #find the length of the final jazz montage once the song lengths are added together and crossfading is subtracted
jazzMix <- Wave(left = rep(0, jazzMix.length), samp.rate = samplingRate, bit = 16) #create a sort of "blank" song to concatenate jazz songs

#Find the positions where both crossfading events would occur
songBlend1 <-length(rawJazz[[1]]@left)-fadeBits 
songBlend2 <-length(rawJazz[[1]]@left)+length(rawJazz[[2]]@left)-2*fadeBits

#Add in the jazz songs. Note that in areas of crossfading, the tips of both songs are added together to blend them
jazzMix@left[1:length(rawJazz[[1]]@left)] <- rawJazz[[1]]@left
jazzMix@left[songBlend1:(songBlend1+length(rawJazz[[2]]@left)-1)] <- jazzMix@left[songBlend1:(songBlend1+length(rawJazz[[2]]@left)-1)] + rawJazz[[2]]@left
jazzMix@left[songBlend2:(songBlend2+length(rawJazz[[3]]@left)-1)] <- jazzMix@left[songBlend2:(songBlend2+length(rawJazz[[3]]@left)-1)] + rawJazz[[3]]@left

writeWave(jazzMix, "~/Desktop/test.wav") #save this mix


# Create Speech Mix -------------------------------------------------------

#Need to create 2 randomized speech clip montages
seed.num <- c(102, 512) #set the 2 locations for randomized clip order
speechMix <- vector(mode = "list", length = 2) #create a list to save both speech clips

for (talk in 1:2){
set.seed(seed.num[talk]) #set the seed to a already determined seed number
setSize <- nrow(newfilter_and_normed.shared_objects) #determine the number of files inside
fadeLength.speech <- 0.5 #amount of time used to ramp into and out of final sound clips (in seconds)


currentGroup <- newfilter_and_normed.shared_objects[sample(setSize), ] #randomize clip order
stimuliSet <- vector(mode = "list", length = setSize) #preallocated a blank list for storing individual sound bites

for (currentWav in 1:setSize) { #for each .wav file within a particular group
  
  stimuliSet[[currentWav]] <- readWave(paste(wavFileLocation,currentGroup$file[currentWav],sep="")) #load the .wav file into a list
  
  if (stimuliSet[[currentWav]]@samp.rate != samplingRate) { #some of the .wav files have different sampling rates. need to make sure that they all share the same sampling rate
    stimuliSet[[currentWav]] <- resamp(stimuliSet[[currentWav]], g=samplingRate) #correct any errant sampling rates to 44100
  }
  
  
  if (currentWav == 1) { #if this is the very first sound bite in the list
    speechMix[[talk]] <- stimuliSet[[1]] #use it to create the eventual concatenated string of clips
  }    
  else { #if it is any clips after the first one
    speechMix[[talk]] <- pastew(stimuliSet[[currentWav]], speechMix[[talk]], f=samplingRate, tjunction = fadeBetween, output="Wave") #just add it to the alredy existing concatenated string of clips
    
  }
}

#Modifications to the appended list of sound bites

amplitude <- max(abs(min(speechMix[[talk]]@left)),abs(max(speechMix[[talk]]@left))) #determine the amplitude of the soundwave (used for later amplitude adjustment)
speechMix[[talk]] <- cutw(speechMix[[talk]], from = 0, to = duration(jazzMix), output = "Wave") #cut the speech montage to be the same length as the jazz mix
speechMix[[talk]] <- fadew(speechMix[[talk]], din=fadeLength.speech, dout=fadeLength.speech,output="Wave") #Fade ends of clip so there is a 0.5s ramp up and 0.5s ramp down on either side of clip. This adjusts the amplitude to range from -1 to 1
speechMix[[talk]]@left <- speechMix[[talk]]@left * amplitude #To correct amplitude adjustment, numbers were multiplied by the original amplitude

writeWave(speechMix[[talk]], paste("~/Desktop/speech_",talk,".wav",sep="")) #after all the clips have been added, save this sample to a folder

}

# Fading Volumes ----------------------------------------------------------

numChanges <- 50 #number of minima or maxima for volumes

#create a blank stirng of numbers the length of the number of samples within the jazz/speech montages that will vary between 0.4 and 0.6. This will be the volume modifier for the clips
volumeWave <- rep(NA, duration(jazzMix)*samplingRate) #first create this montage as a string of NAs

#make the first and last samples 0
volumeWave[1] <- 0
volumeWave[length(volumeWave)] <- 0

#randomly make choose some samples to be maxima
set.seed(36)
chosenOnes <- sample(duration(jazzMix)*samplingRate,numChanges)

#choose some samples to be minima
set.seed(89)
chosenZeros <- sample(duration(jazzMix)*samplingRate,numChanges)

for (i in 1:numChanges){ #for each of the 50 sets of maxima and minima
  pickedOne <- chosenOnes[i] #make one sample 0.6
  volumeWave[pickedOne] <- 0.6
  
  pickedZero <- chosenZeros[i] #make another sample 0.4
  volumeWave[pickedZero] <- 0.4
}

volumeWave.1 <- spline(volumeWave, n=length(volumeWave)) #create another wave that interpolates between maxima and minima to create a randomly shifting "wave" that oscillates (this comes out as a 2D list of points but the y colummn holds the vector we want)

#grab the y column and manipulate it to ensure that it ranges from 0 to 1. (spline can make it surpass those values). Make this the volume modifier for the 2 speech montages
volumeWave.y <- volumeWave.1$y + abs(min(volumeWave.1$y)) 
volumeWave.speech <- volumeWave.y/max(volumeWave.y)

#Make the jazz volume modifier change inversely to the speech modifier
volumeWave.jazz <- 1 - volumeWave.speech

#Create a jazz mix montage where the volume changes according to the volume modifying wave
jazzMix.volume <- jazzMix
jazzMix.volume@left <- (jazzMix.volume@left * volumeWave.jazz)

#Create 2 speech mix montages where the volumes shift according to the volume modifying wave
speechMix1.volume <- speechMix[[1]]
speechMix1.volume@left <- speechMix1.volume@left * volumeWave.speech

speechMix2.volume <- speechMix[[2]]
speechMix2.volume@left <- speechMix2.volume@left * volumeWave.speech

#ensure that the jazz mix's range of volumes matches that of the speech mixes (some times clips may just be overall louder)
jazzMix.volume@left <- (jazzMix.volume@left/max(jazzMix.volume@left))*max(speechMix1.volume@left)

# Combining Waves ---------------------------------------------------------

#Create a final clip where the jazz mix and both speech mixes are all added together
jazzAndSpeech <- jazzMix.volume
jazzAndSpeech@left <- jazzAndSpeech@left + speechMix1.volume@left + speechMix2.volume@left

#Save the final jazz/speech mix and its 3 components
writeWave(jazzMix.volume,"~/Desktop/jazzvolume.wav")
writeWave(speechMix1.volume,"~/Desktop/speechvolume1.wav")
writeWave(speechMix2.volume,"~/Desktop/speechvolume2.wav")
writeWave(jazzAndSpeech,"~/Desktop/jazzspeech.wav")