# Simple Inventory App

This is inventory management application built with SwiftUI and Firebase. Users can sign up and log in with email and password, access various sites, and manage stock levels for items. Each user can view only the sites they are assigned to. Push and pull operations are tracked with transactions, which log the time, item, quantity, and user involved in each operation.

## Features
- User Authentication with Firebase
- Site and Item Management with Firestore
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
### Item Management
 - Users can manage items at a site. (Available, Damaged, In-Use)
 - The StockUpdateView allows users to select items and adjust quantities.
 - Transactions are logged for each push or pull operation.

## Code Overview
### Models
  - `Site`: Represents a site with an ID, name, location, items, and associated user IDs.
  - `Item`: Represents an item with an ID and name.
  - `Transaction`: Represents a transaction with details about the site, item, quantity, user, timestamp, notes, and type (push or pull).
  - `Robot`: Represents a robot with serial number, position, version, health, siteID, notes, wheelType, wheelInstallationdate, cartAssigned, and rsosFinished.
  - `Cart`: Represents a cart made of robot serial numbers per position, name and ID.
    
### ViewModels
  - `SitesViewModel`: Manages the list of sites and handles updating item quantities.
  - `StockChangeViewModel`: Manages the state for the StockUpdateView.
    
### Views
  - `SitesView`: Displays the list of sites the user has access to.
  - `SiteDetailView`: Displays details of a selected site, including its items and quantities.
  - `SiteStockView`: Allows users to push or pull stock for items at a site.
  - `StockUpdateView`: Provides UI for selecting an item and adjusting its quantity.
  - `AuthenticationView`: Manages user authentication.
    
### Managers
  - `UserManager`: Handles user authentication and management.
  - `ItemsManager`: Manages item-related operations.
  - `SitesManager`: Handles interactions with Firestore for fetching sites, updating item quantities, and logging transactions.
  - `AuthenticationManager`: Handles firebase authentication.
  - `RobotManager`: Handles robot functions and collection management
  - `CartsManager`: Handles carts functions and collection management

### Core
  - `Sites`: Contains all the views and models for the sites (Items, Robots, Carts, Main).
  - `TapBar`: Contains the tab bar view.
  - `SubViews`: Contains the EmailSignInView and the view model.
  - `Settings`: Contains the SettingsView and view model which manages user profile settings.
  - `Profile`: Contains the ProfileView which displays user profile information.
  - `RootView`: The root view of the project
  - `Authentication`: Contains the authenticationView
