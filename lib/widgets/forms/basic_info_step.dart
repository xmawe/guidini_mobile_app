import 'package:flutter/material.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/widgets/custom_input_field.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController durationController;
  final TextEditingController maxGroupSizeController;
  final List<dynamic> cities;
  final int? selectedCityId;
  final String availabilityStatus;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final Function(int?) onCityChanged;
  final Function(String?) onAvailabilityChanged;
  final Function(bool?) onTransportChanged;
  final Function(bool?) onFoodChanged;

  const BasicInfoStep({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.durationController,
    required this.maxGroupSizeController,
    required this.cities,
    required this.selectedCityId,
    required this.availabilityStatus,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.onCityChanged,
    required this.onAvailabilityChanged,
    required this.onTransportChanged,
    required this.onFoodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: titleController,
            decoration: customInputDecoration(
              label: 'Tour Title',
              hint: 'Enter tour title',
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: customInputDecoration(
              label: 'Description',
              hint: 'Enter tour description',
            ),
            maxLines: 4,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: priceController,
                  decoration: customInputDecoration(
                    label: 'Price',
                    hint: 'Enter price',
                    prefixIcon: const Icon(Icons.attach_money,
                        color: AppColors.gray300),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Price is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: durationController,
                  decoration: customInputDecoration(
                    label: 'Duration (hours)',
                    hint: 'Enter duration',
                    prefixIcon: const Icon(Icons.timer_outlined,
                        color: AppColors.gray300),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Duration is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: maxGroupSizeController,
                  decoration: customInputDecoration(
                    label: 'Max Group Size',
                    hint: 'Enter max group size',
                    prefixIcon: const Icon(Icons.group_outlined,
                        color: AppColors.gray300),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Max group size is required'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedCityId,
                  decoration: customInputDecoration(
                    label: 'City',
                    hint: 'Select a city',
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: AppColors.gray300),
                  ),
                  items: cities.map<DropdownMenuItem<int>>((city) {
                    return DropdownMenuItem<int>(
                      value: city['id'],
                      child: Text(city['name']),
                    );
                  }).toList(),
                  onChanged: onCityChanged,
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: availabilityStatus,
            decoration: customInputDecoration(
              label: 'Availability Status',
              hint: 'Select availability status',
            ),
            items: const [
              DropdownMenuItem(value: 'available', child: Text('Available')),
              DropdownMenuItem(
                  value: 'unavailable', child: Text('Unavailable')),
            ],
            onChanged: onAvailabilityChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Transport Included',
                  ),
                  value: isTransportIncluded,
                  onChanged: onTransportChanged,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary800,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Food Included'),
                  value: isFoodIncluded,
                  onChanged: onFoodChanged,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
