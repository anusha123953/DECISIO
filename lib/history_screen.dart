
import 'package:flutter/material.dart';

import '../services/decision_engine.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = DecisionEngine.getHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _loadHistory();
    });

    await _historyFuture;
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear decision history?'),
        content: const Text(
          'This will permanently delete all your saved decisions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DecisionEngine.clearHistory();

      if (!mounted) return;

      setState(() {
        _loadHistory();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Decision history cleared successfully.'),
        ),
      );
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Date unavailable';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Unable to load decision history.'),
                  TextButton(
                    onPressed: _refreshHistory,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 72,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No decisions yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your completed decisions will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshHistory,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${history.length} saved decision${history.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < history.length; i++)
                  _buildHistoryCard(history[i]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> decision) {
    final question =
        decision['question']?.toString() ?? 'Untitled decision';
    final winner = decision['winner']?.toString() ?? 'Not available';
    final date = _formatDate(decision['date']);

    final options = (decision['options'] as List? ?? [])
        .map((option) => option.toString())
        .toList();

    final scores = (decision['scores'] as List? ?? [])
        .map((score) => double.tryParse(score.toString()) ?? 0.0)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          child: const Icon(
            Icons.analytics_outlined,
            color: Color(0xFFB69CFF),
          ),
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Saved on $date'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Recommended: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  winner,
                  style: const TextStyle(
                    color: Color(0xFFB69CFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      options[i],
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    i < scores.length
                        ? '${scores[i].toStringAsFixed(1)}/100'
                        : 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
