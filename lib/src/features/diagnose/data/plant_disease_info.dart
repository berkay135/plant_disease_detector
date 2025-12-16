class PlantDiseaseInfo {
  final String id;
  final String title;
  final String description;
  final List<String> symptoms;
  final TreatmentInfo treatment;
  final List<String> care;
  final List<String> products;
  final String severity; // low, medium, high, critical
  final String pathogenType; // fungal, bacterial, viral, pest, healthy

  PlantDiseaseInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.care,
    required this.products,
    required this.severity,
    required this.pathogenType,
  });

  factory PlantDiseaseInfo.fromJson(Map<String, dynamic> json) {
    return PlantDiseaseInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatment: TreatmentInfo.fromJson(json['treatment'] ?? {}),
      care: List<String>.from(json['care'] ?? []),
      products: List<String>.from(json['products'] ?? []),
      severity: json['severity'] ?? 'low',
      pathogenType: json['pathogen_type'] ?? 'healthy',
    );
  }

  bool get isHealthy => pathogenType == 'healthy';
  
  String get severityText {
    switch (severity) {
      case 'critical':
        return 'Kritik Risk';
      case 'high':
        return 'Yüksek Risk';
      case 'medium':
        return 'Orta Risk';
      case 'low':
        return 'Düşük Risk';
      default:
        return 'Sağlıklı';
    }
  }

  String get pathogenText {
    switch (pathogenType) {
      case 'fungal':
        return 'Mantar';
      case 'bacterial':
        return 'Bakteri';
      case 'viral':
        return 'Virüs';
      case 'pest':
        return 'Zararlı';
      case 'healthy':
        return 'Sağlıklı';
      default:
        return pathogenType;
    }
  }
}

class TreatmentInfo {
  final List<String> natural;
  final List<String> chemical;

  TreatmentInfo({
    required this.natural,
    required this.chemical,
  });

  factory TreatmentInfo.fromJson(Map<String, dynamic> json) {
    return TreatmentInfo(
      natural: List<String>.from(json['natural'] ?? []),
      chemical: List<String>.from(json['chemical'] ?? []),
    );
  }
}
