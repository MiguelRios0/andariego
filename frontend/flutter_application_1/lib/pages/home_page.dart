import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import 'caracterizacion_page.dart';
import 'login_page.dart';
import 'favoritos_page.dart';
import 'comentarios_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color naranja = Color(0xFFE65100);

  late Map<String, dynamic> _usuario;

  List<dynamic> _hobbiesUsuario = [];
  List<dynamic> _todosLugares = [];
  List<dynamic> _ruta = [];
  bool _cargando = true;

  // ── GIRARDOT coords (centro del mapa) ───────────────────
  static const LatLng _girardotCenter = LatLng(4.3042, -74.8031);

  @override
  void initState() {
    super.initState();
    _usuario = Map<String, dynamic>.from(widget.usuario);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final results = await Future.wait([
        ApiService.getHobbiesDeUsuario(_usuario['id_usuario']),
        ApiService.getLugares(),
        ApiService.getCaracterizacionUsuario(_usuario['id_usuario']),
        ApiService.getMiRuta(_usuario['id_usuario']),
      ]);

      final hobbies = results[0] as List<dynamic>;
      final lugares = results[1] as List<dynamic>;
      final carac = results[2] as Map<String, dynamic>?;
      final rutaData = results[3] as Map<String, dynamic>;

      if (carac != null && carac['avatar'] != null) {
        _usuario['avatar'] = carac['avatar'];
      }

      setState(() {
        _hobbiesUsuario = hobbies;
        _todosLugares = lugares;
        _ruta = rutaData['lugares'] ?? [];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  // ── PUNTO 2: Filtra por nombre_hobbie contra campo 'categoria' del lugar ──
  List<dynamic> _lugaresPorHobbie(String nombreHobbie) {
    // Mapeo explícito hobbie → categorías en BD
    const Map<String, List<String>> mapeo = {
      'Lectura': ['Lectura', 'Leer'],
      'Naturaleza': ['Naturaleza', 'Caminar'],
      'Cultura': ['Cultura', 'Historia'],
      'Deporte': ['Deporte'],
      'Gastronomía': ['Gastronomía'],
      'Aventura': ['Aventura'],
      'Relajación': ['Relajación'],
      'Fiesta': ['Fiesta', 'Shopping'],
    };

    final categorias = mapeo[nombreHobbie] ?? [nombreHobbie];

    return _todosLugares.where((l) {
      final cat = (l['categoria'] ?? '').toString().trim();
      return categorias.any((c) => cat.toLowerCase() == c.toLowerCase());
    }).toList();
  }
  //List<dynamic> _lugaresPorHobbie(String nombreHobbie) {
  //final termino = nombreHobbie.trim().toLowerCase();
  //return _todosLugares.where((l) {
  //final cat = (l['categoria'] ?? '').toString().toLowerCase();
  // Comparación exacta primero; si no, contiene
  //return cat == termino || cat.contains(termino);
  //}).toList();
  //}

  // ── PUNTO 3: Agrega lugar a ruta persistente en BD ──────
  Future<void> _agregarARuta(Map<String, dynamic> lugar) async {
    final yaEsta = _ruta.any((l) => l['id_lugar'] == lugar['id_lugar']);
    if (yaEsta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este lugar ya está en tu ruta')),
      );
      return;
    }
    try {
      await ApiService.agregarLugarARuta(
        _usuario['id_usuario'],
        lugar['id_lugar'],
      );
      final rutaData = await ApiService.getMiRuta(_usuario['id_usuario']);
      setState(() => _ruta = rutaData['lugares'] ?? []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lugar['nombre_lugar']} agregado a tu ruta'),
            backgroundColor: naranja,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al agregar el lugar a la ruta')),
        );
      }
    }
  }

  Future<void> _eliminarDeRuta(int idLugar) async {
    try {
      await ApiService.eliminarLugarDeRuta(_usuario['id_usuario'], idLugar);
      final rutaData = await ApiService.getMiRuta(_usuario['id_usuario']);
      setState(() => _ruta = rutaData['lugares'] ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el lugar de la ruta'),
          ),
        );
      }
    }
  }

  // ── PUNTO 5: Editar usuario con todos los campos del registro ──
  void _mostrarDialogoEditarUsuario() {
    final nombreCtrl = TextEditingController(text: _usuario['nombre'] ?? '');
    final apellidoCtrl = TextEditingController(
      text: _usuario['apellido'] ?? '',
    );
    final telefonoCtrl = TextEditingController(
      text: _usuario['telefono'] ?? '',
    );
    final aliasCtrl = TextEditingController(
      text: _usuario['alias_usuario'] ?? '',
    );
    final correoCtrl = TextEditingController(
      text: _usuario['correo_electronico'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: naranja, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Número de identificación: solo lectura
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: _usuario['numero_identificacion']?.toString() ?? '',
                ),
                decoration: InputDecoration(
                  labelText: 'Número de identificación',
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: const Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: apellidoCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: aliasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alias (se usa para iniciar sesión)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: correoCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              const SizedBox(height: 12),
              // Contraseña inmutable - aviso
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: naranja),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'La contraseña no puede modificarse por ahora.',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: naranja),
            onPressed: () async {
              try {
                final datosModificados = {
                  'nombre': nombreCtrl.text.trim(),
                  'apellido': apellidoCtrl.text.trim(),
                  'telefono': telefonoCtrl.text.trim(),
                  'alias_usuario': aliasCtrl.text.trim(),
                  'correo_electronico': correoCtrl.text.trim(),
                };
                final respuesta = await ApiService.editarUsuario(
                  _usuario['id_usuario'],
                  datosModificados,
                );
                final usuarioActualizado = respuesta['usuario'] ?? respuesta;
                setState(() {
                  _usuario['nombre'] = usuarioActualizado['nombre'];
                  _usuario['apellido'] = usuarioActualizado['apellido'];
                  _usuario['telefono'] = usuarioActualizado['telefono'];
                  _usuario['alias_usuario'] =
                      usuarioActualizado['alias_usuario'];
                  _usuario['correo_electronico'] =
                      usuarioActualizado['correo_electronico'];
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al actualizar datos')),
                  );
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── PUNTO 1: Menú usuario con botón Cerrar sesión ────────
  void _abrirMenuUsuario() {
    final String? avatar = _usuario['avatar'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.orange[50],
                backgroundImage: avatar != null
                    ? AssetImage('assets/avatares/$avatar')
                    : null,
                child: avatar == null
                    ? const Icon(Icons.account_circle, size: 56, color: naranja)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                _usuario['alias_usuario'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: naranja,
                ),
              ),
              const Divider(height: 24),
              // Caracterización
              ListTile(
                leading: const Icon(Icons.person_outline, color: naranja),
                title: const Text('Caracterización'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CaracterizacionPage(usuario: _usuario),
                    ),
                  );
                  _cargarDatos();
                },
              ),
              // Editar usuario
              ListTile(
                leading: const Icon(Icons.edit, color: naranja),
                title: const Text('Editar usuario'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoEditarUsuario();
                },
              ),
              // Eliminar cuenta
              ListTile(
                leading: const Icon(Icons.person_off, color: Colors.red),
                title: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminarCuenta();
                },
              ),
              const Divider(height: 8),
              // PUNTO 1: Cerrar sesión en el mismo menú
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.grey),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEliminarCuenta() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Tu cuenta será inactivada. Tus datos se conservan en el sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.inactivarUsuario(_usuario['id_usuario']);
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? avatar = _usuario['avatar'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        backgroundColor: naranja,
        automaticallyImplyLeading: false,
        title: Text(
          '¡Hola, ${_usuario['alias_usuario']}!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _abrirMenuUsuario,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: avatar != null
                    ? AssetImage('assets/avatares/$avatar')
                    : null,
                child: avatar == null
                    ? const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 32,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: naranja))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '¿Qué prefieres, aventura o relajo?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: naranja,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cards de hobbies
                  if (_hobbiesUsuario.isEmpty)
                    _cardSinCaracterizacion()
                  else
                    ..._hobbiesUsuario.take(4).map((h) {
                      final nombreHobbie = h['nombre_hobbie'] ?? 'Hobby';
                      final lugares = _lugaresPorHobbie(nombreHobbie);
                      return _cardHobbie(nombreHobbie, lugares);
                    }),

                  const SizedBox(height: 16),
                  // PUNTO 3 + 6 + 7: Card Ruta completa
                  _cardRuta(),
                  const SizedBox(height: 24),

                  // PUNTO 6: Botones inferiores funcionales
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: [
                      _botonInferior(
                        Icons.chat_bubble_outline,
                        'Comentarios',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComentariosPage(usuario: _usuario),
                          ),
                        ),
                      ),
                      _botonInferior(
                        Icons.favorite_border,
                        'Favoritos',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FavoritosPage(usuario: _usuario),
                          ),
                        ),
                      ),
                      _botonInferior(
                        Icons.star_border,
                        'Guardados',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FavoritosPage(usuario: _usuario),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ── WIDGETS ─────────────────────────────────────────────

  Widget _cardSinCaracterizacion() {
    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: naranja, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Aún no tienes caracterización',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: naranja,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completa tu perfil para ver lugares según tus gustos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: naranja),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CaracterizacionPage(usuario: _usuario),
                  ),
                );
                _cargarDatos();
              },
              child: const Text(
                'Completar caracterización',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHobbie(String nombre, List<dynamic> lugares) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ExpansionTile(
        leading: const Icon(Icons.place, color: naranja),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: naranja,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${lugares.length} lugares disponibles',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: lugares.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay lugares para esta categoría aún.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ]
            : lugares.map((lugar) {
                return ListTile(
                  title: Text(lugar['nombre_lugar'] ?? ''),
                  subtitle: Text(
                    lugar['descripcion'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: naranja),
                    tooltip: 'Agregar a mi ruta',
                    onPressed: () =>
                        _agregarARuta(Map<String, dynamic>.from(lugar)),
                  ),
                  onTap: () => _verDetalleLugar(lugar),
                );
              }).toList(),
      ),
    );
  }

  // ── PUNTO 6 + 7: Card Ruta expandida con mapa y botones ─
  Widget _cardRuta() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: ExpansionTile(
        leading: const Icon(Icons.map, color: naranja),
        title: const Text(
          'Mi Ruta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: naranja,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _ruta.isEmpty
              ? 'Agrega lugares desde las cards'
              : '${_ruta.length} lugar(es) en tu ruta',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          // PUNTO 7: Mapa de Girardot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _girardotCenter,
                    zoom: 13,
                  ),
                  markers: _ruta.map((lugar) {
                    final lat =
                        double.tryParse(lugar['latitud']?.toString() ?? '') ??
                        _girardotCenter.latitude;
                    final lng =
                        double.tryParse(lugar['longitud']?.toString() ?? '') ??
                        _girardotCenter.longitude;
                    return Marker(
                      markerId: MarkerId('${lugar['id_lugar']}'),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(
                        title: lugar['nombre_lugar'] ?? '',
                        snippet: lugar['descripcion'] ?? '',
                      ),
                    );
                  }).toSet(),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (_ruta.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tu ruta está vacía. Presiona + en cualquier lugar para agregarlo.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            // PUNTO 7: Lista de lugares con nombre, descripción e imagen
            ...(_ruta.map((lugar) => _itemRuta(lugar))),

          const Divider(height: 1),
          // PUNTO 6: Botones guardar, comentar y favoritos dentro de la ruta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botonAccionRuta(Icons.save_outlined, 'Guardar', () async {
                  // Guardar toda la ruta como favoritos
                  if (_ruta.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tu ruta está vacía')),
                    );
                    return;
                  }
                  int guardados = 0;
                  for (final lugar in _ruta) {
                    try {
                      await ApiService.agregarFavorito(
                        _usuario['id_usuario'],
                        lugar['id_lugar'],
                      );
                      guardados++;
                    } catch (_) {}
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$guardados lugar(es) guardados en favoritos',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }),
                _botonAccionRuta(Icons.chat_bubble_outline, 'Comentar', () {
                  if (_ruta.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agrega lugares a tu ruta primero'),
                      ),
                    );
                    return;
                  }
                  // Comentar el primer lugar de la ruta
                  _mostrarDialogoComentario(_ruta.first);
                }),
                _botonAccionRuta(Icons.favorite_border, 'Favoritos', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritosPage(usuario: _usuario),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // PUNTO 7: Item de lugar dentro de la ruta con imagen, nombre y descripción
  Widget _itemRuta(Map<String, dynamic> lugar) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del lugar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/lugares/${lugar['imagen_url'] ?? ''}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.orange[50],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: naranja,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lugar['nombre_lugar'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: naranja,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lugar['descripcion'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    if (lugar['horario'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lugar['horario'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Botón eliminar de ruta
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'Eliminar de la ruta',
                onPressed: () => _confirmarEliminarDeLaRuta(lugar),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ],
    );
  }

  // PUNTO 6: Diálogo para comentar un lugar
  void _mostrarDialogoComentario(Map<String, dynamic> lugar) {
    final comentarioCtrl = TextEditingController();
    int puntuacion = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(
            'Comentar: ${lugar['nombre_lugar']}',
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
                    _usuario['id_usuario'],
                    lugar['id_lugar'],
                    comentarioCtrl.text.trim(),
                    puntuacion,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
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
                      const SnackBar(
                        content: Text('Error al publicar comentario'),
                      ),
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

  void _confirmarEliminarDeLaRuta(Map<String, dynamic> lugar) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar de la ruta?'),
        content: Text(
          '¿Estás seguro de eliminar "${lugar['nombre_lugar']}" de tu ruta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _eliminarDeRuta(lugar['id_lugar']);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Detalle de lugar (desde card de hobbie)
  void _verDetalleLugar(dynamic lugar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // PUNTO 7: Imagen del lugar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/lugares/${lugar['imagen_url'] ?? ''}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.orange[50],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: naranja,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lugar['nombre_lugar'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: naranja,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lugar['descripcion'] ?? '',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              if (lugar['horario'] != null)
                _infoFila(Icons.access_time, 'Horario', lugar['horario']),
              if (lugar['costo'] != null)
                _infoFila(Icons.attach_money, 'Costo', '\$${lugar['costo']}'),
              if (lugar['contacto'] != null)
                _infoFila(Icons.phone, 'Contacto', lugar['contacto']),
              const SizedBox(height: 20),
              // PUNTO 6: Botones comentar, guardar y favorito en detalle de lugar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _botonAccion(Icons.chat_bubble_outline, 'Comentar', () {
                    Navigator.pop(context);
                    _mostrarDialogoComentario(Map<String, dynamic>.from(lugar));
                  }),
                  _botonAccion(Icons.add_road, 'A mi ruta', () {
                    Navigator.pop(context);
                    _agregarARuta(Map<String, dynamic>.from(lugar));
                  }),
                  _botonAccion(Icons.favorite_border, 'Favorito', () async {
                    Navigator.pop(context);
                    try {
                      await ApiService.agregarFavorito(
                        _usuario['id_usuario'],
                        lugar['id_lugar'],
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${lugar['nombre_lugar']} guardado en favoritos',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al guardar en favoritos'),
                          ),
                        );
                      }
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: naranja, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  Widget _botonAccion(IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: naranja),
      label: Text(label, style: const TextStyle(color: naranja)),
    );
  }

  Widget _botonAccionRuta(IconData icon, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: naranja, size: 22),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: naranja, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _botonInferior(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: naranja, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
