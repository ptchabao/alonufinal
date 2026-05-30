import 'package:riverpod/riverpod.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/order_usecases.dart';

final myOrdersProvider = FutureProvider.family<List<Order>, bool>((ref, isArtisan) async {
  final result = await getIt<GetMyOrdersUseCase>().call(isArtisan: isArtisan, page: 1);
  return result.fold((failure) => [], (orders) => orders);
});

final orderDetailsProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final result = await getIt<GetOrderDetailsUseCase>().call(orderId);
  return result.fold((failure) => throw Exception(failure.message), (order) => order);
});
