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