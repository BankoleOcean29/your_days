import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/date_utils.dart';

class DotBottomSheet {
  DotBottomSheet._();

  static void show(
    BuildContext context, {
    required int dayNumber,
    required int currentDayOfYear,
    required int totalDays,
  }) {
    final year = DateTime.now().year;
    final date = AppDateUtils.fromDayOfYear(year, dayNumber);
    final dateStr = AppDateUtils.formatFull(date);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      // spec: 16dp corner radius, elevation 3
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        if (dayNumber < currentDayOfYear) {
          return _ExhaustedSheet(
            dateStr: dateStr,
            dayNumber: dayNumber,
            isLight: isLight,
            primary: primary,
          );
        } else if (dayNumber == currentDayOfYear) {
          return _TodaySheet(
            dateStr: dateStr,
            isLight: isLight,
            primary: primary,
          );
        } else {
          return _RemainingSheet(
            dateStr: dateStr,
            daysFrom: dayNumber - currentDayOfYear,
            isLight: isLight,
            primary: primary,
          );
        }
      },
    );
  }
}

// ── Drag handle — spec: 32×4dp, neutral.300, centered, 12dp top margin ────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final handleColor =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: handleColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Exhausted ─────────────────────────────────────────────────────────────────

class _ExhaustedSheet extends StatelessWidget {
  final String dateStr;
  final int dayNumber;
  final bool isLight;
  final Color primary;

  const _ExhaustedSheet({
    required this.dateStr,
    required this.dayNumber,
    required this.isLight,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final exhaustedColor =
        isLight ? ColorTokens.dotExhaustedLight : ColorTokens.dotExhaustedDark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          // spec: 24dp H, 16dp top (after handle), 24dp bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StateChip(label: 'Passed', color: exhaustedColor),
                const SizedBox(height: 12),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Day $dayNumber',
                  style: GoogleFonts.nunito(fontSize: 13, color: neutral500),
                ),
                const SizedBox(height: 16),
                Text(
                  'This day has passed.',
                  style: GoogleFonts.nunito(fontSize: 15, color: neutral500),
                ),
                const SizedBox(height: 20),
                _SheetButton(
                  label: 'Open journal for this day',
                  icon: Icons.book_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO(phase-future): navigate to journal entry for dayNumber
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today ─────────────────────────────────────────────────────────────────────

class _TodaySheet extends StatelessWidget {
  final String dateStr;
  final bool isLight;
  final Color primary;

  const _TodaySheet({
    required this.dateStr,
    required this.isLight,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StateChip(label: 'Today', color: primary),
                const SizedBox(height: 12),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _SheetButton(
                  label: 'Write about today',
                  icon: Icons.edit_outlined,
                  isPrimary: true,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO(phase-future): navigate to journal editor for today
                  },
                ),
                const SizedBox(height: 10),
                _SheetButton(
                  label: 'Add a milestone',
                  icon: Icons.flag_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO(phase-future): milestone creation
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Make it count.',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: neutral500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Remaining ─────────────────────────────────────────────────────────────────

class _RemainingSheet extends StatelessWidget {
  final String dateStr;
  final int daysFrom;
  final bool isLight;
  final Color primary;

  const _RemainingSheet({
    required this.dateStr,
    required this.daysFrom,
    required this.isLight,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final remainingColor = isLight
        ? ColorTokens.dotRemainingLight
        : ColorTokens.dotRemainingDark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StateChip(label: 'Ahead', color: remainingColor),
                const SizedBox(height: 12),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  daysFrom == 1 ? 'Tomorrow' : '$daysFrom days from now',
                  style: GoogleFonts.nunito(fontSize: 13, color: neutral500),
                ),
                const SizedBox(height: 20),
                _SheetButton(
                  label: 'Add a milestone',
                  icon: Icons.flag_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO(phase-future): milestone creation
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _StateChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StateChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: primary),
        label: Text(
          label,
          style:
              GoogleFonts.nunito(fontWeight: FontWeight.w600, color: primary),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: primary.withAlpha(80)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
