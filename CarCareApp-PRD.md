## **🏗️ Refined PRD for CarCareApp (Phase 1 Completion)**

### **1. Objective**

Build a "Zero-to-One" market validation tool for vehicle expense tracking using **Flutter** and **Firebase**. The app is **Offline-First**, allowing users to log data without a connection, which then syncs once they are back online. Completion of Phase 1 includes advanced AI-powered data entry to minimize user friction.

### **2. Core Tech Stack**

* **Frontend:** Flutter (Mobile).
* **Backend/Database:** Firebase Firestore (with **Persistence enabled**).
* **Authentication:** Firebase Auth (Email/Password + Google Sign-in).
* **AI Engine:** Google Gemini 1.5 Flash (via `google_generative_ai`) for intelligent document parsing.
* **OCR Engine:** `google_ml_kit` for text recognition.
* **Location:** `geolocator` for passive GPS tagging.

### **3. Feature Specifications (Phase 1 Result)**

#### **Feature 1: AI-Powered "Refuel" Log (formerly Magic Scan)**
* **Status:** [COMPLETED]
* **Action:** FAB opens camera to scan fuel receipts or odometer.
* **AI Logic (Gemini):** Automatically extracts:
  * **Station Name**, **Total Cost**, **Liters**, and **Price per Liter**.
  * **Odometer** reading from dashboard photos.
* **Manual Fallback:** Smart form for Odometer, Liters, and Total Cost.
* **Integration:** "Petrol" expenses from any form now sync directly to refuel history.

#### **Feature 2: Smart Expense & Repair Log**
* **Status:** [COMPLETED]
* **Categories:** Repair, Maintenance, Insurance, Store, etc.
* **AI Parsing:**
  * **Store Receipts:** itemized list extraction (Name, Qty, Price).
  * **Mechanic Bills:** Service description and cost extraction.
* **Vehicle Guards:** Entries are blocked for vehicles marked as **"Sold"**.

#### **Feature 3: Globalization & UX**
* **Status:** [COMPLETED]
* **Real-time Sync:** Settings for **Currency** and **Date Format** reflect instantly across the entire UI.
* **Category Management:** Dynamic addition and auto-selection of user-defined categories.

#### **Feature 4: Viral Share Card**
* **Status:** [COMPLETED]
* **Calculation:** Total Cost / Total Kilometers = **Cost per KM**.
* **Sharing:** OS share sheet for the "Shock/Pride" metric card.
