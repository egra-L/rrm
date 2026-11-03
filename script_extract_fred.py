import os
import sys
import csv
import requests

from pathlib import Path
from dotenv  import load_dotenv

# ---------------------------------------------------------------------------
# Preparation
# ---------------------------------------------------------------------------
OUTPUT_DIR = Path("data/fred")
FRED_URL   = "https://api.stlouisfed.org/fred/series"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# initialize series IDs list with recession flag (NBER)
SERIES_IDS = ["USRECM"]

# add FRED's series IDs from indicator registry
with open("./seeds/indicator_registry.csv", newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    SERIES_IDS.extend(r["series_id"] for r in reader if r["source"].strip().lower() == "fred")

print("Loading API key")

load_dotenv()
api_key = os.getenv("FRED_API_KEY")

if not api_key:
    print("ERROR: No FRED API key found")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Fetch data
# ---------------------------------------------------------------------------
for id in SERIES_IDS:
    clean_id = id.strip()
    
    print()
    print(f"Fetching {clean_id}")

    response = requests.get(
        f"{FRED_URL}/observations",
        params={
            "series_id": clean_id,
            "api_key": api_key,
            "file_type": "json"
        }
    )

    print(f"GET STATUS: {response.status_code}")

    if response.status_code != 200:
        print(f"ERROR: {response.text}")
        sys.exit(1)

    obs = response.json()["observations"]

    target_file = OUTPUT_DIR / f"{clean_id}.csv"

    fieldnames = ["series_id", "observation_date", "value"]

    with open(target_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)

        writer.writeheader()

        for o in obs:
            writer.writerow({
                "series_id": clean_id,
                "observation_date": o["date"],
                "value": o["value"]
            })

# ---------------------------------------------------------------------------
# Finish
# ---------------------------------------------------------------------------
print()
print("Extraction Completed")
