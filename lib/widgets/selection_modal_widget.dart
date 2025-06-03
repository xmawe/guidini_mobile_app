import 'package:flutter/material.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/city.dart';
import 'package:guidini/models/activity_category.dart';

class SelectionModalWidget<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) getDisplayText;
  final IconData Function(T)? getIcon;
  final Widget Function(T)? customItemBuilder;
  final void Function(T) onItemSelected;

  const SelectionModalWidget({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.getDisplayText,
    this.getIcon,
    this.customItemBuilder,
    required this.onItemSelected,
  });

  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) getDisplayText,
    IconData Function(T)? getIcon,
    Widget Function(T)? customItemBuilder,
    required void Function(T) onItemSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModalWidget<T>(
        title: title,
        items: items,
        selectedItem: selectedItem,
        getDisplayText: getDisplayText,
        getIcon: getIcon,
        customItemBuilder: customItemBuilder,
        onItemSelected: onItemSelected,
      ),
    );
  }

  // Convenience methods for specific types
  static Future<void> showCityModal({
    required BuildContext context,
    required List<City> cities,
    required City? selectedCity,
    required void Function(City?) onCitySelected,
  }) {
    return show<City>(
      context: context,
      title: 'Select City',
      items: cities,
      selectedItem: selectedCity,
      getDisplayText: (city) => '${city.name}, Morocco',
      getIcon: (city) => Icons.location_on,
      onItemSelected: onCitySelected,
    );
  }

  static Future<void> showCategoryModal({
    required BuildContext context,
    required List<ActivityCategory> categories,
    required ActivityCategory? selectedCategory,
    required void Function(ActivityCategory?) onCategorySelected,
  }) {
    return show<ActivityCategory>(
      context: context,
      title: 'Select Category',
      items: categories,
      selectedItem: selectedCategory,
      getDisplayText: (category) => category.name,
      getIcon: (category) => Icons.category,
      onItemSelected: onCategorySelected,
    );
  }

  static Future<void> showPriceModal({
    required BuildContext context,
    required List<Map<String, String>> priceRanges,
    required Map<String, String>? selectedPriceRange,
    required void Function(Map<String, String>?) onPriceRangeSelected,
  }) {
    return show<Map<String, String>>(
      context: context,
      title: 'Select Price Range',
      items: priceRanges,
      selectedItem: selectedPriceRange,
      getDisplayText: (range) => range['label']!,
      getIcon: (range) => Icons.attach_money,
      onItemSelected: onPriceRangeSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Items list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    if (customItemBuilder != null) {
                      return GestureDetector(
                        onTap: () {
                          onItemSelected(item);
                          Navigator.pop(context);
                        },
                        child: customItemBuilder!(item),
                      );
                    }

                    // Default item builder
                    return _buildDefaultItem(context, item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultItem(BuildContext context, T item) {
    final isSelected = selectedItem == item;

    return ListTile(
      leading: getIcon != null
          ? Icon(
              getIcon!(item),
              color: isSelected ? AppColors.primaryRed : Colors.grey[400],
            )
          : null,
      title: Text(
        getDisplayText(item),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primaryRed : Colors.black,
          fontFamily: 'InstrumentSans',
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primaryRed,
            )
          : null,
      onTap: () {
        onItemSelected(item);
        Navigator.pop(context);
      },
    );
  }
}
