import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'registro_page.dart';
import 'home_page.dart'; // ← descomenta cuando tengas home_page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _aliasCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _cargando = false;
  bool _verPass = false;

  static const Color naranja = Color(0xFFE65100);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final respuesta = await ApiService.loginUsuario(
        _aliasCtrl.text.trim(),
        _passCtrl.text,
      );

      if (respuesta.containsKey('usuario')) {
        // Login exitoso → guardar datos del usuario y navegar
        // final usuario = respuesta['usuario'];
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(usuario: usuario)));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(usuario: respuesta['usuario']),
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido a Andariego!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          _aliasCtrl.clear();
          _passCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                respuesta['error'] ?? 'Usuario o contraseña incorrectos',
              ),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.explore, size: 100, color: naranja),
                  ),
                  const SizedBox(height: 16),

                  // Título
                  const Text(
                    'Andariego',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: naranja,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre Girardot',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Alias
                  TextFormField(
                    controller: _aliasCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alias',
                      prefixIcon: const Icon(Icons.person, color: naranja),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: naranja, width: 2),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingresa tu alias' : null,
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_verPass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock, color: naranja),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPass ? Icons.visibility_off : Icons.visibility,
                          color: naranja,
                        ),
                        onPressed: () => setState(() => _verPass = !_verPass),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: naranja, width: 2),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
                  ),
                  const SizedBox(height: 32),

                  // Botón acceder
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _login,
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
                              'ACCEDER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Crear cuenta
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistroPage()),
                    ),
                    child: const Text(
                      'crear cuenta',
                      style: TextStyle(color: naranja, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
