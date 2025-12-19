# Full-Stack E-Commerce Client App

A **Flutter-based e-commerce client app** powered by **Supabase** as the backend. This app allows users to browse products, manage a cart, place orders, and pay via **MPESA** or **Cash on Delivery**, with real-time order management. It integrates seamlessly with a **full-stack admin panel** for product and order management.

---

## Features

### **User Functionality**
- **Authentication:** Sign up / Log in with email & password.
- **Profile Management:** Auto-linked with `clients` table in Supabase.
- **Product Browsing:** View products with price, variants, and details.
- **Cart Management:** Add, update quantity, and remove items.
- **Checkout & Orders:**
  - Multi-step checkout (shipping info, payment selection).
  - MPESA payments integrated via Supabase Edge Functions.
  - Cash on Delivery option.
- **Order History:** View all orders with details and statuses.
- **RLS-Safe:** All user actions are secured with **Row-Level Security** in Supabase.

### **Backend (Supabase)**
- **Tables:** `clients`, `orders`, `order_items`, `users`.
- **Policies:**  
  - Clients can insert their own orders.  
  - Staff/admins have controlled access for managing orders.  
  - RLS applied to secure all operations.

### **Admin Panel Integration**
- Fully compatible with an existing **full-stack admin panel**, enabling:
  - Real-time order tracking
  - Staff management
  - Product CRUD operations
  - Order assignment and payment updates

---

## Screenshots

*(Add screenshots of app home, product page, cart, checkout, and MPESA prompt here.)*

---

## Tech Stack

- **Frontend:** Flutter, Riverpod (State Management)
- **Backend:** Supabase (Auth, Database, Storage, Edge Functions)
- **Payment:** MPESA B2B integration via Supabase Edge Functions
- **Database:** PostgreSQL with RLS and strict foreign key constraints

---

## Setup Instructions

### 1. Clone the repo
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
2. Install dependencies
bash
Copy code
flutter pub get
3. Configure Supabase
Create a Supabase project.

Set up tables: clients, orders, order_items, users.

Apply RLS policies for clients and orders.

Obtain the Supabase URL and anon key, then add them to your .env or directly in lib/core/config.dart.

4. Run the app
bash
Copy code
flutter run
Test on a real device or emulator.

Ensure you are authenticated before placing orders.

Folder Structure
graphql
Copy code
lib/
├── core/           # App-wide configurations (Supabase, constants)
├── features/
│   ├── cart/       # Cart provider and UI
│   ├── checkout/   # Checkout flow and MPESA integration
│   ├── products/   # Product listing & details
│   └── auth/       # Authentication flow
├── models/         # Data models
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
Usage
Sign up or log in as a client.

Browse products and add to cart.

Proceed to checkout, fill shipping info, and select a payment method.

Confirm order:

For MPESA, a prompt is sent to your phone.

For COD, the order is saved with a pending status.

Orders can be managed and viewed in real-time via the admin panel.

Contributions
Contributions are welcome! Please open an issue or submit a pull request for enhancements or bug fixes.

## Important Note

⚠️ Some sensitive configuration files, such as `lib/core/config.dart` and `.env`, are **not included in this repository** for security reasons.  

This means that if you clone this repo, the **UI and structure will be visible**, but the app **won't fully run** because Supabase keys and other secrets are missing.  

To get the full working version with backend integration, **please contact the project owner**.


<img width="576" height="1057" alt="home_mobile" src="https://github.com/user-attachments/assets/6a05d1a9-17f3-489b-b180-07b835c360ca" />
<img width="513" height="1057" alt="detail_mobile" src="https://github.com/user-attachments/assets/ad1c866e-a558-4c0c-a3be-699d683815ee" />
<img width="568" height="1057" alt="related_mobile" src="https://github.com/user-attachments/assets/60b85338-fce1-43dc-a7e1-4f6d33197c93" />
<img width="680" height="1057" alt="cart_mobile" src="https://github.com/user-attachments/assets/aac27bac-270c-43e6-86ba-6f6935047879" />
<img width="555" height="1057" alt="profile_mobile" src="https://github.com/user-attachments/assets/34fd0b53-2b32-4ab4-8706-814b0d2d720e" />
<img width="1585" height="892" alt="client_home_desktop" src="https://github.com/user-attachments/assets/d9bb76ab-282a-4ab8-92fc-6064f517ab48" />
<img width="1589" height="892" alt="client_cart_desktop" src="https://github.com/user-attachments/assets/8e640b92-fda2-4278-a8a3-e86787e7058d" />
<img width="1589" height="892" alt="client_detail_desktop" src="https://github.com/user-attachments/assets/4cde78d1-cfdc-4477-a5f1-841e86c05116" />

