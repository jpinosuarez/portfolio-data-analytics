# ============================================================
# CYCLISTIC BIKE-SHARE ANALYSIS
# Author: Joaquín Pino Suárez
# Purpose: Analyze usage differences between annual members 
#          and casual riders for Cyclistic (Google DA Capstone)
# ============================================================


# --- LOAD LIBRARIES AND CONNECT TO DATABASE -----------------

# Uncomment this line if running for the first time
# install.packages("odbc")

library(DBI)
library(odbc)
library(tidyverse)
library(skimr)
library(scales)
library(lubridate)
library(forcats)

# Connect to SQL Server
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "localhost\\SQLEXPRESS02",
                 Database = "Cyclistic",
                 Trusted_Connection = "Yes")

# Load cleaned dataset from SQL view
datos <- dbGetQuery(con, "SELECT * FROM viajes_analisis")


# --- INITIAL EXPLORATION -----------------------------------

# Quick overview of the dataset
skim(datos)
summary(datos)

# Total number of rides
total_viajes <- nrow(datos)


# --- GENERAL METRICS BY USER TYPE ---------------------------

datos %>%
  group_by(member_casual) %>%
  summarise(
    total_rides = n(),
    percentage = round(100 * total_rides / total_viajes, 1),
    avg_duration = round(mean(ride_length), 1),
    median_duration = round(median(ride_length), 1)
  ) %>%
  mutate(
    total_rides = comma(total_rides, big.mark = ".", decimal.mark = ","),
    percentage = paste0(percentage, "%")
  )


# --- BIKE TYPE FREQUENCY BY USER ----------------------------

totales_usuario <- datos %>%
  group_by(member_casual) %>%
  summarise(total = n())

datos %>%
  group_by(rideable_type, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  left_join(totales_usuario, by = "member_casual") %>%
  mutate(
    percentage = round(100 * rides / total, 1),
    rides = comma(rides, big.mark = ".", decimal.mark = ","),
    percentage = paste0(percentage, "%")
  ) %>%
  select(-total) %>%
  pivot_wider(
    names_from = member_casual,
    values_from = c(rides, percentage),
    names_sep = "_"
  )


# --- WEEKDAY CROSS TABLE ------------------------------------

datos <- datos %>%
  mutate(day_of_week = factor(day_of_week,
                              levels = c("Monday", "Tuesday", "Wednesday", 
                                         "Thursday", "Friday", "Saturday", "Sunday")))

datos %>%
  group_by(member_casual, day_of_week) %>%
  summarise(rides = n(), .groups = "drop") %>%
  pivot_wider(names_from = day_of_week, values_from = rides, values_fill = 0) %>%
  mutate(across(where(is.numeric), ~ comma(.x, big.mark = ".", decimal.mark = ",")))


# --- VISUALIZATIONS -----------------------------------------

# 1. Ride Duration Distribution (Histogram)
limit <- quantile(datos$ride_length, 0.99, na.rm = TRUE)

ggplot(datos %>% filter(ride_length <= limit), 
       aes(x = ride_length, fill = member_casual)) +
  geom_histogram(bins = 60, position = "identity", alpha = 0.5) +
  facet_wrap(~member_casual) +
  scale_x_continuous(labels = comma, limits = c(0, limit)) +
  scale_y_continuous(labels = comma) +
  labs(title = "Distribution of Ride Duration by User Type",
       x = "Duration (minutes)", y = "Number of Rides") +
  theme_minimal()


# 2. Boxplot: Comparing Ride Duration
ggplot(datos, aes(x = member_casual, y = ride_length, fill = member_casual)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(ylim = c(0, 30)) +
  scale_y_continuous(labels = comma) +
  labs(title = "Ride Duration Comparison", y = "Duration (minutes)") +
  theme_minimal()


# 3. Rides by Hour of the Day
datos %>%
  group_by(start_hour, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  ggplot(aes(x = start_hour, y = rides, color = member_casual)) +
  geom_line(size = 1.2) +
  scale_y_continuous(labels = comma) +
  labs(title = "Rides by Hour of the Day", x = "Hour", y = "Number of Rides") +
  theme_minimal()


# 4. Rides by Day of the Week
datos %>%
  group_by(day_of_week, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  ggplot(aes(x = day_of_week, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Rides by Day of the Week", x = "Day", y = "Number of Rides") +
  theme_minimal()


# 5. Rides by Season
datos <- datos %>%
  mutate(season = factor(season, levels = c("Winter", "Spring", "Summer", "Fall")))

datos %>%
  group_by(season, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  ggplot(aes(x = season, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Rides by Season", x = "Season", y = "Number of Rides") +
  theme_minimal()


# 6. Rides by Month-Year
datos <- datos %>%
  mutate(mes_ano = format(started_at, "%b %Y")) %>%
  mutate(mes_ano = factor(mes_ano, levels = unique(format(started_at, "%b %Y"))))

datos %>%
  group_by(mes_ano, member_casual) %>%
  summarise(rides = n()) %>%
  ggplot(aes(x = mes_ano, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Rides by Month and Year", x = "Month-Year", y = "Number of Rides") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))


# 7. Weekday vs Weekend
datos %>%
  mutate(day_type = ifelse(day_of_week %in% c("Saturday", "Sunday"), 
                           "Weekend", "Weekday")) %>%
  group_by(day_type, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  ggplot(aes(x = day_type, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Weekday vs Weekend Rides", x = "Day Type", y = "Number of Rides") +
  theme_minimal()


# --- BIKE TYPE COMPARISON CHARTS ----------------------------

# Table: bike type by user
tabla <- datos %>%
  group_by(rideable_type, member_casual) %>%
  summarise(rides = n(), .groups = "drop") %>%
  left_join(totales_usuario, by = "member_casual") %>%
  mutate(
    percentage = round(100 * rides / total, 1),
    label = paste0(percentage, "%")
  )

# 8. Total Rides by Bike Type and User
ggplot(tabla, aes(x = rideable_type, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = label), position = position_dodge(width = 0.45), 
            vjust = -0.5, size = 4) +
  scale_y_continuous(labels = comma_format(big.mark = ".", decimal.mark = ",")) +
  labs(title = "Rides by Bike Type and User Type",
       x = "Bike Type", y = "Number of Rides", fill = "User Type") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )

# 9. Percentage Distribution of Bike Usage
ggplot(tabla, aes(x = member_casual, y = percentage, fill = rideable_type)) +
  geom_col(position = "fill") +
  geom_text(aes(label = label), position = position_fill(vjust = 0.5), size = 4) +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "Bike Usage Distribution by User Type",
       x = "User Type", y = "Percentage of Rides", fill = "Bike Type") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.position = "top"
  ) +
  scale_fill_brewer(palette = "Set2")

# ============================================================
# END OF SCRIPT
# ============================================================
