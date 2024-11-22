import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMeetPageNavigate;

  SearchAppBar({required this.onMeetPageNavigate});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Colors.red,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('SEARCH'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onMeetPageNavigate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('MEET'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}