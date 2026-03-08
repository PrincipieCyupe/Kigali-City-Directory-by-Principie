# Kigali City Directory

A Flutter-based mobile application for exploring and managing businesses, public services, and points of interest in Kigali, Rwanda. The app provides a comprehensive directory with map integration, category filtering, and user-generated listings.

---

## Table of Contents

1. [Features](#features)
2. [Technology Stack](#technology-stack)
3. [Firestore Database Structure](#firestore-database-structure)
4. [State Management Approach](#state-management-approach)
5. [Project Structure](#project-structure)
6. [Getting Started](#getting-started)
7. [Security Rules](#security-rules)

---

## Features

### Core Features

| Feature | Description |
|---------|-------------|
| **Directory Browse** | Browse all listed places in Kigali with detailed information |
| **Category Filtering** | Filter listings by category (Hospitals, Police Stations, Restaurants, etc.) |
| **Search** | Search listings by name or keywords |
| **Map View** | View all listings on an interactive Google Map |
| **Listing Details** | View comprehensive details including address, contact, description, and coordinates |
| **User Listings** | Authenticated users can create, view, edit, and delete their own listings |
| **Authentication** | Email/password authentication with Firebase Auth |
| **Settings** | User profile management and app preferences |

### Available Categories

- 🏥 Hospital
- 🚔 Police Station
- 📚 Public Library
- 🍽️ Restaurant
- ☕ Café
- 🌳 Park
- 🏛️ Tourist Attraction
- 🏢 Utility Office

---

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | ^3.10.4 | Cross-platform UI framework |
| **Dart** | SDK ^3.10.4 | Programming language |
| **Riverpod** | ^3.2.1 | State management |
| **flutter_riverpod** | ^3.2.1 | Flutter-specific Riverpod widgets |
| **Firebase Core** | ^3.12.1 | Firebase initialization |
| **Firebase Auth** | ^5.5.2 | User authentication |
| **Cloud Firestore** | ^5.6.6 | NoSQL database |
| **Google Maps Flutter** | ^2.10.0 | Map integration |
| **URL Launcher** | ^6.3.1 | External directions/navigation |
| **Shared Preferences** | ^2.3.4 | Local storage |

---

## Firestore Database Structure

The application uses two primary collections in Firestore:

### 1. `listings` Collection

Stores all business and public place entries.

```
listings/
├── {documentId}/
│   ├── name              → String (required)
│   ├── category          → String (required)
│   ├── address           → String (required)
│   ├── contactNumber     → String (required)
│   ├── description       → String (required)
│   ├── latitude          → Double (required)
│   ├── longitude         → Double (required)
│   ├── createdBy         → String (Firebase Auth UID)
│   └── timestamp         → ISO 8601 String
```

**Example Document:**
```json
{
  "name": "Kigali Memorial Centre",
  "category": "Tourist Attraction",
  "address": "Kigali, Rwanda",
  "contactNumber": "+250 788 123 456",
  "description": "A memorial to the 1994 genocide...",
  "latitude": -1.9536,
  "longitude": 30.0606,
  "createdBy": "user_abc123xyz",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### 2. `users` Collection

Stores user profile information.

```
users/
├── {userId}/
│   ├── name               → String (required)
│   ├── email              → String (required)
│   ├── notificationsEnabled → Boolean (default: false)
│   └── createdAt          → ISO 8601 String
```

**Example Document:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "notificationsEnabled": false,
  "createdAt": "2024-01-10T08:00:00.000Z"
}
```

---

## State Management Approach

The application uses **Riverpod** (specifically Riverpod v3) for state management, following modern Flutter best practices.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Riverpod Providers                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │ Auth Providers  │    │ Listing Providers│                │
│  ├─────────────────┤    ├──────────────────┤                │
│  │ - authService   │    │ - listingService │                │
│  │ - currentUser   │    │ - listingNotifier│                │
│  │ - userProfile   │    │ - ListingState   │                │
│  │ - authNotifier  │    │                  │                │
│  └─────────────────┘    └──────────────────┘                 │
├─────────────────────────────────────────────────────────────┤
│                     Service Layer                            │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │ AuthService     │    │ ListingService  │                 │
│  │ - signIn        │    │ - getAllListings│                │
│  │ - signUp        │    │ - createListing │                │
│  │ - signOut       │    │ - updateListing│                │
│  │ - getUserProfile│    │ - deleteListing │                │
│  └─────────────────┘    └─────────────────┘                 │
├─────────────────────────────────────────────────────────────┤
│                    Firestore Database                        │
└─────────────────────────────────────────────────────────────┘
```

### Key Providers

#### Authentication Providers

| Provider | Type | Description |
|----------|------|-------------|
| [`authServiceProvider`](lib/providers/auth_provider.dart:6) | `Provider` | Singleton service for auth operations |
| [`currentUserProvider`](lib/providers/auth_provider.dart:12) | `StreamProvider` | Streams Firebase Auth state changes |
| [`userProfileProvider`](lib/providers/auth_provider.dart:18) | `FutureProvider.family` | Fetches user profile by UID |
| [`authNotifierProvider`](lib/providers/auth_provider.dart:70) | `NotifierProvider` | Manages auth state and actions |

#### Listing Providers

| Provider | Type | Description |
|----------|------|-------------|
| [`listingServiceProvider`](lib/providers/listing_provider.dart:6) | `Provider` | Singleton service for Firestore operations |
| [`listingNotifierProvider`](lib/providers/listing_provider.dart:44) | `NotifierProvider` | Manages listing state, filtering, and CRUD |

### State Classes

#### [`ListingState`](lib/providers/listing_provider.dart:11)
```dart
class ListingState {
  final bool isLoading;
  final List<Listing> listings;
  final String? error;
  final String? searchQuery;
  final String? selectedCategory;
}
```

#### [`AuthState`](lib/providers/auth_provider.dart:27)
```dart
class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAuthenticated;
  final bool requiresVerification;
  final String? error;
}
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point with Riverpod setup
├── models/
│   ├── listing.dart             # Listing data model & categories
│   └── user_profile.dart        # User profile data model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── listing_provider.dart    # Listings state management
│   └── navigation_provider.dart # Bottom navigation state
├── services/
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── firebase_config.dart     # Firebase initialization
│   └── listing_service.dart    # Firestore CRUD operations
├── screens/
│   ├── login.dart               # Login screen
│   ├── signup.dart              # Registration screen
│   ├── home/
│   │   └── home_screen.dart     # Main scaffold with bottom nav
│   ├── directory/
│   │   └── directory_screen.dart # Browse all listings
│   ├── my_listings/
│   │   ├── my_listings_screen.dart  # User's own listings
│   │   └── add_listing_screen.dart  # Create/edit listing
│   ├── detail/
│   │   └── listing_detail_screen.dart # Single listing view
│   ├── map_view/
│   │   └── map_view_screen.dart  # Google Maps integration
│   └── settings/
│       └── settings_screen.dart # User settings
└── images/                      # Asset images
```

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4
- Firebase project with:
  - Firebase Auth enabled (Email/Password)
  - Cloud Firestore enabled
  - Google Maps API key

### Installation

1. **Clone the repository**
   ```bash
   cd kigalicity
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   Place your `google-services.json` in `android/app/` for Android.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Security Rules

Firestore security rules ensure data safety:

### Listings Rules
```javascript
match /listings/{listingId} {
  allow read: if true;                    // Public read access
  allow create: if request.auth != null;  // Authenticated users can create
  allow update, delete: if request.auth != null 
    && request.auth.uid == resource.data.createdBy; // Only owner can modify
}
```

### Users Rules
```javascript
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow create: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && request.auth.uid == userId;
}
```

---

## Screenshots

The app features:
- **Directory Screen**: List view with search and category filters
- **My Listings Screen**: User's personal listings management
- **Map View**: Interactive Google Maps with all listings
- **Settings Screen**: Profile and notification preferences

---

## License

This project is for educational purposes not intended for commercial use.

---

## Author

Principie Cyubahiro
