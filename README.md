# Google Capstone Project: Bellabeat
Author: Emily Hampton  
Date: 2024-06-01

**Overview**  
This case study is part of Google's Data Analytics Certificate capstone project.

The project is based around Bellabeat, a manufacturer of health-focused products for women. The company hopes to expand into the smart device market, they want gain marketing insights based on Fitbit user data.

I will be following the ask, prepare, process, analyze, share, and act data analysis cycle outlined in the course. SQL and Tableau will be used to process, analyze and create visualizations.
## Highlights
📊 [**Tableau Public**](https://public.tableau.com/views/BellabeatCapstoneProject_17167013509350/Story1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link): visualizations and presentation deck

🗂️ [**GitHub Repo**](https://github.com/emixmh/bellabeat-google-casestudy): case study report, code, etc.
## Table of Contents
1. [Ask](#ask)
2. [Prepare](#prepare)
3. [Process](#process)
4. [Analyze](#analyze)
5. [Share](#share)
6. [Act](#act)
---
##  1| ASK <a name="ask"></a>

About Bellabeat  
Bellabeat is a high-tech company that manufactures health-focused smart products. Founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women. They focus on developing beautifully designed technology that collects data on activity, sleep, stress, and reproductive health. This information empowers women with knowledge about their own health and habits.

Bellabeat products are available with online retailers and e-commerce via their own website. 

The company has invested in traditional advertising media, but focuses on digital marketing extensively. 

Their digital marketing includes:
- year-round investing in Google Search
- active engagement on socials (Facebook, Instagram, Twitter)
- video ads (Youtube) and display ads (Google Display Network) as campaign support around key marketing dates

Stakeholders
- Urška Sršen: cofounder and Chief Creative Officer
- Sando Mur: cofounder and mathematician
- Bellabeat marketing analytics team

Products
- Bellabeat app: connects to all Bellabeat products and provides users with health data related to their activity, sleep, stress, menstrual cycle, and mindfulness habits
- Leaf: wellness tracker for activity, sleep, and stress that can be worn as a bracelet, necklace, or clip
- Time: wellness watch that doubles as a timepiece and tracker for activity, sleep, and stress
- Spring: water bottle that tracks daily water intake and your hydration levels via the app
- Bellabeat membership: subscription-based membership program that gives users 24/7 access to fully personalized guidance on nutrition, activity, sleep, health and beauty, and mindfulness based on their lifestyle and goals

**📍 Business Task**  
- Analyze non-Bellabeat smart device usage data to gain insight into consumer use
- Apply insights to one of Bellabeat's products which will guide marketing strategies

Guiding Questions
1. What are some trends in smart device usage?  
2. How could these trends apply to Bellabeat customers?
3. How could these trends help influence Bellabeat's marketing strategy?
## 2| PREPARE <a name="prepare"></a>

Dataset: [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) via [Mobius](https://www.kaggle.com/arashnic) on Kaggle  
Version: Version 2 (updated 2024-03-02 by Mobius)  
License: CC0 Public Domain

Date Range: 2016-03-12 to 2016-05-12 (grouped by 03-12 to 04-11 and 04-12 to 05-12)  
Data Collection: survey via Amazon Mechanical Turk  
Sample Size: 30 Fitbit users who consented to submission of their personal tracker data  
Data: minute-level output for physical activity, heart rate, and sleep monitoring

Data Limitations
- From the extracted 31 CSV files representing 18 datasets, only 11 encompassed the entire date range while the other 7 spanned only half of the date range.
- Date range of data spans 2 months during 2016, which at this time is relatively outdated. A longer time span would have also been preferred.
- Sample size is said to be 30 users which is the minimum usually required to accurately represent the population. turns out 35 unique users.
- Users' privacy is kept by referring to them by ID. However there is no additional demographic data that determines gender, age, location etc. It is undetermined if the sample size is representative of the population. Furthermore, Bellabeat produces products specifically for women, the lack of demographic information impacts the relevancy of any insights found.
- Product data also is not present. We don't know which Fitbit products and models collected and tracked the available data.

Supplementary Material: [Fitbase Data Dictionary](https://www.fitabase.com/resources/knowledge-base/exporting-data/data-dictionaries/) latest available PDF 2024-04-05
## 3| PROCESS <a name="process"></a>
Tools: PostgreSQL, Tableau

Datasets Selected (8)
- minuteSleep_merged.csv
- minuteMETsNarrow_merged.csv
- minuteIntensitiesNarrow_merged.csv
- minuteCaloriesNarrow_merged.csv
- minuteStepsNarrow_merged.csv
- heartrate_seconds_merged.csv
- dailyActivity_merged.csv
- weightLogInfo_merged.csv

These datasets were selected because they encompassed the entire date range and contains metrics that are relevant to the business task without being redundant.

Verified
- count of unique IDs
- date range and total number of unique dates
- all values fell within reasonable range for their field
- any null data
- removal of duplicate records

Weight, sleep, and heart rate data were disqualified due to samples sizes having less than 30 total participants.

Sleep: 25 participants
Heart Rate: 15 participants
Weight: 8 participants

Across all datasets there were 35 unique participants.  
However, only 33 will be considered during analysis. Participant 2891001357 and 6391747486 were removed due data inconsistency and data absence.

All datasets were added to the database as their own table. Tables with date-time information was merged into a new combined table for analysis. Tables that had integers representing qualitative data was updated based on the data dictionary e.g.  sleep values with "1" were updated to "asleep."

All code is in the [SQL file](https://github.com/emixmh/bellabeat-google-casestudy/blob/main/20240601.sql).
## 4| ANALYZE <a name="analyze"></a>
Insights
- activity remains relatively constant between weekdays
- active users have a higher step count and spend more time in elevated intensities and MET scores than sedentary users, although the impact on calories burned is extremely minimal
- active users have a higher chance of tracking more metrics (e.g. sleep, weight, heart rate) compared to sedentary users
## SHARE <a name="share"></a>
Presentation deck can be found on [Tableau Public](https://public.tableau.com/views/BellabeatCapstoneProject_17167013509350/Story1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link).
## ACT <a name="act"></a>
### Recommendations
The marketing team can apply these insights by promoting features on the Bellabeat app. Beallabeat's Leaf and Time track similar activity to the Fitbit data. Leaf and Time do not have screens allowing users to view data or change setting directly through the smart device.

Encouraging users to use the Bellabeat app allows them to fully explore the capabilities of Bellabeat products and make the most out of their data. For example, notifications and pop-ups can be utilized to remind and encourage users to increase their activity or input manually tracked data.
### Further Analysis
Further analysis should be done to get more accurate insights. 

When selecting and gathering data for future analysis the limitations of the data from this report should be kept in mind so the gaps can be filled.

Bellabeat can look for other datasets from Fitbit and other smart device companies within the fitness and wellness industry. They can also survey their own client base to see how they already use Bellabeat products and what features current users are interested in adding.
