# 🛒 Retail Sales Dashboard

**Tech Stack:** MySQL · Power BI · Python · pandas

An end-to-end data analytics project simulating a fictional retail business — from database design to interactive BI dashboard.

---

## 📁 Project Structure

```
retail-sales-dashboard/
├── sql/
│   ├── 01_schema.sql           # DB schema (tables + view)
│   └── 02_analysis_queries.sql # 17 analysis queries
├── python/
│   └── retail_data_generator.py # Fake data generator
├── powerbi_guide/
│   └── powerbi_setup.md        # DAX measures + page layout guide
└── README.md
```

---

## 🗄️ Database Schema

5 relational tables designed for a retail store:

| Table | Description |
|---|---|
| `customers` | 500 customers across 4 regions of India |
| `products` | 100 products across 10 categories |
| `categories` | Product category & department |
| `orders` | 3,000 order headers (2022–2024) |
| `order_items` | Line-level order detail |
| `returns` | Returned items with reasons |

Plus `vw_sales_fact` — a flat view joining all tables (used in Power BI).

---

## ⚙️ Setup Instructions

### Step 1 — Create the Database
```sql
-- Run in MySQL Workbench
source sql/01_schema.sql
```

### Step 2 — Load Sample Data
```bash
pip install pandas faker mysql-connector-python sqlalchemy
# Edit DB_PASSWORD in the script, then:
python python/retail_data_generator.py
```

### Step 3 — Run Analysis Queries
```sql
-- Explore insights in MySQL Workbench
source sql/02_analysis_queries.sql
```

### Step 4 — Connect Power BI
Follow `powerbi_guide/powerbi_setup.md` to:
- Connect MySQL → Power BI
- Create DAX measures
- Build 5-page dashboard

---

## 📊 Dashboard Pages

| Page | Visuals |
|---|---|
| 1. Executive Summary | KPI cards, monthly trend, category donut, top products |
| 2. Regional Analysis | Map, region bar chart, state drillthrough |
| 3. Product Deep Dive | Category matrix, scatter (margin vs AOV), waterfall |
| 4. Returns & Ops | Return rate KPI, returns by category, ship mode |
| 5. Customer Insights | Top customers table, payment mode, segmentation |

---

## 💡 Key Insights

- **3 product categories** (Electronics, Clothing, Furniture) contribute **68% of total revenue**
- **South region** leads in revenue; **East** has the highest return rate
- **UPI** is the most popular payment method (~35% of orders)
- **Q4** consistently shows peak sales (Oct–Dec)
- Customers with **5+ orders** generate 3× the average lifetime value

---

## 🛠️ Skills Demonstrated

- Relational database design (normalization, FK constraints)
- SQL aggregations, window functions, CTEs
- Python data generation with pandas & Faker
- Power BI data modeling (star schema, DAX)
- Time intelligence measures (YTD, YoY, MTD)
- Dashboard UX (slicers, drill-through, tooltips, conditional formatting)
