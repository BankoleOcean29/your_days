import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:your_days/models/journal_entry.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/journal_repository.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/constants.dart';

class JournalEditorScreen extends StatefulWidget {
  final String date; // 'YYYY-MM-DD'
  final JournalEntry? existing;

  const JournalEditorScreen({
    super.key,
    required this.date,
    this.existing,
  });

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late final TextEditingController _body;
  late String _savedBody;
  bool _saving = false;

  bool get _isNew => widget.existing == null;
  bool get _isDirty => _body.text != _savedBody;
  bool get _canSave => _isDirty && _body.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final initialBody = widget.existing?.body ?? '';
    _body = TextEditingController(text: initialBody);
    _savedBody = initialBody;
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    PasscodeService.instance.refreshSession();

    // Capture theme colors before async gap (spec: neutral.800 bg, neutral.50 text)
    final isLight = Theme.of(context).brightness == Brightness.light;
    final snackBg = isLight
        ? ColorTokens.neutral800Light
        : ColorTokens.neutral100Dark;
    final snackText = isLight
        ? ColorTokens.neutral50Light
        : ColorTokens.neutral900Dark;

    final now = DateTime.now();
    final entry = JournalEntry(
      id: widget.existing?.id,
      date: widget.date,
      body: _body.text,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await JournalRepository.instance.saveEntry(entry);
      _savedBody = _body.text;

      // Analytics — metadata only, never content
      final words = _body.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final bucket = words < 50 ? 'short' : words <= 200 ? 'medium' : 'long';
      final days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
      AnalyticsService.instance.logJournalEntrySaved(
        dayOfWeek: days[now.weekday - 1],
        wordCountBucket: bucket,
        isEdit: !_isNew,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: snackBg,
            content: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: snackText, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Entry saved',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600, color: snackText),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true); // return true = saved
      }
    } catch (_) {
      if (mounted) {
        final isSessionExpired = PasscodeService.instance.sessionPin == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: snackBg,
            content: Text(
              isSessionExpired
                  ? 'Session expired. Please re-authenticate.'
                  : 'Could not save. Please try again.',
              style: GoogleFonts.nunito(color: snackText),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
        if (isSessionExpired) Navigator.of(context).pop(false);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Delete entry?',
            style: GoogleFonts.lora(fontWeight: FontWeight.w600)),
        content: Text(
          'This entry will be permanently deleted.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await JournalRepository.instance.deleteEntry(widget.existing!);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Discard changes?',
            style: GoogleFonts.lora(fontWeight: FontWeight.w600)),
        content: Text(
          'Your unsaved changes will be lost.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep writing')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;

    final parsedDate = DateTime.parse(widget.date);
    final dateLabel = DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            dateLabel,
            style: GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          actions: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _body,
              builder: (context, val, _) => TextButton(
                onPressed: _canSave && !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        'Save',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: _canSave ? primary : neutral500,
                        ),
                      ),
              ),
            ),
            if (!_isNew)
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') _delete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Delete entry',
                          style: GoogleFonts.nunito(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _body,
                  builder: (context, val, _) => TextField(
                    controller: _body,
                    maxLines: null,
                    maxLength: AppConstants.kJournalCharLimit,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      height: 1.7,
                      color: isLight
                          ? ColorTokens.neutral900Light
                          : ColorTokens.neutral900Dark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: GoogleFonts.nunito(
                          fontSize: 16, color: neutral500),
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ),

            // ── Character counter ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _body,
                builder: (context, val, _) {
                  final count = val.text.length;
                  final Color counterColor;
                  if (count >= AppConstants.kJournalCharLimit) {
                    counterColor = Theme.of(context).colorScheme.error;
                  } else if (count >= AppConstants.kJournalCharWarning) {
                    counterColor =
                        isLight ? ColorTokens.astrologyLight : ColorTokens.astrologyDark;
                  } else {
                    counterColor = neutral500;
                  }
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '$count / ${AppConstants.kJournalCharLimit}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: counterColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
