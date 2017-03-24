
# Initiation --------------------------------------------------------------

#Load up packages
library(dplyr)
library(stringr)
library(reshape2)
library(seewave)
library(tuneR)

options(stringsAsFactors = F) #ensures that csv read into R do not have character values become factors. It can make later organization difficult

setWavPlayer("/Applications/VLC.app/Contents/MacOS/VLC") #explicitly set wav player to VLC in case tuneR or seewave need a Wav Player

parameterThreshold <- 1 #threshold for matching files on normed scale provided for clips
silenceBreak <- 0.5 #length of time between wav files (in seconds)
backgroundNoiseAmplification <- 3.5 #multiplier that the background noise was amplified by to more closely match background noise in speaking clips
fadeIn <- 0.1 #period of time (in seconds) that is smoothed between clips to prevent abrupt clicks
samplingRate <- 44100 #sampling rate for clips (in Hz)
clipLength <- 21 #length of final sound clips (in seconds)
fadeLength <- 0.5 #amount of time used to ramp into and out of final sound clips (in seconds)

wavFileLocation <- "~/Documents/repo/manybabies_norming/wavs/original/" #Folder where normed sample of wavs was stored (https://github.com/langcog/manybabies_norming/tree/master/wavs/original)
stimuliSetLocation <- "~/Desktop/Many Babies Stimuli Sets/Sound Stim Sets/" #Folder to place newly created sound clips
filtered_and_normed <- read.csv("~/Documents/repo/manybabies_norming/wavs/filtered_and_normed.csv") #load up csv file containing data regarding sound clips (https://github.com/langcog/manybabies_norming/blob/master/wavs/filtered_and_normed.csv)
questions <- read.csv(file = "~/Documents/repo/manybabies_norming/scripts/Audio Stimuli Creation/questions.csv") #separate csv which determined whether a sound clip's transcript had a question or was only composed of statements (https://github.com/langcog/manybabies_norming/blob/master/scripts/Audio%20Stimuli%20Creation/questions.csv)
backgroundNoiseLocation <- "~/Documents/repo/manybabies_norming/scripts/Audio Stimuli Creation/silence.wav" #location of .wav file of background noise from a video, used as a separator between adjacent speech bits (https://github.com/langcog/manybabies_norming/blob/master/scripts/Audio%20Stimuli%20Creation/silence.wav)


# BackGround Noise Generation ---------------------------------------------

backgroundNoise <- readWave(backgroundNoiseLocation) #load background noise wav into R
backgroundNoise <- resamp(backgroundNoise, g=samplingRate, output="Wave") #resample background noise to ensure uniform sampling rate between all wavs
loudBackground <- backgroundNoise #create a duplicate of the original background noise
loudBackground@left <- loudBackground@left * backgroundNoiseAmplification #amplify the wav by the multiplier entered ealier
loudBackground <- cutw(loudBackground,from = 0.2, to = 0.2 + silenceBreak, output="Wave") #clip .wav to the desired length of silence
loudBackground@left <- as.integer(loudBackground@left) #converting double vector to integer vector for wav file (R complains that that it prefers to save explicit integers)
writeWave(loudBackground, paste(stimuliSetLocation,"Background.wav",sep="")) #save modified wav file

# Format Wav Information --------------------------------------------------

fileList <- list.files(wavFileLocation) #pull of the list of wav files
numfiles <- length(fileList) #find out how many files there are

wavdurations <- matrix(nrow = numfiles) #preallocate a matrix for storing the wav file durations

for (i in 1:numfiles) { #For every wav file in that folder
  currentfile <- paste(wavFileLocation,fileList[i],sep="")
  currentsound <- readWave(currentfile) #load it into R
  currentduration <- seewave::duration(currentsound) #find its duration
  wavdurations[i] <- currentduration #save its duration
}

wavlengths <- data.frame(file = fileList, duration = wavdurations) #create a dataframe matching the wav file names to their corresponding duratons

addedDurations <- left_join(filtered_and_normed, wavlengths) #join the two files together (this way we get the duration data and other information for only the chosen normed files)
newfilter_and_normed <- left_join(addedDurations, questions) #join 2 files together to add data about presence of questions to dataset

#in the old csv, there was no column that said the baby id # without added numbers after it
#needed to create a column with just baby id numbers by pulling them from the original id numbers that had spaces or underscores and then timing information about the file
newfilter_and_normed$baby.id <- sub("_.*$","",newfilter_and_normed$baby_id) #remove underscores and all subsequent characters
newfilter_and_normed$baby.id <- sub(" .*$","",newfilter_and_normed$baby.id) #remove spaces and all subsequent characters

newfilter_and_normed$object <- as.character(newfilter_and_normed$object)

newfilter_and_normed$object[is.na(newfilter_and_normed$object)] <- "none" #changed the NA argument to "none" since I was having issues with R wanting to throw out rows with NAs in them. To ensure this didn't happen, I filled these rows with "none"

newfilter_and_normed.shared_objects <- subset(newfilter_and_normed, newfilter_and_normed$object != "flag" & newfilter_and_normed$object!="sieve") #create a copied dataset without the files with objects flag or sieve (only the ADS files had these objects, no possible IDS matches)


# Match IDS and ADS Wavs Mentioning Specific Objects ----------------------

allIDSrows <- subset(newfilter_and_normed.shared_objects, newfilter_and_normed.shared_objects$register=="IDS" & newfilter_and_normed.shared_objects$object != "none") #Find all IDS files that mention an object
numMatches <- data.frame(allIDSrows$file, allIDSrows$object, allIDSrows$duration) #create another file that is just these IDS/object rows' file names, objects, and duration (for later matching)
numMatches$bestScore <- numMatches$bestMatch <- numMatches$dupe <- NaN #add some extra NaN column for later data storage


for (i in 1:nrow(allIDSrows)) { #for every IDS file with an object mentioned
  currentFile <- allIDSrows[i,] #grab that paricular file info
  oppositeRegister <- subset(newfilter_and_normed.shared_objects, newfilter_and_normed.shared_objects$register=="ADS" & newfilter_and_normed.shared_objects$object==currentFile$object & newfilter_and_normed.shared_objects$accent <= currentFile$accent + parameterThreshold & newfilter_and_normed.shared_objects$accent >= currentFile$accent - parameterThreshold & newfilter_and_normed.shared_objects$noise <= currentFile$noise + parameterThreshold & newfilter_and_normed.shared_objects$noise >= currentFile$noise - parameterThreshold & newfilter_and_normed.shared_objects$naturalness <= currentFile$naturalness + parameterThreshold & newfilter_and_normed.shared_objects$naturalness >= currentFile$naturalness - parameterThreshold) #Find any ADS files mentioning the same object who are +/- 1 in their naturalness, noise, and accent scores to that of the IDS file
  
  numMatches$num.matches[i] <- nrow(oppositeRegister) #add to the numMatches dataframe the number of matches the IDS file had
  
  
  if (nrow(oppositeRegister) >= 1) { #if there is more than one match, we need to find the best match
    
    oppositeRegister$absDifference <- abs(currentFile$noise - oppositeRegister$noise) + abs(currentFile$naturalness - oppositeRegister$naturalness) + abs(currentFile$accent - oppositeRegister$accent) #find the sum of absolute differences between each ADS match and the IDS file
    numMatches$bestScore[i] <- min(oppositeRegister$absDifference) #choose the ADS file with the smallest differences; store its difference score
    numMatches$bestMatch[i] <- oppositeRegister$file[oppositeRegister$absDifference == min(oppositeRegister$absDifference)] #store the match's file name
    numMatches$bestDuration[i] <- oppositeRegister$duration[oppositeRegister$absDifference == min(oppositeRegister$absDifference)] #also store the match's duration length
  }
}

for (i in 1:nrow(numMatches)) { #Some ADS files were the best matches for multiple IDS files. If that is the case, I wanted to make sure only the best matches stayed while worse matches were dropped. Also some files find any matches that met criteria so those needed to be removed as well
  
  if (numMatches$num.matches[i] >= 1) { #only select files that were successfully matched
    currentRow <- numMatches[i,] #go through each row
    rowdupes <- subset(numMatches, numMatches$bestMatch == currentRow$bestMatch) #for that row, find any rows with the same matched ADS file name
    if (currentRow$bestScore == min(rowdupes$bestScore)) { #of those, mark the files with the strongest match (lowest score) with a 0 and other duplicates with a 1
      numMatches$dupe[i] <- 0}
    else {
      numMatches$dupe[i] <- 1}}
  else {next} #skip over rows where no suitable matches were found
}

numMatches.nodupes <- subset(numMatches, numMatches$dupe == 0) #now just select matched files with the strongest matches


# Assign Wavs to Specific Groups ------------------------------------------

#Now that we have matched object files, the next section really is just creating the groups by hand
#first I allocated object files and their matches to corresponding group pairs (1 through 8)
#I tried to keep the total duration of object clips per group, relatively close (as close as one can get with highly varied durations) generally between 6-10 seconds for ADS and between 3-7 seconds for IDS (since IDS clips were generally much shorter than their ADS counterparts)
#After that, I selected clips were no objects were mentioned and allocated those to groups
#I tried to keep the mean noise, accent,  and naturalness for each group around the same values (between 2-3)
#I also tried to make the number of unique mom-baby dyads to 4 (some were 3) per IDS or ADS group
#The groupStats dataframe describes the average attributes for each group

newfilter_and_normed.shared_objects$grouping <- NaN #create a NaN variable for assigning group numbers

newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 1266_1081.994965918577.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 2936_296.0815847200069.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="shoe, Baby 3214_146.42957350550878.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="shoe, Baby 4_134.149755832785.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 1810_341.78370202005016.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_14.879063232058567.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_681.3154526508381.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_104.18135306605845.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_202.56565007451687.wav"]<- 1
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_113.02363282815345.wav"]<- 1

newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 4_16.034320085213878.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 3214_461.6955604692438.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 4547 at 402.557.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 4_152.04239497413855.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="train, Baby 3214_391.50393768367746.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="train, Baby 3214_709.7436105197614.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2874_470.6960809064687.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_740.8185060018474.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_879.5171532966713.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_653.2399541887826.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_222.11379879288614.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2874_498.20327264845236.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_392.63977244181063.wav"]<- 2
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_527.5306735604257.wav"]<- 2


newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 5_65.9595859218018.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="ball, Baby 4510_341.74610580792717.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="shoe, Baby 2077_478.73114244939586.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="shoe, Baby 2874_479.5476071115915.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_3.5141170515042672.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_194.358287668529.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_119.15118217078498.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_93.3328966173391.wav"]<- 3
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_169.8693129177112.wav"]<- 3


newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="block, Baby 4_494.49767506211765.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="block, Baby 1810_458.0540644809489.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="yeast, Baby 5_347.82013131422985.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="yeast, Baby 5_116.95457424694321.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_836.1680079319436.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 3314 at 90.785.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_900.3117780947271.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_89.85002439231228.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_730.1956497211921.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_105.57700379351351.wav"]<- 4
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4547 at 554.549.wav"]<- 4

newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="block, Baby 4784_742.9883388969735(1).wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="block, Baby 4_184.73879609345.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_325.2131190053606.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 1266_297.497131311381.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_335.3282845753848.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2874_423.9870515300145.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4547 at 646.298.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_155.95953433497698.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_614.102959313815.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_542.4133794672472.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_639.5356066570439.wav"]<- 5
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 1266_386.6540619962722.wav"]<- 5


newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 2077_107.85705677543913.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 2874_545.902024470267.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_579.3790731401354.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_147.46686891933587.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 1810_298.1001772894327.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_70.21009376493727.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_316.3634768658419.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_450.81831091701173.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_1030.7292597994947.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_99.56910174909278.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_532.1076975332735.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_189.90045545569708.wav"]<- 6
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_18.858192396783313.wav"]<- 6

newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="train, Baby 2077_401.6461644731435.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="train, Baby 3214_747.4731669126435.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_349.8681104663433.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 3912_233.49077753067155.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_65.53872765319125.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_406.04803014416336.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_193.0114402841952.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 3214_81.53152246997749.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_639.308111816499.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_369.75832648186525.wav"]<- 7
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_231.4298284816723.wav"]<- 7

newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 5_101.82931237904873.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="cup, Baby 3214_548.2954351161833.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="whisk, Baby 4_371.6131959736724.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="whisk, Baby 1810_284.02024489690655.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_627.1174028986043.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_192.8653554888671.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2936_417.8743349932715.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 1810_298.1001772894327.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4510_203.56842214889127.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 2077_486.724412738805.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 5_60.95494937104302.wav"]<- 8
newfilter_and_normed.shared_objects$grouping[newfilter_and_normed.shared_objects$file=="Baby 4_21.772095962819797.wav"]<- 8


groupStats <- newfilter_and_normed.shared_objects %>% group_by(grouping, register) %>% summarise(duration = sum(duration), naturalness = mean(naturalness), accent = mean(accent), noise = mean(noise), num.babies = n_distinct(baby.id), which.babies = str_c(sort(unique(baby.id)),collapse=', '), min.duration = min(duration), max.duration = max(duration), mean.duration = mean(duration)) #Description of overall group attributes for each group/register

  
# Create Concatenated String of Grouped Wavs ------------------------------

chosenWavs <- subset(newfilter_and_normed.shared_objects, !is.na(newfilter_and_normed.shared_objects$grouping)) #pick all wav files that were assigned to a group

stimuliGroups <- split(chosenWavs, list(chosenWavs$register, chosenWavs$grouping)) #split these rows up by their group number and their register
random.seed <- seq(28,328, length.out = length(stimuliGroups)) #for later sound byte arrangement in their larger sound clips. Set seed to ensure reproducible results but also varied random numbers 

groupingData <- data.frame(matrix(nrow = nrow(chosenWavs), ncol = ncol(chosenWavs))) #create an emoty dataframe to store information about sound byte order within the larger sets
groupCount <- 1 #initiate count for filling order dataframe

for (stimSet in 1:length(stimuliGroups)) { #For each of the 16 groups (8 group numbers by 2 registers)
  set.seed(random.seed[stimSet]) #set the seed to a already determined seed number
  rawGroup <- stimuliGroups[[stimSet]] #load up the current group
  setSize <- nrow(rawGroup) #determine the number of files inside
  
  #clips within a group were grouped together by the same baby ID (to reduce the # of transitions between noticeably different voices). These groups were then shuffled. Ex. 41342123 --> 11223344 --> 33114422
  randMom <- sample(unique(rawGroup$baby.id))
  currentGroup <- left_join(data.frame(baby.id=randMom),rawGroup,by="baby.id")
  stimuliSet <- vector(mode = "list", length = setSize) #preallocated a blank list for storing individual sound bites
  
  if (stimSet == 1) {
    names(groupingData) <- names(currentGroup) #if this is the first group of clips, give the blank order data frame the same header
  }
  
  for (currentWav in 1:setSize) { #for each .wav file within a particular group
    
    groupingData[groupCount,] <- currentGroup[currentWav,] #copy its row into the order dataframe
    groupCount <- groupCount + 1 #update the order group count to load up the next row for the next loop
    
    stimuliSet[[currentWav]] <- readWave(paste(wavFileLocation,currentGroup$file[currentWav],sep="")) #load the .wav file into a list of wavs for that particular group
    
    if (stimuliSet[[currentWav]]@samp.rate != samplingRate) { #some of the .wav files have different sampling rates. need to make sure that they all share the same sampling rate
    stimuliSet[[currentWav]] <- resamp(stimuliSet[[currentWav]], g=samplingRate) #correct any errant sampling rates to 44100
    }
    
    
    if (currentWav != setSize) { #if it is not the very last sound bite in the group
      stimuliSet[[currentWav]] <- pastew(loudBackground, stimuliSet[[currentWav]], f=samplingRate, tjunction = fadeIn, output = "Wave") #Add background noise wav to the end of the clip (later concatenation will have background noise sandwiched between speaking clips)
          }
    
    if (currentWav == 1) { #if this is the very first sound bite in the list
      appendedSample <- stimuliSet[[1]] #use it to create the eventual concatenated string of clips
    }    
    else { #if it is any clips after the first one
      appendedSample <- pastew(stimuliSet[[currentWav]], appendedSample, f=samplingRate, tjunction = fadeIn, output="Wave") #just add it to the alredy existing concatenated string of clips
      
    }
  }
  
  #Modifications to the appended list of sound bites
  
  #Clips must to trimmed to 21s, selected 21s from the center of the clip and trimmed both ends equally
  lengthToTrim <- (duration(appendedSample) - clipLength)/2 #determine the length needed to be trimmed from each end
  appendedSample <- cutw(appendedSample, from = lengthToTrim, to = duration(appendedSample) - lengthToTrim, output="Wave") #Trim off ends of clip
  
  amplitude <- max(abs(min(appendedSample@left)),abs(max(appendedSample@left))) #determine the amplitude of the soundwave (used for later amplitude adjustment)
  appendedSample <- fadew(appendedSample, din=fadeLength, dout=fadeLength,output="Wave") #Fade ends of clip so there is a 0.5s ramp up and 0.5s ramp down on either side of clip. This adjusts the amplitude to range from -1 to 1
  appendedSample@left <- appendedSample@left * amplitude #To correct amplitude adjustment, numbers were multiplied by the original amplitude
  
  appendedSample@left <- as.integer(appendedSample@left) #converting double vector to integer vector for wav file (R complains that that it prefers to save explicit integers)
  
  writeWave(appendedSample, paste(stimuliSetLocation,currentGroup$register[1],"-",currentGroup$grouping[1],".wav",sep="")) #after all the clips have been added, save this sample to a folder
  
}

