# 🚢 Titanic Survival Analysis — A Data Story in SQL

## 🧭 Executive Summary

The sinking of the Titanic was not a random survival event.

This analysis reveals that survival was primarily determined by a combination of **social hierarchy, gender, age, and access**, rather than chance alone.

Using SQL-based exploratory data analysis, we uncover how structural inequality shaped survival outcomes in one of history’s most studied disasters.

---

## 🎯 Business / Analytical Objective

The objective of this project is to identify which passenger attributes most strongly influenced survival probability.

We explore:

- Who was most likely to survive?
- Which socioeconomic groups were prioritized?
- How did age, gender, and class interact?
- Did wealth guarantee survival?

---

## 📊 Dataset Overview

The dataset contains passenger-level information from the Titanic disaster:

- Demographics (gender, age)
- Socioeconomic indicators (ticket class, fare)
- Family structure
- Cabin location
- Embarkation port
- Survival outcome

---

# 🧠 Data Story: What the Data Reveals

## 1. ⚖️ Survival Was Strongly Driven by Social Rules

The data clearly reflects the historical “Women and Children First” policy.

- Women had a survival rate of ~74%
- Men had a survival rate of ~19%

👉 Gender was the single strongest determinant of survival.

This suggests survival priority was socially enforced rather than random.

<br><br>

![gender factor](/images/1.png)

<br><br>
---

## 2. 🏛️ Class Structure Directly Influenced Survival Access

Passenger class acted as a proxy for access to lifeboats and location on the ship.

- First Class: highest survival rates (~60%+)
- Second Class: moderate survival
- Third Class: lowest survival (~20–25%)

👉 Higher social class increased physical proximity to evacuation routes.

---

## 3. 👶 Age Effects Were Conditional, Not Absolute

Age alone did not determine survival — it interacted with gender and class.

- Children had better survival outcomes overall
- Elderly male passengers had the lowest survival probability
- Age advantage disappeared for lower-class passengers

👉 Age only helped when combined with social priority (women/upper class).

---

## 4. 💰 Wealth Improved Survival — But Did Not Guarantee It

Higher ticket fares were associated with better survival rates.

However:

- Wealthy men still died in significant numbers
- Low-fare women often survived at higher rates than high-fare men

👉 Wealth increased opportunity, but gender determined priority.

---

## 5. 👨‍👩‍👧 Family Size Showed a Non-Linear Pattern

Survival probability varied with family size:

- Solo travelers had lower survival rates
- Small to medium families performed better
- Very large families had the lowest survival outcomes

👉 Moderate family size may have improved coordination during evacuation.

---

## 6. 🛏️ Cabin Location Influenced Survival Probability

Passengers with known cabin information generally survived more often.

- Upper decks had better survival outcomes
- Missing cabin data strongly correlated with low survival

👉 Physical location on the ship influenced evacuation speed and access.

---

## 7. ⚓ Embarkation Port Reflects Socioeconomic Segregation

Different boarding ports reflected different passenger profiles:

- Southampton: majority of passengers (mixed classes)
- Cherbourg: wealthier passengers, higher fares
- Queenstown: mostly third-class passengers

👉 Embarkation point indirectly reflects economic status.

---

# 📌 Key Takeaways (Core Insights)

- Survival was primarily driven by **gender and class hierarchy**
- Socioeconomic status improved survival probability but was not decisive alone
- Physical location (cabin/deck) influenced evacuation access
- Age effects were conditional and interacted with other variables
- Family structure influenced survival in a non-linear way

---

# 🧩 Final Analytical Conclusion

Survival on the Titanic was shaped by structured social prioritization rather than randomness.

The strongest survival determinants were:

1. Gender (primary factor)
2. Passenger class (access factor)
3. Age (secondary factor)
4. Wealth (supporting factor)
5. Physical location (structural factor)
6. Family structure (behavioral factor)

---

# 🛠️ Analytical Methods Used

- Data cleaning using CASE logic
- Feature engineering (age groups, family size, fare bands)
- Window functions for comparative analysis
- Percentile-based segmentation (PERCENTILE_CONT)
- Grouped survival rate analysis
- Multi-dimensional EDA (gender × class × age)

---

# 📈 What This Project Demonstrates

This project demonstrates:

- Strong SQL data wrangling skills
- Ability to perform structured exploratory analysis
- Understanding of statistical grouping and segmentation
- Analytical thinking beyond raw querying
- Business-style interpretation of data patterns

---

# 🧠 What Makes This Analysis Different

Instead of only answering *what happened*, this project focuses on:

- Why patterns appear in the data
- How multiple factors interact
- What structural systems influenced outcomes

This transforms raw SQL output into a **data-driven narrative of historical behavior**.
