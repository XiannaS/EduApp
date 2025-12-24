class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final String duration;
  final String imageUrl;
  final double price;
  final int maxCapacity;
  final bool isOpen;
  final String instructorName; 

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.duration,
    required this.imageUrl,
    this.price = 0.0,
    this.maxCapacity = 30,
    this.isOpen = true,
    this.instructorName = "Prof. Non assigné",
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'duration': duration,
      'imageUrl': imageUrl,
      'price': price,
      'maxCapacity': maxCapacity,
      'isOpen': isOpen,
      'instructorName': instructorName,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Général',
      level: map['level'] ?? 'Débutant',
      duration: map['duration'] ?? '0h',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      maxCapacity: map['maxCapacity'] ?? 30,
      isOpen: map['isOpen'] ?? true,
      instructorName: map['instructorName'] ?? "Prof. Non assigné",
    );
  }
 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}  