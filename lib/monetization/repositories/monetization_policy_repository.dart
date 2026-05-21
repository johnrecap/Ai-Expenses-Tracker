import '../models/models.dart';

abstract class MonetizationPolicyRepository {
  Future<MonetizationPolicy> getPolicy();
}

class LocalMonetizationPolicyRepository
    implements MonetizationPolicyRepository {
  const LocalMonetizationPolicyRepository({
    MonetizationPolicy? policy,
  }) : _policy = policy;

  final MonetizationPolicy? _policy;

  @override
  Future<MonetizationPolicy> getPolicy() async {
    return _policy ?? MonetizationPolicy.defaults();
  }
}
