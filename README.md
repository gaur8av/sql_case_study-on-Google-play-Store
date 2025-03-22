# 📱 Google Play Store Data Analysis with SQL

This project is a deep-dive SQL-based analysis of Google Play Store data aimed at uncovering insights to help app developers, product strategists, and market analysts make data-driven decisions. The dataset was cleaned and analyzed using SQL, and this repository showcases key business queries and results derived from the data.

---

## 📦 Dataset

- **Source**: Google Play Store dataset (provided as `playstore.csv`)
- **Size**: ~10K+ apps with features such as category, price, rating, installs, reviews, and more.

---

## 🧹 Data Cleaning

Before performing any analysis, data cleaning was done to ensure accuracy and reliability:

- Converted price and install columns into numeric format.
- Removed duplicates and null entries.
- Cleaned `Genres` column to handle multiple genres (split into two columns).
- Standardized column values (e.g., removing "$" from price, "+" and "," from install counts).
- Removed inconsistent or malformed entries.

---

## 🔍 Project Objectives

The following business questions were tackled using SQL:

1. **Top 5 Categories for Launching Free Apps**  
   Based on average ratings, identify the most promising categories to launch new free apps.

2. **Top 3 Revenue-Generating Categories (Paid Apps)**  
   Calculated using: `App Price × Number of Installs`.

3. **Category-Wise App Distribution (%)**  
   Understand how apps are distributed across different categories.

4. **Free vs Paid App Recommendation (By Category)**  
   Recommend whether free or paid apps perform better in each category based on average rating.

5. **Track Price Changes due to Security Breach**  
   A trigger mechanism was designed to **log all price changes** due to unauthorized access.

6. **Restore Correct Prices After Hack**  
   Used logged data to **revert price changes** once the breach was contained.

7. **Correlation Between Ratings and Reviews**  
   Studied the relationship between user ratings and number of reviews using statistical SQL functions.

8. **Cleaning the `Genres` Column**  
   Split multi-genre rows into two columns (`Genre_1`, `Genre_2`) for better analysis.

9. **Dynamic Feedback Tool for Underperforming Apps**  
   A **parameterized query** to find apps with ratings below the average within a given category.

10. **Conceptual Discussion: "Duration Time" vs "Fetch Time"**  
   Explained the key difference between data fetch time and duration time from a database performance standpoint.

---

## 🛠️ Tools Used

- **SQL** (PostgreSQL / MySQL compatible)
- **DBMS Triggers**
- **Data Preprocessing** (Python for CSV cleaning, if needed)
- **Google Sheets / Excel** (initial data inspection)

---

## 📂 Files in the Repository

| File Name | Description |
|-----------|-------------|
| `playstore.csv` | Raw dataset containing app data |
| `task_solution.sql` | All SQL queries and triggers used in the analysis |
| `Questions.docx` | Business problems and tasks defined for the project |
| `README.md` | You’re reading it! 😄 |

---

## 📈 Key Insights

- Free apps in categories like **Education**, **Health & Fitness**, and **Productivity** tend to receive higher ratings.
- Categories like **Tools**, **Business**, and **Lifestyle** generate the most revenue through paid apps.
- A clear positive correlation was found between **number of reviews** and **ratings**.
- Splitting `Genres` improved accuracy for downstream tasks like building recommendation systems.

---

## 🤝 Let's Connect!

If you liked this project or have feedback, feel free to connect:

- 💼 [LinkedIn](https://www.linkedin.com/)
- 🐙 [GitHub](https://github.com/yourusername)

---

⭐ Star this repository if you found it helpful!

