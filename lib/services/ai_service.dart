import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';

class AIService {
  final _logger = Logger('AIService');

  Future<Map<String, dynamic>> scanReceipt() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status.isDenied) {
        _logger.warning('Camera permission denied');
        return {};
      }

      // Pick image from camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image == null) {
        _logger.info('No image selected');
        return {};
      }

      // Return the image path for preview
      return {
        'imagePath': image.path,
        'merchantName': '',
        'totalAmount': null,
        'date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.severe('Error scanning receipt: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> analyzeReceipt(Map<String, dynamic> receiptData) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null) {
        throw Exception('OpenAI API key not found');
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a receipt analysis assistant. Analyze the receipt and provide insights about spending patterns and suggestions for saving money.',
            },
            {
              'role': 'user',
              'content': '''
                Receipt Details:
                Merchant: ${receiptData['merchantName']}
                Total Amount: ${receiptData['totalAmount']}
                Date: ${receiptData['date']}
                
                Please analyze this receipt and provide:
                1. Spending category
                2. Potential savings suggestions
                3. Any unusual patterns
                ''',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'category': _extractCategory(data['choices'][0]['message']['content']),
          'suggestions': _extractSuggestions(data['choices'][0]['message']['content']),
          'patterns': _extractPatterns(data['choices'][0]['message']['content']),
        };
      } else {
        throw Exception('Failed to analyze receipt with AI');
      }
    } catch (e) {
      _logger.severe('Error analyzing receipt: $e');
      return {};
    }
  }

  String _extractCategory(String content) {
    final categoryMatch = RegExp(r'category:\s*([^\n]+)').firstMatch(content);
    return categoryMatch?.group(1)?.trim() ?? 'Other';
  }

  List<String> _extractSuggestions(String content) {
    final suggestionsMatch = RegExp(r'suggestions:\s*([^\n]+)').firstMatch(content);
    return suggestionsMatch?.group(1)?.split(',').map((s) => s.trim()).toList() ?? [];
  }

  List<String> _extractPatterns(String content) {
    final patternsMatch = RegExp(r'patterns:\s*([^\n]+)').firstMatch(content);
    return patternsMatch?.group(1)?.split(',').map((s) => s.trim()).toList() ?? [];
  }

  String categorizeTransaction(String title, double amount) {
    // Simple categorization logic based on keywords and amount
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('food') || 
        titleLower.contains('restaurant') || 
        titleLower.contains('cafe') || 
        titleLower.contains('grocery')) {
      return 'Food & Dining';
    }
    
    if (titleLower.contains('uber') || 
        titleLower.contains('lyft') || 
        titleLower.contains('taxi') || 
        titleLower.contains('transit')) {
      return 'Transportation';
    }
    
    if (titleLower.contains('amazon') || 
        titleLower.contains('walmart') || 
        titleLower.contains('target') || 
        titleLower.contains('store')) {
      return 'Shopping';
    }
    
    if (titleLower.contains('electric') || 
        titleLower.contains('water') || 
        titleLower.contains('gas') || 
        titleLower.contains('internet') || 
        titleLower.contains('phone')) {
      return 'Bills & Utilities';
    }
    
    if (titleLower.contains('movie') || 
        titleLower.contains('netflix') || 
        titleLower.contains('spotify') || 
        titleLower.contains('entertainment')) {
      return 'Entertainment';
    }
    
    if (titleLower.contains('doctor') || 
        titleLower.contains('pharmacy') || 
        titleLower.contains('medical') || 
        titleLower.contains('health')) {
      return 'Health';
    }

    // Default category
    return 'Other';
  }
} 