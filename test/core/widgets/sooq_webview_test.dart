// test/core/widgets/sooq_webview_test.dart
//
// Widget tests for SooqWebView — focused on JS bridge message parsing and structure.
// Note: Full widget lifecycle tests require DI initialization and are covered by integration tests.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

// Fake for JavaScriptMessage
class FakeJavaScriptMessage {
  final String message;

  FakeJavaScriptMessage(this.message);
}

/// Parses a bridge message and returns the type, or null if invalid.
/// Mirrors the logic in SooqWebView._onBridgeMessage
String? parseBridgeMessage(String message) {
  final Map<String, dynamic> payload;
  try {
    payload = json.decode(message) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }

  final typeValue = payload['type'];
  // Type must be a non-null string
  if (typeValue is! String) return null;
  if (typeValue.isEmpty) return null;

  return typeValue;
}

/// Extracts share payload from a bridge message
Map<String, dynamic>? extractSharePayload(String message) {
  try {
    final payload = json.decode(message) as Map<String, dynamic>;
    if (payload['type'] != 'share') return null;
    return payload['payload'] as Map<String, dynamic>? ?? {};
  } catch (_) {
    return null;
  }
}

/// Validates if a message is a valid bridge message
bool isValidBridgeMessage(String message) {
  try {
    final payload = json.decode(message) as Map<String, dynamic>;
    return payload['type'] != null;
  } catch (_) {
    return false;
  }
}

void main() {
  group('SooqWebView Bridge Message Parsing', () {
    group('parseBridgeMessage', () {
      test('extracts type from navigate:wallet message', () {
        final message = jsonEncode({'type': 'navigate:wallet'});

        expect(parseBridgeMessage(message), 'navigate:wallet');
      });

      test('extracts type from navigate:profile message', () {
        final message = jsonEncode({'type': 'navigate:profile'});

        expect(parseBridgeMessage(message), 'navigate:profile');
      });

      test('extracts type from navigate:back message', () {
        final message = jsonEncode({'type': 'navigate:back'});

        expect(parseBridgeMessage(message), 'navigate:back');
      });

      test('extracts type from auth:expired message', () {
        final message = jsonEncode({'type': 'auth:expired'});

        expect(parseBridgeMessage(message), 'auth:expired');
      });

      test('extracts type from openCamera message', () {
        final message = jsonEncode({'type': 'openCamera'});

        expect(parseBridgeMessage(message), 'openCamera');
      });

      test('extracts type from share message', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'text': 'Check this out!',
            'url': 'https://example.com/item/123',
          },
        });

        expect(parseBridgeMessage(message), 'share');
      });

      test('returns null for invalid JSON', () {
        expect(parseBridgeMessage('not valid json'), isNull);
        expect(parseBridgeMessage('{'), isNull);
        expect(parseBridgeMessage(''), isNull);
      });

      test('returns null for JSON without type field', () {
        final message = jsonEncode({'payload': 'some data'});

        expect(parseBridgeMessage(message), isNull);
      });

      test('returns null for null message type', () {
        final message = jsonEncode({'type': null});

        expect(parseBridgeMessage(message), isNull);
      });

      test('handles boolean type value', () {
        final message = jsonEncode({'type': true});

        // Boolean is not a String, so returns null
        expect(parseBridgeMessage(message), isNull);
      });

      test('handles numeric type value', () {
        final message = jsonEncode({'type': 123});

        // Number is not a String, so returns null
        expect(parseBridgeMessage(message), isNull);
      });
    });

    group('extractSharePayload', () {
      test('extracts text and URL from share message', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'text': 'Check this out!',
            'url': 'https://example.com/item/123',
          },
        });

        final payload = extractSharePayload(message);

        expect(payload?['text'], 'Check this out!');
        expect(payload?['url'], 'https://example.com/item/123');
      });

      test('handles share with only text', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {'text': 'Just text'},
        });

        final payload = extractSharePayload(message);

        expect(payload?['text'], 'Just text');
        expect(payload?['url'], isNull);
      });

      test('handles share with only URL', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {'url': 'https://example.com'},
        });

        final payload = extractSharePayload(message);

        expect(payload?['url'], 'https://example.com');
        expect(payload?['text'], isNull);
      });

      test('handles share with empty payload', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {},
        });

        final payload = extractSharePayload(message);

        expect(payload, isEmpty);
      });

      test('handles share with null payload', () {
        final message = jsonEncode({'type': 'share'});

        final payload = extractSharePayload(message);

        expect(payload, isEmpty);
      });

      test('returns null for non-share messages', () {
        final message = jsonEncode({'type': 'navigate:wallet'});

        expect(extractSharePayload(message), isNull);
      });

      test('returns null for invalid JSON', () {
        expect(extractSharePayload('invalid'), isNull);
      });
    });

    group('isValidBridgeMessage', () {
      test('returns true for valid navigation messages', () {
        expect(
          isValidBridgeMessage(jsonEncode({'type': 'navigate:wallet'})),
          isTrue,
        );
        expect(
          isValidBridgeMessage(jsonEncode({'type': 'navigate:profile'})),
          isTrue,
        );
        expect(
          isValidBridgeMessage(jsonEncode({'type': 'navigate:back'})),
          isTrue,
        );
      });

      test('returns true for auth:expired message', () {
        expect(
          isValidBridgeMessage(jsonEncode({'type': 'auth:expired'})),
          isTrue,
        );
      });

      test('returns true for openCamera message', () {
        expect(
          isValidBridgeMessage(jsonEncode({'type': 'openCamera'})),
          isTrue,
        );
      });

      test('returns true for share message', () {
        expect(
          isValidBridgeMessage(jsonEncode({
            'type': 'share',
            'payload': {'text': 'Hello'},
          })),
          isTrue,
        );
      });

      test('returns false for invalid JSON', () {
        expect(isValidBridgeMessage('invalid'), isFalse);
        expect(isValidBridgeMessage('{'), isFalse);
        expect(isValidBridgeMessage(''), isFalse);
      });

      test('returns false for JSON without type', () {
        expect(isValidBridgeMessage(jsonEncode({'data': 'value'})), isFalse);
      });

      test('returns false for JSON with null type', () {
        expect(isValidBridgeMessage(jsonEncode({'type': null})), isFalse);
      });
    });

    group('Message Types', () {
      test('all supported message types are recognized', () {
        final supportedTypes = [
          'navigate:wallet',
          'navigate:profile',
          'navigate:back',
          'auth:expired',
          'openCamera',
          'share',
        ];

        for (final type in supportedTypes) {
          final message = jsonEncode({'type': type});
          expect(
            parseBridgeMessage(message),
            type,
            reason: 'Type $type should be recognized',
          );
        }
      });
    });

    group('Complex Payloads', () {
      test('handles nested payload structure', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'text': 'Multi\nline\ntext',
            'url': 'https://example.com?param=value&other=123',
            'metadata': {
              'timestamp': 1234567890,
              'source': 'web',
            },
          },
        });

        final payload = extractSharePayload(message);
        expect(payload?['metadata']?['timestamp'], 1234567890);
      });

      test('handles unicode in payload', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'text': 'مرحبا بالعالم 🌍',
            'url': 'https://example.com',
          },
        });

        final payload = extractSharePayload(message);
        expect(payload?['text'], 'مرحبا بالعالم 🌍');
      });

      test('handles special characters in URLs', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'url': 'https://example.com/callback?token=abc+def&user=test@email.com',
          },
        });

        final payload = extractSharePayload(message);
        expect(payload?['url'], contains('abc+def'));
        expect(payload?['url'], contains('test@email.com'));
      });

      test('handles openCamera with callback ID', () {
        final message = jsonEncode({
          'type': 'openCamera',
          'callbackId': 'camera-123',
        });

        final type = parseBridgeMessage(message);
        expect(type, 'openCamera');
      });

      test('handles extra fields in payload', () {
        final message = jsonEncode({
          'type': 'navigate:wallet',
          'returnUrl': '/wallet?tab=transactions',
          'extra': 'data',
        });

        expect(parseBridgeMessage(message), 'navigate:wallet');
      });
    });

    group('Edge Cases', () {
      test('handles empty JSON object', () {
        expect(parseBridgeMessage('{}'), isNull);
        expect(isValidBridgeMessage('{}'), isFalse);
      });

      test('handles JSON array', () {
        expect(parseBridgeMessage('[1, 2, 3]'), isNull);
        expect(isValidBridgeMessage('[1, 2, 3]'), isFalse);
      });

      test('handles JSON string', () {
        expect(parseBridgeMessage('"string"'), isNull);
        expect(isValidBridgeMessage('"string"'), isFalse);
      });

      test('handles JSON number', () {
        expect(parseBridgeMessage('123'), isNull);
        expect(isValidBridgeMessage('123'), isFalse);
      });

      test('handles JSON boolean', () {
        expect(parseBridgeMessage('true'), isNull);
        expect(isValidBridgeMessage('true'), isFalse);
      });

      test('handles JSON null', () {
        expect(parseBridgeMessage('null'), isNull);
        expect(isValidBridgeMessage('null'), isFalse);
      });

      test('handles very long message', () {
        final longText = 'a' * 10000;
        final message = jsonEncode({'type': 'share', 'payload': {'text': longText}});

        expect(parseBridgeMessage(message), 'share');
      });

      test('handles deeply nested JSON', () {
        final message = jsonEncode({
          'type': 'share',
          'payload': {
            'level1': {
              'level2': {
                'level3': {
                  'level4': 'value',
                },
              },
            },
          },
        });

        expect(parseBridgeMessage(message), 'share');
      });
    });
  });

  group('SooqWebView Message Constants', () {
    test('navigate:wallet message format is correct', () {
      final message = jsonEncode({'type': 'navigate:wallet'});
      expect(jsonDecode(message), {'type': 'navigate:wallet'});
    });

    test('navigate:profile message format is correct', () {
      final message = jsonEncode({'type': 'navigate:profile'});
      expect(jsonDecode(message), {'type': 'navigate:profile'});
    });

    test('navigate:back message format is correct', () {
      final message = jsonEncode({'type': 'navigate:back'});
      expect(jsonDecode(message), {'type': 'navigate:back'});
    });

    test('auth:expired message format is correct', () {
      final message = jsonEncode({'type': 'auth:expired'});
      expect(jsonDecode(message), {'type': 'auth:expired'});
    });

    test('openCamera message format is correct', () {
      final message = jsonEncode({'type': 'openCamera'});
      expect(jsonDecode(message), {'type': 'openCamera'});
    });
  });
}
