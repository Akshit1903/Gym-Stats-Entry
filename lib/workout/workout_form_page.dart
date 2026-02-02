import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/services/samsung_health.dart';
import 'package:gym_stats_entry_client/workout/fields/field_model.dart';
import 'package:gym_stats_entry_client/workout/fields/fields.dart';
import 'package:gym_stats_entry_client/workout/workflow_type.dart';
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
  WorkflowType _workflowType = WorkflowType.workoutLog;

  @override
  void initState() {
    super.initState();
    _dateController.text = Utils.formatDate(DateTime.now());
    for (FieldModel field in [...BODY_MEASUREMENT_FIELDS, ...EXERCISE_FIELDS]) {
      field.init();
    }
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
    for (FieldModel field in [...BODY_MEASUREMENT_FIELDS, ...EXERCISE_FIELDS]) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    // Refresh the page if settings were updated
    if (mounted && result == true) {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    switch (_workflowType) {
      case WorkflowType.workoutLog:
        final workoutData = {
          'Date': Utils.parseFormattedDate(
            _dateController.text,
          ).toIso8601String(),
          ...{
            for (final field in [
              ...BODY_MEASUREMENT_FIELDS,
              ...EXERCISE_FIELDS,
            ])
              field.name: field.valueTransformer(field.controller?.text ?? ''),
          },
        };
        await _appsScriptsClient.submitWorkoutLog(workoutData, context);
        break;
      case WorkflowType.cutLog:
        final cutData = {
          'Date': Utils.parseFormattedDate(
            _dateController.text,
          ).toIso8601String(),
          ...{
            for (final field in BODY_MEASUREMENT_FIELDS)
              field.name: field.valueTransformer(field.controller?.text ?? ''),
          },
        };
        await _appsScriptsClient.submitCutLog(cutData, context);
        break;
    }

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
    setState(() {
      _isFetchingFromSamsungHealth = true;
    });
    final Map<String, String>? data =
        await SamsungHealth.getBodyCompositionAndExerciseData();

    if (data != null && mounted) {
      setState(() {
        for (final field in [...BODY_MEASUREMENT_FIELDS, ...EXERCISE_FIELDS]) {
          final samsungKey = field.samsungHealthDataKey;
          if (samsungKey != null && data.containsKey(samsungKey)) {
            field.controller?.text = field
                .valueTransformer(data[samsungKey] ?? '')
                .toString();
          }
        }
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
    if (mounted) {
      setState(() {
        _isFetchingFromSamsungHealth = false;
      });
    }
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
    for (final field in [...BODY_MEASUREMENT_FIELDS, ...EXERCISE_FIELDS]) {
      field.controller?.clear();
    }
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
                    _setNextWorkoutType();
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
                const SizedBox(height: 32),

                _buildWorkflowDropdown(),
                const SizedBox(height: 24),
                // Date Field
                _buildDateField(),

                if (_isFetchingFromSamsungHealth) LinearProgressIndicator(),
                const SizedBox(height: 24),

                // Body Measurements Section
                if ([
                  WorkflowType.workoutLog,
                  WorkflowType.cutLog,
                ].contains(_workflowType)) ...[
                  _buildSectionHeader('Body Measurements'),
                  const SizedBox(height: 16),
                  ..._buildSectionBody(BODY_MEASUREMENT_FIELDS),
                  const SizedBox(height: 8),
                ],
                // Workout Section
                if ([WorkflowType.workoutLog].contains(_workflowType)) ...[
                  _buildSectionHeader('Workout Details'),
                  const SizedBox(height: 16),
                  _buildWorkoutDropdown(),
                  const SizedBox(height: 16),
                  ..._buildSectionBody(EXERCISE_FIELDS),
                ],

                // Submit Button
                _buildSubmitButton(scheme),
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

  List<Widget> _buildSectionBody(List<FieldModel> fields) {
    List<List<Widget>> rows = [];
    for (FieldModel field in fields) {
      if (field.controller == null) {
        continue;
      }
      if (field.startsFromNewRow || rows.isEmpty) {
        rows.add([]);
      }
      rows.last.add(
        Expanded(
          child: _buildTextField(
            controller: field.controller,
            label: field.displayName,
            keyboardType: field.textInputType,
            maxLines: field.maxLines,
          ),
        ),
      );
    }
    return rows.map((rowFields) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            ...rowFields
                .expand((widget) => [widget, const SizedBox(width: 16)])
                .toList()
              ..removeLast(),
          ],
        ),
      );
    }).toList();
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

  Widget _buildWorkflowDropdown() {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<WorkflowType>(
      value: _workflowType,
      decoration: InputDecoration(
        labelText: 'Workflow Type',
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
        const DropdownMenuItem<WorkflowType>(
          value: null,
          child: Text('Select Workflow Type'),
        ),
        ...WorkflowType.values.map((WorkflowType type) {
          return DropdownMenuItem<WorkflowType>(
            value: type,
            child: Text(type.displayName),
          );
        }),
      ],
      onChanged: (WorkflowType? newValue) {
        setState(() {
          if (newValue != null) {
            _workflowType = newValue;
          }
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
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
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          overflow: TextOverflow.visible,
        ),
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

  Widget _buildSubmitButton(ColorScheme scheme) {
    return SizedBox(
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Workout Entry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
