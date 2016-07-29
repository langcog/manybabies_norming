rm(list=ls())
library(dplyr)
library(tidyr)
library(stringr)
library(rjson)
library(readr)

ad_files <- dir("../wavs/AD Recordings/")
id_files <- dir("../wavs/ID Recordings/")

files <- data_frame(file = c(ad_files, 
                             id_files), 
                    register = factor(c(rep("ADS", length(ad_files)), 
                                 rep("IDS", length(id_files)))))

d <- files %>%
  mutate(name = file) %>%
  separate(name, into = c("object", "name"), sep = "Baby ") %>%
  separate(name, into = c("baby_id","recording_id","extension"), 
           sep = "\\.") %>%
  mutate(object = str_replace(object, pattern = ", ", ""),
         object = ifelse(object == "", NA, object)) %>%
  select(-extension)

# print(toJSON(d$file))

write_csv(d, "../wavs/file_key.csv")
