#EDA CP2
library(tidyverse)

read.csv("data/repdata_data_StormData.csv.bz2") -> raw_data

sapply(raw_data, function(x) unique(x)[1:5])

raw_data %>% filter(STATE == "XX") %>% select(BGN_DATE) %>%
  mutate(BGN_DATE = lubridate::mdy_hms(BGN_DATE))

unique(raw_data$STATE)

cols_of_interest = c("BGN_DATE", "STATE", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
raw_data %>% select(cols_of_interest) %>% mutate(BGN_DATE = lubridate::mdy_hms(BGN_DATE)) %>%
  filter(STATE != "XX") -> clean_data

str(clean_data)

sapply(clean_data[c("PROPDMGEXP", "CROPDMGEXP")], function(x) unique(x))

`%!in%` <- Negate(`%in%`)
clean_data %>%
  filter(  PROPDMGEXP %!in% c("-", "+", "?"),  CROPDMGEXP %!in% c("?")  ) %>%
  mutate(PROPDMG_V = case_when(
    PROPDMGEXP == "" ~ PROPDMG*1,
    PROPDMGEXP == "0" ~ PROPDMG*1,
    PROPDMGEXP == "1" ~ PROPDMG*10,
    PROPDMGEXP == "2" ~ PROPDMG*100,
    PROPDMGEXP == "3" ~ PROPDMG*1000,
    PROPDMGEXP == "4" ~ PROPDMG*10000,
    PROPDMGEXP == "5" ~ PROPDMG*100000,
    PROPDMGEXP == "6" ~ PROPDMG*1000000,
    PROPDMGEXP == "7" ~ PROPDMG*10000000,
    str_detect(PROPDMGEXP, "h|H") ~ CROPDMG*1000,
    PROPDMGEXP == "K" ~ PROPDMG*1000,
    PROPDMGEXP == "M" ~ PROPDMG*1000000,
    PROPDMGEXP == "B" ~ CROPDMG*1000000000
  ),
  CROPDMG_V = case_when(
    CROPDMGEXP == "" ~ CROPDMG*1,
    CROPDMGEXP == "0" ~ CROPDMG*1,
    CROPDMGEXP == "2" ~ CROPDMG*100,
    str_detect(CROPDMGEXP, "k|K") ~ CROPDMG*1000,
    str_detect(CROPDMGEXP, "m|M") ~  CROPDMG*1000000,
    CROPDMGEXP == "B" ~ CROPDMG*1000000000
  ),
  EVTYPE_mod = case_when(
    str_detect(EVTYPE, "MARINE TSTM WIND|THUNDERSTORM WIND|MARINE THUNDERSTORM WIND") ~ "MARINE TSTM WIND",
    str_detect(EVTYPE, "THUNDERSTORM WIND|THUNDERSTORM WINDS|THUNDERSTORMW WINDS")  ~ "TSTM WIND",
    TRUE ~ EVTYPE
  )) -> df

install.packages("treemapify")
library(treemapify)
library(treemap)

par(mar = c(2, 2, 2, 2))

df %>% group_by(EVTYPE_mod)%>%
  summarise(n = n()) %>% ungroup() %>%
  arrange(desc(n)) %>%
  
  ggplot(aes(area = n, fill = EVTYPE_mod, label = paste(EVTYPE_mod, n, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(colour = "black",
                    place = "centre",
                    size = 8,
                    grow = TRUE) +
  theme(legend.position="none") +
  labs(title = "Proportion of event type")
  
treemap(.,
        index="EVTYPE_mod",
        vSize="n",
        fontsize.labels=c(12),
        fontface.labels=c(1),
        inflate.labels=T,
        palette = "Set2",                     
        title="My Treemap",                      
        fontsize.title=12)

unique(clean_data$CROPDMGEXP)
unique(df$EVTYPE)

df %>% group_by(EVTYPE_mod)%>%
  summarise(n = n()) %>% ungroup() %>%
  arrange(desc(n)) %>% head(5) %>% pull(EVTYPE_mod) -> events

df %>% filter(EVTYPE_mod %in% events) %>%
  group_by(year = lubridate::year(BGN_DATE), EVTYPE_mod) %>%
  summarise(n = n()) %>% ungroup() %>%
  
  ggplot(aes(x = year, y = n, color = EVTYPE_mod)) +
  geom_line() +
  theme_light() +
  scale_color_discrete(name = "") + 
  theme(legend.position = "bottom" ) +
  labs(y = "Number of occurrences",
       title = "Occurrences by event type")

#######impact 
df %>% #filter(FATALITIES > 0, INJURIES > 0) %>%
  group_by(EVTYPE_mod) %>%
  summarize(n_FAT = sum(FATALITIES), n_INJ = sum(INJURIES)) %>%
  arrange(desc(n_FAT), desc(n_INJ)) %>% head(10) %>%
  reshape2::melt(id.vars = c("EVTYPE_mod")) %>%
  
  ggplot(aes(x = EVTYPE_mod, y= value, fill = variable)) +
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_brewer(name ="Impact", palette="Reds", labels = c("Fatalities", "Injuries")) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = c(0.1, 0.85),
        legend.key = element_rect(colour = "transparent", fill = "transparent")) +
  labs(x = "Event type")


df %>% 
  filter(EVTYPE_mod == "TORNADO") %>%
  group_by(STATE) %>% 
  summarize(n_INJ = sum(INJURIES)) %>%
  
  ggplot(aes(area = n_INJ, fill = STATE, label = paste(STATE, n_INJ, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(colour = "black",
                    place = "centre",
                    size = 8,
                    grow = TRUE) +
  theme(legend.position="none") +
  labs(title = "Proportion of injuries caused by tornadoes")
  

##damage
library(gridExtra)
df %>%
  group_by(EVTYPE_mod) %>%
  summarize(n_PROP = sum(PROPDMG_V), n_CROP = sum(CROPDMG_V)) %>%
  arrange(desc(n_PROP), desc(n_CROP)) %>% head(5) %>%
  reshape2::melt(id.vars = c("EVTYPE_mod")) %>%
  
  ggplot(aes(x = EVTYPE_mod, y = value, fill = variable)) +
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_brewer(name ="Impact", palette="Reds", labels = c("Property", "Crop")) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = c(0.1, 0.85),
        legend.key = element_rect(colour = "transparent", fill = "transparent")) +
  labs(x = "Event type") -> two_p1
  
df %>% 
  filter(EVTYPE_mod %in% c("HURRICANE", "HURRICANE/TYPHOON") ) %>%
  group_by(STATE) %>% 
  summarize(n_INJ = sum(INJURIES)) %>%
  
  ggplot(aes(area = n_INJ, fill = STATE, label = paste(STATE, n_INJ, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(colour = "black",
                    place = "centre",
                    size = 8,
                    grow = TRUE) +
  theme(legend.position="none") +
  labs(title = "Proportion of property damage caused by Hurricanes and Typhoones") -> two_p2


grid.arrange(two_p1, two_p2, ncol=2, nrow=1, widths=c(4, 2) )
 