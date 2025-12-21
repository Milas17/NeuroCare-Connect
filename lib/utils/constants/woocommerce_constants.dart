class CartKeys {
  static const cartItemCountKey = 'Cart Item Count';
  static const billingAddress = 'Billing Address';
  static const shippingAddress = 'Shipping Address';
}

class ProductFilters {
  static const String priceLowHigh = "price_asc";
  static const String priceHighLow = "price_desc";
  static const String discount = "discount";
  static const String date = "date";
  static const String rating = "rating";
  static const String popularity = "popularity";
}

class OrderStatus {
  static String any = 'any';
  static String pending = 'pending';
  static String processing = 'processing';
  static String onHold = 'on-hold';
  static String completed = 'completed';
  static String cancelled = 'cancelled';
  static String refunded = 'refunded';
  static String failed = 'failed';
  static String trash = 'trash';
}

class ProductTypes {
  static String simple = 'simple';
  static String grouped = 'grouped';
  static String variation = 'variation';
  static String variable = 'variable';

  static String external = 'external';
}

class DiscountType {
  static String percentage = 'percent';
  static String fixedCart = 'fixed_cart';
  static String fixedProduct = 'fixed_product';
}
