import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipes_app/models/movie_model.dart';
import 'package:recipes_app/providers/movie_providers.dart';
import 'package:recipes_app/screens/movie_detail_screen.dart';
import 'package:recipes_app/screens/cart_screen.dart';

class MovieCatalogScreen extends StatefulWidget {
  const MovieCatalogScreen({Key? key}) : super(key: key);

  @override
  State<MovieCatalogScreen> createState() => _MovieCatalogScreenState();
}

class _MovieCatalogScreenState extends State<MovieCatalogScreen> {
  @override
  void initState() {
    super.initState();
    print('MovieCatalogScreen - initState called');
    // Fetch movies when the screen loads
    Future.microtask(() {
      print('MovieCatalogScreen - fetching movies');
      Provider.of<MovieProviders>(context, listen: false).fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProviders>(context);
    final movies = moviesProvider.movies;
    final isLoading = moviesProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Películas'),
        actions: [
          // Botón de favoritos
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          // Botón del carrito con contador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (moviesProvider.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${moviesProvider.cartItems.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : movies.isEmpty
              ? Center(child: Text('No hay películas disponibles'))
              : GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (ctx, index) {
                  final movie = movies[index];
                  return MovieCard(movie: movie);
                },
              ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final MovieModel movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProviders>(context, listen: false);
    final isFavorite = moviesProvider.favoriteMovies.contains(movie);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la película
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  movie.imageLink,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder:
                      (ctx, error, _) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.movie, size: 50),
                        alignment: Alignment.center,
                      ),
                ),
              ),
            ),
            // Información de la película
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Botón de favorito
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                            size: 20,
                          ),
                          onPressed: () {
                            moviesProvider.toggleFavoriteStatus(movie);
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Director: ${movie.director}',
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${movie.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        // Botón para agregar al carrito
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart, size: 20),
                          onPressed: () {
                            moviesProvider.addToCart(movie);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Película agregada al carrito'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
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
