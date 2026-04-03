// test/core/network/web_constants_test.dart
//
// Unit tests for WebConstants — URL generation for the Madhmoon React web app.
// Guards against regressions in dev/prod URL construction and sooq path formatting.


import 'package:flutter_test/flutter_test.dart';

import 'package:luqta/core/network/web_constants.dart';

void main() {
  group('WebConstants', () {
    group('baseWebUrl', () {
      test('returns dev URL format with port in debug mode', () {
        // Debug mode should return localhost with port 5173
        // Note: Actual host depends on Platform (Android uses 10.0.2.2, iOS uses 127.0.0.1)
        final url = WebConstants.baseWebUrl;

        expect(url, contains(':5173'));
        expect(url, startsWith('http://'));
      });

      test('contains Vite default dev server port 5173', () {
        final url = WebConstants.baseWebUrl;
        expect(url, contains(':5173'));
      });

      test('uses http protocol in debug mode', () {
        final url = WebConstants.baseWebUrl;
        expect(url, startsWith('http://'));
      });
    });

    group('sooqUrl', () {
      test('constructs correct URL for mazadat sooq', () {
        final url = WebConstants.sooqUrl('mazadat');

        expect(url, endsWith('/m/mazadat'));
        expect(url, contains(WebConstants.baseWebUrl));
      });

      test('constructs correct URL for matajir sooq', () {
        final url = WebConstants.sooqUrl('matajir');

        expect(url, endsWith('/m/matajir'));
      });

      test('constructs correct URL for balla sooq', () {
        final url = WebConstants.sooqUrl('balla');

        expect(url, endsWith('/m/balla'));
      });

      test('constructs correct URL for mustamal sooq', () {
        final url = WebConstants.sooqUrl('mustamal');

        expect(url, endsWith('/m/mustamal'));
      });

      test('constructs correct URL for chat sooq', () {
        final url = WebConstants.sooqUrl('chat');

        expect(url, endsWith('/m/chat'));
      });

      test('constructs correct URL for activity sooq', () {
        final url = WebConstants.sooqUrl('activity');

        expect(url, endsWith('/m/activity'));
      });

      test('constructs correct URL for feed sooq', () {
        final url = WebConstants.sooqUrl('feed');

        expect(url, endsWith('/m/feed'));
      });

      test('handles special characters in sooq slug', () {
        final url = WebConstants.sooqUrl('special-slug_123');

        expect(url, endsWith('/m/special-slug_123'));
      });

      test('handles empty string sooq slug', () {
        final url = WebConstants.sooqUrl('');

        expect(url, endsWith('/m/'));
      });

      test('handles sooq slug with unicode characters', () {
        final url = WebConstants.sooqUrl('مزادات');

        expect(url, contains('/m/'));
        expect(url, contains('مزادات'));
      });

      test('URL contains correct base path segment', () {
        final url = WebConstants.sooqUrl('test');

        // Should have /m/ segment for mobile web entry point
        expect(url, contains('/m/'));
      });

      test('produces valid URI that can be parsed', () {
        final url = WebConstants.sooqUrl('test');
        final uri = Uri.parse(url);

        expect(uri.path, equals('/m/test'));
        expect(uri.scheme, equals('http'));
      });
    });

    group('URL format consistency', () {
      test('all sooq URLs share the same base', () {
        final baseUrl = WebConstants.baseWebUrl;
        final sooqs = ['mazadat', 'matajir', 'balla', 'mustamal', 'chat'];

        for (final sooq in sooqs) {
          final sooqUrl = WebConstants.sooqUrl(sooq);
          expect(sooqUrl, startsWith(baseUrl));
        }
      });

      test('sooqUrl always produces unique URLs for different slugs', () {
        final sooqs = ['mazadat', 'matajir', 'balla', 'mustamal'];
        final urls = sooqs.map((s) => WebConstants.sooqUrl(s)).toSet();

        expect(urls.length, equals(sooqs.length));
      });
    });
  });
}
