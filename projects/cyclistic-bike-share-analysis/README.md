# 🚲 Cyclistic Bike-Share Analysis

**Author:** Joaquín Pino Suarez  
**Date:** August 10, 2025 

---

## 📘 Project Overview
This **Capstone Project** was developed as part of the *Google Data Analytics Professional Certificate*.  
The goal is to analyze user behavior in the **Cyclistic bike-share program** in Chicago to identify **differences between annual members and casual riders**.  
These insights will help guide **data-driven marketing strategies** focused on converting casual users into annual members.

---

## 🎯 Business Objective
Cyclistic aims to **increase the number of annual memberships**, which generate more stable and profitable revenue than casual rides.

**Key Question:**  
> How do annual members and casual riders use Cyclistic bikes differently?

Understanding these behavioral patterns allows the marketing team to design targeted campaigns and retention strategies.

---

## 🧹 Data Preparation
- **Source:** Public data from [Divvy Bikes](https://divvybikes.com/system-data), licensed by Motivate International Inc.  
- **Time Frame:** January 2024 – June 2025 (18 months)  
- **Tools Used:**  
  - **SQL Server** → Data cleaning, validation, integration  
  - **R** → Data transformation, analysis, visualization (`tidyverse`, `lubridate`, `ggplot2`)  
- **Main Cleaning Steps:**  
  - Removed duplicates and invalid records  
  - Filtered negative or null durations  
  - Created new variables: `ride_length`, `day_of_week`, `start_hour`, `season`, `month_year`  
  - Standardized formats and ensured consistent data integrity  

---

## 🧠 Data Processing
- Combined **8,001,993 records** from 18 monthly CSV files  
- Created an SQL view `viajes_analisis` for analysis  
- Connected RStudio directly to the SQL Server database  

---

## 📊 Analysis Summary
Key analytical areas explored:
- Total rides and share by user type  
- Ride duration (mean, median, max)  
- Usage patterns by day, hour, month, and season  
- Bike type preferences  
- Weekday vs weekend behavior  

### Main Findings
- Casual riders take **longer rides** on average (25.1 min) than members (12.6 min)  
- Members show strong **weekday commuting patterns**, while casuals ride more on **weekends**  
- Both groups favor **electric bikes**, though members use classic bikes more frequently  
- Usage peaks during **summer months**, especially among casual users  

---

## 📈 Visualizations
- **Ride Duration Distribution:** Histogram comparing trip lengths by user type  
- **Usage by Time and Day:** Line and bar charts highlighting differences in daily and hourly patterns  
- **Seasonality and Month Trends:** Clear peaks in warmer months  
- **Bike Type Preference:** Comparison across rideable types  
- **Weekday vs Weekend Behavior:** Contrast between leisure and commuter usage  

*(Visualizations created in R using ggplot2)*

---

## 💡 Recommendations
1. **Seasonal Promotions:** Offer discounts and incentives during high-demand months (spring/summer).  
2. **Membership Value Messaging:** Highlight benefits like cost savings and convenience for frequent riders.  
3. **Weekend Campaigns:** Target casual users with promotional offers and encourage subscription upgrades.  
4. **Behavior-Based Retargeting:** Use ride history data to create personalized marketing messages.  

---

## 🧩 Conclusion
This analysis demonstrates clear behavioral distinctions between **casual** and **member** riders.  
By leveraging these insights, Cyclistic can design targeted, data-backed strategies to **increase conversions and strengthen customer retention**.

---

## 📁 Repository Includes
- SQL scripts for data cleaning and integration  
- R script (`cyclistic_analysis.R`) with code and visualizations  
- R Markdown report (`cyclistic_case_study.Rmd`)   

---

*This project was created as part of the **Google Data Analytics Professional Certificate**.*  
