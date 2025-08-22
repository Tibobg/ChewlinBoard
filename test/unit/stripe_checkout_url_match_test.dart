import 'package:flutter_test/flutter_test.dart';
import 'package:chewlin_board/pages/checkout/stripe_checkout_page.dart';

void main() {
  test('shouldGoToSuccess détecte les URLs de succès', () {
    expect(
      StripeCheckoutPage.shouldGoToSuccess(
        'https://site/checkout/success?sid=123',
      ),
      isTrue,
    );
    expect(
      StripeCheckoutPage.shouldGoToSuccess('https://site/success'),
      isTrue,
    );
    expect(
      StripeCheckoutPage.shouldGoToSuccess('https://site/checkout/cancel'),
      isFalse,
    );
    expect(
      StripeCheckoutPage.shouldGoToSuccess('https://site/anything'),
      isFalse,
    );
  });
}
