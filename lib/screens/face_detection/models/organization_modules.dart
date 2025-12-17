class OrganizationModule {
  final int id;
  final String moduleDisplayName;
  final String moduleIcon;
  final String moduleRoute;

  OrganizationModule({
    required this.id,
    required this.moduleDisplayName,
    required this.moduleIcon,
    required this.moduleRoute,
  });

  factory OrganizationModule.fromJson(Map<String, dynamic> json) {
    return OrganizationModule(
      id: json['id'] ?? 0,
      moduleDisplayName: json['module_display_name'] ?? '',
      moduleIcon: json['module_icon'] ?? '',
      moduleRoute: json['module_route'] ?? '',
    );
  }
}
