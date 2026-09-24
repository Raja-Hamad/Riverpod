class Fruit {
  final int id;
  final String name;
  final String emoji;

  const Fruit({
    required this.id,
    required this.name,
    required this.emoji,
  });

  Fruit copyWith({
    int? id,
    String? name,
    String? emoji,
  }) {
    return Fruit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
    );
  }
}