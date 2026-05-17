# Titanic Survival Analysis — A Data Story in SQL

---

# 📌 Table of Contents

- [Executive Summary](#executive-summary)
- [Business / Analytical Objective](#business--analytical-objective)
- [Dataset Overview](#dataset-overview)
- [Data Story](#data-story)
  - [Survival Driven by Social Rules](#survival-driven-by-social-rules)
  - [Class Structure Influenced Survival Access](#class-structure-influenced-survival-access)
  - [Age Effects Were Conditional](#age-effects-were-conditional)
  - [Wealth Improved Survival but Did Not Guarantee It](#wealth-improved-survival-but-did-not-guarantee-it)
  - [Family Size Showed Non Linear Pattern](#family-size-showed-non-linear-pattern)
  - [Cabin Location Influenced Survival](#cabin-location-influenced-survival)
  - [Embarkation Port and Socioeconomic Segregation](#embarkation-port-and-socioeconomic-segregation)
- [Key Takeaways](#key-takeaways)
- [Final Analytical Conclusion](#final-analytical-conclusion)
- [Analytical Methods Used](#analytical-methods-used)
- [Project Learnings](#project-learnings)

---

## Executive Summary

The sinking of the Titanic was not a random survival event.

This analysis shows that survival was strongly influenced by **social hierarchy, gender, age, and access**, rather than chance alone.

Using SQL-based exploratory data analysis, we uncover how structural inequality shaped survival outcomes.

---

## Business / Analytical Objective

The objective of this project is to identify which passenger attributes most strongly influenced survival probability.

We explore:

- Who was most likely to survive
- Which socioeconomic groups were prioritized
- How age, gender, and class interacted
- Whether wealth guaranteed survival

---

## Dataset Overview

The dataset contains passenger-level information from the Titanic disaster:

- Demographics (gender, age)
- Socioeconomic indicators (ticket class, fare)
- Family structure
- Cabin information
- Embarkation port
- Survival outcome

---

# Data Story

## Survival Driven by Social Rules

The data reflects structured evacuation priorities such as “Women and Children First”.

- Women had significantly higher survival rates than men
- Gender was the strongest determinant of survival

---

## Class Structure Influenced Survival Access

Passenger class strongly influenced survival probability.

- First Class: highest survival rates
- Second Class: moderate survival rates
- Third Class: lowest survival rates

---

## Age Effects Were Conditional

Age alone did not determine survival outcomes.

- Children generally had higher survival rates
- Elderly male passengers had the lowest survival probability
- Age effects depended on gender and class

---

## Wealth Improved Survival but Did Not Guarantee It

Higher fares were associated with better survival outcomes.

However:

- Wealthy men still died in significant numbers
- Low-fare women often survived at higher rates than high-fare men

---

## Family Size Showed Non Linear Pattern

Survival probability varied with family size:

- Solo travelers had lower survival rates
- Small to medium families performed better
- Very large families had the lowest survival outcomes

---

## Cabin Location Influenced Survival

Passengers with known cabin information had better survival outcomes.

- Upper deck passengers had higher survival rates
- Missing cabin data was associated with lower survival

---

## Embarkation Port and Socioeconomic Segregation

Boarding ports reflected passenger socioeconomic distribution:

- Southampton: mixed class passengers
- Cherbourg: wealthier passengers
- Queenstown: mostly third class passengers

---

# Key Takeaways

- Survival was primarily driven by gender and class
- Socioeconomic status improved survival probability
- Physical location influenced evacuation success
- Age effects were conditional
- Family structure influenced survival in non linear ways

---

# Final Analytical Conclusion

Survival on the Titanic was shaped by structured social prioritization rather than randomness.

Key determinants:

1. Gender
2. Passenger class
3. Age
4. Wealth
5. Physical location
6. Family structure

---

# Analytical Methods Used

- Data cleaning using CASE logic
- Feature engineering (age groups, family size, fare bands)
- Window functions
- Percentile-based segmentation (PERCENTILE_CONT)
- Grouped survival analysis
- Multi-dimensional EDA

---

# Project Learnings

This project demonstrates:

- Strong SQL data manipulation skills
- Ability to perform structured exploratory analysis
- Understanding of grouped statistical reasoning
- Ability to convert data into business insights
- Analytical storytelling using SQL outputs
