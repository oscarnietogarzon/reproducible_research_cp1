#Explore the data
library(tidyverse)
summary(df)

str(df)

## Transform dates into an appropriate format
df$date <- lubridate::ymd(df$date)

## Histogram of steps
df %>% group_by(date) %>%
  summarise(total_steps = sum(steps, na.rm = TRUE)) %>%
  
  ggplot(aes(x=total_steps)) +
  geom_histogram(color="black", fill="white", binwidth = 1000) +
  labs(title="Total number of steps taken each day") +
  theme_classic()

## Statistics number of steps taken each day
df %>% group_by(date) %>%
  summarise(total_steps = sum(steps, na.rm = TRUE) ) %>% ungroup() %>%
    summarise(
             mean = mean(total_steps, na.rm = TRUE),
             median = median(total_steps, na.rm = TRUE)
    )

## Time series plot
df %>% group_by(date) %>%
  summarise(total_steps = mean(steps, na.rm = TRUE) ) %>% 
  
  ggplot(aes(y=total_steps, x=date)) +
  geom_line() +
  labs(title="Average number of steps taken") +
  theme_classic()

## Interval with the maximum number of steps
df %>% group_by(interval) %>%
  summarise(int_steps = mean(steps, na.rm = TRUE) ) %>%
  arrange(desc(int_steps)) %>%
  head(1)

## Imputing missing data
## Since we have many values per 5-minute interval, we can use the mean or the median of the measures
## values to imputing the missing values on the same interval

df %>%
  group_by(interval) %>%
  mutate(steps = replace_na(steps,  median(steps, na.rm = TRUE) ) ) -> df_im

## Histogram of steps imputed
df_im %>% group_by(date) %>%
  summarise(total_steps = sum(steps, na.rm = TRUE)) %>%
  
  ggplot(aes(x=total_steps)) +
  geom_histogram(color="black", fill="white", binwidth = 1000) +
  labs(title="Total number of steps taken each day") +
  theme_classic()

## Panel plot Weekdays vs. Weekends
df_im %>% mutate(wday = lubridate::wday(date, label=TRUE),
                 dow = ifelse(wday %in% c("Sat", "Sun"), "Weekends", "Weekdays")  ) %>%
  group_by(interval, dow) %>%
  summarise(int_steps = mean(steps, na.rm = TRUE) ) %>%
  
  ggplot(aes(y = int_steps)) +
  geom_boxplot(varwidth = TRUE, outlier.colour = "red", outlier.shape = 1) +
  facet_grid(cols = vars(dow))  +
  labs(title="Total number of steps taken each day") +
  theme_classic()
  

