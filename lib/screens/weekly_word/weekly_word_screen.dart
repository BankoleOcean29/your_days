import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:your_days/models/weekly_word.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/services/weekly_word_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/date_utils.dart';

class WeeklyWordScreen extends StatefulWidget {
  const WeeklyWordScreen({super.key});

  @override
  State<WeeklyWordScreen> createState() => _WeeklyWordScreenState();
}

class _WeeklyWordScreenState extends State<WeeklyWordScreen> {
  bool _showingPast = false;

  @override
  void didUpdateWidget(WeeklyWordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // IndexedStack keeps this mounted; rebuild whenever MainScaffold setState
    // fires (e.g. switching tabs after changing belief track in Settings).
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesService.instance;
    final now = DateTime.now();
    final week = AppDateUtils.weekOfYear(now);
    final belief = prefs.beliefTrack;
    final zodiac = prefs.zodiacSign;

    final current = WeeklyWordService.instance.getForWeek(
      week,
      belief,
      zodiacSign: zodiac,
    );

    final past = WeeklyWordService.instance.getPastWords(
      week,
      belief,
      zodiacSign: zodiac,
    );

    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Weekly Word',
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isLight
                          ? ColorTokens.neutral900Light
                          : ColorTokens.neutral900Dark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Week $week',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (current == null) ...[
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Loading...',
                  style: GoogleFonts.nunito(color: neutral500),
                ),
              ),
            ] else ...[
              // ── Main word card ────────────────────────────────────────────
              _WordCard(
                word: current,
                week: week,
                isLight: isLight,
                primary: primary,
                beliefTrack: belief,
                zodiacSign: zodiac,
                onShare: () => _share(current, week),
              ),

              const SizedBox(height: 24),

              // ── Reflection prompt ─────────────────────────────────────────
              _ReflectionSection(
                word: current,
                isLight: isLight,
                primary: primary,
                neutral600: neutral600,
              ),

              // ── Past weeks toggle ─────────────────────────────────────────
              if (past.isNotEmpty) ...[
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => setState(() => _showingPast = !_showingPast),
                  child: Row(
                    children: [
                      Text(
                        'Past Weeks',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: neutral500,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _showingPast
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: neutral500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (_showingPast) ...[
                  const SizedBox(height: 8),
                  for (final item in past)
                    _PastWordTile(
                      week: item.week,
                      word: item.word,
                      isLight: isLight,
                      neutral500: neutral500,
                    ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _share(WeeklyWord word, int week) {
    final ref = word.reference != null ? '\n— ${word.reference}' : '';
    final text =
        '"${word.text}"$ref\n\nWeek $week • Your Days app';
    // ignore: deprecated_member_use
    Share.share(text);
    AnalyticsService.instance.logWeeklyWordShared(
      beliefTrack: PreferencesService.instance.beliefTrack,
      weekNumber: week,
    );
  }
}

// ── _WordCard ──────────────────────────────────────────────────────────────

class _WordCard extends StatelessWidget {
  final WeeklyWord word;
  final int week;
  final bool isLight;
  final Color primary;
  final String beliefTrack;
  final String? zodiacSign;
  final VoidCallback onShare;

  const _WordCard({
    required this.word,
    required this.week,
    required this.isLight,
    required this.primary,
    required this.beliefTrack,
    required this.zodiacSign,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isLight
        ? ColorTokens.neutral100Light
        : ColorTokens.neutral100Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;

    final trackLabel = _trackLabel(beliefTrack, zodiacSign);
    final trackColor = _trackColor(beliefTrack, isLight);

    // spec: left accent bar 3dp, radius.lg (16dp), padding 16/20/16
    // quote: Lora SemiBold Italic — 24dp (≤60 chars), 18dp (longer)
    final quoteIsShort = word.text.length <= 80;
    final quoteFontSize = quoteIsShort ? 22.0 : 17.0;

    // Use Stack for the accent bar — non-uniform Border + borderRadius throws
    // an assertion in Flutter, so we draw the bar inside the clip instead.
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: trackColor.withAlpha(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Left accent bar ──────────────────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: trackColor),
          ),

          // ── Card content ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Belief label + share icon row
                Row(
                  children: [
                    Text(
                      trackLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: trackColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onShare,
                      child: Icon(
                        Icons.share_outlined,
                        color: neutral500,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Quote — Lora SemiBold Italic per spec
                Text(
                  word.text,
                  style: GoogleFonts.lora(
                    fontSize: quoteFontSize,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.55,
                    color: isLight
                        ? ColorTokens.neutral800Light
                        : ColorTokens.neutral800Dark,
                  ),
                ),

                // Attribution — body.small 12dp neutral.500
                if (word.reference != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '— ${word.reference}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: neutral500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _trackLabel(String track, String? zodiac) {
    switch (track) {
      case 'christian':
        return 'SCRIPTURE';
      case 'muslim':
        return 'QURAN & HADITH';
      case 'astrology':
        final sign = zodiac != null
            ? '${zodiac[0].toUpperCase()}${zodiac.substring(1)}'
            : 'COSMOS';
        return sign.toUpperCase();
      default:
        return 'WISDOM';
    }
  }

  Color _trackColor(String track, bool isLight) {
    switch (track) {
      case 'christian':
        return isLight
            ? ColorTokens.christianLight
            : ColorTokens.christianDark;
      case 'muslim':
        return isLight ? ColorTokens.muslimLight : ColorTokens.muslimDark;
      case 'astrology':
        return isLight
            ? ColorTokens.astrologyLight
            : ColorTokens.astrologyDark;
      default:
        return isLight ? ColorTokens.generalLight : ColorTokens.generalDark;
    }
  }
}

// ── _ReflectionSection ─────────────────────────────────────────────────────

class _ReflectionSection extends StatelessWidget {
  final WeeklyWord word;
  final bool isLight;
  final Color primary;
  final Color neutral600;

  const _ReflectionSection({
    required this.word,
    required this.isLight,
    required this.primary,
    required this.neutral600,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight
        ? ColorTokens.neutral50Light
        : ColorTokens.neutral100Dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFLECT',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.reflection,
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.6,
              color: isLight
                  ? ColorTokens.neutral800Light
                  : ColorTokens.neutral800Dark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _PastWordTile ──────────────────────────────────────────────────────────

class _PastWordTile extends StatelessWidget {
  final int week;
  final WeeklyWord word;
  final bool isLight;
  final Color neutral500;

  const _PastWordTile({
    required this.week,
    required this.word,
    required this.isLight,
    required this.neutral500,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;

    // Work out the date of the Monday of that ISO week in the current year
    final year = DateTime.now().year;
    final jan4 = DateTime(year, 1, 4);
    final weekStart =
        jan4.subtract(Duration(days: jan4.weekday - 1)).add(Duration(days: (week - 1) * 7));
    final weekLabel = DateFormat('MMM d').format(weekStart);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week $week  ·  $weekLabel',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: neutral500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lora(
              fontSize: 13,
              height: 1.5,
              color: isLight
                  ? ColorTokens.neutral700Light
                  : ColorTokens.neutral700Dark,
            ),
          ),
          if (word.reference != null) ...[
            const SizedBox(height: 2),
            Text(
              '— ${word.reference}',
              style: GoogleFonts.nunito(fontSize: 11, color: neutral500),
            ),
          ],
        ],
      ),
    );
  }
}
