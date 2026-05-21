import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Página de comentarios públicos: muestra los comentarios de TODOS
/// los usuarios para un lugar seleccionable. (Punto 6)
class ComentariosPage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const ComentariosPage({super.key, required this.usuario});

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  static const Color naranja = Color(0xFFE65100);

  List<dynamic> _lugares = [];
  List<dynamic> _comentarios = [];
  dynamic _lugarSeleccionado;
  bool _cargandoLugares = true;
  bool _cargandoComentarios = false;

  @override
  void initState() {
    super.initState();
    _cargarLugares();
  }

  Future<void> _cargarLugares() async {
    try {
      final data = await ApiService.getLugares();
      setState(() {
        _lugares = data;
        _cargandoLugares = false;
      });
    } catch (e) {
      setState(() => _cargandoLugares = false);
    }
  }

  Future<void> _cargarComentarios(int idLugar) async {
    setState(() => _cargandoComentarios = true);
    try {
      final data = await ApiService.getComentariosDeLugar(idLugar);
      setState(() => _comentarios = data);
    } catch (e) {
      setState(() => _comentarios = []);
    } finally {
      if (mounted) setState(() => _cargandoComentarios = false);
    }
  }

  void _mostrarDialogoComentario() {
    if (_lugarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un lugar primero')),
      );
      return;
    }

    final comentarioCtrl = TextEditingController();
    int puntuacion = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(
            'Comentar: ${_lugarSeleccionado['nombre_lugar']}',
            style: const TextStyle(color: naranja, fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: comentarioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tu comentario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Puntuación: '),
                  ...List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setStateDialog(() => puntuacion = i + 1),
                      child: Icon(
                        i < puntuacion ? Icons.star : Icons.star_border,
                        color: naranja,
                        size: 28,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranja),
              onPressed: () async {
                if (comentarioCtrl.text.trim().isEmpty) return;
                try {
                  await ApiService.agregarComentario(
                    widget.usuario['id_usuario'],
                    _lugarSeleccionado['id_lugar'],
                    comentarioCtrl.text.trim(),
                    puntuacion,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  // Recargar comentarios
                  await _cargarComentarios(_lugarSeleccionado['id_lugar']);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Comentario publicado!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al publicar')),
                    );
                  }
                }
              },
              child: const Text(
                'Publicar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        backgroundColor: naranja,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Comentarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: naranja,
        onPressed: _mostrarDialogoComentario,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('Comentar', style: TextStyle(color: Colors.white)),
      ),
      body: _cargandoLugares
          ? const Center(child: CircularProgressIndicator(color: naranja))
          : Column(
              children: [
                // Selector de lugar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: DropdownButtonFormField<dynamic>(
                    value: _lugarSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Selecciona un lugar',
                      prefixIcon: const Icon(Icons.place, color: naranja),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: naranja, width: 2),
                      ),
                    ),
                    items: _lugares.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Text(
                          l['nombre_lugar'] ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _lugarSeleccionado = value;
                        _comentarios = [];
                      });
                      if (value != null) {
                        _cargarComentarios(value['id_lugar']);
                      }
                    },
                  ),
                ),

                // Lista de comentarios (PÚBLICOS de todos los usuarios)
                Expanded(
                  child: _lugarSeleccionado == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: naranja,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Selecciona un lugar para\nver sus comentarios',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _cargandoComentarios
                      ? const Center(
                          child: CircularProgressIndicator(color: naranja),
                        )
                      : _comentarios.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.comment, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Sin comentarios aún.\n¡Sé el primero!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _comentarios.length,
                          itemBuilder: (_, i) {
                            final c = _comentarios[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.orange[100],
                                          child: Text(
                                            (c['alias_usuario'] ?? '?')[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: naranja,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            c['alias_usuario'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: naranja,
                                            ),
                                          ),
                                        ),
                                        // Estrellas
                                        Row(
                                          children: List.generate(
                                            5,
                                            (si) => Icon(
                                              si < (c['puntuacion'] ?? 0)
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      c['comentario'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['fecha'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
