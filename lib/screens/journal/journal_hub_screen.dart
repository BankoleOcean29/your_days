import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:your_days/models/journal_entry.dart';
import 'package:your_days/screens/journal/journal_editor_screen.dart';
import 'package:your_days/services/journal_repository.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/date_utils.dart';

class JournalHubScreen extends StatefulWidget {
  const JournalHubScreen({super.key});

  @override
  State<JournalHubScreen> createState() => _JournalHubScreenState();
}

class _JournalHubScreenState extends State<JournalHubScreen> {
  List<JournalEntry> _entries = [];
  List<JournalEntry> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JournalHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Triggered when MainScaffold rebuilds after unlock — kick off the real load.
    if (PasscodeService.instance.isUnlocked && _loading) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    if (!PasscodeService.instance.isUnlocked) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    PasscodeService.instance.refreshSession();
    final entries = await JournalRepository.instance.getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _filtered = entries;
        _loading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _filtered = _entries);
      return;
    }
    final results = await JournalRepository.instance.searchEntries(query);
    if (mounted) setState(() => _filtered = results);
  }

  void _openEditor(String date, {JournalEntry? existing}) async {
    PasscodeService.instance.refreshSession();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            JournalEditorScreen(date: date, existing: existing),
      ),
    );
    if (saved == true) _loadEntries();
  }

  void _openTodayEditor() {
    final today = AppDateUtils.toStorageKey(DateTime.now());
    final existing = _entries
        .where((e) => e.date == today)
        .firstOrNull;
    _openEditor(today, existing: existing);
  }

  // ── Grouping ────────────────────────────────────────────────────────────────

  Map<String, List<JournalEntry>> _grouped(List<JournalEntry> entries) {
    final result = <String, List<JournalEntry>>{};
    final now = DateTime.now();
    final today = AppDateUtils.toStorageKey(now);

    // Remove today's entry — shown separately at top
    final past = entries.where((e) => e.date != today).toList();

    for (final entry in past) {
      final date = DateTime.parse(entry.date);
      final label = _weekLabel(date, now);
      result.putIfAbsent(label, () => []).add(entry);
    }
    return result;
  }

  String _weekLabel(DateTime date, DateTime now) {
    final diff = now.difference(date).inDays;
    if (diff < 7) return 'This Week';
    if (diff < 14) return 'Last Week';
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    final today = AppDateUtils.toStorageKey(DateTime.now());
    final todayEntry = _entries.where((e) => e.date == today).firstOrNull;
    final grouped = _grouped(_searching ? _filtered : _entries);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Column(
                children: [
                  // ── App bar ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Journal',
                          style: GoogleFonts.lora(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isLight
                                ? ColorTokens.neutral900Light
                                : ColorTokens.neutral900Dark,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _searching ? Icons.close : Icons.search,
                            color: neutral500,
                          ),
                          onPressed: () {
                            setState(() {
                              _searching = !_searching;
                              if (!_searching) {
                                _searchController.clear();
                                _filtered = _entries;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Search bar ───────────────────────────────────────────
                  if (_searching)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: GoogleFonts.nunito(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search entries...',
                          hintStyle: GoogleFonts.nunito(color: neutral600),
                          prefixIcon:
                              Icon(Icons.search, color: neutral500, size: 20),
                        ),
                        onChanged: _search,
                      ),
                    ),

                  // ── Entry list ───────────────────────────────────────────
                  Expanded(
                    child: _entries.isEmpty
                        ? _EmptyState(
                            primary: primary,
                            onWrite: _openTodayEditor,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadEntries,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              children: [
                                // Today's card
                                _TodayCard(
                                  entry: todayEntry,
                                  isLight: isLight,
                                  primary: primary,
                                  onTap: _openTodayEditor,
                                ),

                                if (!_searching || _filtered.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  // Past entries grouped
                                  for (final group in grouped.entries) ...[
                                    _SectionLabel(
                                        label: group.key,
                                        neutral500: neutral500),
                                    ...group.value.map(
                                      (e) => _EntryCard(
                                        entry: e,
                                        isLight: isLight,
                                        onTap: () =>
                                            _openEditor(e.date, existing: e),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openTodayEditor,
        backgroundColor: primary,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color primary;
  final VoidCallback onWrite;

  const _EmptyState({required this.primary, required this.onWrite});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral400 =
        isLight ? ColorTokens.neutral400Light : ColorTokens.neutral400Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 52, color: neutral400),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isLight
                  ? ColorTokens.neutral800Light
                  : ColorTokens.neutral800Dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Write your first entry today.',
            style: GoogleFonts.nunito(fontSize: 14, color: neutral600),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onWrite,
            child: Text(
              'Write first entry',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final JournalEntry? entry;
  final bool isLight;
  final Color primary;
  final VoidCallback onTap;

  const _TodayCard({
    required this.entry,
    required this.isLight,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: GoogleFonts.nunito(fontSize: 12, color: neutral500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (entry == null)
              Text(
                "What's on your mind?",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: neutral500,
                ),
              )
            else
              Text(
                entry!.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isLight
                      ? ColorTokens.neutral800Light
                      : ColorTokens.neutral800Dark,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              entry == null ? 'Tap to write' : 'Tap to edit',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color neutral500;

  const _SectionLabel({required this.label, required this.neutral500});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: neutral500,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isLight;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final date = DateTime.parse(entry.date);
    final dateLabel = DateFormat('EEE, MMM d').format(date);
    final timeLabel = DateFormat('h:mm a').format(entry.updatedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              style: GoogleFonts.lora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLight
                    ? ColorTokens.neutral800Light
                    : ColorTokens.neutral800Dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: neutral500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeLabel,
                style:
                    GoogleFonts.nunito(fontSize: 11, color: neutral500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
