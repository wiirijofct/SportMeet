import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onClear;
  final VoidCallback onFilter;

  const SearchBar({
    required this.searchController,
    required this.onClear,
    required this.onFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Ionicons.search),
              hintText: 'Search',
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
          ),
        ),
        IconButton(
          icon: const Icon(Ionicons.filter_outline),
          onPressed: onFilter,
        ),
      ],
    );
  }
}
