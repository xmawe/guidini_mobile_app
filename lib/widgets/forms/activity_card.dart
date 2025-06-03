import 'package:flutter/material.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/activity_data.dart';
import 'package:guidini/widgets/custom_input_field.dart';
import 'package:guidini/widgets/location_picker_dialog.dart';

class ActivityCard extends StatefulWidget {
  final int index;
  final ActivityData activity;
  final List<dynamic> activityCategories;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const ActivityCard({
    Key? key,
    required this.index,
    required this.activity,
    required this.activityCategories,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.activity.description ?? '');
    _durationController =
        TextEditingController(text: widget.activity.duration?.toString() ?? '');

    // Add listeners to update the activity data when text changes
    _titleController.addListener(() {
      widget.activity.title = _titleController.text;
      widget.onChanged();
    });

    _descriptionController.addListener(() {
      widget.activity.description = _descriptionController.text;
      widget.onChanged();
    });

    _durationController.addListener(() {
      widget.activity.duration = int.tryParse(_durationController.text);
      widget.onChanged();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialLatitude: widget.activity.latitude != null &&
                widget.activity.latitude!.isNotEmpty
            ? double.tryParse(widget.activity.latitude!)
            : null,
        initialLongitude: widget.activity.longitude != null &&
                widget.activity.longitude!.isNotEmpty
            ? double.tryParse(widget.activity.longitude!)
            : null,
        initialLabel: widget.activity.locationLabel,
      ),
    );

    if (result != null) {
      setState(() {
        widget.activity.latitude = result['latitude'].toString();
        widget.activity.longitude = result['longitude'].toString();
        widget.activity.locationLabel = result['label'];
      });
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity ${widget.index + 1}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (widget.activity.isValid())
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    if (widget.canDelete)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Title',
              hint: 'Enter activity title',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: customInputDecoration(
                label: 'Description',
                hint: 'Enter activity description',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: widget.activity.categoryId,
              decoration: customInputDecoration(
                label: 'Category',
              ),
              items: widget.activityCategories
                  .map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                widget.activity.categoryId = value;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Duration (min)',
              hint: 'Enter duration in minutes',
              controller: _durationController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Location Picker Section
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Location Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: widget.activity.locationLabel != null
                    ? Colors.green[50]
                    : Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: widget.activity.locationLabel != null
                            ? Colors.green
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.activity.locationLabel ??
                              'No location selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: widget.activity.locationLabel != null
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.activity.latitude != null &&
                      widget.activity.longitude != null &&
                      widget.activity.latitude!.isNotEmpty &&
                      widget.activity.longitude!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${widget.activity.latitude}, Lng: ${widget.activity.longitude}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Location Picker Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openLocationPicker,
                icon: const Icon(Icons.map),
                label: Text(
                  widget.activity.locationLabel != null
                      ? 'Change Location'
                      : 'Select Location on Map',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
