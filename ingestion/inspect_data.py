import csv
from pathlib import Path

DATA_DIR = Path("data/raw")

for file_path in sorted(DATA_DIR.glob("*.csv")):
    print(f"\n{'=' * 60}")
    print(f"File: {file_path.name}")

    with file_path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        print("Columns:", reader.fieldnames)

        row_count = sum(1 for _ in reader)
        print("Data rows:", row_count)

print("\nDataset inspection complete.")
