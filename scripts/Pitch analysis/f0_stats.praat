#based off of http://www.helsinki.fi/~lennes/praat-scripts/public/collect_pitch_data_from_files.praat

form Analyze pitch maxima from labeled segments in files
	comment Directory of sound files
	text sound_directory /Users/danielle/Documents/repo/manybabies_norming/wavs/normed/
	sentence Sound_file_extension .wav
	comment Full path of the resulting text file:
	text resultfile /Users/danielle/Documents/repo/manybabies_norming/scripts/Pitch Analysis/pitchresults.txt
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch_(Hz) 100
	positive Maximum_pitch_(Hz) 600
endform


Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	filedelete 'resultfile$'
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "Filename;Pitchmean;Pitchmin;Pitchmax'newline$'"
fileappend "'resultfile$'" 'titleline$'

# Go through all the sound files, one by one:

for ifile to numberOfFiles
	filename$ = Get string... ifile
	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'
	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	startTime = Get start time
	endTime = Get end time
	View & Edit
	soundname$ = selected$ ("Sound", 1)
	To Pitch... time_step minimum_pitch maximum_pitch
	pitchmean = Get mean: startTime, endTime, "Hertz"
	pitchmin = Get minimum: startTime, endTime, "Hertz", "Parabolic"
	pitchmax = Get maximum: startTime, endTime, "Hertz", "Parabolic"
	resultline$ = "'filename$';'pitchmean';'pitchmin';'pitchmax''newline$'"
	fileappend "'resultfile$'" 'resultline$'
	select Sound 'soundname$'
	plus Pitch 'soundname$'
	Remove
	select Strings list
endfor

select all
Remove

