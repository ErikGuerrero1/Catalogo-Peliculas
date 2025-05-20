import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipes_app/models/movie_model.dart';
import 'package:recipes_app/providers/movie_providers.dart';

class AddMovieScreen extends StatefulWidget {
  static const routeName = '/movies';

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _imageLinkController = TextEditingController();
  final _priceController = TextEditingController(text: '4.99');

  List<String> _rentalSteps = [
    'Seleccionar película',
    'Realizar pago',
    'Ver película',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _synopsisController.dispose();
    _imageLinkController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Capture all form values first before any potential state changes
    final String title = _titleController.text.trim();
    final String director = _directorController.text.trim();
    final String synopsis = _synopsisController.text.trim();
    final String imageLink = _imageLinkController.text.trim();
    final double price = double.tryParse(_priceController.text) ?? 4.99;
    final List<String> rentalSteps = List.from(
      _rentalSteps.where((step) => step.isNotEmpty),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new movie with a unique ID
      final int newId = DateTime.now().millisecondsSinceEpoch % 10000;

      final newMovie = MovieModel(
        id: newId,
        title: title,
        director: director,
        synopsis: synopsis,
        imageLink: imageLink,
        rentalSteps: rentalSteps,
        price: price,
      );

      print('Attempting to save movie: ${newMovie.title}');

      final moviesProvider = Provider.of<MovieProviders>(
        context,
        listen: false,
      );
      final success = await moviesProvider.saveMovie(newMovie);

      if (!mounted) return; // Safety check if widget is disposed

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Película agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form safely
        if (_formKey.currentState != null) {
          _formKey.currentState!.reset();
        }
        _titleController.clear();
        _directorController.clear();
        _synopsisController.clear();
        _imageLinkController.clear();
        _priceController.text = '4.99';

        setState(() {
          _rentalSteps = [
            'Seleccionar película',
            'Realizar pago',
            'Ver película',
          ];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo agregar la película'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _saveMovie: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Nueva Película')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el título';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _directorController,
                        decoration: InputDecoration(
                          labelText: 'Director',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el nombre del director';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _synopsisController,
                        decoration: InputDecoration(
                          labelText: 'Sinopsis',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una sinopsis';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _imageLinkController,
                        decoration: InputDecoration(
                          labelText: 'URL de la imagen',
                          border: OutlineInputBorder(),
                          hintText: 'https://ejemplo.com/imagen.jpg',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una URL de imagen';
                          }

                          try {
                            final uri = Uri.parse(value);
                            if (!uri.hasScheme ||
                                (!uri.scheme.startsWith('http') &&
                                    !uri.scheme.startsWith('https'))) {
                              return 'URL debe comenzar con http:// o https://';
                            }
                          } catch (e) {
                            return 'Por favor ingresa una URL válida';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un precio';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingresa un número válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Pasos para alquilar:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._rentalSteps.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: step,
                                  decoration: InputDecoration(
                                    labelText: 'Paso ${idx + 1}',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rentalSteps[idx] = value;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _rentalSteps.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _rentalSteps.add('');
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text('Agregar paso'),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveMovie,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'GUARDAR PELÍCULA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
