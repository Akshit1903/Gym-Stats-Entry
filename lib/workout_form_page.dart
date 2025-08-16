import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './auth.dart';

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

  // Form field controllers
  final _bodyweightController = TextEditingController();
  final _skeletalMassController = TextEditingController();
  final _fatMassController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  final _bmrController = TextEditingController();
  final _workoutController = TextEditingController();
  final _energyController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
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
    _workoutController.dispose();
    _energyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final authService = AuthService();
    await authService.signOut();
    if (widget.onSignOut != null) {
      widget.onSignOut!();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare the data for the POST request
      final workoutData = {
        'date': _dateController.text,
        'bodyweight': double.tryParse(_bodyweightController.text) ?? 0.0,
        'skeletalMass': double.tryParse(_skeletalMassController.text) ?? 0.0,
        'fatMass': double.tryParse(_fatMassController.text) ?? 0.0,
        'bodyWater': double.tryParse(_bodyWaterController.text) ?? 0.0,
        'fatPercentage': double.tryParse(_fatPercentageController.text) ?? 0.0,
        'bmr': double.tryParse(_bmrController.text) ?? 0.0,
        'workout': _workoutController.text,
        'energy': int.tryParse(_energyController.text) ?? 0,
        'notes': _notesController.text,
      };

      // TODO: Replace with your actual API endpoint
      const String apiUrl = 'YOUR_API_ENDPOINT_HERE';
      String token = (await widget.user.authHeaders)['accessToken'] ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(workoutData),
      );

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
          _dateController.text = DateTime.now().toIso8601String().split('T')[0];
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add workout entry. Status: ${response.statusCode}',
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

                // Body Measurements Section
                _buildSectionHeader('Body Measurements'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _bodyweightController,
                        label: 'Bodyweight (kg)',
                        hint: '70.5',
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
                        hint: '25.2',
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
                        hint: '15.8',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bodyWaterController,
                        label: 'Body Water (kg)',
                        hint: '42.3',
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
                        hint: '22.4',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bmrController,
                        label: 'BMR',
                        hint: '1650',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Workout Section
                _buildSectionHeader('Workout Details'),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _workoutController,
                  label: 'Workout',
                  hint: 'Upper body, chest, triceps',
                  maxLines: 2,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _energyController,
                  label: 'Energy (kcal)',
                  hint: '450',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Felt strong today, increased weight on bench press',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
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
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (date != null) {
          _dateController.text = date.toIso8601String().split('T')[0];
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
