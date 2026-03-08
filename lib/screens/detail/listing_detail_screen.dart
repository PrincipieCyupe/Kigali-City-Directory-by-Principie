import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../my_listings/add_listing_screen.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  late GoogleMapController _mapController;

  final LatLng _initialPosition = const LatLng(
    -1.9536,
    30.0606,
  ); // Kigali coordinates

  LatLng get _listingPosition => LatLng(
    widget.listing.latitude != 0
        ? widget.listing.latitude
        : _initialPosition.latitude,
    widget.listing.longitude != 0
        ? widget.listing.longitude
        : _initialPosition.longitude,
  );

  Set<Marker> get _markers => {
    Marker(
      markerId: MarkerId(widget.listing.id),
      position: _listingPosition,
      infoWindow: InfoWindow(
        title: widget.listing.name,
        snippet: widget.listing.address,
      ),
    ),
  };

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_listingPosition.latitude},${_listingPosition.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
    }
  }

  Future<void> _callPhone() async {
    final phoneNumber = widget.listing.contactNumber.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not call')));
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Public Library':
        return Icons.local_library;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.local_cafe;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.tour;
      case 'Utility Office':
        return Icons.business;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user is the creator
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.uid;
    final isCreator = currentUserId == widget.listing.createdBy;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: isCreator
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddListingScreen(listing: widget.listing),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.listing.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                color: Colors.green.shade100,
                child: Center(
                  child: Icon(
                    _getCategoryIcon(widget.listing.category),
                    size: 80,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.listing.category,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Section
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    widget.listing.address,
                  ),
                  _buildInfoRow(
                    Icons.phone,
                    'Contact',
                    widget.listing.contactNumber,
                  ),
                  _buildInfoRow(
                    Icons.description,
                    'Description',
                    widget.listing.description,
                  ),

                  const SizedBox(height: 24),

                  // Map Section
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _listingPosition,
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _callPhone,
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.uid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text(
          'Are you sure you want to delete "${widget.listing.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref
                  .read(listingNotifierProvider.notifier)
                  .deleteListing(widget.listing.id, userId: userId);
              if (mounted) {
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Listing deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

