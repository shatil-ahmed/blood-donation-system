import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AuthController _authController = Get.find();
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalDonors = 0;
  int _totalRecipients = 0;
  int _activeUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      
      setState(() {
        _allUsers = List<Map<String, dynamic>>.from(response);
        _totalUsers = _allUsers.length;
        _totalDonors = _allUsers.where((user) => user['is_donor'] == true).length;
        _totalRecipients = _allUsers.where((user) => user['is_donor'] == false).length;
        _activeUsers = _allUsers.where((user) => user['is_available'] == true).length;
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getUserTypeColor(bool isDonor) {
    return isDonor ? Colors.green : Colors.blue;
  }

  Color _getBloodColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'O+': return Colors.red[700]!;
      case 'O-': return Colors.red[900]!;
      case 'A+': return Colors.blue[700]!;
      case 'A-': return Colors.blue[900]!;
      case 'B+': return Colors.green[700]!;
      case 'B-': return Colors.green[900]!;
      case 'AB+': return Colors.purple[700]!;
      case 'AB-': return Colors.purple[900]!;
      default: return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAllUsers,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                          'Admin Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage all registered users',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Statistics Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildStatCard(
                        title: 'Total Users',
                        value: _totalUsers.toString(),
                        color: Colors.blue,
                        icon: Icons.people,
                      ),
                      _buildStatCard(
                        title: 'Donors',
                        value: _totalDonors.toString(),
                        color: Colors.green,
                        icon: Icons.bloodtype,
                      ),
                      _buildStatCard(
                        title: 'Recipients',
                        value: _totalRecipients.toString(),
                        color: Colors.orange,
                        icon: Icons.medical_services,
                      ),
                      _buildStatCard(
                        title: 'Active',
                        value: _activeUsers.toString(),
                        color: Colors.purple,
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Blood Group Distribution
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Group Distribution',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildBloodGroupStat('O+'),
                            _buildBloodGroupStat('A+'),
                            _buildBloodGroupStat('B+'),
                            _buildBloodGroupStat('AB+'),
                            _buildBloodGroupStat('O-'),
                            _buildBloodGroupStat('A-'),
                            _buildBloodGroupStat('B-'),
                            _buildBloodGroupStat('AB-'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // All Users List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Registered Users (${_allUsers.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sorted by: Newest First',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  _allUsers.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                              SizedBox(height: 20),
                              Text(
                                'No users registered yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Users will appear here after signing up',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _allUsers.length,
                          itemBuilder: (context, index) {
                            final user = _allUsers[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _getUserTypeColor(user['is_donor']),
                                        child: Icon(
                                          user['is_donor'] 
                                              ? Icons.bloodtype 
                                              : Icons.medical_services,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        user['name'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user['email']),
                                          SizedBox(height: 2),
                                          Text(
                                            'Joined: ${_formatDate(user['created_at'])}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: user['is_donor']
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user['is_donor'] ? 'Donor' : 'Recipient',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: user['is_donor']
                                                    ? Colors.green
                                                    : Colors.blue,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: user['is_available']
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user['is_available'] ? 'Active' : 'Inactive',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: user['is_available']
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getBloodColor(user['blood_group']),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              user['blood_group'],
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          if (user['phone'] != null && user['phone'].isNotEmpty)
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 14, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                  user['phone'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (user['address'] != null && user['address'].isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                user['address'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 30),

                  // Export Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Export',
                          'User data export feature coming soon',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      icon: Icon(Icons.download),
                      label: Text('Export User Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupStat(String bloodGroup) {
    final count = _allUsers.where((user) => user['blood_group'] == bloodGroup).length;
    final percentage = _totalUsers > 0 ? (count / _totalUsers * 100).toStringAsFixed(1) : '0.0';
    
    return Container(
      width: 80,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getBloodColor(bloodGroup).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getBloodColor(bloodGroup).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            bloodGroup,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getBloodColor(bloodGroup),
            ),
          ),
          SizedBox(height: 5),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}