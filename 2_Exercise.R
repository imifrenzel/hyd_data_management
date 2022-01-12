#Exercise 2 data collection storage and management Immanuel Frenzel 12.01.2022

library("lubridate")
library("tidyverse")
library("zoo")
library("tibbletime")

rm(list=ls())

#dataimport
reimport <- read.csv("C:/Users/Imifr/Documents/Github/hyd_data_management/10610854.csv")

data <- reimport %>% 
  mutate(dttm = ymd_hm(reimport$dttm))

#QCPs

data <- data %>%
  mutate(QCP_1 = ifelse(temp >= -20 && temp <= 70, 1, 0)) %>% 
  mutate(QCP_2 = ifelse(between(temp - lag(temp), -1, 1), 1, 0)) %>% 
  mutate(QCP_3 = ifelse((temp == lag(temp)) +
                        (temp == lag(temp, n = 2)) +
                        (temp == lag(temp, n = 3)) +
                        (temp == lag(temp, n = 4)) +
                        (temp == lag(temp, n = 5)) == 5, 0, 1 
                        )) %>% 
  mutate(SIC = case_when(lux < 0 ~ "NA",
                         lux < 10 ~ "night",
                         lux < 500 ~ "sun_rise_or_set",
                         lux < 2000 ~ "overcast_full",
                         lux < 15000 ~ "overcast_light",
                         lux < 20000 ~ "clear_sky_shady",
                         lux < 50000 ~ "sunshine",
                         lux >= 50000 ~ "sunshine_bright")) %>% 
  mutate(QCP_4 = case_when((hour(dttm) < 6 | hour(dttm) >= 18) ~ 1, #set all QCP_4 values for nighttime to 1
                           lag(SIC, n = 3) == "sunshine_bright" ~ 0, #set 0 if sunshine_bright +- 3 before or ahead
                           lag(SIC, n = 2) == "sunshine_bright" ~ 0,
                           lag(SIC) == "sunshine_bright" ~ 0,
                           SIC == "sunshine_bright" ~ 0,
                           lead(SIC) == "sunshine_bright" ~ 0,
                           lead(SIC, n = 2) == "sunshine_bright" ~ 0,
                           lead(SIC, n = 3) == "sunshine_bright" ~ 0, #set 0 if sunshine +- 1 before or ahead
                           lag(SIC) == "sunshine" ~ 0,
                           SIC == "sunshine" ~ 0,
                           lead(SIC) == "sunshine" ~ 0,
                           TRUE ~ 1)) 
data_hourly <- data %>% 
  mutate(QCP_total = ifelse(QCP_1 + QCP_2 + QCP_3 + QCP_4 < 4, 0, 1)) %>% 
  mutate(hour = cut(dttm, breaks = "hour")) %>% 
  group_by(hour) %>% 
  summarise(date_time = first(hour), th = ifelse(sum(QCP_total) < 6, NA, mean(temp)))
 



#test 4 QCPS
filter(data, temp <= -20 && temp >= 70)
filter(data, !between(temp - lag(temp), -1, 1))
filter(data, (temp == lag(temp)) +
         (temp == lag(temp, n = 2)) +
         (temp == lag(temp, n = 3)) +
         (temp == lag(temp, n = 4)) +
         (temp == lag(temp, n = 5)) == 5)
filter(data, SIC == "sunshine_bright" | SIC == "sunshine")

tinytex::install_tinytex()

