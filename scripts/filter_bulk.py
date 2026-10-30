import zipfile
from pathlib import Path
import pandas as pd

ZIP_PATH = sorted(Path('data/raw').glob('*.zip'))[0]
OUT_PATH = Path('data/raw/complaints_structured.csv')
PRODUCTS = [
    'Credit card',
    'Checking or savings account',
    'Money transfer, virtual currency, or money service',
    'Prepaid card',
]
START, END = '2023-09-01', '2026-08-14'

seen = kept = 0
first = True
with zipfile.ZipFile(ZIP_PATH) as z:
    csv_name = [n for n in z.namelist() if n.lower().endswith('.csv')][0]
    with z.open(csv_name) as f:
        for chunk in pd.read_csv(f, chunksize=500_000, dtype=str):
            seen += len(chunk)
            dates = pd.to_datetime(chunk['Date received'], errors='coerce')
            mask = chunk['Product'].isin(PRODUCTS) & (dates >= START) & (dates <= END)
            sub = chunk[mask]
            kept += len(sub)
            sub.to_csv(OUT_PATH, mode='w' if first else 'a', header=first, index=False)
            first = False
            print(f'read {seen:,} rows, kept {kept:,}', flush=True)

print('Done. Saved to', OUT_PATH)
