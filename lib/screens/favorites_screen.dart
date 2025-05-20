import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipes_app/models/movie_model.dart';
import 'package:recipes_app/providers/movie_providers.dart';
import 'package:recipes_app/screens/movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProviders>(context);
    final favoriteMovies = moviesProvider.favoriteMovies;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Películas Favoritas'),
      ),
      body: favoriteMovies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Aún no tienes películas favoritas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Explorar catálogo'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: favoriteMovies.length,
              itemBuilder: (ctx, index) {
                final movie = favoriteMovies[index];
                return FavoriteMovieCard(movie: movie);
              },
            ),
    );
  }
}

class FavoriteMovieCard extends StatelessWidget {
  final MovieModel movie;

  const FavoriteMovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProviders>(context, listen: false);

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Row(
          children: [
            // Imagen de la película
            Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(movie.imageLink),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Información de la película
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Director: ${movie.director}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Precio: \$${movie.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón para quitar de favoritos
                        OutlinedButton.icon(
                          icon: Icon(Icons.favorite_border),
                          label: Text('Quitar de favoritos'),
                          onPressed: () {
                            moviesProvider.toggleFavoriteStatus(movie);
                          },
                        ),
                        // Botón para agregar al carrito
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            moviesProvider.addToCart(movie);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Película agregada al carrito'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}