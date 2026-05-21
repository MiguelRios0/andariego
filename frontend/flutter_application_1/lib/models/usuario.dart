class Usuario {
  final int? idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String tipoIdentificacion;
  final String numeroIdentificacion;
  final String telefono;
  final String aliasUsuario;
  final String password;
  final int estadoCuenta;

  Usuario({
    this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    required this.telefono,
    required this.aliasUsuario,
    required this.password,
    this.estadoCuenta = 1,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      tipoIdentificacion: json['tipo_identificacion'],
      numeroIdentificacion: json['numero_identificacion'],
      telefono: json['telefono'],
      aliasUsuario: json['alias_usuario'],
      password: json['password'] ?? '',
      estadoCuenta: json['estado_cuenta'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'tipo_identificacion': tipoIdentificacion,
      'numero_identificacion': numeroIdentificacion,
      'telefono': telefono,
      'alias_usuario': aliasUsuario,
      'password': password,
      'estado_cuenta': estadoCuenta,
    };
  }
}
