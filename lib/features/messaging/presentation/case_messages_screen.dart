import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../auth/domain/app_role.dart';
import '../../vet/domain/vet_contact_launcher.dart';
import '../domain/case_thread.dart';
import '../domain/link_quality.dart';
import '../domain/message_delivery_state.dart';
import '../domain/messaging_rules.dart';
import '../domain/quick_replies.dart';
import '../domain/urgent_sla.dart';
import 'messaging_providers.dart';

class CaseMessagesScreen extends ConsumerStatefulWidget {
  const CaseMessagesScreen({
    required this.requestId,
    required this.farmId,
    required this.status,
    this.priority = 'normal',
    this.summary,
    super.key,
  });

  final String requestId;
  final String farmId;
  final String status;
  final String priority;
  final String? summary;

  @override
  ConsumerState<CaseMessagesScreen> createState() => _CaseMessagesScreenState();
}

class _CaseMessagesScreenState extends ConsumerState<CaseMessagesScreen> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  final _rules = const MessagingRules();
  var _markArmed = false;
  var _headerExpanded = false;

  String get _draftKey => 'case_msg:${widget.requestId}';

  @override
  void initState() {
    super.initState();
    _composer.addListener(() => setState(() {}));
    _restoreDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_repairAndSync());
      ref.read(caseRadioForegroundProvider).attach(
            farmId: widget.farmId.isEmpty ? null : widget.farmId,
            requestId: widget.requestId,
          );
      if (ref.read(appRoleProvider).value == AppRole.vet) {
        unawaited(_hydrateVet());
      }
    });
  }

  Future<void> _repairAndSync() async {
    try {
      await ref
          .read(caseMessageRepositoryProvider)
          .repairFarmerOutboxPayloads(widget.requestId);
    } catch (_) {}
    unawaited(ref.read(syncEngineProvider).requestPull());
  }

  Future<void> _hydrateVet() async {
    try {
      await ref.read(vetCaseHydratorProvider).pullAssigned();
    } catch (_) {}
  }

  @override
  void dispose() {
    _persistDraft();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_draftKey);
    if (text != null && mounted) {
      _composer.text = text;
    }
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _composer.text.trim();
    if (text.isEmpty) {
      await prefs.remove(_draftKey);
    } else {
      await prefs.setString(_draftKey, text);
    }
  }

  Future<void> _send() async {
    final body = _composer.text;
    if (_rules.validateText(body) != null) return;
    await ref.read(caseMessageRepositoryProvider).sendText(
          requestId: widget.requestId,
          farmId: widget.farmId,
          requestStatus: widget.status,
          body: body,
        );
    _composer.clear();
    await _persistDraft();
    unawaited(ref.read(syncEngineProvider).syncOnce(force: true));
  }

  Future<void> _attachPhotos() async {
    final files = await ImagePicker().pickMultiImage(limit: 3);
    if (files.isEmpty || !mounted) return;
    final quality = ref.read(linkQualityProvider);
    await ref.read(caseMessageRepositoryProvider).sendPhotos(
          requestId: widget.requestId,
          farmId: widget.farmId,
          requestStatus: widget.status,
          localPaths: [for (final f in files) f.path],
          quality: quality,
          metered: quality == LinkQualityLevel.poor,
          dataSaver: false,
        );
    unawaited(
      ref.read(mediaUploaderProvider).processDue(
            quality: quality,
            metered: quality == LinkQualityLevel.poor,
            dataSaver: false,
          ),
    );
    unawaited(ref.read(syncEngineProvider).syncOnce(force: true));
  }

  void _maybeMarkRead(List<CaseThreadMessage> messages) {
    if (messages.isEmpty) return;
    if (!_scroll.hasClients) return;
    // reverse:true — 0 is the latest messages.
    if (_scroll.position.pixels > 100) {
      _markArmed = false;
      return;
    }
    if (_markArmed) return;
    _markArmed = true;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final latest = messages.last;
      ref.read(caseMessageRepositoryProvider).markRead(
            requestId: widget.requestId,
            farmId: widget.farmId,
            messageId: latest.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(caseThreadProvider(widget.requestId));
    final online = ref.watch(connectivityOnlineProvider).value ?? true;
    final quality = ref.watch(linkQualityProvider);
    final role = ref.watch(farmRoleProvider).value;
    final isVet = ref.watch(appRoleProvider).value == AppRole.vet;
    final canSend = _rules.canSend(
      requestStatus: widget.status,
      farmRole: role?.name ?? (isVet ? 'viewer' : 'owner'),
      isAssignedVet: isVet,
      requestDeleted: false,
    );
    final archived = _rules.isArchived(widget.status);
    final waiting = _rules.isWaitingForAcceptance(widget.status);
    final uid = ref.watch(authUserIdProvider).value ?? '';

    return AppPage(
      title: isVet ? 'Chat with farmer' : 'Chat with vet',
      preset: PageLayout.reading,
      frame: false,
      actions: [
        IconButton(
          tooltip: 'Case details',
          onPressed: () => setState(() => _headerExpanded = !_headerExpanded),
          icon: Icon(
            _headerExpanded ? Icons.expand_less : Icons.info_outline,
          ),
        ),
        if (!isVet)
          IconButton(
            tooltip: 'Call vet',
            onPressed: () => VetContactLauncher.call(''),
            icon: const Icon(Icons.call_outlined),
          ),
      ],
      body: Column(
        children: [
          _CaseBar(
            status: widget.status,
            priority: widget.priority,
            summary: widget.summary,
            expanded: _headerExpanded,
            isVet: isVet,
            onToggle: () => setState(() => _headerExpanded = !_headerExpanded),
          ),
          if (!online)
            const InlineBanner(
              icon: Icons.cloud_off_outlined,
              tone: BannerTone.info,
              message:
                  "You're offline. Messages will send when you have a signal.",
            ),
          if (online && quality == LinkQualityLevel.poor)
            const InlineBanner(
              icon: Icons.signal_cellular_alt_outlined,
              tone: BannerTone.warning,
              message: 'Slow connection: photos will wait. Text sends now.',
            ),
          if (widget.priority == 'urgent' && _rules.isOpen(widget.status))
            InlineBanner(
              icon: Icons.sms_outlined,
              tone: BannerTone.info,
              message: const UrgentSla().waitingExplainer(
                submittedAt: ref.watch(clockProvider).now(),
              ),
            ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.scheme.surfaceContainerLowest,
              ),
              child: AsyncStateView<List<CaseThreadMessage>>(
                value: thread,
                skeleton: const ListSkeleton(count: 6, scrollable: false),
                error: (error, _) => ErrorState(
                  failure: FailureMapper.mapObject(error),
                  onRetry: () =>
                      ref.invalidate(caseThreadProvider(widget.requestId)),
                ),
                builder: (messages) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _maybeMarkRead(messages);
                  });
                  if (messages.isEmpty) {
                    return EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: waiting
                          ? 'Waiting for the vet'
                          : isVet
                              ? 'Start the conversation'
                              : 'Say hello',
                      message: waiting
                          ? 'You can write here once the vet accepts this request.'
                          : isVet
                              ? 'Ask what they are seeing, or share next steps.'
                              : 'Describe what you are seeing with the birds.',
                    );
                  }
                  final now = ref.watch(clockProvider).now();
                  final rows = _buildRows(messages, now);
                  return ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.md,
                    ),
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      return _ChatRowView(row: rows[i], myUserId: uid);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottom: _ComposerBar(
        controller: _composer,
        enabled: canSend,
        archived: archived,
        waiting: waiting,
        isVet: isVet,
        disabledReason: _rules.composerDisabledReason(
          requestStatus: widget.status,
          isViewer: role?.name == 'viewer' && !isVet,
        ),
        onSend: _send,
        onAttach: _attachPhotos,
        onQuick: (line) {
          _composer.text = line;
          _send();
        },
      ),
    );
  }

  List<_ChatRow> _buildRows(
    List<CaseThreadMessage> messages,
    DateTime now,
  ) {
    final rows = <_ChatRow>[];
    String? lastDay;
    for (final m in messages) {
      final day = _dayLabel(m.createdAt, now);
      if (day != lastDay) {
        rows.add(_ChatRow.day(day));
        lastDay = day;
      }
      rows.add(_ChatRow.message(m));
    }
    return rows.reversed.toList();
  }

  static String _dayLabel(DateTime utc, DateTime now) {
    final d = DateTime(utc.toLocal().year, utc.toLocal().month, utc.toLocal().day);
    final n = DateTime(now.toLocal().year, now.toLocal().month, now.toLocal().day);
    final diff = n.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

class _ChatRow {
  const _ChatRow.day(this.label)
      : message = null,
        isUnread = false;
  const _ChatRow.unread()
      : label = null,
        message = null,
        isUnread = true;
  const _ChatRow.message(this.message)
      : label = null,
        isUnread = false;

  final String? label;
  final CaseThreadMessage? message;
  final bool isUnread;
}

class _ChatRowView extends StatelessWidget {
  const _ChatRowView({required this.row, required this.myUserId});

  final _ChatRow row;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    if (row.isUnread) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'New messages',
                style: context.text.labelSmall?.copyWith(
                  color: context.scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      );
    }
    if (row.label != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Text(
                row.label!,
                style: context.text.labelSmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }
    final message = row.message!;
    return _Bubble(
      message: message,
      mine: message.senderUserId == myUserId && message.senderRole != 'system',
    );
  }
}

class _CaseBar extends StatelessWidget {
  const _CaseBar({
    required this.status,
    required this.priority,
    required this.expanded,
    required this.isVet,
    required this.onToggle,
    this.summary,
  });

  final String status;
  final String priority;
  final bool expanded;
  final bool isVet;
  final VoidCallback onToggle;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final title = _titleFromSummary(summary);
    final extra = _extraFromSummary(summary);
    return Material(
      color: context.scheme.surface,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.scheme.primaryContainer,
                    child: Icon(
                      isVet ? Icons.agriculture_outlined : Icons.healing_outlined,
                      color: context.scheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: expanded ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _statusCopy(status),
                          style: context.text.labelMedium?.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (priority == 'urgent')
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        'Urgent',
                        style: context.text.labelSmall?.copyWith(
                          color: context.scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (expanded) ...[
                if (extra != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(extra, style: context.text.bodySmall),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Visible to farm members and the assigned vet. Not end-to-end encrypted. In an emergency, call. Do not share passwords or payment details.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _titleFromSummary(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Vet request';
    final i = raw.indexOf('Birds affected:');
    if (i > 0) return raw.substring(0, i).trim();
    return raw.trim();
  }

  static String? _extraFromSummary(String? raw) {
    if (raw == null) return null;
    final i = raw.indexOf('Birds affected:');
    if (i < 0) return null;
    return raw.substring(i).trim();
  }

  static String _statusCopy(String status) => switch (status) {
        'submitted' || 'received' => 'Awaiting vet',
        'accepted' => 'Accepted · you can chat',
        'in_progress' => 'Visit in progress',
        'completed' => 'Case closed',
        'declined' || 'cancelled' => 'Case closed',
        _ => status,
      };
}

class _Bubble extends ConsumerWidget {
  const _Bubble({required this.message, required this.mine});

  final CaseThreadMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.senderRole == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              message.body ?? '',
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    final scheme = context.scheme;
    final bg = mine ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = mine ? scheme.onPrimaryContainer : scheme.onSurface;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xs,
                    bottom: 2,
                  ),
                  child: Text(
                    message.senderRole == 'vet' ? 'Vet' : 'Farm',
                    style: context.text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              GestureDetector(
                onLongPress: () {
                  final text = message.body;
                  if (text != null) {
                    Clipboard.setData(ClipboardData(text: text));
                  }
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(color: bg, borderRadius: radius),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final a in message.attachments) ...[
                          _Thumb(attachment: a),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        if (message.body != null && message.body!.isNotEmpty)
                          Text(
                            message.body!,
                            style: context.text.bodyMedium?.copyWith(color: fg),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CaseThread.timeLabel(message),
                    style: context.text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _deliveryIcon(message.delivery.kind),
                      size: 14,
                      color: message.delivery.kind == MessageDeliveryKind.failed
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              if (message.delivery.kind == MessageDeliveryKind.failed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(caseMessageRepositoryProvider)
                            .retryFailed(message.id);
                        unawaited(
                          ref.read(syncEngineProvider).syncOnce(force: true),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: () {
                        final text = message.body;
                        if (text != null) {
                          Clipboard.setData(ClipboardData(text: text));
                        }
                      },
                      child: const Text('Copy text'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _deliveryIcon(MessageDeliveryKind kind) => switch (kind) {
        MessageDeliveryKind.queued => Icons.schedule,
        MessageDeliveryKind.sending => Icons.schedule,
        MessageDeliveryKind.sent => Icons.done,
        MessageDeliveryKind.seen => Icons.done_all,
        MessageDeliveryKind.failed => Icons.error_outline,
      };
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.attachment});

  final CaseThreadAttachment attachment;

  @override
  Widget build(BuildContext context) {
    Widget image;
    final b64 = attachment.thumbB64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        image = Image.memory(
          base64Decode(b64),
          width: 180,
          height: 136,
          fit: BoxFit.cover,
        );
      } catch (_) {
        image = _placeholder(context);
      }
    } else {
      image = _placeholder(context);
    }
    final waiting = attachment.subState == AttachmentSubState.waitingForSignal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Stack(
        children: [
          image,
          if (waiting)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: context.scheme.surface.withValues(alpha: 0.82),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Text(
                    'Waiting for a better signal',
                    style: context.text.labelSmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: context.scheme.surfaceContainerHigh,
      child: SizedBox(
        width: 180,
        height: 96,
        child: Icon(
          Icons.photo_outlined,
          color: context.scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.enabled,
    required this.archived,
    required this.waiting,
    required this.isVet,
    required this.disabledReason,
    required this.onSend,
    required this.onAttach,
    required this.onQuick,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool archived;
  final bool waiting;
  final bool isVet;
  final String disabledReason;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final ValueChanged<String> onQuick;

  @override
  Widget build(BuildContext context) {
    final replies =
        isVet ? const QuickReplies().vet() : const QuickReplies().farmer();
    final length = controller.text.trim().length;
    final canSendNow = enabled && const MessagingRules().validateText(controller.text) == null;

    return Material(
      color: context.scheme.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!enabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    disabledReason,
                    style: context.text.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final line in replies)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: ActionChip(
                            label: Text(line),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onQuick(line),
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Attach photo',
                    onPressed: enabled ? onAttach : null,
                    icon: const Icon(Icons.photo_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: waiting
                            ? 'Waiting for the vet to accept…'
                            : archived
                                ? 'This case is closed'
                                : isVet
                                    ? 'Message the farmer'
                                    : 'Message the vet',
                        filled: true,
                        fillColor: context.scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: canSendNow ? onSend : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              if (length >= MessagingRules.warnBodyLength)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xxs,
                    right: AppSpacing.sm,
                  ),
                  child: Text(
                    '$length / ${MessagingRules.maxBodyLength}',
                    textAlign: TextAlign.end,
                    style: context.text.labelSmall?.copyWith(
                      color: length > MessagingRules.maxBodyLength
                          ? context.scheme.error
                          : context.scheme.onSurfaceVariant,
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
