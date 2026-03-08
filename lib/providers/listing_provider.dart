import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/listing_service.dart';
import '../models/listing.dart';

// Listing service provider
final listingServiceProvider = Provider<ListingService>((ref) {
  return ListingService();
});

// Listing state
class ListingState {
  final bool isLoading;
  final List<Listing> listings;
  final String? error;
  final String? searchQuery;
  final String? selectedCategory;

  ListingState({
    this.isLoading = false,
    this.listings = const [],
    this.error,
    this.searchQuery,
    this.selectedCategory,
  });

  ListingState copyWith({
    bool? isLoading,
    List<Listing>? listings,
    String? error,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ListingState(
      isLoading: isLoading ?? this.isLoading,
      listings: listings ?? this.listings,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Listing notifier
class ListingNotifier extends Notifier<ListingState> {
  @override
  ListingState build() {
    return ListingState();
  }

  ListingService get _listingService => ref.read(listingServiceProvider);

  Future<void> loadAllListings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<Listing> listings = await _listingService.getAllListings();
      state = state.copyWith(isLoading: false, listings: listings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadListingsByCategory(String category) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedCategory: category,
    );
    try {
      List<Listing> listings = await _listingService.getListingsByCategory(
        category,
      );
      state = state.copyWith(isLoading: false, listings: listings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUserListings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<Listing> listings = await _listingService.getListingsByUser(userId);
      state = state.copyWith(isLoading: false, listings: listings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchListings(String query) async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: query);
    try {
      List<Listing> listings = await _listingService.searchListings(query);
      state = state.copyWith(isLoading: false, listings: listings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _listingService.createListing(
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
      );
      // Reload user's listings
      await loadUserListings(createdBy);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateListing({
    required String id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _listingService.updateListing(
        id: id,
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      // Reload user's listings
      await loadUserListings(userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteListing(String id, {String? userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _listingService.deleteListing(id);
      // Reload user's listings if userId provided, otherwise load all
      if (userId != null) {
        await loadUserListings(userId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: null, selectedCategory: null);
  }

  void clearListings() {
    state = state.copyWith(listings: [], isLoading: false, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Listing provider
final listingNotifierProvider = NotifierProvider<ListingNotifier, ListingState>(
  () {
    return ListingNotifier();
  },
);

// Filtered listings provider (for search and category filtering)
final filteredListingsProvider = Provider<List<Listing>>((ref) {
  final state = ref.watch(listingNotifierProvider);
  return state.listings;
});

// Single listing provider
final listingByIdProvider = FutureProvider.family<Listing?, String>((
  ref,
  id,
) async {
  final listingService = ref.watch(listingServiceProvider);
  return await listingService.getListingById(id);
});

