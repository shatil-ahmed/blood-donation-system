import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = Get.find();

  // Remove unused _bloodGroups variable or use it
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Chip(
                          backgroundColor: user?.isDonor == true
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          label: Text(
                            user?.isDonor == true ? 'DONOR' : 'RECIPIENT',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: user?.isDonor == true
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Personal Information
            _buildSectionTitle('Personal Information'),
            SizedBox(height: 15),
            _buildInfoRow('Blood Group', user?.bloodGroup ?? 'Not set'),
            _buildInfoRow('Phone', user?.phone ?? 'Not set'),
            _buildInfoRow('Address', user?.address ?? 'Not set'),
            SizedBox(height: 30),

            // Account Status
            _buildSectionTitle('Account Status'),
            SizedBox(height: 15),
            SwitchListTile(
              title: Text('Available for Donation'),
              subtitle: Text('Toggle your availability status'),
              value: user?.isAvailable ?? false,
              onChanged: (value) {
                // TODO: Implement availability toggle
              },
              activeColor: Color(0xFFD32F2F),
              activeTrackColor: Color(0xFFD32F2F).withOpacity(0.5),
            ),
            SizedBox(height: 30),

            // Statistics
            _buildSectionTitle('My Statistics'),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatistic('12', 'Donations'),
                  _buildStatistic('5', 'Lives Saved'),
                  _buildStatistic('3', 'Requests'),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Actions
            Column(
              children: [
                _buildActionButton(
                  icon: Icons.history,
                  text: 'Donation History',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.help,
                  text: 'Help & Support',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.logout,
                  text: 'Logout',
                  textColor: Color(0xFFD32F2F),
                  onTap: () {
                    _authController.logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: Color(0xFFD32F2F)),
        SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFD32F2F)),
            SizedBox(width: 15),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: textColor ?? Colors.black,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
