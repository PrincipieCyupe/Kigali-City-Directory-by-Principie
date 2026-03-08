import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _listings => _firestore.collection('listings');

  // Create a new listing
  Future<String> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    try {
      DocumentReference doc = await _listings.add({
        'name': name,
        'category': category,
        'address': address,
        'contactNumber': contactNumber,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdBy': createdBy,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all listings
  Future<List<Listing>> getAllListings() async {
    try {
      QuerySnapshot snapshot = await _listings
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get listings by category
  Future<List<Listing>> getListingsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _listings
          .where('category', isEqualTo: category)
          .get();

      List<Listing> listings = snapshot.docs
          .map(
            (doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Sort by timestamp descending locally
      listings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return listings;
    } catch (e) {
      rethrow;
    }
  }

  // Get listings created by specific user
  Future<List<Listing>> getListingsByUser(String userId) async {
    try {
      // Query only by createdBy, then sort locally to avoid needing composite index
      QuerySnapshot snapshot = await _listings
          .where('createdBy', isEqualTo: userId)
          .get();

      List<Listing> listings = snapshot.docs
          .map(
            (doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Sort by timestamp descending locally
      listings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return listings;
    } catch (e) {
      rethrow;
    }
  }

  // Search listings by name
  Future<List<Listing>> searchListings(String query) async {
    try {
      // Firestore doesn't support full-text search, so we get all and filter
      QuerySnapshot snapshot = await _listings.get();

      List<Listing> allListings = snapshot.docs
          .map(
            (doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Filter by name (case-insensitive)
      return allListings
          .where(
            (listing) =>
                listing.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a single listing by ID
  Future<Listing?> getListingById(String id) async {
    try {
      DocumentSnapshot doc = await _listings.doc(id).get();

      if (doc.exists) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update a listing
  Future<void> updateListing({
    required String id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (category != null) updates['category'] = category;
      if (address != null) updates['address'] = address;
      if (contactNumber != null) updates['contactNumber'] = contactNumber;
      if (description != null) updates['description'] = description;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      if (updates.isNotEmpty) {
        await _listings.doc(id).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    try {
      await _listings.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of all listings (for real-time updates)
  Stream<List<Listing>> getAllListingsStream() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Stream of user's listings (for real-time updates)
  Stream<List<Listing>> getUserListingsStream(String userId) {
    // Query only by createdBy, then sort locally to avoid needing composite index
    return _listings.where('createdBy', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      List<Listing> listings = snapshot.docs
          .map(
            (doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
      // Sort by timestamp descending locally
      listings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return listings;
    });
  }
}

