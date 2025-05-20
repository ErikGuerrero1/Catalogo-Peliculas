import 'package:recipes_app/models/movie_model.dart';

class CartItem {
  MovieModel movie;
  int quantity;

  CartItem({
    required this.movie,
    this.quantity = 1,
  });

  double get totalPrice => movie.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'movie': movie.toJson(),
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}