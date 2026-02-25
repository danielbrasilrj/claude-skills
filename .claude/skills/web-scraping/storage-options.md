# Storage Options

## JSON (Simple, Portable)

```python
import json

data = [{"name": "Product 1", "price": 99.99}, ...]

with open("products.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

## CSV (Excel-Compatible)

```python
import csv

with open("products.csv", "w", newline='', encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["name", "price", "url"])
    writer.writeheader()
    writer.writerows(data)
```

## SQLite (Queryable)

```python
import sqlite3

conn = sqlite3.connect("products.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL,
    url TEXT
)
""")

for product in data:
    cursor.execute("INSERT INTO products (name, price, url) VALUES (?, ?, ?)",
                   (product['name'], product['price'], product['url']))

conn.commit()
conn.close()
```
