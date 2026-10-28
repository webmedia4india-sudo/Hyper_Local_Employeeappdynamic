class Employee {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final int? companyId;
  final String? industry;
  final String? businessName;
  final String? establishmentYear;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.companyId,
    this.industry,
    this.businessName,
    this.establishmentYear,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      companyId: json['company_id'] != null
          ? (json['company_id'] is int
              ? json['company_id']
              : int.tryParse(json['company_id'].toString()))
          : null,
      industry: json['industry']?.toString(),
      businessName: json['business_name']?.toString() ??
          json['businessName']?.toString() ??
          json['company_name']?.toString() ??
          json['companyName']?.toString(),
      establishmentYear: json['establishment_year']?.toString() ??
          json['establishmentYear']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'company_id': companyId,
      'industry': industry,
      'business_name': businessName,
      'establishment_year': establishmentYear,
    };
  }
}