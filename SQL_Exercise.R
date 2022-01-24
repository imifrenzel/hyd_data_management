
library("tidyverse")
library("viridis")
#dataimport
data <- read.csv("https://raw.githubusercontent.com/imifrenzel/hyd_data_management/main/data_plot_1.csv")
data <- data %>% 
  mutate(category = case_when(category == 1 ~ "night",
                              category == 2 ~ "sun_rise_or_set",
                              category == 3 ~ "overcast_full",
                              category == 4 ~ "overcast_light",
                              category == 5 ~ "clear_sky_shady",
                              category == 6 ~ "sunshine",
                              category == 7 ~ "sunshine_bright"))

data_2 <- data %>% 
  group_by(name) %>% 
  summarise(avgtemp = min(avgtemp)/10) %>% 
  ungroup()

ggplot(data = data) +
  geom_col(mapping = aes(x = name, y = n, fill  = factor(category, levels = c("night",
                                                                          "sun_rise_or_set",
                                                                          "overcast_full",
                                                                          "overcast_light",
                                                                          "clear_sky_shady",
                                                                          "sunshine",
                                                                          "sunshine_bright"))), position = "fill") +
  geom_point(data = data_2, mapping = aes(x = name, y = avgtemp), shape = 3, color = "white", size = 2) +
  scale_color_viridis(discrete = TRUE, option = "D") +
  scale_fill_viridis(discrete = TRUE) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(fill = "light") +
  xlab("") +
  ylab("percent of measurements") +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name="mean temperature °C"))

  
  

