import '../../core/error/result.dart';

class CheckoutSession {
  const CheckoutSession({required this.checkoutUrl, required this.reference});

  final String checkoutUrl;
  final String reference;
}

abstract class PaymentGateway {
  Future<Result<CheckoutSession>> createCheckout({required String planId});

  Future<Result<void>> refreshEntitlement();
}
