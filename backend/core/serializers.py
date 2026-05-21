from rest_framework import serializers
from .models import (
    Usuarios, Lugares, LugarImagen, TipoTurismo,
    Hobbies, HobbiesUsuario, Caracterizacion,
    HorariosPreferidos, Presupuestos,
    Favoritos, Comentarios,
    Rutas, RutaLugares, Eventos, Bitacora
)


class TipoTurismoSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoTurismo
        fields = '__all__'


class HobbiesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hobbies
        fields = '__all__'


class HorariosPreferidosSerializer(serializers.ModelSerializer):
    class Meta:
        model = HorariosPreferidos
        fields = '__all__'


class PresupuestosSerializer(serializers.ModelSerializer):
    class Meta:
        model = Presupuestos
        fields = '__all__'


class UsuariosSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuarios
        fields = '__all__'
        extra_kwargs = {
            'password': {'write_only': True}
        }


class LugarImagenSerializer(serializers.ModelSerializer):
    class Meta:
        model = LugarImagen
        fields = '__all__'


class LugaresSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lugares
        fields = '__all__'


class HobbiesUsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = HobbiesUsuario
        fields = '__all__'


class CaracterizacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Caracterizacion
        fields = '__all__'


class FavoritosSerializer(serializers.ModelSerializer):
    class Meta:
        model = Favoritos
        fields = '__all__'


class ComentariosSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comentarios
        fields = '__all__'


class RutasSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rutas
        fields = '__all__'


class RutaLugaresSerializer(serializers.ModelSerializer):
    class Meta:
        model = RutaLugares
        fields = '__all__'


class EventosSerializer(serializers.ModelSerializer):
    class Meta:
        model = Eventos
        fields = '__all__'


class BitacoraSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bitacora
        fields = '__all__'