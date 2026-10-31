import re
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neighbors import NearestNeighbors

# Purpose: measure how templated complaint narratives are, by group
# Method: normalize text, then measure exact duplicates, shared 10-word openings,
# and the share of narratives whose nearest neighbor within the same group has cosine similarity >= 0.8
# Each group is sampled to the same size (3000), so rates are comparable across groups
# Narratives under 20 words are dropped because very short text cannot be templated in a meaningful way

def norm(t):
    t = re.sub(r"\bx{2,}\b", " ", t.lower())
    t = re.sub(r"[^a-z0-9 ]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()

def campaign_test(con, sample_size=3000, seed=1):
    df = con.sql("""
    SELECT * FROM (
      SELECT c.complaint_id, c.date_received, c.company, n.narrative,
        CASE
          WHEN c.company IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.date_received BETWEEN DATE '2023-09-01' AND DATE '2024-12-31'
            THEN '0 Block+Zelle before (Sep 2023-Dec 2024)'
          WHEN c.company IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.date_received BETWEEN DATE '2025-01-13' AND DATE '2025-02-28'
            THEN '1 Block+Zelle campaign (Jan 13-Feb 28 2025)'
          WHEN c.company IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.date_received BETWEEN DATE '2025-03-01' AND DATE '2025-08-31'
            THEN '2 Block+Zelle Mar-Aug 2025'
          WHEN c.company IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.date_received >= DATE '2025-09-01'
            THEN '3 Block+Zelle after (Sep 2025-Jul 2026)'
          WHEN c.company NOT IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.company NOT IN (SELECT company FROM spike_companies)
               AND c.date_received BETWEEN DATE '2025-01-13' AND DATE '2025-02-28'
            THEN '4 Control: all others, same weeks'
          WHEN c.company NOT IN ('Block, Inc.', 'Early Warning Services, LLC')
               AND c.date_received >= DATE '2025-09-01'
            THEN '5 Control: all others, Sep 2025-Jul 2026'
        END AS grp
      FROM narratives n JOIN complaints_scoped c USING (complaint_id)
    ) WHERE grp IS NOT NULL
    """).df()
    df = df[df["narrative"].str.split().str.len() >= 20]
    rows, openers = [], {}
    for g, d in sorted(df.groupby("grp"), key=lambda x: x[0]):
        d = d.sample(min(len(d), sample_size), random_state=seed)
        texts = d["narrative"].map(norm).tolist()
        words = [t.split() for t in texts]
        exact = pd.Series(texts).duplicated(keep=False).mean()
        op = pd.Series([" ".join(w[:10]) for w in words])
        X = TfidfVectorizer(min_df=2, ngram_range=(1, 2), sublinear_tf=True).fit_transform(texts)
        nn = NearestNeighbors(n_neighbors=2, metric="cosine", algorithm="brute").fit(X)
        dist, _ = nn.kneighbors(X)
        sim = 1 - dist[:, 1]
        rows.append(dict(group=g, narratives=len(texts),
                         median_words=int(np.median([len(w) for w in words])),
                         exact_dup_pct=round(100 * exact, 1),
                         same_opening_pct=round(100 * op.duplicated(keep=False).mean(), 1),
                         near_dup_pct=round(100 * float((sim >= 0.8).mean()), 1)))
        openers[g] = op.value_counts().head(3)
    return pd.DataFrame(rows), openers
