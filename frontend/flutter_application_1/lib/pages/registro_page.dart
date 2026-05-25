import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  bool _verPassword = false;
  bool _verRepetir = false;

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _numDocCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repetirPasswordCtrl = TextEditingController();

  String _tipoDoc = 'CC';
  final List<String> _tiposDoc = ['TI', 'CC', 'CE', 'PA'];

  static const Color naranja = Color(0xFFE65100);
  

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: naranja),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: naranja, width: 2),
    ),
  );

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final datos = {
        'nombre': _nombreCtrl.text.trim(),
        'apellido': _apellidoCtrl.text.trim(),
        'correo': _correoCtrl.text.trim(),
        'tipo_identificacion': _tipoDoc,
        'numero_identificacion': _numDocCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'alias_usuario': _aliasCtrl.text.trim(),
        'password': _passwordCtrl.text,
      };

      final respuesta = await ApiService.registrarUsuario(datos);

      if (respuesta.containsKey('mensaje')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada! Inicia sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(respuesta.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: naranja,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _deco('Nombre', Icons.person),
                  validator: (v) {
                    if (v == null || v.trim().length < 3)
                      return 'Mínimo 3 letras, sin números';
                    if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(v))
                      return 'Solo letras permitidas';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Apellido
                TextFormField(
                  controller: _apellidoCtrl,
                  decoration: _deco('Apellido', Icons.person_outline),
                  validator: (v) {
                    if (v == null || v.trim().length < 3)
                      return 'Mínimo 3 letras, sin números';
                    if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(v))
                      return 'Solo letras permitidas';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Correo
                TextFormField(
                  controller: _correoCtrl,
                  decoration: _deco('Correo electrónico', Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null ||
                        !RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v)) {
                      return 'Correo inválido (ej: nombre@dominio.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de documento
                DropdownButtonFormField<String>(
                  value: _tipoDoc,
                  decoration: _deco('Tipo de identificación', Icons.badge),
                  items: _tiposDoc
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _tipoDoc = v!),
                ),
                const SizedBox(height: 16),

                // Número de documento
                TextFormField(
                  controller: _numDocCtrl,
                  decoration: _deco('Número de identificación', Icons.numbers),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.length < 8 || v.length > 12) {
                      return 'Debe tener entre 8 y 12 números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: _deco('Teléfono', Icons.phone),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.length != 10)
                      return 'Debe tener exactamente 10 números';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Alias
                TextFormField(
                  controller: _aliasCtrl,
                  decoration: _deco(
                    'Alias (nombre visible en la app)',
                    Icons.alternate_email,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 3)
                      return 'Mínimo 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: _deco('Contraseña', Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verPassword ? Icons.visibility_off : Icons.visibility,
                        color: naranja,
                      ),
                      onPressed: () =>
                          setState(() => _verPassword = !_verPassword),
                    ),
                  ),
                  obscureText: !_verPassword,
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                    if (!RegExp(r'[A-Za-z]').hasMatch(v))
                      return 'Debe contener al menos una letra';
                    if (!RegExp(r'[0-9]').hasMatch(v))
                      return 'Debe contener al menos un número';
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                      return 'Debe contener al menos un carácter especial';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Repetir contraseña
                TextFormField(
                  controller: _repetirPasswordCtrl,
                  decoration: _deco('Repetir contraseña', Icons.lock_outline)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verRepetir
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: naranja,
                          ),
                          onPressed: () =>
                              setState(() => _verRepetir = !_verRepetir),
                        ),
                      ),
                  obscureText: !_verRepetir,
                  validator: (v) {
                    if (v != _passwordCtrl.text)
                      return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: naranja,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'GUARDAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
