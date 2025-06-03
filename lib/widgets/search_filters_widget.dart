import 'package:flutter/material.dart';
import 'package:guidini/constants/colors.dart' as AppColorUtils;
import 'package:guidini/models/city.dart';
import 'package:guidini/models/activity_category.dart';
import 'package:guidini/widgets/custom_input_field.dart';

class SearchFiltersWidget extends StatefulWidget {
  final TextEditingController searchController;
  final List<City> cities;
  final City? selectedCity;
  final List<ActivityCategory> activityCategories;
  final ActivityCategory? selectedActivityCategory;
  final List<Map<String, String>> priceRanges;
  final Map<String, String>? selectedPriceRange;
  final VoidCallback onCityTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onPriceTap;
  final VoidCallback onSearchPressed;
  final Function(String) onKeywordChanged;
  final ScrollController? scrollController;

  const SearchFiltersWidget({
    super.key,
    required this.searchController,
    required this.cities,
    required this.selectedCity,
    required this.activityCategories,
    required this.selectedActivityCategory,
    required this.priceRanges,
    required this.selectedPriceRange,
    required this.onCityTap,
    required this.onCategoryTap,
    required this.onPriceTap,
    required this.onSearchPressed,
    required this.onKeywordChanged,
    this.scrollController,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget>
    with SingleTickerProviderStateMixin {
  bool _showFilters = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add scroll listener to auto-hide filters when scrolling
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_handleScroll);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_showFilters && !_isScrolling) {
      setState(() {
        _isScrolling = true;
        _showFilters = false;
        _animationController.reverse();
      });

      // Reset scrolling flag after animation completes
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Custom decoration for dropdown fields matching CustomInputField style
  InputDecoration _customDropdownDecoration({
    required String label,
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColorUtils.AppColors.gray300,
      ),
      labelStyle: const TextStyle(
        color: AppColorUtils.AppColors.gray600,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColorUtils.AppColors.gray600,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: prefixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorUtils.AppColors.gray100,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorUtils.AppColors.primary800,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sticky search section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: _showFilters
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Search field with search icon button and filter toggle
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        label: 'Search',
                        hint: 'Search activity, guide, city',
                        controller: widget.searchController,
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColorUtils.AppColors.gray300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter toggle button
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? AppColorUtils.AppColors.primary800
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showFilters
                              ? AppColorUtils.AppColors.primary800
                              : AppColorUtils.AppColors.gray100,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _toggleFilters,
                        icon: Icon(
                          Icons.tune,
                          color: _showFilters
                              ? Colors.white
                              : AppColorUtils.AppColors.gray600,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search button
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColorUtils.AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: widget.onSearchPressed,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                // Animated filters section
                SizeTransition(
                  sizeFactor: _animation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      children: [
                        // City dropdown
                        GestureDetector(
                          onTap: widget.onCityTap,
                          child: AbsorbPointer(
                            child: DropdownButtonFormField<City>(
                              value: widget.selectedCity,
                              items: widget.cities.map((city) {
                                return DropdownMenuItem<City>(
                                  value: city,
                                  child: Text(city.name),
                                );
                              }).toList(),
                              onChanged: (city) {},
                              decoration: _customDropdownDecoration(
                                label: '',
                                hint: 'Select a city',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/images/icons/ic_city.png',
                                    width: 22,
                                    height: 22,
                                    color: AppColorUtils.AppColors.gray400,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.my_location_rounded,
                                        size: 20,
                                        color: AppColorUtils.AppColors.gray300,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category dropdown (separate row)
                        GestureDetector(
                          onTap: widget.onCategoryTap,
                          child: AbsorbPointer(
                            child: DropdownButtonFormField<ActivityCategory>(
                              value: widget.selectedActivityCategory,
                              items: widget.activityCategories.map((category) {
                                return DropdownMenuItem<ActivityCategory>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (category) {},
                              decoration: _customDropdownDecoration(
                                label: '',
                                hint: 'Select category',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/images/icons/ic_category.png',
                                    width: 22,
                                    height: 22,
                                    color: AppColorUtils.AppColors.gray400,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.category_outlined,
                                        size: 20,
                                        color: AppColorUtils.AppColors.gray300,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price dropdown (separate row)
                        GestureDetector(
                          onTap: widget.onPriceTap,
                          child: AbsorbPointer(
                            child: DropdownButtonFormField<Map<String, String>>(
                              value: widget.selectedPriceRange,
                              items: widget.priceRanges.map((range) {
                                return DropdownMenuItem<Map<String, String>>(
                                  value: range,
                                  child: Text(range['label']!),
                                );
                              }).toList(),
                              onChanged: (range) {},
                              decoration: _customDropdownDecoration(
                                label: '',
                                hint: 'Select price range',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/images/icons/ic_price.png',
                                    width: 22,
                                    height: 22,
                                    color: AppColorUtils.AppColors.gray400,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.attach_money,
                                        size: 20,
                                        color: AppColorUtils.AppColors.gray300,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
