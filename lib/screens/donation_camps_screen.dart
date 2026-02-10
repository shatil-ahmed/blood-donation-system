import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';

class DonationCampsScreen extends StatefulWidget {
  const DonationCampsScreen({super.key});

  @override
  State<DonationCampsScreen> createState() => _DonationCampsScreenState();
}

class _DonationCampsScreenState extends State<DonationCampsScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _camps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('donation_camps')
          .select()
          .order('date', ascending: true);
      
      setState(() {
        _camps = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching camps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Camps'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchCamps,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : _camps.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 20),
                      Text(
                        'No donation camps scheduled',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _camps.length,
                  itemBuilder: (context, index) {
                    final camp = _camps[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  camp['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD32F2F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Camp',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  _formatDate(camp['date']),
                                  style: GoogleFonts.poppins(),
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.access_time, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  '${camp['start_time']} - ${camp['end_time']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    camp['location'],
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              camp['description'] ?? '',
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement registration
                                  Get.snackbar(
                                    'Registration',
                                    'Registered for ${camp['name']}',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, // Changed from Color(0xFFD32F2F) to Colors.green
                                ),
                                child: Text('Register Now'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}