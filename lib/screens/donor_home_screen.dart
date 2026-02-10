import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _availableDonors = [];
  bool _isLoadingDonors = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDonors();
  }

  Future<void> _fetchAvailableDonors() async {
    try {
      setState(() => _isLoadingDonors = true);
      final response = await _supabase
          .from('users')
          .select('id, name, email, phone, blood_group, address, is_available, created_at')
          .eq('is_donor', true)
          .order('created_at', ascending: false)
          .limit(10);
      
      setState(() {
        _availableDonors = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching donors: $e');
    } finally {
      setState(() => _isLoadingDonors = false);
    }
  }

  Color _getBloodColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'O+': return Colors.red.shade700;
      case 'O-': return Colors.red.shade900;
      case 'A+': return Colors.blue.shade700;
      case 'A-': return Colors.blue.shade900;
      case 'B+': return Colors.green.shade700;
      case 'B-': return Colors.green.shade900;
      case 'AB+': return Colors.purple.shade700;
      case 'AB-': return Colors.purple.shade900;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAvailableDonors,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.currentUser;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section for Donor
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Donor ${user?.name ?? "Hero"}! 🩸',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Thank you for being a lifesaver!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.bloodtype, color: Colors.white, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Blood Group: ${user?.bloodGroup ?? "Not set"}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Available to Donate',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: user?.isAvailable ?? false,
                      onChanged: (value) async {
                        try {
                          await _authController.updateProfile(isAvailable: value);
                        } catch (e) {
                          debugPrint('Error updating availability: $e');
                        }
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.green.shade100,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Available Donors Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🩸 Available Donors',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_availableDonors.length} Total',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              if (_isLoadingDonors)
                const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
              else if (_availableDonors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No donors available',
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: _availableDonors.take(5).map((donor) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: donor != _availableDonors.take(5).last
                                ? BorderSide(color: Colors.grey.shade100)
                                : BorderSide.none,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getBloodColor(donor['blood_group']),
                            child: Text(
                              donor['blood_group'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            donor['name'],
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${donor['blood_group']}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              if (donor['address'] != null && donor['address'].isNotEmpty)
                                Text(
                                  donor['address'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              donor['is_available'] ? 'Available' : 'Busy',
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                            backgroundColor: donor['is_available'] 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              const SizedBox(height: 15),
              if (_availableDonors.length > 5)
                TextButton(
                  onPressed: () {
                    Get.toNamed('/find-donors');
                  },
                  child: Text(
                    'View All ${_availableDonors.length} Donors',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              
              // Emergency SOS Requests
              Text(
                '🆘 Emergency Requests',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.emergency, color: Colors.red),
                      title: Text(
                        'Urgent: O+ Blood Needed',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Dhaka Medical • 2 units'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Thank You!',
                            'You volunteered to help',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('HELP', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.emergency, color: Colors.orange),
                      title: Text(
                        'A+ Blood Required',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Square Hospital • 1 unit'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Thank You!',
                            'You volunteered to help',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('HELP', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Quick Actions for Donors
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildDonorActionCard(
                    icon: Icons.visibility,
                    title: 'View Requests',
                    color: Colors.red,
                    onTap: () {
                      Get.toNamed('/emergency-requests');
                    },
                  ),
                  _buildDonorActionCard(
                    icon: Icons.history,
                    title: 'My Donations',
                    color: Colors.purple,
                    onTap: () {
                      Get.toNamed('/donation-history');
                    },
                  ),
                  _buildDonorActionCard(
                    icon: Icons.calendar_today,
                    title: 'Donation Camps',
                    color: Colors.green,
                    onTap: () {
                      Get.toNamed('/donation-camps');
                    },
                  ),
                  _buildDonorActionCard(
                    icon: Icons.person,
                    title: 'My Profile',
                    color: Colors.blue,
                    onTap: () {
                      Get.toNamed('/profile');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Donor Statistics
              Text(
                'My Donor Stats',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDonorStatistic('${_availableDonors.length}', 'Donors'),
                    _buildDonorStatistic('3', 'Lives Saved'),
                    _buildDonorStatistic('12', 'Points'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Next Donation Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue, size: 40),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Eligible Donation',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'You can donate again after: 15 Jan 2024',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Community Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Community Impact',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${_availableDonors.where((d) => d['blood_group'] == 'O+').length}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'O+ Donors',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${_availableDonors.where((d) => d['is_available'] == true).length}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Available Now',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildDonorActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDonorStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}