class SiteConfigLoginPage {
  final String companyName;
  final String logoPath;

  SiteConfigLoginPage({
    required this.companyName,
    required this.logoPath,
  });

  factory SiteConfigLoginPage.fromJson(Map<String, dynamic> json) {
    return SiteConfigLoginPage(
      companyName: json['companyName'] ?? '',
      logoPath: json['logoPath'] ?? '',
    );
  }
}
