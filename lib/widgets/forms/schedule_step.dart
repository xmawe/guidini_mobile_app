// widgets/forms/schedule_step.dart
import 'package:flutter/material.dart';
import 'package:guidini/models/tour_date_data.dart'; // Import the model

class ScheduleStep extends StatefulWidget {
  final List<TourDateData> tourDates;
  final Function(List<TourDateData>) onTourDatesChanged;

  const ScheduleStep({
    Key? key,
    required this.tourDates,
    required this.onTourDatesChanged,
  }) : super(key: key);

  @override
  State<ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends State<ScheduleStep> {
  void _addTourDate() {
    final updatedDates = List<TourDateData>.from(widget.tourDates);
    updatedDates.add(TourDateData());
    widget.onTourDatesChanged(updatedDates);
  }

  void _removeTourDate(int index) {
    final updatedDates = List<TourDateData>.from(widget.tourDates);
    updatedDates.removeAt(index);
    widget.onTourDatesChanged(updatedDates);
  }

  void _updateTourDate(int index, TourDateData updatedDate) {
    final updatedDates = List<TourDateData>.from(widget.tourDates);
    updatedDates[index] = updatedDate;
    widget.onTourDatesChanged(updatedDates);
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
                'Tour Schedule *',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addTourDate,
                icon: const Icon(Icons.add),
                label: const Text('Add Schedule'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'At least one tour schedule is required',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.tourDates.length,
            itemBuilder: (context, index) {
              return _buildScheduleCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(int index) {
    final tourDate = widget.tourDates[index];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule ${index + 1}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (tourDate.isValid())
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    if (widget.tourDates.length > 1)
                      IconButton(
                        onPressed: () => _removeTourDate(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: tourDate.dayOfWeek,
              decoration: const InputDecoration(
                labelText: 'Day of Week *',
                border: OutlineInputBorder(),
              ),
              items: days.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key + 1,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                final updatedDate = TourDateData(
                  dayOfWeek: value,
                  startTime: tourDate.startTime,
                  endTime: tourDate.endTime,
                );
                _updateTourDate(index, updatedDate);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: tourDate.startTime,
                    decoration: const InputDecoration(
                      labelText: 'Start Time (HH:MM) *',
                      border: OutlineInputBorder(),
                      hintText: '09:00',
                    ),
                    onChanged: (value) {
                      final updatedDate = TourDateData(
                        dayOfWeek: tourDate.dayOfWeek,
                        startTime: value,
                        endTime: tourDate.endTime,
                      );
                      _updateTourDate(index, updatedDate);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: tourDate.endTime,
                    decoration: const InputDecoration(
                      labelText: 'End Time (HH:MM) *',
                      border: OutlineInputBorder(),
                      hintText: '17:00',
                    ),
                    onChanged: (value) {
                      final updatedDate = TourDateData(
                        dayOfWeek: tourDate.dayOfWeek,
                        startTime: tourDate.startTime,
                        endTime: value,
                      );
                      _updateTourDate(index, updatedDate);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
