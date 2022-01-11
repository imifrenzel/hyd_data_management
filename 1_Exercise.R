# First Exercise
# Immanunel Frenzel
# 11.01.2021

library("tidyverse")
library("lubridate")

rm(list = ls(all.names = TRUE))

rawdata <- read.csv("https://raw.githubusercontent.com/data-hydenv/data/master/hobo/2022/raw/10610854.csv", skip = 1) %>% 
  as_tibble() %>% 
  select(1:4)

rawdata <- rawdata %>% rename("id" = names(rawdata)[1]) %>% 
  rename("charDTTM" = names(rawdata)[2]) %>% 
  rename("temp" = names(rawdata)[3]) %>% 
  rename("lux" = names(rawdata)[4])

rawdata <- rawdata %>% 
  mutate("posDTTM" = parse_date_time(rawdata$charDTTM, "%d/%m/%Y %H:%M:%S"))

rawdata <- rawdata %>%
  mutate("dttm" = format(as.POSIXct(rawdata$posDTTM), "%Y-%m-%d %H:%M"))

rawdata <- rawdata %>%
  select("id" , "dttm", "temp", "lux")
