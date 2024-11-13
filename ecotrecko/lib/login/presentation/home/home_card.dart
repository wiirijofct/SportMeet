import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final void Function() onPressed;

  const HomeCard({
    Key? key,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    bool isDarkTheme = themeManager.themeData == darkTheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        backgroundColor:Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: ClipRect(
        child: SizedBox(
          height: 140,
          width: 140,
          child: LayoutGrid(
            columnSizes: [
              auto,
            ],
            rowSizes: [
              auto,
              auto,
            ],
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20), // Ajuste o valor de acordo com sua preferência
                  child: Icon(
                    icon,
                    size: 60,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "FredokaRegular",
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
