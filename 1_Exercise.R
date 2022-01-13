# First Exercise
# Immanunel Frenzel
# 11.01.2021

library("tidyverse")
library("lubridate")
library("tibbletime")

rm(list = ls(all.names = TRUE))

#import
rawdata <- read.csv("https://raw.githubusercontent.com/data-hydenv/data/master/hobo/2022/raw/10610854.csv", skip = 1) %>% 
  as_tibble() %>% 
  select(1:4)

#name colums
rawdata <- rawdata %>%
  rename("charDTTM" = names(rawdata)[2]) %>% 
  rename("temp" = names(rawdata)[3]) %>% 
  rename("lux" = names(rawdata)[4])

#datetime in posixct
rawdata <- rawdata %>% 
  mutate(posDTTM = ymd_hms(parse_date_time(rawdata$charDTTM, "%d/%m/%Y %H:%M:%S")))

#using the tibbletime package function filtertime to select the range of my data
rawdata <- filter_time(tbl_time(rawdata, posDTTM), '2021-12-13 00:00:00' ~ '2022-01-09 10:30:00') 

#my data is incompete -> adding the missing rows
rawdata <- rawdata %>% 
  add_row(posDTTM = seq(ymd_hms('2022-01-09 10:40:00'), ymd_hms('2022-01-09 23:00:00'),                        
                        by = '10 mins'))

#delete 2 row at 2021-12-22 because of sensor readout
rawdata <- rawdata[-c(1355, 1357), ]

#shaping the exportfile
export <- rawdata %>%
  mutate("dttm" = format(as.POSIXct(rawdata$posDTTM), "%Y-%m-%d %H:%M"), id = 1:length(rawdata$posDTTM)) %>% 
  select("id", "dttm", "temp", "lux")

#shaping the exportfile
write.csv(export, file = "C:/Users/Imifr/Documents/Github/hyd_data_management/10610854.csv", append = FALSE, quote = FALSE, sep = ",",
          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
          col.names = TRUE, qmethod = c("escape", "double"),
          fileEncoding = "")
#Tests
reimport <- read.csv("C:/Users/Imifr/Documents/Github/hyd_data_management/10610854.csv")

