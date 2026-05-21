from django.contrib import admin
from .models import (
    Usuarios, Lugares, LugarImagen, TipoTurismo,
    Hobbies, HobbiesUsuario, Caracterizacion,
    HorariosPreferidos, Presupuestos,
    Favoritos, Comentarios,
    Rutas, RutaLugares, Eventos, Bitacora
)

admin.site.site_header = "Andariego — Panel de Administración"
admin.site.site_title = "Andariego Admin"
admin.site.index_title = "Bienvenido al panel de Andariego"

admin.site.register(Usuarios)
admin.site.register(Lugares)
admin.site.register(LugarImagen)
admin.site.register(TipoTurismo)
admin.site.register(Hobbies)
admin.site.register(HobbiesUsuario)
admin.site.register(Caracterizacion)
admin.site.register(HorariosPreferidos)
admin.site.register(Presupuestos)
admin.site.register(Favoritos)
admin.site.register(Comentarios)
admin.site.register(Rutas)
admin.site.register(RutaLugares)
admin.site.register(Eventos)
admin.site.register(Bitacora)