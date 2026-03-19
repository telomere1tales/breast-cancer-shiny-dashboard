# 🧬 Breast Cancer Interactive Dashboard
## Exploratory Analysis and Machine Learning Prediction Tool

## 🔗 Live App
👉 **[Open Dashboard](http://telomeretales.shinyapps.io/cancer_dashboard)**

---

## 📌 Overview

This project presents an interactive dashboard for breast cancer analysis 
and prediction, built using Shiny and based on clinical data.

The application allows users to:
- Explore the distribution of clinical features
- Analyze relationships between variables
- Understand patterns associated with diagnosis
- Simulate patient profiles and obtain model-based predictions

The goal is to bridge the gap between data analysis and user-facing 
applications, transforming machine learning results into an accessible 
and interpretable tool.

---

## 🎯 Objective

To develop an interactive application that enables both exploratory data 
analysis and real-time prediction of breast cancer diagnosis using 
machine learning.

---

## 📊 Dataset

- **Source:** Breast Cancer Wisconsin Dataset
- **Type:** Clinical diagnostic data
- **Task:** Binary classification (Benign vs Malignant)
- **Patients:** 683

The dataset includes features derived from cell nuclei measurements:
- Clump Thickness, Cell Size/Shape Uniformity
- Marginal Adhesion, Epithelial Cell Size
- Bare Nuclei, Bland Chromatin
- Normal Nucleoli, Mitoses

---

## 🏗️ Dashboard Structure

### 🏠 Overview
Introduces the dataset, project objective and context of the analysis.

### 🔍 Exploration
Allows users to visualize the distribution of individual features and 
understand how variables behave across the dataset.

### 📊 Correlations
Displays relationships between variables, helping identify patterns 
and potential predictors associated with diagnosis.

### 🤖 Prediction
Provides an interactive interface where users can input clinical values 
and obtain a prediction based on a trained machine learning model.

### 📘 About
Methodology, model details and variable definitions.

---

## 🤖 Machine Learning Model

- **Model:** Random Forest Classifier
- **Objective:** Predict probability of malignant diagnosis
- **Training:** 80% of data (546 patients)
- **Evaluation:** 20% held-out test set (137 patients)

## 📈 Model Performance

| Metric | Value |
|---|---|
| ROC-AUC | 0.97 |
| Recall | 0.92 |
| Precision | 0.90 |

The model is optimized to prioritize **high recall**, reducing the risk 
of missing malignant cases — critical in medical screening scenarios.

---

## 🧠 Key Insights

- Several features related to tumor size show strong association with malignancy
- Correlation analysis helps identify redundant or highly related variables
- Model performance highlights the trade-off between recall and precision
- Interactive prediction enables exploration of how feature changes affect risk

---

## ⚠️ Disclaimer

This application is intended for **educational and portfolio purposes only** 
and should not be used for clinical decision-making.

---

## 🛠️ Tech Stack

- R 4.5.3
- `shiny`, `shinydashboard`, `plotly`
- `randomForest`, `caret`, `corrplot`, `tidyverse`
- Deployed on **shinyapps.io**

## 📁 Files

- `app.R` — Complete Shiny application

---

## 💼 Why This Project Matters

✔ Build interactive data applications
✔ Combine EDA and machine learning in a single product
✔ Communicate insights to non-technical users
✔ Translate models into usable tools
✔ Work with healthcare data responsibly

---

## 👩‍💻 Author

**Noelia Caba Martin**
Junior Data Analyst / Data Scientist
Interested in health data, bioinformatics and applied machine learning

⭐ Feel free to star the repo or connect!
