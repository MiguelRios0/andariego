import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class CaracterizacionPage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const CaracterizacionPage({super.key, required this.usuario});

  @override
  State<CaracterizacionPage> createState() => _CaracterizacionPageState();
}

class _CaracterizacionPageState extends State<CaracterizacionPage> {
  bool _guardando = false;
  bool _cargando = true; // PUNTO 4: cargamos valores existentes al abrir

  // ── Avatares ────────────────────────────────────────────
  final Map<String, String> _avatares = {
    'tortuga.png': 'Tortuga',
    'iguana.png': 'Iguana',
    'garza.png': 'Garza',
    'capibara.png': 'Capibara',
    'mariposa.png': 'Mariposa',
  };
  String? _avatarSeleccionado;

  // ── Mapas texto → ID ────────────────────────────────────
  final Map<String, int> _tipoTurismoIds = {
    'Individual': 3,
    'Pareja': 2,
    'Familiar': 1,
  };
  final Map<int, String> _tipoTurismoNombres = {
    3: 'Individual',
    2: 'Pareja',
    1: 'Familiar',
  };

  final Map<String, int> _horarioIds = {'Mañana': 1, 'Tarde': 2, 'Noche': 3};
  final Map<int, String> _horarioNombres = {
    1: 'Mañana',
    2: 'Tarde',
    3: 'Noche',
  };

  final Map<String, int> _presupuestoIds = {
    'Económico': 1,
    'Medio': 2,
    'Alto': 3,
  };
  final Map<int, String> _presupuestoNombres = {
    1: 'Económico',
    2: 'Medio',
    3: 'Alto',
  };

  // ── Selecciones ─────────────────────────────────────────
  String _sexo = 'Prefiero no decirlo';
  String _tipoTurismo = 'Individual';
  String _presupuesto = 'Medio';
  String _tiempoDisponible = '1 día';
  String _horario = 'Tarde';

  // ── Hobbies ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _hobbiesDisponibles = [
    {'id': 1, 'nombre': 'Deporte'},
    {'id': 2, 'nombre': 'Gastronomía'},
    {'id': 3, 'nombre': 'Cultura'},
    {'id': 4, 'nombre': 'Naturaleza'},
    {'id': 5, 'nombre': 'Aventura'},
    {'id': 6, 'nombre': 'Relajación'},
    {'id': 7, 'nombre': 'Lectura'},
    {'id': 8, 'nombre': 'Fiesta'},
  ];
  final List<int> _hobbiesSeleccionados = [];

  static const Color naranja = Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _cargarCaracterizacionExistente();
  }

  // PUNTO 4: Carga los datos actuales para mostrárselos al usuario al editar
  Future<void> _cargarCaracterizacionExistente() async {
    try {
      final carac = await ApiService.getCaracterizacionUsuario(
        widget.usuario['id_usuario'],
      );
      final hobbies = await ApiService.getHobbiesDeUsuario(
        widget.usuario['id_usuario'],
      );

      if (carac != null) {
        final idTipo = carac['id_tipo_turismo'];
        final idHorario = carac['id_horarios_preferidos'];
        final idPresupuesto = carac['id_presupuesto'];

        setState(() {
          _avatarSeleccionado = carac['avatar'];
          _sexo = carac['sexo'] ?? 'Prefiero no decirlo';
          _tiempoDisponible = carac['tiempo_disponible'] ?? '1 día';
          _tipoTurismo = _tipoTurismoNombres[idTipo] ?? 'Individual';
          _horario = _horarioNombres[idHorario] ?? 'Tarde';
          _presupuesto = _presupuestoNombres[idPresupuesto] ?? 'Medio';
        });
      }

      if (hobbies.isNotEmpty) {
        setState(() {
          _hobbiesSeleccionados.clear();
          for (final h in hobbies) {
            _hobbiesSeleccionados.add(h['id_hobbie']);
          }
        });
      }
    } catch (e) {
      // Si no hay caracterización previa, se muestran los valores por defecto
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // PUNTO 4: Upsert — sobreescribe la caracterización existente
  Future<void> _guardar() async {
    if (_avatarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un avatar')),
      );
      return;
    }
    if (_hobbiesSeleccionados.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar exactamente 4 hobbies'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      // El endpoint /guardar/ ya hace upsert (sobreescribe si existe)
      await ApiService.guardarCaracterizacion({
        'id_usuario': widget.usuario['id_usuario'],
        'avatar': _avatarSeleccionado,
        'tiempo_disponible': _tiempoDisponible,
        'sexo': _sexo,
        'id_tipo_turismo': _tipoTurismoIds[_tipoTurismo],
        'id_horarios_preferidos': _horarioIds[_horario],
        'id_presupuesto': _presupuestoIds[_presupuesto],
      });

      // PUNTO 4: Primero borramos los hobbies anteriores y luego guardamos los nuevos
      await ApiService.reemplazarHobbiesUsuario(
        widget.usuario['id_usuario'],
        _hobbiesSeleccionados,
      );

      final usuarioActualizado = Map<String, dynamic>.from(widget.usuario)
        ..['avatar'] = _avatarSeleccionado;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Caracterización actualizada!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(usuario: usuarioActualizado),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: naranja)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caracterización',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: naranja,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aviso si ya tiene caracterización
            if (_avatarSeleccionado != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_note, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estás editando tu caracterización. Los cambios sobreescribirán la anterior.',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ── 1. Avatar ──────────────────────────────────
            _titulo('1. Elige tu Avatar'),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _avatares.entries.map((entry) {
                  final archivo = entry.key;
                  final nombre = entry.value;
                  final seleccionado = _avatarSeleccionado == archivo;
                  return GestureDetector(
                    onTap: () => setState(() => _avatarSeleccionado = archivo),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: seleccionado
                                    ? naranja
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Image.asset(
                              'assets/avatares/$archivo',
                              width: 75,
                              height: 75,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                size: 75,
                                color: naranja,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: seleccionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: seleccionado ? naranja : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── 2. Sexo ────────────────────────────────────
            _titulo('2. Sexo'),
            _dropdown('Sexo', _sexo, [
              'Masculino',
              'Femenino',
              'Prefiero no decirlo',
            ], (v) => setState(() => _sexo = v!)),

            const SizedBox(height: 16),

            // ── 3. Tipo de turismo ─────────────────────────
            _titulo('3. Tipo de turismo'),
            _dropdown(
              'Tipo de turismo',
              _tipoTurismo,
              ['Individual', 'Pareja', 'Familiar'],
              (v) => setState(() => _tipoTurismo = v!),
            ),

            const SizedBox(height: 16),

            // ── 4. Presupuesto ─────────────────────────────
            _titulo('4. Presupuesto aproximado'),
            _dropdown('Presupuesto', _presupuesto, [
              'Económico',
              'Medio',
              'Alto',
            ], (v) => setState(() => _presupuesto = v!)),

            const SizedBox(height: 16),

            // ── 5. Tiempo disponible ───────────────────────
            _titulo('5. Tiempo disponible'),
            _dropdown(
              'Tiempo disponible',
              _tiempoDisponible,
              [
                '2-3 horas',
                '+3 horas',
                '1 día',
                'Un fin de semana',
                'Vacaciones',
              ],
              (v) => setState(() => _tiempoDisponible = v!),
            ),

            const SizedBox(height: 16),

            // ── 6. Horario preferido ───────────────────────
            _titulo('6. Horario preferido'),
            _dropdown('Horario', _horario, [
              'Mañana',
              'Tarde',
              'Noche',
            ], (v) => setState(() => _horario = v!)),

            const SizedBox(height: 24),

            // ── 7. Hobbies ─────────────────────────────────
            _titulo('7. Selecciona exactamente 4 hobbies'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _hobbiesDisponibles.map((h) {
                final sel = _hobbiesSeleccionados.contains(h['id']);
                return FilterChip(
                  label: Text(h['nombre']),
                  selected: sel,
                  selectedColor: naranja.withAlpha(50),
                  checkmarkColor: naranja,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        if (_hobbiesSeleccionados.length < 4) {
                          _hobbiesSeleccionados.add(h['id']);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solo puedes elegir 4 hobbies'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      } else {
                        _hobbiesSeleccionados.remove(h['id']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '${_hobbiesSeleccionados.length}/4 seleccionados',
              style: TextStyle(
                color: _hobbiesSeleccionados.length == 4
                    ? Colors.green
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: naranja,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GUARDAR Y CONTINUAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: naranja,
      ),
    ),
  );

  Widget _dropdown(
    String label,
    String valor,
    List<String> opciones,
    void Function(String?) onChange,
  ) {
    return DropdownButtonFormField<String>(
      value: valor,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: naranja, width: 2),
        ),
      ),
      items: opciones
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChange,
    );
  }
}
