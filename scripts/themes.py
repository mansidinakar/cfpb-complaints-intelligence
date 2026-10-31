import re
import numpy as np
import pandas as pd
from pathlib import Path
from sklearn.decomposition import NMF
from sklearn.feature_extraction.text import ENGLISH_STOP_WORDS, TfidfVectorizer

# Purpose: find the recurring themes inside complaint narratives for each failure mode
# Window: complaints received Sep 2023 to Nov 2025, the months where narrative coverage is stable
# Cleaning, applied before modeling:
#   1. surge-flagged rows are already out (the modes view excludes them)
#   2. drop narratives under 30 words
#   3. drop Block and Early Warning Services narratives that start with one of the two template openings
#      found by the campaign test
#   4. drop exact duplicates after normalizing the text
# Model: TF-IDF (single words and word pairs) then NMF, which gives each narrative one dominant theme
# Version 2 changes: company and bank names plus common narrative verbs are added to the stop words, so themes
# describe what went wrong and not who it happened to; NMF runs up to 1000 iterations;
# Fraud and scams is modeled too; each theme reports the share of its narratives that share an 8-word
# opening with at least 10 other narratives in the same mode (a simple template check)
# Fixed random seed. Each mode is capped at 20,000 randomly sampled narratives
# Themes are labeled by hand after reading the top terms and 20 sample narratives per theme

K = {
    "Disputes and unauthorized transactions": 8,
    "Access to funds and holds": 6,
    "Debits and payments gone wrong": 5,
    "Fraud and scams": 6,
    "Unclassified transaction problems": 6,
}
MAX_N = 20000
BLOCK_ZELLE = ("Block, Inc.", "Early Warning Services, LLC")
TEMPLATE_STARTS = ("i am filing a complaint against cash app block inc",
                   "i am writing to formally express my concerns regarding")
COMPANY_WORDS = {"wells", "fargo", "chase", "jpmorgan", "morgan", "bank", "banks", "america", "bofa", "boa",
                 "citi", "citibank", "capital", "chime", "cash", "app", "cashapp", "paypal", "venmo",
                 "coinbase", "zelle", "zelles", "block", "robinhood", "sofi", "wise", "remitly", "navy",
                 "federal", "usaa", "discover", "synchrony", "amex", "american", "express", "goldman",
                 "sachs", "apple", "dave", "moneylion"}
GENERIC_WORDS = {"told", "said", "called", "asked", "tried", "just", "got", "did", "went", "like", "know",
                 "say", "says", "didn", "doesn", "wasn", "don", "ve", "ll", "pm", "am"}
STOP = sorted(set(ENGLISH_STOP_WORDS) | COMPANY_WORDS | GENERIC_WORDS)


def norm(t):
    t = re.sub(r"\bx{2,}\b", " ", t.lower())
    t = re.sub(r"[^a-z ]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def run_themes(con, out_dir="../data/processed"):
    in_list = ", ".join("'" + m + "'" for m in K)
    df = con.sql(f"""
    SELECT m.complaint_id, m.mode, m.company, m.date_received, m.got_relief, n.narrative
    FROM modes m JOIN narratives n USING (complaint_id)
    WHERE m.date_received BETWEEN DATE '2023-09-01' AND DATE '2025-11-30'
      AND m.mode IN ({in_list})
    """).df()
    rows, samples = [], []
    for mode, k in K.items():
        d = df[df["mode"] == mode].copy()
        start_n = len(d)
        d["clean"] = d["narrative"].map(norm)
        d = d[d["clean"].str.split().str.len() >= 30]
        short_n = start_n - len(d)
        is_tmpl = d["company"].isin(BLOCK_ZELLE) & d["clean"].str.startswith(TEMPLATE_STARTS)
        tmpl_n = int(is_tmpl.sum())
        d = d[~is_tmpl]
        before = len(d)
        d = d.drop_duplicates("clean")
        dup_n = before - len(d)
        d["open8"] = d["clean"].str.split().str[:8].str.join(" ")
        d["open_n"] = d.groupby("open8")["open8"].transform("size")
        if len(d) > MAX_N:
            d = d.sample(MAX_N, random_state=1)
        vec = TfidfVectorizer(stop_words=STOP, ngram_range=(1, 2), min_df=5,
                              max_df=0.4, max_features=30000, sublinear_tf=True)
        X = vec.fit_transform(d["clean"])
        nmf = NMF(n_components=k, init="nndsvd", random_state=1, max_iter=1000)
        d["theme"] = nmf.fit_transform(X).argmax(axis=1)
        terms = vec.get_feature_names_out()
        print(f"{mode}: {start_n:,} narratives, dropped {short_n:,} short, {tmpl_n:,} template, "
              f"{dup_n:,} duplicates, modeled {len(d):,}", flush=True)
        for t in range(k):
            top = ", ".join(terms[nmf.components_[t].argsort()[::-1][:10]])
            sub = d[d["theme"] == t]
            rows.append(dict(mode=mode, theme=t, narratives=len(sub),
                             share_pct=round(100 * len(sub) / len(d), 1),
                             relief_pct=round(100 * float(sub["got_relief"].mean()), 1),
                             shared_opening_pct=round(100 * float((sub["open_n"] >= 10).mean()), 1),
                             top_terms=top))
            samples.append(sub.sample(min(20, len(sub)), random_state=1)
                              [["mode", "theme", "complaint_id", "company", "narrative"]])
    summary = pd.DataFrame(rows)
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    summary.to_csv(Path(out_dir) / "theme_summary.csv", index=False)
    pd.concat(samples).to_csv(Path(out_dir) / "theme_samples.csv", index=False)
    return summary


def show(summary, mode_prefixes):
    for _, r in summary.iterrows():
        if r["mode"].startswith(mode_prefixes):
            print(f'{r["mode"][:12]} T{r["theme"]}: {r["share_pct"]:4.1f}% | relief {r["relief_pct"]:4.1f}% '
                  f'| shared opening {r["shared_opening_pct"]:4.1f}% | {r["top_terms"]}')
