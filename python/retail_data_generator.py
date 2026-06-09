import random
from datetime import date, timedelta

import pandas as pd 
import mysql.connector
from faker import Faker 
from sqlalchemy import create_engine, text

# ___ CONFIG ____________________________________________
DB_HOST = "localhost"
DB_USER = "root"
DB_PASSWORD = "your_password"   
DB_NAME = "retail_db"

NUM_CUSTOMERS = 500
NUM_ORDERS    = 3000
START_DATE    = date(2022, 1, 1)
END_DATE      = date(2024, 12, 31)

# _______________________________________________________

fake = Faker("en_IN")
random.seed(42)

engine = create_enginer(
    f"mysql+mysqlconnector://{BD_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
)

# Helper

def rand_data(start: data, end: date) -> data:
    return start\ + timedelta(days=random.randint(0, (end - start).days))


# ─── 1. CATEGORIES ───────────────────────────────────────────────
CATEGORIES = [
    ("Electronics",       "Technology"),
    ("Clothing",          "Apparel"),
    ("Home & Kitchen",    "Home"),
    ("Books",             "Education"),
    ("Sports & Outdoors", "Fitness"),
    ("Beauty & Health",   "Personal Care"),
    ("Toys & Games",      "Kids"),
    ("Groceries",         "Food"),
    ("Furniture",         "Home"),
    ("Automotive",        "Vehicle"),
]

categories_df = pd.DataFrame(CATEGORIES, columns=["category_name", "department"])
categories_df.index += 1
categories_df.index.name = "category_id"

categories_df.to_sql("categories", engine, if_exists="append", index=True)
print(f" Inserted {len(categories_df)} categories")


# ─── 2. PRODUCTS ─────────────────────────────────────────────────
PRODUCTS_PER_CATEGORY = 10

product_templates = {
    1:  [("Smartphone",80), ("Laptop",600), ("Tablet",300), ("Headphones",50),
         ("Smart Watch",150), ("Bluetooth Speaker",40), ("Webcam",35),
         ("Keyboard",25), ("Mouse",15), ("Monitor",200)],
    2:  [("T-Shirt",12), ("Jeans",30), ("Jacket",60), ("Dress",45),
         ("Shorts",18), ("Saree",55), ("Kurta",25), ("Sneakers",70),
         ("Sandals",20), ("Cap",10)],
    3:  [("Non-Stick Pan",25), ("Pressure Cooker",40), ("Mixer Grinder",55),
         ("Water Bottle",8), ("Dinner Set",35), ("Coffee Maker",45),
         ("Chopping Board",10), ("Storage Box",12), ("Knife Set",20),
         ("Towel Set",15)],
    4:  [("Programming Book",20), ("Novel",12), ("Self-Help Book",15),
         ("Science Book",18), ("Cookbook",14), ("History Book",16),
         ("Children Book",10), ("Dictionary",22), ("Comic Book",8),
         ("Textbook",30)],
    5:  [("Yoga Mat",20), ("Dumbbells",35), ("Cricket Bat",40),
         ("Football",25), ("Badminton Racket",18), ("Cycling Helmet",30),
         ("Running Shoes",65), ("Gym Bag",22), ("Jump Rope",8),
         ("Water Flask",12)],
    6:  [("Face Wash",10), ("Shampoo",8), ("Moisturizer",15),
         ("Perfume",35), ("Lipstick",12), ("Sunscreen",18),
         ("Vitamin C Serum",25), ("Hair Dryer",30), ("Electric Shaver",45),
         ("Toothbrush",5)],
    7:  [("LEGO Set",50), ("Board Game",30), ("Remote Car",25),
         ("Doll",15), ("Puzzle",12), ("Action Figure",18),
         ("Card Game",8), ("Building Blocks",20), ("Play-Doh",10),
         ("Toy Kitchen",40)],
    8:  [("Rice 5kg",8), ("Cooking Oil",6), ("Tea 500g",5),
         ("Coffee",10), ("Biscuits",3), ("Noodles",2),
         ("Sauce Pack",4), ("Cereal",7), ("Protein Bar",3),
         ("Juice Pack",4)],
    9:  [("Office Chair",120), ("Study Table",150), ("Bookshelf",90),
         ("Sofa",350), ("Bed Frame",250), ("Wardrobe",300),
         ("Coffee Table",80), ("TV Stand",70), ("Mirror",40),
         ("Shoe Rack",35)],
    10: [("Car Vacuum",30), ("Dash Cam",60), ("Car Charger",12),
         ("Seat Cover",25), ("Steering Lock",20), ("Wiper Blades",15),
         ("Car Freshener",5), ("Jump Starter",50), ("Tyre Inflator",35),
         ("Parking Sensor",45)],
}

products_rows = []
product_id = 1
for cat_id, items in product_templates.items():
    for name, price in items:
        cost = round(price * random.uniform(0.45, 0.65), 2)
        stock = random.randint(20, 500)
        supplier = fake.company()
        products_rows.append((product_id, name, cat_id, price, cost, supplier, stock))
        product_id += 1

products_df = pd.DataFrame(
    products_rows,
    columns=["product_id","product_name","category_id",
             "unit_price","unit_cost","supplier","stock_qty"]
)
products_df.to_sql("products", engine, if_exists="append", index=False)
print(f Inserted {len(products_df)} products")


# ─── 3. CUSTOMERS ────────────────────────────────────────────────
REGIONS = {
    "North": ["Delhi", "Punjab", "Haryana", "Uttar Pradesh", "Uttarakhand"],
    "South": ["Tamil Nadu", "Karnataka", "Kerala", "Telangana", "Andhra Pradesh"],
    "East":  ["West Bengal", "Odisha", "Bihar", "Jharkhand", "Assam"],
    "West":  ["Maharashtra", "Gujarat", "Rajasthan", "Goa", "Madhya Pradesh"],
}
STATE_REGION = {state: region for region, states in REGIONS.items() for state in states}
ALL_STATES = list(STATE_REGION.keys())

customers_rows = []
for cid in range(1, NUM_CUSTOMERS + 1):
    state  = random.choice(ALL_STATES)
    region = STATE_REGION[state]
    signup = rand_date(date(2021, 1, 1), END_DATE)
    customers_rows.append({
        "customer_id": cid,
        "first_name":  fake.first_name(),
        "last_name":   fake.last_name(),
        "email":       fake.unique.email(),
        "phone":       fake.phone_number()[:15],
        "city":        fake.city(),
        "state":       state,
        "region":      region,
        "signup_date": signup,
    })

customers_df = pd.DataFrame(customers_rows)
customers_df.to_sql("customers", engine, if_exists="append", index=False)
print(f" Inserted {len(customers_df)} customers")


# ─── 4. ORDERS + ORDER_ITEMS ──────────────────────────────────────
ship_modes    = ["Standard", "Express", "Same-Day", "Economy"]
payment_modes = ["Card", "UPI", "COD", "Net Banking"]
statuses      = ["Delivered"]*85 + ["Cancelled"]*8 + ["Returned"]*7

orders_rows     = []
order_items_rows = []
item_id   = 1

for oid in range(1, NUM_ORDERS + 1):
    cid        = random.randint(1, NUM_CUSTOMERS)
    order_date = rand_date(START_DATE, END_DATE)
    ship_gap   = random.randint(2, 10)
    ship_date  = order_date + timedelta(days=ship_gap)
    status     = random.choice(statuses)

    orders_rows.append({
        "order_id":     oid,
        "customer_id":  cid,
        "order_date":   order_date,
        "ship_date":    ship_date,
        "ship_mode":    random.choice(ship_modes),
        "payment_mode": random.choice(payment_modes),
        "order_status": status,
    })

    # 1–5 line items per order
    num_items   = random.randint(1, 5)
    chosen_prods = random.sample(range(1, len(products_df)+1), num_items)
    for pid in chosen_prods:
        price    = float(products_df.loc[products_df.product_id==pid, "unit_price"].values[0])
        qty      = random.randint(1, 5)
        discount = random.choice([0, 0, 0, 0.05, 0.10, 0.15, 0.20])
        order_items_rows.append({
            "item_id":    item_id,
            "order_id":   oid,
            "product_id": pid,
            "quantity":   qty,
            "unit_price": price,
            "discount":   discount,
        })
        item_id += 1

orders_df      = pd.DataFrame(orders_rows)
order_items_df = pd.DataFrame(order_items_rows)

orders_df.to_sql("orders", engine, if_exists="append", index=False)
print(f" Inserted {len(orders_df)} orders")

order_items_df.to_sql("order_items", engine, if_exists="append", index=False)
print(f" Inserted {len(order_items_df)} order items")


# ─── 5. RETURNS ──────────────────────────────────────────────────
return_reasons = [
    "Defective product", "Wrong item delivered", "Size issue",
    "Not as described", "Changed mind", "Damaged in transit",
    "Duplicate order", "Better price found",
]

returns_rows = []
return_candidates = order_items_df[
    order_items_df.order_id.isin(
        orders_df[orders_df.order_status == "Returned"].order_id
    )
].sample(frac=0.6, random_state=42)

for rid, (_, row) in enumerate(return_candidates.iterrows(), start=1):
    order_date = orders_df.loc[orders_df.order_id==row.order_id, "order_date"].values[0]
    ret_date   = pd.Timestamp(order_date) + timedelta(days=random.randint(3, 15))
    returns_rows.append({
        "return_id":   rid,
        "order_id":    int(row.order_id),
        "product_id":  int(row.product_id),
        "return_date": ret_date.date(),
        "quantity":    int(row.quantity),
        "reason":      random.choice(return_reasons),
    })

returns_df = pd.DataFrame(returns_rows)
returns_df.to_sql("returns", engine, if_exists="append", index=False)
print(f"✓ Inserted {len(returns_df)} returns")

print("\n All data loaded into retail_db successfully!")
