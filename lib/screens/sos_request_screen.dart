import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';

class SosRequestScreen extends StatefulWidget {
  const SosRequestScreen({super.key});

  @override
  State<SosRequestScreen> createState() => _SosRequestScreenState();
}

class _SosRequestScreenState extends State<SosRequestScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AuthController _authController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  
  String? _selectedBloodGroup;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isUrgent = true;
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        
        final requestData = {
          'user_id': _authController.currentUser!.id,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'blood_group': _selectedBloodGroup,
          'units_needed': int.tryParse(_unitsController.text.trim()) ?? 1,
          'location': _locationController.text.trim(),
          'is_urgent': _isUrgent,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
          'request_date': _selectedDate?.toIso8601String(),
          'request_time': _selectedTime?.format(context),
        };

        await _supabase.from('sos_requests').insert(requestData);
        
        Get.back();
        Get.snackbar(
          'Success',
          'SOS Request created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to create request: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create SOS Request'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Blood Request',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Request Title',
                  prefixIcon: Icon(Icons.title, color: Color(0xFFD32F2F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Blood Group
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Required Blood Group',
                  prefixIcon: Icon(Icons.bloodtype, color: Color(0xFFD32F2F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _bloodGroups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _selectedBloodGroup = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select blood group';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Units Needed
              TextFormField(
                controller: _unitsController,
                decoration: InputDecoration(
                  labelText: 'Units Needed',
                  prefixIcon: Icon(Icons.bloodtype_outlined, color: Color(0xFFD32F2F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter units needed';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location/Hospital',
                  prefixIcon: Icon(Icons.location_on, color: Color(0xFFD32F2F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFFD32F2F)),
                            SizedBox(width: 10),
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Color(0xFFD32F2F)),
                            SizedBox(width: 10),
                            Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Urgency
              SwitchListTile(
                title: Text('Urgent Request'),
                subtitle: Text('Mark as emergency'),
                value: _isUrgent,
                onChanged: (value) => setState(() => _isUrgent = value),
                activeColor: Color(0xFFD32F2F),
              ),
              SizedBox(height: 15),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Additional Details',
                  prefixIcon: Icon(Icons.description, color: Color(0xFFD32F2F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Send SOS Request',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}