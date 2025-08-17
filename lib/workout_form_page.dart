import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_stats_entry_client/settings_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './auth.dart';
import './settings_page.dart';
import './samsung_health_service.dart';

// Workout type enum
enum WorkoutType {
  upper('Upper'),
  lower('Lower'),
  push('Push'),
  pull('Pull'),
  legs('Legs'),
  active('Active');

  const WorkoutType(this.displayName);
  final String displayName;
}

class WorkoutFormPage extends StatefulWidget {
  const WorkoutFormPage({super.key, required this.user, this.onSignOut});

  final GoogleSignInAccount user;
  final VoidCallback? onSignOut;

  @override
  State<WorkoutFormPage> createState() => _WorkoutFormPageState();
}

class _WorkoutFormPageState extends State<WorkoutFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  bool _isSubmitting = false;
  WorkoutType _selectedWorkout = WorkoutType.upper;

  // Form field controllers
  final _bodyweightController = TextEditingController();
  final _skeletalMassController = TextEditingController();
  final _fatMassController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  final _bmrController = TextEditingController();
  final _energyController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _bodyweightController.dispose();
    _skeletalMassController.dispose();
    _fatMassController.dispose();
    _bodyWaterController.dispose();
    _fatPercentageController.dispose();
    _bmrController.dispose();
    _energyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  DateTime _parseFormattedDate(String formattedDate) {
    final parts = formattedDate.split(' ');
    if (parts.length == 2) {
      final month = parts[0];
      final day = int.tryParse(parts[1]);
      if (day != null) {
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final monthIndex = months.indexOf(month);
        if (monthIndex != -1) {
          final year = DateTime.now().year;
          return DateTime(year, monthIndex + 1, day);
        }
      }
    }
    return DateTime.now();
  }

  Future<void> _signOut() async {
    final authService = AuthService();
    await authService.signOut();
    if (widget.onSignOut != null) {
      widget.onSignOut!();
    }
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    // Refresh the page if settings were updated
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _fetchSamsungHealthData() async {
    try {
      final samsungHealthService = SamsungHealthService();

      // Check if Samsung Health is available
      final isAvailable = await samsungHealthService.isAvailable();
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Samsung Health is not available on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Request permissions
      final hasPermissions = await samsungHealthService.requestPermissions();
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied for Samsung Health data'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get the selected date
      final selectedDate = _parseFormattedDate(_dateController.text);

      // Check if data exists for the selected date
      final hasData = await samsungHealthService.hasDataForDate(selectedDate);
      if (!hasData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No Samsung Health data available for the selected date',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching data from Samsung Health...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Fetch data from Samsung Health
      final healthData = await samsungHealthService.fetchDataForDate(
        selectedDate,
      );

      if (healthData != null && mounted) {
        setState(() {
          if (healthData.bodyweight != null) {
            _bodyweightController.text = healthData.bodyweight!.toString();
          }
          if (healthData.skeletalMass != null) {
            _skeletalMassController.text = healthData.skeletalMass!.toString();
          }
          if (healthData.fatMass != null) {
            _fatMassController.text = healthData.fatMass!.toString();
          }
          if (healthData.bodyWater != null) {
            _bodyWaterController.text = healthData.bodyWater!.toString();
          }
          if (healthData.fatPercentage != null) {
            _fatPercentageController.text = healthData.fatPercentage!
                .toString();
          }
          if (healthData.bmr != null) {
            _bmrController.text = healthData.bmr!.toString();
          }
          if (healthData.energy != null) {
            _energyController.text = healthData.energy!.toString();
          }
          if (healthData.notes != null) {
            _notesController.text = healthData.notes!;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported from Samsung Health!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch data from Samsung Health'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Future<String?> getAccessToken(
      GoogleSignInAccount? googleSignInAccount,
    ) async {
      if (googleSignInAccount == null) {
        return null;
      }
      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      return googleSignInAuthentication.accessToken;
    }

    try {
      // Prepare the data for the POST request
      final workoutData = {
        'Date': _dateController.text,
        'Bodyweight': double.tryParse(_bodyweightController.text) ?? 0.0,
        'SkeletalMass': double.tryParse(_skeletalMassController.text) ?? 0.0,
        'FatMass': double.tryParse(_fatMassController.text) ?? 0.0,
        'BodyWater': double.tryParse(_bodyWaterController.text) ?? 0.0,
        'FatPercent': double.tryParse(_fatPercentageController.text) ?? 0.0,
        'BMR': double.tryParse(_bmrController.text) ?? 0.0,
        'Workout': _selectedWorkout.displayName,
        'Energy': int.tryParse(_energyController.text) ?? 0,
        'Notes': _notesController.text,
      };

      // Get API URL from settings
      final apiUrl = await SettingsService().getApiUrl();
      if (apiUrl.isEmpty) {
        throw Exception('API URL not configured. Please set it in Settings.');
      }
      final authorization = await getAccessToken(widget.user);
      final Uri uri = Uri.parse(await SettingsService().getApiUrl());
      var headers = {
        if (authorization != null) 'Authorization': "Bearer $authorization",
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": "addBodyCompositionEntry",
        "parameters": [workoutData],
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout entry added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form after successful submission
          _formKey.currentState!.reset();
          _dateController.text = _formatDate(DateTime.now());
          _selectedWorkout = WorkoutType.upper;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add workout entry. Status: ${response.statusCode.toString() + " Message: " + (response.reasonPhrase ?? "")}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Add Workout Entry'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: scheme.onSurfaceVariant),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.user.photoUrl ?? ''),
            radius: 16,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.logout, color: scheme.onSurfaceVariant),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Track Your Progress',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your workout details and body measurements',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Date Field
                _buildDateField(),
                const SizedBox(height: 24),

                // Samsung Health Integration Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _fetchSamsungHealthData,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: scheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.health_and_safety, color: scheme.primary),
                    label: Text(
                      'Import from Samsung Health',
                      style: TextStyle(color: scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Body Measurements Section
                _buildSectionHeader('Body Measurements'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _bodyweightController,
                        label: 'Bodyweight (kg)',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _skeletalMassController,
                        label: 'Skeletal Mass (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatMassController,
                        label: 'Fat Mass (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bodyWaterController,
                        label: 'Body Water (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fatPercentageController,
                        label: 'Fat %',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bmrController,
                        label: 'BMR',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Workout Section
                _buildSectionHeader('Workout Details'),
                const SizedBox(height: 16),

                _buildWorkoutDropdown(),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _energyController,
                  label: 'Energy (kcal)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit Workout Entry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildWorkoutDropdown() {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<WorkoutType>(
      value: _selectedWorkout,
      decoration: InputDecoration(
        labelText: 'Workout Type',
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: WorkoutType.values.map((WorkoutType type) {
        return DropdownMenuItem<WorkoutType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (WorkoutType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedWorkout = newValue;
          });
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _parseFormattedDate(_dateController.text),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (date != null) {
          _dateController.text = _formatDate(date);
        }
      },
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Date',
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: Icon(Icons.calendar_today, color: scheme.primary),
      ),
    );
  }
}
