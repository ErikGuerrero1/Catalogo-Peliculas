import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_app/models/movie_model.dart';
import 'package:recipes_app/models/cart_item_model.dart';

class MovieProviders extends ChangeNotifier {
  bool isLoading = false;

  List<MovieModel> movies = [];
  List<MovieModel> favoriteMovies = [];
  List<CartItem> cartItems = [];

  String getBaseUrl() {
    if (kIsWeb) {
      // Running in a web browser
      return 'https://682c2a3ad29df7a95be5ca4f.mockapi.io';
    } else if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host localhost
      return 'https://682c2a3ad29df7a95be5ca4f.mockapi.io';
    } else if (Platform.isIOS) {
      // iOS Simulator uses localhost or 127.0.0.1
      return 'https://682c2a3ad29df7a95be5ca4f.mockapi.io';
    } else {
      // Default or other platforms
      return 'https://682c2a3ad29df7a95be5ca4f.mockapi.io';
    }
  }

  Future<void> fetchMovies() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('${getBaseUrl()}/movies');

    print("Fetch Movies");
    try {
      print("Trying to fetch movies");

      final response = await http.get(url);

      print("response status ${response.statusCode}");
      print("respuesta ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        movies = List<MovieModel>.from(
          data.map((movie) => MovieModel.fromJSON(movie)),
        );
      } else {
        print('Error ${response.statusCode}');
        movies = [];
      }
    } catch (e) {
      print("Error in request $e");
      movies = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para agregar o quitar películas de favoritos
  void toggleFavoriteStatus(MovieModel movie) {
    final isFavorite = favoriteMovies.contains(movie);

    try {
      if (isFavorite) {
        favoriteMovies.remove(movie);
      } else {
        favoriteMovies.add(movie);
      }
      print("Favorite status toggled: ${!isFavorite}");
      print("Favorite movies count: ${favoriteMovies.length}");

      notifyListeners();
    } catch (e) {
      print("Error updating favorite movies $e");
      notifyListeners();
    }
  }

  // Métodos para el carrito de compras
  void addToCart(MovieModel movie) {
    // Verificar si la película ya está en el carrito
    int index = cartItems.indexWhere((item) => item.movie.id == movie.id);

    if (index >= 0) {
      // Si ya está en el carrito, incrementar la cantidad
      cartItems[index].quantity++;
    } else {
      // Si no está en el carrito, agregarla
      cartItems.add(CartItem(movie: movie));
    }

    print("Added to cart: ${movie.title}");
    print("Cart items count: ${cartItems.length}");

    notifyListeners();
  }

  void removeFromCart(MovieModel movie) {
    int index = cartItems.indexWhere((item) => item.movie.id == movie.id);

    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        // Si hay más de una unidad, disminuir la cantidad
        cartItems[index].quantity--;
      } else {
        // Si solo hay una unidad, eliminar la película del carrito
        cartItems.removeAt(index);
      }

      print("Removed from cart: ${movie.title}");
      print("Cart items count: ${cartItems.length}");

      notifyListeners();
    }
  }

  void clearCart() {
    cartItems.clear();
    print("Cart cleared");
    notifyListeners();
  }

  double get cartTotal {
    return cartItems.fold(0, (total, cartItem) => total + cartItem.totalPrice);
  }

  // Simulación de proceso de compra
  Future<bool> checkout() async {
    isLoading = true;
    notifyListeners();

    try {
      // Aquí podrías hacer una petición al servidor para procesar la compra
      // Por ahora, simulamos un proceso exitoso con un retraso
      await Future.delayed(Duration(seconds: 2));

      // Vaciar el carrito después de una compra exitosa
      clearCart();

      return true;
    } catch (e) {
      print("Error in checkout process: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Agregar una nueva película (funcionalidad de administrador)
  Future<bool> saveMovie(MovieModel movie) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${getBaseUrl()}/movies');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movie.toJson()),
      );

      print('POST response status: ${response.statusCode}');
      print('POST response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newMovie = MovieModel.fromJSON(jsonDecode(response.body));
        movies.add(newMovie); // Agrega la película que respondió el servidor
        notifyListeners();
        return true;
      } else {
        print('Failed to save movie');
        return false;
      }
    } catch (e) {
      print('Error saving movie: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
