# Operational Performance & SLA Monitoring Dashboard

## 📌 Project Overview
This project demonstrates an **industry-grade operational analytics pipeline** built on real commercial web server logs.  
The objective is to monitor **latency, reliability, and SLA adherence**, and to move beyond surface-level KPIs into **diagnostics and prioritization**.

The dashboard is designed to answer:
- Are we meeting SLAs?
- Where is operational risk concentrated?
- Which services should engineering teams prioritize?

---

## 🧱 Tech Stack
- **SQL Server (SSMS)** – Data ingestion, validation, and analytical views  
- **Power BI** – DAX measures, diagnostics, and visualization  
- **Python** – Log parsing and preprocessing  
- **GitHub** – Version control and portfolio hosting  

---

## 📂 Dataset
- **Source:** Public commercial web server logs (Mendeley, 2009)
- **Nature:** Real production-like traffic (non-synthetic)
- **Volume:** ~670K requests
- **Why it matters:** Real data introduces noise, skew, and long-tail latency behavior that materially impacts SLA analysis.

---

## 🛠 Data Engineering (SQL)
- Raw data ingested without transformation (all columns as VARCHAR)
- No logic applied to the raw table (best practice)
- All business and validation logic implemented in a **single analytical SQL view**:
  - Timestamp parsing
  - Latency validation
  - Error detection
  - SLA breach derivation
- Final analytical object:
