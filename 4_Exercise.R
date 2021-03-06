# 4th Exercise
# Immanunel Frenzel
# 14.01.2021

library("tidyverse")
library("lubridate")
library("tibbletime")

rm(list=ls())

#import
data <- read.csv("https://raw.githubusercontent.com/imifrenzel/hyd_data_management/main/10610854_Th.csv")
data <- data %>% 
  mutate(dttm = ymd_hms(dttm)) %>% 
  tibble()

data_ex3 <- read.csv("https://raw.githubusercontent.com/imifrenzel/hyd_data_management/main/10610854_hourly.csv")
data_ex3 <- data_ex3 %>% 
  mutate(dttm = ymd_hms(date_time)) %>% 
  tibble()

data_ex1 <- read.csv("https://raw.githubusercontent.com/imifrenzel/hyd_data_management/main/10610854.csv")
data_ex1 <- data_ex1 %>% 
  mutate(dttm = ymd_hm(dttm)) %>% 
  tibble()

#values
###tavg

tdaynight <- data %>% 
  mutate(daytime = ifelse(hour(dttm) < 6 | hour(dttm) >= 18, "night", "day")) %>% 
  group_by(daytime) %>% 
  summarise(mean = mean(temp))

tavg <- mean(data$temp)

###tamp

tamp_data <- data %>%
  mutate(date = date(dttm)) %>% 
  group_by(date) %>%
  summarise(tmin = min(temp), tmax =(max(temp)))

tamp = mean(tamp_data$tmax) - mean(tamp_data$tmin)

###t6h

t6h_data <- data %>%
  mutate(t6h_1 = abs(temp - lead(temp)),
         t6h_2 = abs(temp - lead(temp, n = 2)),
         t6h_3 = abs(temp - lead(temp, n = 3)),
         t6h_4 = abs(temp - lead(temp, n = 4)),
         t6h_5 = abs(temp - lead(temp, n = 5)),
         t6h_6 = abs(temp - lead(temp, n = 6))) %>%
  rowwise() %>%
  mutate(t6h = max(t6h_1, t6h_2, t6h_3, t6h_4, t6h_5, t6h_6, na.rm = T))

t6h <- max(t6h_data$t6h)

###fna

fna_data_ex3 <- data_ex3 %>% #exclude nas at the end, which are due to manual cut
  tbl_time(dttm) %>% 
  filter_time('2021-12-13 00:00:00' ~ '2022-01-07 17:00:00')

fna <- sum(is.na(fna_data_ex3$th))/length(fna_data_ex3$th)

###Lavg
data_lavg <- data_ex1 %>% 
  mutate(daytime = if_else(hour(dttm) < 6 | hour(dttm) >= 18, "night", "day")) %>% 
  group_by(daytime) 
  
median_lux <- summarise(data_lavg, median = median(lux, na.rm = T))[1,2]

###Lmax
data_lmax <- data_lavg %>% 
  ungroup() %>%
  filter(daytime == "day") %>% 
  mutate(hm = hm(format(dttm, "%H:%M"))) %>% 
  group_by(hm) %>% 
  summarise(meanlux = mean(lux, na.rm = TRUE)) %>% 
  arrange(desc(meanlux))

lmax <- data_lmax[1,1]



  






