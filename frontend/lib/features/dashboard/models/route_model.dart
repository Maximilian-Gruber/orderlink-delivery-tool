class RouteCustomers {
  final String routeId;
  final String routeName;
  final List<CustomerAddress> customers;

  RouteCustomers({required this.routeId, required this.routeName, required this.customers});

  factory RouteCustomers.fromJson(Map<String, dynamic> json) {
    return RouteCustomers(
      routeId: json['routeId'],
      routeName: json['routeName'],
      customers: (json['customers'] as List).map((c) => CustomerAddress.fromJson(c)).toList(),
    );
  }
}

class CustomerAddress {
  final String customerName;
  final String streetName;
  final String streetNumber;
  final String postCode;
  final String city;

  CustomerAddress({
    required this.customerName,
    required this.streetName,
    required this.streetNumber,
    required this.postCode,
    required this.city,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      customerName: json['customerName'],
      streetName: json['streetName'],
      streetNumber: json['streetNumber'],
      postCode: json['postCode'],
      city: json['city'],
    );
  }
}

class RouteOrders {
  final String routeId;
  final String routeName;
  final List<RouteOrder> orders;

  RouteOrders({
    required this.routeId,
    required this.routeName,
    required this.orders,
  });

  factory RouteOrders.fromJson(Map<String, dynamic> json) {
    return RouteOrders(
      routeId: json['routeId'] ?? '',
      routeName: json['routeName'] ?? '',
      orders: (json['orders'] as List? ?? [])
          .map((o) => RouteOrder.fromJson(o))
          .toList(),
    );
  }
}

class RouteOrder {
  final String orderId;
  final String customerName;
  final String streetName;
  final String streetNumber;
  final String postCode;
  final String city;
  final List<ProductSimple> products;

  RouteOrder({
    required this.orderId,
    required this.customerName,
    required this.streetName,
    required this.streetNumber,
    required this.postCode,
    required this.city,
    required this.products,
  });

  factory RouteOrder.fromJson(Map<String, dynamic> json) {
    return RouteOrder(
      orderId: json['orderId'] ?? '',
      customerName: json['customerName'] ?? '',
      streetName: json['streetName'] ?? '',
      streetNumber: json['streetNumber'] ?? '',
      postCode: json['postCode'] ?? '',
      city: json['city'] ?? '',
      products: (json['products'] as List? ?? [])
          .map((p) => ProductSimple.fromJson(p))
          .toList(),
    );
  }
}

class ProductSimple {
  final String productName;
  final int amount;
  final double price;

  ProductSimple({
    required this.productName,
    required this.amount,
    required this.price,
  });

  factory ProductSimple.fromJson(Map<String, dynamic> json) {
    return ProductSimple(
      productName: json['productName'] ?? '',
      amount: json['amount'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}