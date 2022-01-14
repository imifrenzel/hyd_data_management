#Exercise 2 data collection storage and management Immanuel Frenzel 12.01.2022

library("lubridate")
library("tidyverse")
library("zoo")
library("tibbletime")

rm(list=ls())

#dataimport
reimport <- read.csv("https://raw.githubusercontent.com/imifrenzel/hyd_data_management/main/10610854.csv")

data <- reimport %>% 
  mutate(dttm = ymd_hm(reimport$dttm))

#QCPs

#QCP_1
data <- data %>%
  mutate(QCP_1 = if_else(temp <= -20 | temp >= 70, 0, 1))

sum <- summarise(data, QCP_1 = sum(QCP_1, na.rm = TRUE))
length(data$QCP_1) - sum
summary(data)

#QCP_2
data <- data %>%
  mutate(QCP_2 = ifelse(between(temp - lag(temp), -1, 1), 1, 0))

summarise(data, QCP_2 = sum(QCP_2 == 0, na.rm = TRUE))
filter(data, QCP_2 == 0)
summary(data)

#QCP_3
data <- data %>%
  mutate(QCP_3 = ifelse((temp == lag(temp)) +
                        (temp == lag(temp, n = 2)) +
                        (temp == lag(temp, n = 3)) +
                        (temp == lag(temp, n = 4)) +
                        (temp == lag(temp, n = 5)) == 5, 0, 1 
                        )) 

filter(data, QCP_3 == 0)

#QCP_4
data <- data %>%
  mutate(SIC = case_when(lux < 0 ~ "NA",
                         lux < 10 ~ "night",
                         lux < 500 ~ "sun_rise_or_set",
                         lux < 2000 ~ "overcast_full",
                         lux < 15000 ~ "overcast_light",
                         lux < 20000 ~ "clear_sky_shady",
                         lux < 50000 ~ "sunshine",
                         lux >= 50000 ~ "sunshine_bright")) %>% 
  mutate(QCP_4 = case_when(is.na(SIC) ~ as.double(NA),
                           hour(dttm) < 6 | hour(dttm) >= 18 ~ 1, #set all QCP_4 values for nighttime to 1
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
#plot of SIC
summary(data)
ggplot(data, mapping = aes(x = SIC)) +
  geom_bar() +
  theme_bw()

#plot for QCP counts
a <- data %>% 
  summarise_at(vars(QCP_1 , QCP_2, QCP_3, QCP_4), ~ sum(.x == 0, na.rm = TRUE)) %>% 
  pivot_longer(cols = QCP_1:QCP_4)

ggplot(a, mapping = aes(x = name, y = value)) +
  geom_col() +
  theme_bw()

#flagging
qc_df <- data %>% 
  mutate(QCP_total = ifelse(QCP_1 + QCP_2 + QCP_3 + QCP_4 < 4, 0, 1))

#aggregate hourly
hobo_hourly <- qc_df %>% 
  mutate(hour = cut(dttm, breaks = "hour")) %>% 
  group_by(hour) %>% 
  summarise(date_time = first(hour), th = round(ifelse(sum(QCP_total) < 6, NA, mean(temp)), digits = 4)) %>% 
  select("date_time", "th")

write.csv(hobo_hourly, file = "C:/Users/Imifr/Documents/Github/hyd_data_management/10610854_hourly.csv", append = FALSE, quote = FALSE, sep = ",",
          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
          col.names = TRUE, qmethod = c("escape", "double"),
          fileEncoding = "")


