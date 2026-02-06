import 'package:flutter/material.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class LocationFilterDialog extends StatefulWidget {
  final List<String> allLocations;
  final List<String> selectedLocations;

  const LocationFilterDialog({
    super.key,
    required this.allLocations,
    required this.selectedLocations,
  });

  @override
  State<LocationFilterDialog> createState() => _LocationFilterDialogState();
}

class _LocationFilterDialogState extends State<LocationFilterDialog> {
  late List<String> _selectedLocations;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocations = List.from(widget.selectedLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return widget.allLocations;
    }
    return widget.allLocations
        .where(
          (location) =>
              location.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  bool get _isAllSelected =>
      _selectedLocations.isEmpty ||
      _selectedLocations.length == widget.allLocations.length;

  void _toggleAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedLocations.clear();
      } else {
        _selectedLocations = List.from(widget.allLocations);
      }
    });
  }

  void _toggleLocation(String location) {
    setState(() {
      if (_selectedLocations.contains(location)) {
        _selectedLocations.remove(location);
      } else {
        _selectedLocations.add(location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C2333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search locations...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // All Locations Option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleAll,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isAllSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAllSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAllSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: _isAllSelected ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'All Locations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location List
            Expanded(
              child: _filteredLocations.isEmpty
                  ? Center(
                      child: Text(
                        'No locations found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        final isSelected = _selectedLocations.contains(
                          location,
                        );

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _toggleLocation(location),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocations.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedLocations);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
