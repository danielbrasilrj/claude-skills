# Data Cleaning and Post-Processing

## Common Cleaning Tasks

**Remove whitespace:**

```python
import re

def clean_text(text):
    text = re.sub(r'\s+', ' ', text)  # Replace multiple whitespace with single space
    return text.strip()

# Example
raw = "  Product    Title\n\n  "
clean = clean_text(raw)  # "Product Title"
```

**Parse prices:**

```python
def parse_price(price_str):
    # "$1,234.56" -> 1234.56
    cleaned = re.sub(r'[^\d.]', '', price_str)
    return float(cleaned) if cleaned else None

parse_price("$1,299.99")  # 1299.99
parse_price("R$ 1.299,99")  # 1299.99 (Brazilian format)
```

**Parse dates:**

```python
from dateutil.parser import parse

date_str = "January 15, 2026"
date_obj = parse(date_str)  # datetime(2026, 1, 15)
```

## Data Validation with Pydantic

```python
from pydantic import BaseModel, HttpUrl, validator

class Product(BaseModel):
    name: str
    price: float
    url: HttpUrl
    in_stock: bool

    @validator('price')
    def price_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError('Price must be positive')
        return v

# Validate scraped data
try:
    product = Product(
        name="Laptop",
        price=1299.99,
        url="https://example.com/laptop",
        in_stock=True
    )
except ValidationError as e:
    print(f"Invalid data: {e}")
```
