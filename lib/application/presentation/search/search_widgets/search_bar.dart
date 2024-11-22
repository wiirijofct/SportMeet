import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;

  const SearchBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Ionicons.search,
          color: Colors.black, ),
        hintText: 'Search',
        hintStyle: const TextStyle(
          color: Colors.black, // Sets the hint text color
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: IconButton(
          icon: const Icon(Ionicons.close_circle, color: Colors.red),
          onPressed: onClear,
        ),
      ),
    );
  }
}