import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../supabase/supabase_bootstrap.dart';
import 'payment_gateway.dart';

class MakyPayGateway implements PaymentGateway {
  @override
  Future<Result<CheckoutSession>> createCheckout({required String planId}) async {
    try {
      await supabaseClient.functions.invoke(
        'makypay-checkout',
        body: {'plan_id': planId},
      );
      // TODO(MakyPay docs): parse checkout URL / reference from response.
      return const Error(SyncFailure('MakyPay checkout response not implemented'));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Result<void>> refreshEntitlement() async {
    // Entitlements sync via pull; no client-side grant.
    return const Success(null);
  }
}
