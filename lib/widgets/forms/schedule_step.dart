import 'package:flutter/material.dart';
import 'package:guidini/models/tour_date_data.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/widgets/custom_input_field.dart';

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

  Future<void> _selectTime(
      BuildContext context, int index, bool isStartTime) async {
    final tourDate = widget.tourDates[index];
    final currentTime = isStartTime ? tourDate.startTime : tourDate.endTime;

    // Parse current time or use default
    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    if (currentTime != null && currentTime.isNotEmpty) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initialTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    } else if (!isStartTime) {
      initialTime = const TimeOfDay(hour: 17, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      final updatedDate = TourDateData(
        dayOfWeek: tourDate.dayOfWeek,
        startTime: isStartTime ? timeString : tourDate.startTime,
        endTime: isStartTime ? tourDate.endTime : timeString,
      );
      _updateTourDate(index, updatedDate);
    }
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
                'Tour Schedule',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addTourDate,
                icon: const Icon(Icons.add),
                label: const Text('Add Schedule'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary800,
                ),
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
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: tourDate.dayOfWeek,
              decoration: customInputDecoration(
                label: 'Day of Week',
                prefixIcon: const Icon(Icons.calendar_today_outlined,
                    color: AppColors.gray300, size: 20),
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
            const SizedBox(height: 20),

            // Creative Time Picker Section
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePickerCard(
                        context: context,
                        index: index,
                        isStartTime: true,
                        title: 'Start Time',
                        time: tourDate.startTime ?? '09:00',
                        icon: Icons.play_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePickerCard(
                        context: context,
                        index: index,
                        isStartTime: false,
                        title: 'End Time',
                        time: tourDate.endTime ?? '17:00',
                        icon: Icons.stop_circle_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard({
    required BuildContext context,
    required int index,
    required bool isStartTime,
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _selectTime(context, index, isStartTime),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gray100,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
