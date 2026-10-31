import sys
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = ROOT / "data" / "raw" / "archive"
OUT = ROOT / "data" / "processed" / "narratives_in_scope.csv"

PRODUCTS = [
    "Credit card",
    "Checking or savings account",
    "Money transfer, virtual currency, or money service",
    "Prepaid card",
]
START, END = "2023-09-01", "2026-08-14"
KEEP = ["Complaint ID", "Date received", "Product", "Sub-product", "Issue",
        "Sub-issue", "Company", "Consumer complaint narrative"]

OUT.parent.mkdir(parents=True, exist_ok=True)
files = sorted(ARCHIVE.glob("*.csv"))
print(f"{len(files)} files found", flush=True)

first, total, dupes = True, 0, 0
seen = set()
for fp in files:
    rows = kept = 0
    for chunk in pd.read_csv(fp, chunksize=200_000, dtype=str):
        rows += len(chunk)
        dates = pd.to_datetime(chunk["Date received"], errors="coerce")
        narr = chunk["Consumer complaint narrative"].fillna("").str.strip()
        mask = (chunk["Product"].isin(PRODUCTS) & (dates >= START)
                & (dates <= END) & (narr != ""))
        sub = chunk.loc[mask, KEEP]
        fresh = ~sub["Complaint ID"].isin(seen)
        dupes += int((~fresh).sum())
        sub = sub[fresh]
        seen.update(sub["Complaint ID"])
        sub.to_csv(OUT, mode="w" if first else "a", header=first, index=False)
        first = False
        kept += len(sub)
    total += kept
    print(f"{fp.name}: {rows:,} rows, {kept:,} kept, running total {total:,}", flush=True)

print(f"Done. {total:,} narratives saved to {OUT} ({dupes} duplicates dropped)")
