import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/workout/fields/field_model.dart';
import 'package:gym_stats_entry_client/workout/fields/fields.dart';

class CutLogDiffFieldsPage extends StatelessWidget {
  const CutLogDiffFieldsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Impact Summary'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          _buildHeader('Body Composition'),
          _buildFieldGrid(
            BODY_MEASUREMENT_FIELDS
                .where((f) => f.diffResponseValue != null)
                .toList(),
          ),

          _buildHeader('Nutrition (Health Connect)'),
          _buildFieldGrid(
            NUTRITION_FIELDS.where((f) => f.diffResponseValue != null).toList(),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGrid(List<FieldModel> fields) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _MetricCard(field: fields[index]),
          childCount: fields.length,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final FieldModel field;
  const _MetricCard({required this.field});

  @override
  Widget build(BuildContext context) {
    final diff = field.valueTransformer(field.diffResponseValue) ?? 0.0;

    // Color Logic: moreTheMerrier = true means positive is good (green)
    // moreTheMerrier = false means positive is bad (red)
    Color displayColor = Colors.grey;
    if (diff > 0) {
      displayColor = field.moreTheMerrier
          ? Colors.greenAccent
          : Colors.redAccent;
    } else if (diff < 0) {
      displayColor = field.moreTheMerrier
          ? Colors.redAccent
          : Colors.greenAccent;
    }

    final prefix = diff > 0 ? "+" : "";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: displayColor.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              field.displayName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "$prefix${field.diffResponseValue ?? '0'}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: displayColor,
                fontFamily: 'Monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
