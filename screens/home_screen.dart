import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _recentDonors = [];
  bool _isLoadingDonors = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentDonors();
  }

  Future<void> _fetchRecentDonors() async {
    try {
      setState(() => _isLoadingDonors = true);
      final response = await _supabase
          .from('users')
          .select('id, name, blood_group, phone, is_available, created_at')
          .eq('is_donor', true)
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(5);
      
      setState(() {
        _recentDonors = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching recent donors: $e');
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
        title: const Text('Blood Donation SOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecentDonors,
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
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD32F2F),
                      Color(0xFFB71C1C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? "User"}!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ready to save lives today?',
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
                    if (user?.isDonor == false)
                      Text(
                        'Need blood? Find donors below 👇',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Quick Actions
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
                  _buildActionCard(
                    icon: Icons.search,
                    title: 'Find Donors',
                    color: Colors.blue,
                    onTap: () {
                      Get.toNamed('/find-donors');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.emergency,
                    title: 'SOS Request',
                    color: Colors.red,
                    onTap: () {
                      Get.toNamed('/sos-request');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.calendar_today,
                    title: 'Donation Camp',
                    color: Colors.green,
                    onTap: () {
                      Get.toNamed('/donation-camps');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.person,
                    title: 'My Profile',
                    color: Colors.orange,
                    onTap: () {
                      Get.toNamed('/profile');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Recent Donors Section
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
                    '${_recentDonors.length} Available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              if (_isLoadingDonors)
                const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
              else if (_recentDonors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'No donors available',
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check back later',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentDonors.length,
                    itemBuilder: (context, index) {
                      final donor = _recentDonors[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: index < _recentDonors.length - 1
                                ? BorderSide(color: Colors.grey.shade100)
                                : BorderSide.none,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getBloodColor(donor['blood_group']),
                            child: Text(
                              donor['blood_group'].substring(0, 2),
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
                          subtitle: Text(
                            'Blood Group: ${donor['blood_group']}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.green, size: 20),
                                onPressed: () {
                                  Get.snackbar(
                                    'Call',
                                    'Calling ${donor['phone']}',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.blue, size: 20),
                                onPressed: () {
                                  Get.snackbar(
                                    'Message',
                                    'Messaging ${donor['name']}',
                                    backgroundColor: Colors.blue,
                                    colorText: Colors.white,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              if (_recentDonors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/find-donors');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All Donors',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFD32F2F)),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 30),

              // Recent Activity
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              _buildActivityItem(
                icon: Icons.check_circle,
                title: 'Last Donation',
                subtitle: '3 months ago',
                color: Colors.green,
              ),
              _buildActivityItem(
                icon: Icons.notifications,
                title: 'Recent Request',
                subtitle: '2 hours ago',
                color: Colors.blue,
              ),
              _buildActivityItem(
                icon: Icons.thumb_up,
                title: 'Thank You',
                subtitle: 'You helped save a life!',
                color: Colors.red,
              ),

              const SizedBox(height: 30),

              // Statistics
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatistic(
                      value: '${_recentDonors.length}',
                      label: 'Donors Online',
                    ),
                    _buildStatistic(
                      value: '12',
                      label: 'Donations',
                    ),
                    _buildStatistic(
                      value: user?.isAvailable == true ? 'Active' : 'Inactive',
                      label: 'Status',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Blood Group Distribution
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood Group Availability',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildBloodGroupChip('O+', _recentDonors.where((d) => d['blood_group'] == 'O+').length),
                        _buildBloodGroupChip('A+', _recentDonors.where((d) => d['blood_group'] == 'A+').length),
                        _buildBloodGroupChip('B+', _recentDonors.where((d) => d['blood_group'] == 'B+').length),
                        _buildBloodGroupChip('AB+', _recentDonors.where((d) => d['blood_group'] == 'AB+').length),
                        _buildBloodGroupChip('O-', _recentDonors.where((d) => d['blood_group'] == 'O-').length),
                        _buildBloodGroupChip('A-', _recentDonors.where((d) => d['blood_group'] == 'A-').length),
                        _buildBloodGroupChip('B-', _recentDonors.where((d) => d['blood_group'] == 'B-').length),
                        _buildBloodGroupChip('AB-', _recentDonors.where((d) => d['blood_group'] == 'AB-').length),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/sos-request');
        },
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionCard({
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

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildStatistic({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD32F2F),
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
  
  Widget _buildBloodGroupChip(String bloodGroup, int count) {
    return Chip(
      label: Text('$bloodGroup ($count)'),
      backgroundColor: _getBloodColor(bloodGroup).withOpacity(0.1),
      labelStyle: TextStyle(
        color: _getBloodColor(bloodGroup),
        fontWeight: FontWeight.bold,
      ),
      avatar: CircleAvatar(
        backgroundColor: _getBloodColor(bloodGroup),
        radius: 10,
        child: Text(
          bloodGroup.substring(0, 1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}