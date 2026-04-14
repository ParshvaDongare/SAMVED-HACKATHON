import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../providers/ticket_providers.dart';

class ContractorIssueScreen extends ConsumerStatefulWidget {
  const ContractorIssueScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<ContractorIssueScreen> createState() =>
      _ContractorIssueScreenState();
}

class _ContractorIssueScreenState extends ConsumerState<ContractorIssueScreen> {
  String? _issue;
  String _urgency = 'medium';
  final _notes = TextEditingController();
  bool _busy = false;

  static const _issues = [
    'Access Blocked',
    'Rain / Weather',
    'Material Delay',
    'Site Mismatch',
    'Safety Issue',
    'Contract Dispute',
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(ticketDetailProvider(widget.ticketId)).valueOrNull;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Flag Issue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose the issue blocking this work order.',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _issues
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: _issue == item,
                    onSelected: (_) => setState(() => _issue = item),
                    backgroundColor: cs.surface,
                    selectedColor: cs.primaryContainer,
                    side: BorderSide(color: cs.outlineVariant),
                    labelStyle: tt.labelLarge?.copyWith(
                      color:
                          _issue == item ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'low', label: Text('Low')),
              ButtonSegment(value: 'medium', label: Text('Medium')),
              ButtonSegment(value: 'critical', label: Text('Critical')),
            ],
            selected: {_urgency},
            onSelectionChanged: (v) => setState(() => _urgency = v.first),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(
                '₹${ticket?.estimatedCost?.toStringAsFixed(2) ?? '-'} at risk',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'This issue will be permanently recorded in the audit trail.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Notes (min 10 chars)',
              hintText: 'Describe what is blocking the work on site.',
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: (_busy || _issue == null || _notes.text.trim().length < 10)
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      await ref.read(ticketEventServiceProvider).insertEvent(
                            ticketId: widget.ticketId,
                            actorRole: 'contractor',
                            eventType: 'escalation',
                            notes: '${_issue!}: ${_notes.text.trim()}',
                            metadata: {
                              'issue_type': _issue,
                              'urgency': _urgency,
                            },
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Issue logged successfully'),
                        ),
                      );
                      context.pop();
                    } finally {
                      if (mounted) {
                        setState(() => _busy = false);
                      }
                    }
                  },
            child: Text(_busy ? 'Submitting...' : 'Submit Issue'),
          ),
        ],
      ),
    );
  }
}
