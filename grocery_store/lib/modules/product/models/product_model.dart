class Product {
  final int id;
  final String title;
  final String image;
  final double price;
  final String category;
  final Rating rating;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.category,
    required this.rating,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      rating: Rating.fromJson(json['rating']),
      description: json['description'],
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(rate: (json['rate'] as num).toDouble(), count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {'rate': rate, 'count': count};
  }
}
