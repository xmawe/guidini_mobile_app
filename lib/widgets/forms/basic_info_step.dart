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
                    label: 'Price (\$)/Person',
                    hint: 'Enter price',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.gray300,
                      size: 20,
                    ),
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
                    prefixIcon: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.gray300,
                      size: 20,
                    ),
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
                    prefixIcon: const Icon(
                      Icons.group_outlined,
                      color: AppColors.gray300,
                      size: 20,
                    ),
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
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.gray300,
                      size: 20,
                    ),
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
          // const SizedBox(height: 24),
          // Creative Availability Status Section
          // _buildAvailabilitySection(),

          const SizedBox(height: 24),

          // Creative Inclusions Section
          _buildInclusionsSection(),
        ],
      ),
    );
  }

  // Widget _buildAvailabilitySection() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           AppColors.primary800.withOpacity(0.05),
  //           AppColors.primary800.withOpacity(0.02),
  //         ],
  //       ),
  //       border: Border.all(
  //         color: AppColors.primary800.withOpacity(0.1),
  //         width: 1,
  //       ),
  //     ),
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary800.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Icon(
  //                 Icons.schedule_outlined,
  //                 color: AppColors.primary800,
  //                 size: 20,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             const Text(
  //               'Availability Status',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: GestureDetector(
  //                 onTap: () => onAvailabilityChanged('available'),
  //                 child: AnimatedContainer(
  //                   duration: const Duration(milliseconds: 200),
  //                   padding: const EdgeInsets.symmetric(
  //                       vertical: 16, horizontal: 20),
  //                   decoration: BoxDecoration(
  //                     color: availabilityStatus == 'available'
  //                         ? AppColors.primary800
  //                         : Colors.transparent,
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(
  //                       color: availabilityStatus == 'available'
  //                           ? AppColors.primary800
  //                           : AppColors.gray300,
  //                       width: 2,
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(
  //                         Icons.check_circle_outline,
  //                         color: availabilityStatus == 'available'
  //                             ? Colors.white
  //                             : AppColors.gray300,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         'Available',
  //                         style: TextStyle(
  //                           color: availabilityStatus == 'available'
  //                               ? Colors.white
  //                               : AppColors.gray300,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: GestureDetector(
  //                 onTap: () => onAvailabilityChanged('unavailable'),
  //                 child: AnimatedContainer(
  //                   duration: const Duration(milliseconds: 200),
  //                   padding: const EdgeInsets.symmetric(
  //                       vertical: 16, horizontal: 20),
  //                   decoration: BoxDecoration(
  //                     color: availabilityStatus == 'unavailable'
  //                         ? Colors.red.shade600
  //                         : Colors.transparent,
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(
  //                       color: availabilityStatus == 'unavailable'
  //                           ? Colors.red.shade600
  //                           : AppColors.gray300,
  //                       width: 2,
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(
  //                         Icons.cancel_outlined,
  //                         color: availabilityStatus == 'unavailable'
  //                             ? Colors.white
  //                             : AppColors.gray300,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         'Unavailable',
  //                         style: TextStyle(
  //                           color: availabilityStatus == 'unavailable'
  //                               ? Colors.white
  //                               : AppColors.gray300,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInclusionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tour Inclusions',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        // Row(
        //   children: [
        //     Container(
        //       padding: const EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Colors.orange.shade100,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Icon(
        //         Icons.card_giftcard_outlined,
        //         color: Colors.orange.shade700,
        //         size: 20,
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     const Text(
        //       'Tour Inclusions',
        //       style: TextStyle(
        //         fontSize: 18,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 16),
        _buildInclusionCard(
          title: 'Transport Included',
          subtitle: 'Comfortable transportation provided',
          icon: Icons.directions_car_outlined,
          isSelected: isTransportIncluded,
          onChanged: onTransportChanged,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildInclusionCard(
          title: 'Food Included',
          subtitle: 'Delicious meals during the tour',
          icon: Icons.restaurant_outlined,
          isSelected: isFoodIncluded,
          onChanged: onFoodChanged,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInclusionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Function(bool?) onChanged,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.gray100,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: isSelected ? color : AppColors.gray300,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : AppColors.gray100,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.gray200,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.gray600 : AppColors.gray300,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.gray600 : AppColors.gray300,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
