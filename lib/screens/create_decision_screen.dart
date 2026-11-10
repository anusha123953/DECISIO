
import 'package:flutter/material.dart';
import 'result_screen.dart';

class CreateDecisionScreen extends StatefulWidget {
  const CreateDecisionScreen({super.key});

  @override
  State<CreateDecisionScreen> createState() =>
      _CreateDecisionScreenState();
}

class _CreateDecisionScreenState
    extends State<CreateDecisionScreen> {
  final questionController = TextEditingController();
  final optionsController = TextEditingController();

  void continueToRatings() {
    final question = questionController.text.trim();

    final options = optionsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (question.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a question and at least two alternatives.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          question: question,
          options: options,
        ),
      ),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Decision')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are you deciding?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Decision question'),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                hintText: 'Which internship should I choose?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            const Text('Alternatives'),
            const SizedBox(height: 8),
            TextField(
              controller: optionsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Company A\nCompany B\nCompany C',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: continueToRatings,
                child: const Text('Evaluate Alternatives'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
