import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoritosPage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const FavoritosPage({super.key, required this.usuario});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  static const Color naranja = Color(0xFFE65100);
  List<dynamic> _favoritos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() => _cargando = true);
    try {
      final data = await ApiService.getFavoritos(widget.usuario['id_usuario']);
      setState(() => _favoritos = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar favoritos')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarFavorito(int idLugar) async {
    try {
      await ApiService.eliminarFavorito(widget.usuario['id_usuario'], idLugar);
      await _cargarFavoritos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        backgroundColor: naranja,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mis Favoritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: naranja))
          : _favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: naranja),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: naranja,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrega lugares desde el detalle de cada lugar.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoritos.length,
              itemBuilder: (_, i) {
                final lugar = _favoritos[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/lugares/${lugar['imagen_url'] ?? ''}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.orange[50],
                          child: const Icon(
                            Icons.place,
                            color: naranja,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      lugar['nombre_lugar'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: naranja,
                      ),
                    ),
                    subtitle: Text(
                      lugar['descripcion'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 22,
                      ),
                      tooltip: 'Quitar de favoritos',
                      onPressed: () => _eliminarFavorito(lugar['id_lugar']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
