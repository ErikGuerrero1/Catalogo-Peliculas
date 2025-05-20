class MovieModel {
  int id;
  String title;
  String director;
  String imageLink;
  String synopsis;
  List<String> rentalSteps;
  double price;

  // Constructor
  MovieModel({
    required this.id,
    required this.title,
    required this.director,
    required this.imageLink,
    required this.synopsis,
    required this.rentalSteps,
    required this.price,
  });

  factory MovieModel.fromJSON(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'],
      director: json['director'],
      imageLink: json['imageLink'],
      synopsis: json['synopsis'],
      rentalSteps: List<String>.from(json['rentalSteps']),
      price: json['price'] != null ? json['price'].toDouble() : 4.99,
    );
  }

  // Conversor a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'director': director,
      'imageLink': imageLink,
      'synopsis': synopsis,
      'rentalSteps': rentalSteps,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, director: $director, imageLink: $imageLink, synopsis: $synopsis, price: $price)';
  }
}
