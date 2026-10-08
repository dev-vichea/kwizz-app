import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class OpenTdbService {
  static const String _baseUrl = 'https://opentdb.com/api.php';

  /// Fetches questions from OpenTDB API with rate-limit resilient retry & curated fallback
  Future<List<QuestionModel>> fetchQuestions({
    int amount = 10,
    int? categoryId,
    String? difficulty, // 'easy', 'medium', 'hard', null for any
    String? type = 'multiple', // 'multiple', 'boolean', null for any
  }) async {
    final Map<String, String> queryParameters = {
      'amount': amount.toString(),
    };

    if (categoryId != null && categoryId > 0) {
      queryParameters['category'] = categoryId.toString();
    }
    if (difficulty != null && difficulty.isNotEmpty && difficulty != 'any') {
      queryParameters['difficulty'] = difficulty.toLowerCase();
    }
    if (type != null && type.isNotEmpty && type != 'any') {
      queryParameters['type'] = type;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final int responseCode = data['response_code'] ?? -1;

        if (responseCode == 0) {
          final List<dynamic> results = data['results'] ?? [];
          if (results.isNotEmpty) {
            return results
                .map((item) => QuestionModel.fromOpenTdbJson(item))
                .toList();
          }
        }
      }
    } catch (_) {
      // Fallback below if network fails or OpenTDB rate limits
    }

    // Return curated offline questions if API call fails or rate-limits
    return _getCuratedFallbackQuestions(categoryId: categoryId, count: amount);
  }

  /// High quality offline question pool so quiz always works flawlessly
  List<QuestionModel> _getCuratedFallbackQuestions({int? categoryId, int count = 10}) {
    final List<Map<String, dynamic>> allCurated = [
      // Tech / Computers (Category 18)
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'Which programming language is Flutter written in and powered by?',
        'correct_answer': 'Dart',
        'incorrect_answers': ['Kotlin', 'Swift', 'TypeScript'],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What does "HTML" stand for in web development?',
        'correct_answer': 'HyperText Markup Language',
        'incorrect_answers': [
          'HighText Machine Language',
          'Hyperlink and Text Model Language',
          'Home Tool Markup Language'
        ],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'hard',
        'question': 'Who is considered the pioneer father of modern Computer Science and artificial intelligence?',
        'correct_answer': 'Alan Turing',
        'incorrect_answers': ['John von Neumann', 'Charles Babbage', 'Ada Lovelace'],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What company originally designed the Android mobile operating system before acquisition?',
        'correct_answer': 'Android Inc. (acquired by Google)',
        'incorrect_answers': ['Apple Inc.', 'Microsoft', 'Nokia'],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'Which database architectural model does Supabase leverage underneath?',
        'correct_answer': 'PostgreSQL',
        'incorrect_answers': ['MongoDB', 'MySQL', 'Redis'],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What does the acronym CPU stand for?',
        'correct_answer': 'Central Processing Unit',
        'incorrect_answers': [
          'Core Performance Utility',
          'Computer Power Unit',
          'Control Program Unit'
        ],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'Which quantum computing unit is the analogue to the classical binary bit?',
        'correct_answer': 'Qubit',
        'incorrect_answers': ['Byte', 'Trabit', 'Fluxon'],
      },
      {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What is the open-source version control system created by Linus Torvalds?',
        'correct_answer': 'Git',
        'incorrect_answers': ['SVN', 'Mercurial', 'Perforce'],
      },

      // Science & Nature (Category 17)
      {
        'category': 'Science & Nature',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What planet in our solar system is nicknamed the Red Planet?',
        'correct_answer': 'Mars',
        'incorrect_answers': ['Jupiter', 'Venus', 'Mercury'],
      },
      {
        'category': 'Science & Nature',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'What is the chemical symbol for Gold on the periodic table?',
        'correct_answer': 'Au',
        'incorrect_answers': ['Ag', 'Fe', 'Gd'],
      },
      {
        'category': 'Science & Nature',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'What is the speed of light in vacuum approximately?',
        'correct_answer': '300,000 km/s',
        'incorrect_answers': ['150,000 km/s', '3,000 km/s', '1,000,000 km/s'],
      },

      // General Knowledge (Category 9)
      {
        'category': 'General Knowledge',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'Which city is the capital of France?',
        'correct_answer': 'Paris',
        'incorrect_answers': ['Lyon', 'Marseille', 'Nice'],
      },
      {
        'category': 'General Knowledge',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'How many continents are there on planet Earth?',
        'correct_answer': '7',
        'incorrect_answers': ['5', '6', '8'],
      },
      {
        'category': 'General Knowledge',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'Which ocean is the largest on Earth by surface area?',
        'correct_answer': 'Pacific Ocean',
        'incorrect_answers': ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean'],
      },

      // History (Category 23)
      {
        'category': 'History',
        'type': 'multiple',
        'difficulty': 'medium',
        'question': 'In which year did the Apollo 11 moon landing take place?',
        'correct_answer': '1969',
        'incorrect_answers': ['1965', '1971', '1959'],
      },
      {
        'category': 'History',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'Who was the first President of the United States?',
        'correct_answer': 'George Washington',
        'incorrect_answers': ['Thomas Jefferson', 'Abraham Lincoln', 'John Adams'],
      },
    ];

    List<Map<String, dynamic>> filtered;
    if (categoryId == 18) {
      filtered = allCurated.where((q) => q['category'] == 'Science: Computers').toList();
    } else if (categoryId == 17) {
      filtered = allCurated.where((q) => q['category'] == 'Science & Nature').toList();
    } else if (categoryId == 9) {
      filtered = allCurated.where((q) => q['category'] == 'General Knowledge').toList();
    } else if (categoryId == 23) {
      filtered = allCurated.where((q) => q['category'] == 'History').toList();
    } else {
      filtered = List.from(allCurated);
    }

    if (filtered.isEmpty) {
      filtered = List.from(allCurated);
    }

    filtered.shuffle(Random());
    final selected = filtered.take(count).toList();
    return selected.map((item) => QuestionModel.fromOpenTdbJson(item)).toList();
  }
}
