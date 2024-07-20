# Simple Inventory App

This is nventory management application built with SwiftUI and Firebase. Users can sign up and log in with email and password, access various sites, and manage stock levels for items. Each user can view only the sites they are assigned to. Push and pull operations are tracked with transactions, which log the time, item, quantity, and user involved in each operation.

## Features
- User Authentication with Firebase
- Site and Item Management
- Stock Management with Push and Pull Operations
- Transaction Logging for Auditing
- Responsive UI with SwiftUI

## Installation 
1. Clone the repository
2. Open project in Xcode
3. Install package dependecies
   - FirebaseAnalytics
   - FirebaseAnalyticsSwift
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseFirestoreSwift
4. Setup Firebase
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new project or use an existing one.
   - Add an iOS app to your project.
   - Follow the instructions to download the GoogleService-Info.plist file.
   - Add the GoogleService-Info.plist file to your Xcode project.

## Usage
### Authentication
 - Users can sign up and log in using their email and password.
 - Firebase Authentication is used for managing user sessions.
### Site Management
 - Users can view the list of sites they have access to.
 - Each site includes a name, location, and a list of items with quantities.
### Stock Management
 - Users can push or pull stock for items at a site.
 - The StockUpdateView allows users to select items and adjust quantities.
 - Transactions are logged for each push or pull operation.

## Code Overview
### Models
  - `Site`: Represents a site with an ID, name, location, items, and associated user IDs.
  - `Item`: Represents an item with an ID and name.
  - `Transaction`: Represents a transaction with details about the site, item, quantity, user, timestamp, notes, and type (push or pull).
### ViewModels
  - `SitesViewModel`: Manages the list of sites and handles updating item quantities.
  - `StockChangeViewModel`: Manages the state for the StockUpdateView.
### Views
  - `SitesView`: Displays the list of sites the user has access to.
  - `SiteDetailView`: Displays details of a selected site, including its items and quantities.
  - `SiteStockView`: Allows users to push or pull stock for items at a site.
  - `StockUpdateView`: Provides UI for selecting an item and adjusting its quantity.
  - `ProfileView`: Displays user profile information.
  - `SettingsView`: Manages application settings.
  - `AuthenticationView`: Manages user authentication.
### Managers
  - `UserManager`: Handles user authentication and management.
  - `ItemsManager`: Manages item-related operations.
  - `SitesManager`: Handles interactions with Firestore for fetching sites, updating item quantities, and logging transactions.
