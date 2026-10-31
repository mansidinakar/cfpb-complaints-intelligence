import pandas as pd
from pathlib import Path

# Purpose: manual check of theme labels
# For each theme below, show 10 sampled narratives (first 70 words) and record whether the main complaint
# fits the proposed label (1) or not (0)
# Rule: 1 if the main complaint is what the label says, even if the narrative also mentions other things
# 0 if the main complaint is something else or the narrative is unclear
# Answers are saved after every entry, so the check can be stopped (q) and resumed
# Type f to see the full narrative before answering

CHECK = [
    ("Disputes and unauthorized transactions", 5, "Unauthorized debit card transactions, claim denied"),
    ("Disputes and unauthorized transactions", 6, "Money taken from a checking account or ATM, no help"),
    ("Disputes and unauthorized transactions", 7, "Merchant refund or non-delivery dispute"),
    ("Disputes and unauthorized transactions", 3, "Charge disputed with a company after payment"),
    ("Access to funds and holds", 2, "Check deposit held, funds not available"),
    ("Access to funds and holds", 0, "Locked out of account or stuck in verification"),
    ("Access to funds and holds", 4, "Account closed or funds hard to withdraw (tentative, catch-all cluster)"),
    ("Debits and payments gone wrong", 3, "Sign-up bonus or direct deposit promotion not honored"),
    ("Fraud and scams", 5, "Fake check or job scam"),
    ("Unclassified transaction problems", 3, "Wire transfer problem, recall requested"),
]
SAMPLES = Path("../data/processed/theme_samples.csv")
ANSWERS = Path("../data/processed/validation_answers.csv")


def run(per_theme=10, words=70):
    samples = pd.read_csv(SAMPLES)
    if ANSWERS.exists():
        done = pd.read_csv(ANSWERS)
    else:
        done = pd.DataFrame(columns=["mode", "theme", "complaint_id", "fits"])
    answered = set(zip(done["mode"], done["theme"], done["complaint_id"]))
    for mode, theme, label in CHECK:
        s = samples[(samples["mode"] == mode) & (samples["theme"] == theme)].head(per_theme)
        for _, r in s.iterrows():
            key = (mode, theme, r["complaint_id"])
            if key in answered:
                continue
            text = " ".join(str(r["narrative"]).split()[:words])
            print(f"\n[{mode[:12]} T{theme}] LABEL: {label}\n{text}")
            ans = input("Fits the label? 1 yes, 0 no, f full text, q stop: ").strip().lower()
            if ans == "f":
                print("\nFULL TEXT:\n" + str(r["narrative"]))
                ans = input("Fits the label? 1 yes, 0 no, q stop: ").strip().lower()
            if ans == "q":
                print("Stopped. Run again to resume.")
                return
            if ans not in ("0", "1"):
                print("Skipped, run again to answer it later.")
                continue
            done.loc[len(done)] = [mode, theme, r["complaint_id"], int(ans)]
            done.to_csv(ANSWERS, index=False)
    print("All answered.")


def summary():
    d = pd.read_csv(ANSWERS)
    labels = {(m, t): l for m, t, l in CHECK}
    g = d.groupby(["mode", "theme"])["fits"].agg(["sum", "count"]).reset_index()
    for _, r in g.iterrows():
        name = labels[(r["mode"], r["theme"])]
        print(f"{r['mode'][:12]} T{r['theme']}: {int(r['sum'])} of {int(r['count'])} fit | {name}")
