
import 'package:flutter/material.dart';

import '../services/decision_engine.dart';
import '../widgets/score_chart.dart';

class ResultScreen extends StatefulWidget {
  final String question;
  final List<String> options;

  const ResultScreen({
    super.key,
    required this.question,
    required this.options,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final List<String> criteria = [
    'Learning opportunities',
    'Mentorship',
    'Financial benefits',
    'Flexibility',
  ];

  final List<double> weights = [35, 30, 20, 15];

  late List<List<double>> ratings;
  bool isCalculating = false;

  @override
  void initState() {
    super.initState();

    ratings = List.generate(
      widget.options.length,
      (_) => List.filled(criteria.length, 5.0),
    );
  }

  Future<void> calculateDecision() async {
    final weightSum = weights.fold<double>(
      0,
      (sum, weight) => sum + weight,
    );

    if (weightSum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set valid criteria weights.'),
        ),
      );
      return;
    }

    setState(() {
      isCalculating = true;
    });

    final List<double> scores = [];

    for (int i = 0; i < widget.options.length; i++) {
      double total = 0;

      for (int j = 0; j < criteria.length; j++) {
        total += ratings[i][j] * weights[j] / weightSum * 10;
      }

      scores.add(total);
    }

    final bestIndex = scores.indexOf(
      scores.reduce((a, b) => a > b ? a : b),
    );

    try {
      await DecisionEngine.saveDecision(
        question: widget.question,
        options: widget.options,
        scores: scores,
        winner: bestIndex,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DecisionResultView(
            question: widget.question,
            options: widget.options,
            scores: scores,
            winner: bestIndex,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCalculating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save decision: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluate Alternatives'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rate Each Alternative',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < widget.options.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.options[i],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    for (int j = 0; j < criteria.length; j++) ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(criteria[j])),
                          Text(ratings[i][j].round().toString()),
                        ],
                      ),
                      Slider(
                        value: ratings[i][j],
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() {
                            ratings[i][j] = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          const Text(
            'Criteria Weights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust the importance of each criterion.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < criteria.length; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(criteria[i]),
                Text('${weights[i].round()}%'),
              ],
            ),
            Slider(
              value: weights[i],
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  weights[i] = value;
                });
              },
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isCalculating ? null : calculateDecision,
              child: isCalculating
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Calculate Best Alternative',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DecisionResultView extends StatelessWidget {
  final String question;
  final List<String> options;
  final List<double> scores;
  final int winner;

  const DecisionResultView({
    super.key,
    required this.question,
    required this.options,
    required this.scores,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    final winningScore = scores[winner];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Analysis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          const Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.amber,
          ),

          const SizedBox(height: 16),

          const Text(
            'Highest-scoring alternative',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            options[winner],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5EE6B2),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Score: ${winningScore.toStringAsFixed(1)} / 100',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Visual Analytics',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ScoreChart(
            options: options,
            scores: scores,
            winner: winner,
          ),

          const SizedBox(height: 20),

          const Text(
            'Alternative Comparison',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          for (int i = 0; i < options.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[i],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          scores[i].toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (scores[i] / 100).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: Colors.white12,
                      color: i == winner
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFFB69CFF),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            'Recommendation',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${options[winner]} achieved the highest weighted score '
            'based on your selected criteria and ratings. '
            'Review individual ratings before making your final decision.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 28),

          OutlinedButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}
