import os
import csv
import duckdb

# ---------------------------------------------------------------------------
# Preparation
# ---------------------------------------------------------------------------
devdb_path = "dwh.ddb"

# initialize sources dictionary with NBER recession flag 
sources = {'fred': ['USRECM']}

# read indicators from registry and add them by source to sources dictionary
with open("./seeds/indicator_registry.csv", newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    for r in reader:
        source = r["source"].strip()
        series_id = r["series_id"].strip()

        sources.setdefault(source, []).append(series_id)

print()
print("------------")
print("Data to load")
print(sources)

# ---------------------------------------------------------------------------
# load data in database
# ---------------------------------------------------------------------------
try:
    conn = duckdb.connect(devdb_path)
    conn.execute(f"CREATE SCHEMA IF NOT EXISTS raw;")
    print()
    print("-----------------------------------")
    print("Raw data schema created succesfully")
    for src, ids in sources.items():
        print()
        print("------")
        print(f"SOURCE: {src}")
        
        for id in ids:
            series_id = id.lower()
            
            # build target table identifier
            target_table = f"raw.{src}_{series_id}"
            
            # load data from file
            conn.execute(f"CREATE OR REPLACE TABLE {target_table} AS FROM './data/{src}/{id}.csv';")
            print(f"  --> Successfully loaded {id} into {target_table}")
finally:
    conn.close()
    print()
    print("Connection to DB closed successfully.")
