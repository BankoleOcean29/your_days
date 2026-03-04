import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/theme/color_tokens.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    // spec: active = primary, inactive icon = neutral.400, label = neutral.500
    final inactiveIcon =
        isLight ? ColorTokens.neutral400Light : ColorTokens.neutral400Dark;
    final inactiveLabel =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    // spec: top border 1dp neutral.200
    final borderColor =
        isLight ? ColorTokens.neutral200Light : ColorTokens.neutral200Dark;
    final bgColor =
        isLight ? ColorTokens.neutral50Light : ColorTokens.neutral50Dark;
    // spec: active indicator = primary.container (small pill 32×24dp, radius.full)
    final indicatorColor = primary.withAlpha(30);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // spec: 64dp height
        height: 64,
        backgroundColor: bgColor,
        indicatorColor: indicatorColor,
        indicatorShape: const StadiumBorder(),
        // Label styles
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? primary : inactiveLabel,
          );
        }),
        // Icon themes
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected ? primary : inactiveIcon,
          );
        }),
      ),
      child: Container(
        // spec: top border 1dp neutral.200, no elevation
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.circle_outlined),
              selectedIcon: Icon(Icons.circle),
              label: 'Grid',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_quote_outlined),
              selectedIcon: Icon(Icons.format_quote),
              label: 'Word',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
