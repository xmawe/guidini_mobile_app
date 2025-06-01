// widgets/activities_step.dart
import 'package:flutter/material.dart';
import 'package:guidini/models/activity_data.dart';
import 'activity_card.dart';

class ActivitiesStep extends StatelessWidget {
  final List<ActivityData> activities;
  final List<dynamic> activityCategories;
  final Function(List<ActivityData>) onActivitiesChanged;

  const ActivitiesStep({
    Key? key,
    required this.activities,
    required this.activityCategories,
    required this.onActivitiesChanged,
  }) : super(key: key);

  void _addActivity() {
    final updatedActivities = List<ActivityData>.from(activities);
    updatedActivities.add(ActivityData());
    onActivitiesChanged(updatedActivities);
  }

  void _removeActivity(int index) {
    if (activities.length > 1) {
      final updatedActivities = List<ActivityData>.from(activities);
      updatedActivities.removeAt(index);
      onActivitiesChanged(updatedActivities);
    }
  }

  void _onActivityChanged() {
    // Trigger a rebuild by calling the parent's callback
    // This ensures the parent widget knows the activities have been modified
    onActivitiesChanged(activities);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activities',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addActivity,
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'At least one complete activity is required',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ActivityCard(
                index: index,
                activity: activities[index],
                activityCategories: activityCategories,
                canDelete: activities.length > 1,
                onDelete: () => _removeActivity(index),
                onChanged: _onActivityChanged,
              );
            },
          ),
        ],
      ),
    );
  }
}
