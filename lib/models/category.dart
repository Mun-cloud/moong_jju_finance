class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String userId;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? 'help_outline',
      color: json['color'] ?? '#808080',
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'user_id': userId,
    };
  }
}
