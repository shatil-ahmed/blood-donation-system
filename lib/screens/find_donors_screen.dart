import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  String? _selectedBloodType;
  String? _selectedLocation;
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _locations = [
    'Uttara',
    'Gulshan',
    'Banani',
    'Dhanmondi',
    'Mirpur',
    'Motijheel',
    'Khulna',
    'Chittagong',
    'Sylhet',
    'Rajshahi'
  ];
  
  final List<Map<String, dynamic>> _donors = [
    {
      'name': 'Shatil Ahmed',
      'bloodType': 'O+',
      'location': 'Uttara',
      'distance': '2.5 km',
      'lastDonation': '3 months ago',
      'available': true,
      'phone': '+880-1711-234567',
      'rating': 4.8,
    },
    {
      'name': 'Tasnim Rahman',
      'bloodType': 'A-',
      'location': 'Gulshan',
      'distance': '5.1 km',
      'lastDonation': '1 month ago',
      'available': true,
      'phone': '+880-1712-345678',
      'rating': 4.9,
    },
    {
      'name': 'Rahim Uddin',
      'bloodType': 'B+',
      'location': 'Dhanmondi',
      'distance': '3.7 km',
      'lastDonation': '6 months ago',
      'available': false,
      'phone': '+880-1713-456789',
      'rating': 4.7,
    },
    {
      'name': 'Fatema Begum',
      'bloodType': 'AB+',
      'location': 'Mirpur',
      'distance': '8.2 km',
      'lastDonation': '2 weeks ago',
      'available': true,
      'phone': '+880-1714-567890',
      'rating': 5.0,
    },
    {
      'name': 'Karim Mia',
      'bloodType': 'O-',
      'location': 'Banani',
      'distance': '4.3 km',
      'lastDonation': '4 months ago',
      'available': true,
      'phone': '+880-1715-678901',
      'rating': 4.6,
    },
    {
      'name': 'Nusrat Jahan',
      'bloodType': 'A+',
      'location': 'Motijheel',
      'distance': '6.2 km',
      'lastDonation': '2 months ago',
      'available': true,
      'phone': '+880-1716-789012',
      'rating': 4.5,
    },
    {
      'name': 'Shahidul Islam',
      'bloodType': 'B-',
      'location': 'Khulna',
      'distance': '15.5 km',
      'lastDonation': '5 months ago',
      'available': false,
      'phone': '+880-1717-890123',
      'rating': 4.3,
    },
    {
      'name': 'Sabina Yasmin',
      'bloodType': 'AB-',
      'location': 'Chittagong',
      'distance': '22.3 km',
      'lastDonation': '3 weeks ago',
      'available': true,
      'phone': '+880-1718-901234',
      'rating': 4.8,
    },
    {
      'name': 'Jamil Hossain',
      'bloodType': 'O+',
      'location': 'Sylhet',
      'distance': '30.1 km',
      'lastDonation': '7 months ago',
      'available': true,
      'phone': '+880-1719-012345',
      'rating': 4.4,
    },
    {
      'name': 'Sharmin Akter',
      'bloodType': 'A+',
      'location': 'Rajshahi',
      'distance': '35.7 km',
      'lastDonation': '1 week ago',
      'available': true,
      'phone': '+880-1720-123456',
      'rating': 4.9,
    },
  ];
  List<Map<String, dynamic>> get filteredDonors {
    List<Map<String, dynamic>> result = List.from(_donors);

    if (_selectedBloodType != null) {
      result = result
          .where((donor) => donor['bloodType'] == _selectedBloodType)
          .toList();
    }

    if (_selectedLocation != null) {
      result = result
          .where((donor) => donor['location'] == _selectedLocation)
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Blood Donors',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Blood Type Selection
                Wrap(
                  spacing: 8,
                  children: _bloodTypes.map((bloodType) {
                    bool isSelected = _selectedBloodType == bloodType;
                    return ChoiceChip(
                      label: Text(bloodType),
                      selected: isSelected,
                      selectedColor: Colors.redAccent.withOpacity(0.2),
                      onSelected: (selected) {
                        setState(() {
                          _selectedBloodType = selected ? bloodType : null;
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.red : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      avatar: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.red)
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Location Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Locations'),
                    ),
                    ..._locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: filteredDonors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No donors found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different filters',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredDonors.length,
                    itemBuilder: (context, index) {
                      final donor = filteredDonors[index];
                      return _buildDonorCard(donor);
                    },
                  ),
          ),
        ],
      ),

      // Emergency Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEmergencyDialog,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.emergency),
        label: Text(
          'Emergency',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDonorCard(Map<String, dynamic> donor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            donor['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getBloodTypeColor(donor['bloodType']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              donor['bloodType'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            donor['location'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            donor['distance'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          donor['rating'].toString(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: donor['available']
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        donor['available'] ? 'Available' : 'Unavailable',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              donor['available'] ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Donor Info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Last donated: ${donor['lastDonation']}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactDonor(donor),
                    icon: const Icon(Icons.phone),
                    label: Text(
                      'Contact',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _requestDonation(donor),
                    icon: const Icon(Icons.bloodtype),
                    label: Text(
                      'Request',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // CHANGED TO GREEN
                      foregroundColor: Colors.white, // Added for better contrast
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'O-':
        return Colors.red[800]!;
      case 'O+':
        return Colors.red[600]!;
      case 'A-':
        return Colors.blue[800]!;
      case 'A+':
        return Colors.blue[600]!;
      case 'B-':
        return Colors.green[800]!;
      case 'B+':
        return Colors.green[600]!;
      case 'AB-':
        return Colors.purple[800]!;
      case 'AB+':
        return Colors.purple[600]!;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Advanced Filters',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add more filter options here
              SwitchListTile(
                title: Text(
                  'Show only available donors',
                  style: GoogleFonts.poppins(),
                ),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: Text(
                  'Within 10 km radius',
                  style: GoogleFonts.poppins(),
                ),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // CHANGED TO GREEN
                foregroundColor: Colors.white, // Added for better contrast
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.emergency,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                'Emergency Request',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will notify all nearby donors immediately. Use only for urgent situations.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Blood Type Needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _bloodTypes.map((bloodType) {
                  return DropdownMenuItem(
                    value: bloodType,
                    child: Text(bloodType),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Hospital/Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Emergency Alert Sent',
                  'Nearby donors have been notified',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Send Emergency Alert'),
            ),
          ],
        );
      },
    );
  }

  void _contactDonor(Map<String, dynamic> donor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Contact ${donor['name']}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone: ${donor['phone']}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please be respectful when contacting donors.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Here you would implement actual calling functionality
                Get.snackbar(
                  'Calling...',
                  'Dialing ${donor['phone']}',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // CHANGED TO GREEN
                foregroundColor: Colors.white, // Added for better contrast
              ),
              child: const Text('Call Now'),
            ),
          ],
        );
      },
    );
  }

  void _requestDonation(Map<String, dynamic> donor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Request Donation',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getBloodTypeColor(donor['bloodType']),
                  child: Text(
                    donor['bloodType'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(donor['name']),
                subtitle: Text(donor['location']),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Request Sent',
                  'Donation request sent to ${donor['name']}',
                  backgroundColor: Colors.green, // CHANGED TO GREEN
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // CHANGED TO GREEN
                foregroundColor: Colors.white, // Added for better contrast
              ),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }
}