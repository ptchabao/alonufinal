import 'package:riverpod/riverpod.dart';
import '../../domain/entities/order.dart';

class CartItem {
  final String productId;
  final String productTitle;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productTitle,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final double totalPrice;

  CartState({
    this.items = const [],
  }) : totalPrice = items.fold(0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  CartState addItem(CartItem item) {
    final existingIndex = items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      final updatedItems = [...items];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      return copyWith(items: updatedItems);
    }
    return copyWith(items: [...items, item]);
  }

  CartState removeItem(String productId) {
    return copyWith(items: items.where((i) => i.productId != productId).toList());
  }

  CartState updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    return copyWith(
      items: items.map((item) {
        if (item.productId == productId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
  }

  CartState clear() {
    return CartState();
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(CartItem item) {
    state = state.addItem(item);
  }

  void removeItem(String productId) {
    state = state.removeItem(productId);
  }

  void updateItemQuantity(String productId, int quantity) {
    state = state.updateItemQuantity(productId, quantity);
  }

  void clearCart() {
    state = state.clear();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Order state
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState());

  void setOrders(List<Order> orders) {
    state = state.copyWith(orders: orders);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
