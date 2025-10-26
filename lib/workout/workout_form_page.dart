import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/services/samsung_health.dart';
import 'package:provider/provider.dart';
import 'package:gym_stats_entry_client/apps_scripts_client.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import '../providers/auth_provider.dart';
import '../settings/settings_page.dart';
import '../graphs_page.dart';
import 'workout_type.dart';

class WorkoutFormPage extends StatefulWidget {
  const WorkoutFormPage({super.key});

  @override
  State<WorkoutFormPage> createState() => _WorkoutFormPageState();
}

class _WorkoutFormPageState extends State<WorkoutFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  bool _isSubmitting = false;
  bool _isFetchingFromSamsungHealth = false;
  late AppsScriptsClient _appsScriptsClient;
  String _noOfGymDays = "-";
  WorkoutType? _selectedWorkout;
  late AuthProvider _authProvider;

  // Form field controllers
  final _bodyweightController = TextEditingController();
  final _skeletalMassController = TextEditingController();
  final _fatMassController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  final _bmrController = TextEditingController();
  final _energyController = TextEditingController();
  final _avgHeartRateController = TextEditingController();
  final _maxHeartRateController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = Utils.formatDate(DateTime.now());
    _appsScriptsClient = AppsScriptsClient.instance;
    _handleNoOfGymDaysHomeWidgetUpdate();
    _fetchAndSetDataFromSamsungHealth();
    _setNextWorkoutType();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context);
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
    _avgHeartRateController.dispose();
    _maxHeartRateController.dispose();
    _notesController.dispose();
    super.dispose();
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

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    final workoutData = {
      'Date': _dateController.text,
      'Bodyweight': _bodyweightController.text.isNotEmpty
          ? double.tryParse(_bodyweightController.text)
          : null,
      'SkeletalMass': _skeletalMassController.text.isNotEmpty
          ? double.tryParse(_skeletalMassController.text)
          : null,
      'FatMass': _fatMassController.text.isNotEmpty
          ? double.tryParse(_fatMassController.text)
          : null,
      'BodyWater': _bodyWaterController.text.isNotEmpty
          ? double.tryParse(_bodyWaterController.text)
          : null,
      'FatPercent': _fatPercentageController.text.isNotEmpty
          ? double.tryParse(_fatPercentageController.text)
          : null,
      'BMR': _bmrController.text.isNotEmpty
          ? double.tryParse(_bmrController.text)
          : null,
      'Workout': _selectedWorkout?.displayName,
      'Energy': _energyController.text.isNotEmpty
          ? int.tryParse(_energyController.text)
          : null,
      'AvgHeartRate': _avgHeartRateController.text.isNotEmpty
          ? int.tryParse(_avgHeartRateController.text)
          : null,
      'MaxHeartRate': _maxHeartRateController.text.isNotEmpty
          ? int.tryParse(_maxHeartRateController.text)
          : null,
      'Notes': _notesController.text.isNotEmpty ? _notesController.text : null,
    };

    await _appsScriptsClient.submitBodyCompositionEntry(workoutData, context);
    _resetForm();
    _handleNoOfGymDaysHomeWidgetUpdate();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GraphsPage()),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  Future<void> _handleNoOfGymDaysHomeWidgetUpdate() async {
    setState(() {
      _isSubmitting = true;
    });

    _noOfGymDays = await _appsScriptsClient.getNumberOfGymDays(context);
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    Utils.updateNoOfGymDaysHomeWidget(_noOfGymDays);
  }

  Future<void> _fetchAndSetDataFromSamsungHealth() async {
    String? parseToTwoDecimals(String? value) {
      if (value == null) return null;
      final parsed = double.tryParse(value);
      if (parsed == null) return null;
      return double.parse(parsed.toStringAsFixed(2)).toString();
    }

    setState(() {
      _isFetchingFromSamsungHealth = true;
    });
    final Map<String, String>? data =
        await SamsungHealth.getBodyCompositionAndExerciseData();

    if (data != null && mounted) {
      String? basalMetabolicRate = data['basal_metabolic_rate'];
      String? bodyFatPercentage = parseToTwoDecimals(data['body_fat']);
      String? bodyFatMass = parseToTwoDecimals(data['body_fat_mass']);
      // String? fatFreeMass = data['fat_free_mass'];
      String? skeletalMuscleMass = parseToTwoDecimals(
        data['skeletal_muscle_mass'],
      );
      String? totalBodyWater = parseToTwoDecimals(data['total_body_water']);
      String? weight = data['weight'];
      String? calories = data['calories'];
      // String? duration = data['duration'];
      String? maxHeartRate = data['maxHeartRate'];
      String? meanHeartRate = data['meanHeartRate'];

      setState(() {
        _bodyweightController.text = weight ?? '';
        _skeletalMassController.text = skeletalMuscleMass ?? '';
        _fatMassController.text = bodyFatMass ?? '';
        _bodyWaterController.text = totalBodyWater ?? '';
        _fatPercentageController.text = bodyFatPercentage ?? '';
        _bmrController.text = basalMetabolicRate ?? '';
        _energyController.text = calories ?? '';
        _maxHeartRateController.text = maxHeartRate ?? '';
        _avgHeartRateController.text = meanHeartRate ?? '';
      });
    } else {
      if (mounted) {
        Utils.showSnackBar(
          "Could not fetch data from Samsung Health",
          Colors.red,
          context,
        );
      }
    }
    setState(() {
      _isFetchingFromSamsungHealth = false;
    });
  }

  Future<void> _setNextWorkoutType() async {
    String nextWorkoutTypeResponse = await _appsScriptsClient
        .getNextWorkoutType(context);
    WorkoutType? nextWorkoutType = WorkoutType.values.firstWhere(
      (type) => type.displayName == nextWorkoutTypeResponse,
      orElse: () => _selectedWorkout ?? WorkoutType.active,
    );
    if (mounted) {
      setState(() {
        _selectedWorkout = nextWorkoutType;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _dateController.text = Utils.formatDate(DateTime.now());
    _selectedWorkout = null;
    _bodyweightController.clear();
    _skeletalMassController.clear();
    _fatMassController.clear();
    _bodyWaterController.clear();
    _fatPercentageController.clear();
    _bmrController.clear();
    _energyController.clear();
    _avgHeartRateController.clear();
    _maxHeartRateController.clear();
    _notesController.clear();
  }

  Color _parseNoOfGymDaysColor(String noOfGymDays) {
    if (noOfGymDays == "-") {
      return Colors.white;
    }
    final days = int.tryParse(noOfGymDays) ?? 0;
    if (days >= 6) {
      return Colors.green;
    } else if (days >= 4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const FittedBox(child: Text('Add Workout Entry')),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    _handleNoOfGymDaysHomeWidgetUpdate();
                    _fetchAndSetDataFromSamsungHealth();
                  },
            icon: _isSubmitting
                ? SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(),
                  )
                : Icon(Icons.refresh, color: scheme.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphsPage()),
              ),
            },
            icon: Icon(Icons.auto_graph, color: scheme.onSurfaceVariant),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: scheme.onSurfaceVariant),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: NetworkImage(
              _authProvider.currentUser?.photoUrl ?? '',
            ),
            radius: 16,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.logout, color: scheme.onSurfaceVariant),
            onPressed: _authProvider.signOut,
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
                Row(
                  children: [
                    Text(
                      'Gym Consistency: ',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                    ),
                    Text(
                      _noOfGymDays,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _parseNoOfGymDaysColor(_noOfGymDays),
                          ),
                    ),
                  ],
                ),
                // FutureBuilder(
                //   future: HomeWidget.getWidgetData<String>(
                //     'no_of_gym_days_time',
                //   ),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasData && snapshot.data != null) {
                //       DateTime lastUpdated = DateTime.parse(
                //         snapshot.data!,
                //       ).toLocal();
                //       return Text(
                //         'Last updated: ${lastUpdated.hour}:${lastUpdated.minute}',
                //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //           color: scheme.onSurfaceVariant,
                //         ),
                //       );
                //     }
                //     return const SizedBox.shrink();
                //   },
                // ),
                const SizedBox(height: 32),

                // Date Field
                _buildDateField(),

                if (_isFetchingFromSamsungHealth) LinearProgressIndicator(),
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

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _avgHeartRateController,
                        label: 'Avg. Heart Rate (bpm)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _maxHeartRateController,
                        label: 'Max. Heart Rate (bpm)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
      items: [
        const DropdownMenuItem<WorkoutType>(
          value: null,
          child: Text('Select Workout Type'),
        ),
        ...WorkoutType.values.map((WorkoutType type) {
          return DropdownMenuItem<WorkoutType>(
            value: type,
            child: Text(type.displayName),
          );
        }).toList(),
      ],
      onChanged: (WorkoutType? newValue) {
        setState(() {
          _selectedWorkout = newValue;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
          initialDate: Utils.parseFormattedDate(_dateController.text),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (date != null) {
          _dateController.text = Utils.formatDate(date);
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
