class CartItem {
  String foodName;
  String foodId;
  int price;
  String orderId;
  String restaurantId;
  String customerId;
  bool restaurantApproval;
  bool customerConfirmation;

  CartItem({
    required this.foodName,
    required this.foodId,
    required this.price,
    required this.orderId,
    required this.restaurantId,
    required this.customerId,
    required this.restaurantApproval,
    required this.customerConfirmation, required bool isSelected,
  });
}