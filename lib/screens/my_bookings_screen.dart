import 'package:flutter/material.dart';
import 'booking_item.dart';
import 'booking_card.dart';
import '../services/api_service.dart';
import '../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  final String? userToken;

  const MyBookingsScreen({Key? key, this.userToken}) : super(key: key);

  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int? expandedCardIndex;
  bool showSearchFrame = false;
  bool isLoading = false;
  String? errorMessage;
  List<BookingItem> bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('Loading bookings from API...');

      // Use getMyBookingsRaw() instead of getMyBookings()
      final List<Booking> apiBookings = await ApiService.getMyBookingsRaw();
      print('API returned ${apiBookings.length} bookings');

      final convertedBookings =
          apiBookings.map((booking) => _convertToBookingItem(booking)).toList();

      setState(() {
        bookings = convertedBookings;
        isLoading = false;
      });

      print('Successfully loaded ${bookings.length} bookings');
    } catch (error) {
      print('Error loading bookings: $error');
      setState(() {
        String errorMsg = error.toString();

        // More specific error messages
        if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
          errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        } else if (errorMsg.contains('timeout') ||
            errorMsg.contains('connection')) {
          errorMessage = 'Problème de connexion. Vérifiez votre réseau.';
        } else if (errorMsg.contains('404')) {
          errorMessage = 'Service non disponible. Contactez le support.';
        } else {
          errorMessage = 'Erreur: $errorMsg';
        }

        isLoading = false;
      });
    }
  }

  // Convert Booking (API) to BookingItem (UI)
  // Convert Booking (API) to BookingItem (UI)
  BookingItem _convertToBookingItem(Booking booking) {
    return BookingItem(
      id: booking.id is int
          ? booking.id as int
          : int.tryParse(booking.id?.toString() ?? '') ?? 0, // Ensure id is int
      date: _formatDate(booking.bookedDate),
      title: booking.tour?.title ?? 'Tour non disponible',
      location: booking.tour?.location?.label ?? 'Lieu non disponible',
      guide: booking.tour?.guide?.user?.firstName ?? 'Guide non assigné',
      rating: booking.tour?.guide?.rating?.toDouble() ?? 0.0,
      price: double.parse(booking.totalPrice ?? '0'),
      status: _mapBookingStatus(booking.status),
      isWaitingConfirmation: _isWaitingConfirmation(booking.status),
      duration: booking.tour?.duration ?? 0, // Provide a default or handle null
      isTransportIncluded: booking.tour?.isTransportIncluded ==
          1, // Changed from == true to == 1
      isFoodIncluded: booking.tour?.isFoodIncluded ==
          1, // Changed from complex bool check to == 1
      groupSize:
          booking.groupSize ?? 1, // Use groupSize from Booking model, not Tour
      description: booking.tour?.description ?? 'Description non disponible',
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date non disponible';

    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _mapBookingStatus(String? apiStatus) {
    switch (apiStatus?.toLowerCase()) {
      case 'confirmed':
      case 'confirmé':
        return 'Confirmé';
      case 'pending':
      case 'en_attente':
      case 'waiting_confirmation':
        return 'En attente de confirmation du guide';
      case 'cancelled':
      case 'annulé':
        return 'Annulé';
      case 'completed':
      case 'terminé':
        return 'Terminé';
      default:
        return 'Statut inconnu';
    }
  }

  bool _isWaitingConfirmation(String? status) {
    return status?.toLowerCase() == 'pending' ||
        status?.toLowerCase() == 'en_attente' ||
        status?.toLowerCase() == 'waiting_confirmation';
  }

  Future<void> _refreshBookings() async {
    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'MJ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, Mohamed',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Prêt pour un voyage?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes réservations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (!isLoading)
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.grey[600]),
                    onPressed: _refreshBookings,
                  ),
              ],
            ),
          ),

          // Search Bar
          _buildSearchBar(),

          // Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement de vos réservations...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Une erreur s\'est produite',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez à explorer et réservez votre premier tour!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      color: Colors.red[700],
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isExpanded = expandedCardIndex == index;
          return BookingCard(
            booking: booking,
            isExpanded: isExpanded,
            onTapExpand: () {
              setState(() {
                expandedCardIndex = isExpanded ? null : index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              'Rechercher',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey[400],
        currentIndex: 2, // Bookings tab selected
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Conversations',
          ),
        ],
      ),
    );
  }
}
