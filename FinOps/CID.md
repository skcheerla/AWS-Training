The **Cloud Intelligence Dashboard (CID)** is an open-source framework developed by AWS to help enterprises manage their cloud financial management (FinOps), operations, and optimization at scale.

While Splunk and Grafana (which we discussed earlier) are great for **real-time operational monitoring**, the CID is built on top of **Amazon QuickSight** and **Amazon Athena** to provide deep, historical insights into your cloud spending and architectural efficiency.

---

### Core Components of CID
The framework isn't just one dashboard; it's a suite of pre-built visualizations tailored to different roles in your organization:

| Dashboard | Target Audience | Primary Focus |
| :--- | :--- | :--- |
| **CUDOS** | CTO, SRE, DevOps | **Granular Detail:** Deep dives into resource-level costs (e.g., specific S3 buckets or Lambda functions) and usage spikes. |
| **CID (The Original)** | CFO, Finance Teams | **High-Level Finance:** Executive-level views of monthly spend, budgets, and commitment coverage (RI/Savings Plans). |
| **KPI Dashboard** | Platform Leads | **Modernization:** Tracks goals like "Spot Instance adoption %," "Graviton usage," and "Old Snapshot cleanup." |
| **TAO (Trusted Advisor)** | Security & SRE | **Governance:** Visualizes risks identified by AWS Trusted Advisor across Security, Performance, and Reliability. |

---

### Why it Matters for Your Application
Since you are managing a **Digital Banking** environment with high-performance hardware (NVIDIA H100s) and complex networking (API Gateways/Load Balancers), here is how a Cloud Intelligence Dashboard helps you specifically:

* **GPU Cost Tracking:** Tracking the specific ROI and spend of those H100 clusters over time, which are significantly more expensive than standard compute.
* **Multi-Account Governance:** For banking, you likely have separate accounts for Production, Staging, and Dev. CID aggregates all this into a "Single Pane of Glass."
* **FinOps Accountability:** It allows you to implement **Showback** or **Chargeback**, mapping cloud costs directly to specific banking features (e.g., "How much does the Mobile App's API Gateway cost us per month?").
* **Waste Detection:** It automatically highlights "Zombie" resources, such as unattached EBS volumes or underutilized Load Balancers that are still drawing a budget.

### How it compares to your current tools:
* **Grafana:** Best for **"What is happening right now?"** (CPU spikes, 5xx errors).
* **Splunk:** Best for **"Why did it happen?"** (Log forensics, security audits).
* **Cloud Intelligence Dashboard:** Best for **"How much did it cost, and are we efficient?"** (FinOps and Long-term trends).

If your organization is scaling its AWS footprint, the CID is usually the "gold standard" for moving from simple monitoring to mature **Cloud Financial Management**.
