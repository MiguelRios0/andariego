from django.db import models


class Bitacora(models.Model):
    id_bitacora = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_lugar = models.ForeignKey('Lugares', models.DO_NOTHING, db_column='id_lugar')
    fecha_visita = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'bitacora'


class Caracterizacion(models.Model):
    id_caracterizacion = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    avatar = models.CharField(max_length=255)
    tiempo_disponible = models.CharField(max_length=45)
    sexo = models.CharField(max_length=45)
    id_tipo_turismo = models.ForeignKey('TipoTurismo', models.DO_NOTHING, db_column='id_tipo_turismo')
    id_horarios_preferidos = models.ForeignKey('HorariosPreferidos', models.DO_NOTHING, db_column='id_horarios_preferidos')
    id_presupuesto = models.ForeignKey('Presupuestos', models.DO_NOTHING, db_column='id_presupuesto')

    class Meta:
        managed = False
        db_table = 'caracterizacion'


class Comentarios(models.Model):
    id_comentarios = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_lugar = models.ForeignKey('Lugares', models.DO_NOTHING, db_column='id_lugar')
    comentarios = models.TextField()
    fecha_comentario = models.DateTimeField()
    puntuacion = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'comentarios'


class Eventos(models.Model):
    id_eventos = models.AutoField(primary_key=True)
    nombre_evento = models.CharField(max_length=100)
    descripcion = models.TextField()
    fecha_evento = models.DateTimeField()
    categoria = models.CharField(max_length=45)
    id_lugar = models.ForeignKey('Lugares', models.DO_NOTHING, db_column='id_lugar')

    class Meta:
        managed = False
        db_table = 'eventos'


class Favoritos(models.Model):
    id_favoritos = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_lugar = models.ForeignKey('Lugares', models.DO_NOTHING, db_column='id_lugar')
    fecha_agregado = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'favoritos'
        unique_together = (('id_usuario', 'id_lugar'),)


class Hobbies(models.Model):
    id_hobbies = models.IntegerField(primary_key=True)
    nombre_hobbie = models.CharField(max_length=50)

    class Meta:
        managed = False
        db_table = 'hobbies'


class HobbiesUsuario(models.Model):
    id_hobbies_usuario = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_hobbie = models.ForeignKey(Hobbies, models.DO_NOTHING, db_column='id_hobbie')

    class Meta:
        managed = False
        db_table = 'hobbies_usuario'


class HorariosPreferidos(models.Model):
    id_horarios_preferidos = models.AutoField(primary_key=True)
    nombre = models.CharField(unique=True, max_length=50)

    class Meta:
        managed = False
        db_table = 'horarios_preferidos'


class LugarImagen(models.Model):
    id_lugar_imagen = models.AutoField(primary_key=True)
    id_lugar = models.ForeignKey('Lugares', models.DO_NOTHING, db_column='id_lugar')
    url_imagen = models.CharField(max_length=255)
    descripcion = models.CharField(max_length=100, blank=True, null=True)
    principal = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'lugar_imagen'


class Lugares(models.Model):
    id_lugar = models.AutoField(primary_key=True)
    nombre_lugar = models.CharField(max_length=45)
    categoria = models.CharField(max_length=45)
    descripcion = models.TextField()
    latitud = models.DecimalField(max_digits=10, decimal_places=8)
    longitud = models.DecimalField(max_digits=11, decimal_places=8)
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    horario = models.CharField(max_length=100, blank=True, null=True)
    costo = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    contacto = models.CharField(max_length=20, blank=True, null=True)
    sitio_web = models.CharField(max_length=255, blank=True, null=True)
    seguridad = models.IntegerField()
    tiempo_aproximado = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lugares'


class Presupuestos(models.Model):
    id_presupuesto = models.AutoField(primary_key=True)
    nombre = models.CharField(unique=True, max_length=50)
    valor_minimo = models.DecimalField(max_digits=10, decimal_places=2)
    valor_maximo = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        managed = False
        db_table = 'presupuestos'


class RutaLugares(models.Model):
    id_ruta_lugares = models.AutoField(primary_key=True)
    id_rutas = models.ForeignKey('Rutas', models.DO_NOTHING, db_column='id_rutas')
    id_lugar = models.ForeignKey(Lugares, models.DO_NOTHING, db_column='id_lugar')
    orden_secuencial = models.IntegerField()
    tiempo_estimado = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'ruta_lugares'


class Rutas(models.Model):
    id_rutas = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    nombre_ruta = models.CharField(max_length=100)
    fecha_creacion = models.DateTimeField()
    tipo = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'rutas'


class TipoTurismo(models.Model):
    id_tipo_turismo = models.AutoField(primary_key=True)
    nombre = models.CharField(unique=True, max_length=50)

    class Meta:
        managed = False
        db_table = 'tipo_turismo'


class Usuarios(models.Model):
    id_usuario = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=45)
    apellido = models.CharField(max_length=45)
    correo = models.CharField(unique=True, max_length=60)
    tipo_identificacion = models.CharField(max_length=10)
    numero_identificacion = models.CharField(unique=True, max_length=12)
    telefono = models.CharField(max_length=10)
    alias_usuario = models.CharField(unique=True, max_length=45)
    password = models.CharField(max_length=225)
    fecha_registro = models.DateTimeField()
    estado_cuenta = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'usuarios'