# Olist-E-Commerce-Sales-Operations-Analysis

# 🧾 Project Overview

This project delivers an end-to-end business intelligence solution for Olist, the largest Brazilian marketplace. The analysis transforms a complex relational database of 100,000 orders into actionable insights regarding logistics performance, customer satisfaction, and payment behavior.

The workflow integrates SQL/PostgreSQL for heavy-duty data transformation and Power BI for executive dashboarding to identify bottlenecks in the supply chain and revenue growth.

# 🎯 Business Objective

E-commerce platforms must balance delivery speed with customer satisfaction to retain sellers and buyers.
The goal of this project is to:

* Analyze Logistics Performance (Estimated vs. Actual delivery dates).

* Segment sales by Product Category and Geography (Brazilian States).

* Evaluate the impact of Payment Methods on Average Order Value (AOV).

# 🛠️ Tools & Technologies

* PostgreSQL → Data ingestion, relational mapping, and complex ETL across 5 tables.

* Power BI → Data modeling, DAX measures, and interactive geospatial visualization.

* Excel → Initial data inspection and schema validation.

# 📂 Dataset Description
The project utilizes the Olist Brazilian E-Commerce Dataset, consisting of 5 interconnected tables:

* Orders & Items → Core transaction data.

* Customers → Geographic and demographic data.

* Products & Category Translation → Catalog details (Portuguese to English).

* Payments  → Financial and sentiment data.

# 🔄 Project Workflow (Step-by-Step)

# 1️⃣ Data Loading into PostgreSQL

Tasks performed:
* Created a relational schema in PostgreSQL to host 5 disparate CSV datasets.

* Used the COPY command for high-speed data ingestion of 100k+ rows.

* Standardized date/time columns to TIMESTAMP formats for accurate lead-time calculations.


# 2️⃣ ETL & Feature Engineering (SQL)

Built a multi-layer SQL workflow to prepare data for Power BI:

* Mapping: Joined product translations to convert Portuguese categories to English.

* Delivery Metrics: Calculated shipping_days (Actual vs. Estimated) using SQL date functions.

* Customer Aggregation: Created views to calculate Total Spend and Order Frequency per customer.

* Geographic Grouping: Consolidated revenue and order volume by Brazilian state codes.


# 3️⃣ Data Modeling in Power BI

Steps:

* Imported the cleaned SQL views into Power BI via DirectQuery/Import.

* Established a Star Schema to connect facts (Orders/Payments) with dimensions (Customers/Products).

* Created DAX Measures for:
  * Total Revenue
  * Average Delivery Delay
  * % of Late Deliveries


# 4️⃣ Dashboard Development

Built a 3-Page Interactive Dashboard:


* 📈 Page 1 — Sales & Revenue Overview

  * Total Revenue, Total Orders, and AOV (Average Order Value) KPIs.

  * Sales Trend Over Time (Monthly/Quarterly).

  * Top 10 Product Categories by Revenue.

* 🚚 Page 2 — Logistics & Shipping Performance

  * Average Delivery Time by State.

  * Late Delivery Rate: Percentage of orders delivered after the estimated date.

  * Correlation analysis: Impact of shipping delays on Customer Review Scores.

* 💳 Page 3 — Payment & Customer Insights

  * Payment Method distribution (Boleto, Credit Card, Voucher).

  * Influence of installments on high-ticket purchases.

  * Geospatial Map showing Customer Density across Brazil.


# 🎛️ Interactive Features

* State-level Slicers: Filter the entire dashboard by Brazilian State.

* Dynamic Time Slicers: Ability to view data by Year, Quarter, or Month.

* Visual Tooltips: Hover over states to see specific delivery performance metrics.


# 📊 Key Insights from Analysis

* The "3-Day" Rule: Orders delivered more than 3 days after the estimate see a 60% drop in 5-star ratings.

* Regional Dominance: São Paulo (SP) accounts for over 35% of total sales, suggesting a need for localized logistics hubs.

* Payment Strategy: Credit cards drive the highest AOV, especially when offering 5+ installment options for Electronics.


👤 Author

Yogesh Kumar Pal

Data Analyst | SQL | Power BI
