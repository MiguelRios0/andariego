from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.contrib.auth.hashers import make_password, check_password

from .models import (
    Usuarios, Lugares, LugarImagen, TipoTurismo,
    Hobbies, HobbiesUsuario, Caracterizacion,
    HorariosPreferidos, Presupuestos,
    Favoritos, Comentarios,
    Rutas, RutaLugares, Eventos, Bitacora
)
from .serializers import (
    UsuariosSerializer, LugaresSerializer, LugarImagenSerializer,
    TipoTurismoSerializer, HobbiesSerializer, HobbiesUsuarioSerializer,
    CaracterizacionSerializer, HorariosPreferidosSerializer,
    PresupuestosSerializer, FavoritosSerializer, ComentariosSerializer,
    RutasSerializer, RutaLugaresSerializer, EventosSerializer,
    BitacoraSerializer
)


class UsuariosViewSet(viewsets.ModelViewSet):
    queryset = Usuarios.objects.all()
    serializer_class = UsuariosSerializer

    @action(detail=False, methods=['post'], url_path='registro')
    def registro(self, request):
        data = request.data.copy()
        if 'password' in data and data['password']:
            data['password'] = make_password(data['password'])
        data['fecha_registro'] = timezone.now()
        data['estado_cuenta'] = 1
        serializer = UsuariosSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {'mensaje': 'Usuario registrado correctamente'},
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], url_path='login')
    def login(self, request):
        alias = request.data.get('alias_usuario', '').strip()
        password_raw = request.data.get('password', '')
        if not alias or not password_raw:
            return Response(
                {'error': 'Debes ingresar alias y contraseña'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            usuario = Usuarios.objects.get(alias_usuario=alias, estado_cuenta=1)
        except Usuarios.DoesNotExist:
            return Response(
                {'error': 'Usuario no encontrado o cuenta inactiva'},
                status=status.HTTP_404_NOT_FOUND
            )
        if check_password(password_raw, usuario.password):
            serializer = UsuariosSerializer(usuario)
            return Response({'mensaje': 'Login exitoso', 'usuario': serializer.data})
        return Response(
            {'error': 'Contraseña incorrecta'},
            status=status.HTTP_400_BAD_REQUEST
        )

    @action(detail=True, methods=['post'], url_path='inactivar')
    def inactivar(self, request, pk=None):
        try:
            usuario = Usuarios.objects.get(pk=pk)
            usuario.estado_cuenta = 0
            usuario.save()
            return Response({'mensaje': 'Cuenta inactivada correctamente'})
        except Usuarios.DoesNotExist:
            return Response(
                {'error': 'Usuario no encontrado'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=True, methods=['patch'], url_path='editar')
    def editar(self, request, pk=None):
        try:
            usuario = Usuarios.objects.get(pk=pk)
        except Usuarios.DoesNotExist:
            return Response(
                {'error': 'Usuario no encontrado'},
                status=status.HTTP_404_NOT_FOUND
            )
        data = request.data.copy()
        data.pop('numero_identificacion', None)
        data.pop('id_usuario', None)
        data.pop('password', None)
        serializer = UsuariosSerializer(usuario, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'mensaje': 'Usuario actualizado', 'usuario': serializer.data})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LugaresViewSet(viewsets.ModelViewSet):
    queryset = Lugares.objects.all()
    serializer_class = LugaresSerializer

    @action(detail=False, methods=['get'], url_path='por_categoria')
    def por_categoria(self, request):
        categoria = request.query_params.get('categoria', None)
        if categoria:
            lugares = Lugares.objects.filter(categoria__icontains=categoria)
        else:
            lugares = Lugares.objects.all()
        serializer = LugaresSerializer(lugares, many=True)
        return Response(serializer.data)


class LugarImagenViewSet(viewsets.ModelViewSet):
    queryset = LugarImagen.objects.all()
    serializer_class = LugarImagenSerializer


class TipoTurismoViewSet(viewsets.ModelViewSet):
    queryset = TipoTurismo.objects.all()
    serializer_class = TipoTurismoSerializer


class HobbiesViewSet(viewsets.ModelViewSet):
    queryset = Hobbies.objects.all()
    serializer_class = HobbiesSerializer


class HobbiesUsuarioViewSet(viewsets.ModelViewSet):
    queryset = HobbiesUsuario.objects.all()
    serializer_class = HobbiesUsuarioSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        id_usuario = self.request.query_params.get('id_usuario')
        if id_usuario:
            qs = qs.filter(id_usuario=id_usuario)
        return qs

    @action(detail=False, methods=['get'], url_path='con_nombre')
    def con_nombre(self, request):
        id_usuario = request.query_params.get('id_usuario')
        if not id_usuario:
            return Response([], status=200)
        hobbies = HobbiesUsuario.objects.filter(
            id_usuario=id_usuario
        ).select_related('id_hobbie')
        data = [
            {
                'id_hobbie': h.id_hobbie.id_hobbies,
                'nombre_hobbie': h.id_hobbie.nombre_hobbie,
            }
            for h in hobbies
        ]
        return Response(data)

    @action(detail=False, methods=['delete'], url_path='eliminar')
    def eliminar(self, request):
        id_usuario = request.query_params.get('id_usuario')
        id_hobbie  = request.query_params.get('id_hobbie')
        HobbiesUsuario.objects.filter(
            id_usuario=id_usuario, id_hobbie=id_hobbie
        ).delete()
        return Response({'mensaje': 'Hobbie eliminado'})


class CaracterizacionViewSet(viewsets.ModelViewSet):
    queryset = Caracterizacion.objects.all()
    serializer_class = CaracterizacionSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        id_usuario = self.request.query_params.get('id_usuario')
        if id_usuario:
            qs = qs.filter(id_usuario=id_usuario)
        return qs

    @action(detail=False, methods=['post'], url_path='guardar')
    def guardar(self, request):
        id_usuario = request.data.get('id_usuario')

        # filter().first() evita MultipleObjectsReturned si hay duplicados en BD
        carac = Caracterizacion.objects.filter(id_usuario=id_usuario).first()

        if carac:
            # Si existe, eliminar duplicados y actualizar el primero
            Caracterizacion.objects.filter(
                id_usuario=id_usuario
            ).exclude(pk=carac.pk).delete()
            serializer = CaracterizacionSerializer(
                carac, data=request.data, partial=True
            )
        else:
            serializer = CaracterizacionSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class HorariosPreferidosViewSet(viewsets.ModelViewSet):
    queryset = HorariosPreferidos.objects.all()
    serializer_class = HorariosPreferidosSerializer


class PresupuestosViewSet(viewsets.ModelViewSet):
    queryset = Presupuestos.objects.all()
    serializer_class = PresupuestosSerializer


# ── FAVORITOS ────────────────────────────────────────────────
class FavoritosViewSet(viewsets.ModelViewSet):
    queryset = Favoritos.objects.all()
    serializer_class = FavoritosSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        id_usuario = self.request.query_params.get('id_usuario')
        if id_usuario:
            qs = qs.filter(id_usuario=id_usuario)
        return qs

    @action(detail=False, methods=['post'], url_path='agregar')
    def agregar(self, request):
        id_usuario = request.data.get('id_usuario')
        id_lugar   = request.data.get('id_lugar')
        existe = Favoritos.objects.filter(
            id_usuario=id_usuario, id_lugar=id_lugar
        ).first()
        if existe:
            return Response({'mensaje': 'Ya está en favoritos'}, status=200)
        data = {
            'id_usuario': id_usuario,
            'id_lugar': id_lugar,
            'fecha_agregado': timezone.now(),
        }
        serializer = FavoritosSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['delete'], url_path='eliminar')
    def eliminar(self, request):
        id_usuario = request.query_params.get('id_usuario')
        id_lugar   = request.query_params.get('id_lugar')
        Favoritos.objects.filter(
            id_usuario=id_usuario, id_lugar=id_lugar
        ).delete()
        return Response({'mensaje': 'Eliminado de favoritos'})

    @action(detail=False, methods=['get'], url_path='con_lugar')
    def con_lugar(self, request):
        id_usuario = request.query_params.get('id_usuario')
        if not id_usuario:
            return Response([])
        favs = Favoritos.objects.filter(
            id_usuario=id_usuario
        ).select_related('id_lugar')
        data = []
        for f in favs:
            l = f.id_lugar
            data.append({
                'id_favoritos': f.id_favoritos,
                'id_lugar': l.id_lugar,
                'nombre_lugar': l.nombre_lugar,
                'categoria': l.categoria,
                'descripcion': l.descripcion,
                'imagen_url': l.imagen_url,
                'horario': l.horario,
                'costo': str(l.costo) if l.costo else None,
            })
        return Response(data)


# ── COMENTARIOS ──────────────────────────────────────────────
class ComentariosViewSet(viewsets.ModelViewSet):
    queryset = Comentarios.objects.all()
    serializer_class = ComentariosSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        id_lugar   = self.request.query_params.get('id_lugar')
        id_usuario = self.request.query_params.get('id_usuario')
        if id_lugar:
            qs = qs.filter(id_lugar=id_lugar)
        if id_usuario:
            qs = qs.filter(id_usuario=id_usuario)
        return qs

    @action(detail=False, methods=['post'], url_path='agregar')
    def agregar(self, request):
        data = request.data.copy()
        data['fecha_comentario'] = timezone.now()
        serializer = ComentariosSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='de_lugar')
    def de_lugar(self, request):
        id_lugar = request.query_params.get('id_lugar')
        if not id_lugar:
            return Response([])
        comentarios = Comentarios.objects.filter(
            id_lugar=id_lugar
        ).select_related('id_usuario').order_by('-fecha_comentario')
        data = [
            {
                'id_comentarios': c.id_comentarios,
                'alias_usuario': c.id_usuario.alias_usuario,
                'comentario': c.comentarios,
                'puntuacion': c.puntuacion,
                'fecha': c.fecha_comentario.strftime('%d/%m/%Y %H:%M'),
            }
            for c in comentarios
        ]
        return Response(data)


# ── RUTAS ────────────────────────────────────────────────────
class RutasViewSet(viewsets.ModelViewSet):
    queryset = Rutas.objects.all()
    serializer_class = RutasSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        id_usuario = self.request.query_params.get('id_usuario')
        if id_usuario:
            qs = qs.filter(id_usuario=id_usuario)
        return qs

    @action(detail=False, methods=['get'], url_path='mi_ruta')
    def mi_ruta(self, request):
        id_usuario = request.query_params.get('id_usuario')
        if not id_usuario:
            return Response({'error': 'id_usuario requerido'}, status=400)
        ruta, _ = Rutas.objects.get_or_create(
            id_usuario_id=id_usuario,
            tipo='personal',
            defaults={
                'nombre_ruta': 'Mi Ruta',
                'fecha_creacion': timezone.now(),
            }
        )
        lugares = RutaLugares.objects.filter(
            id_rutas=ruta
        ).select_related('id_lugar').order_by('orden_secuencial')
        data = {
            'id_rutas': ruta.id_rutas,
            'lugares': [
                {
                    'id_ruta_lugares': rl.id_ruta_lugares,
                    'id_lugar': rl.id_lugar.id_lugar,
                    'nombre_lugar': rl.id_lugar.nombre_lugar,
                    'categoria': rl.id_lugar.categoria,
                    'descripcion': rl.id_lugar.descripcion,
                    'imagen_url': rl.id_lugar.imagen_url,
                    'horario': rl.id_lugar.horario,
                    'costo': str(rl.id_lugar.costo) if rl.id_lugar.costo else None,
                    'latitud': str(rl.id_lugar.latitud),
                    'longitud': str(rl.id_lugar.longitud),
                    'orden': rl.orden_secuencial,
                }
                for rl in lugares
            ]
        }
        return Response(data)

    @action(detail=False, methods=['post'], url_path='agregar_lugar')
    def agregar_lugar(self, request):
        id_usuario = request.data.get('id_usuario')
        id_lugar   = request.data.get('id_lugar')
        ruta, _ = Rutas.objects.get_or_create(
            id_usuario_id=id_usuario,
            tipo='personal',
            defaults={
                'nombre_ruta': 'Mi Ruta',
                'fecha_creacion': timezone.now(),
            }
        )
        if RutaLugares.objects.filter(id_rutas=ruta, id_lugar_id=id_lugar).exists():
            return Response({'mensaje': 'Ya está en la ruta'}, status=200)
        orden = RutaLugares.objects.filter(id_rutas=ruta).count() + 1
        rl = RutaLugares.objects.create(
            id_rutas=ruta,
            id_lugar_id=id_lugar,
            orden_secuencial=orden,
            tiempo_estimado=0,
        )
        return Response(
            {'mensaje': 'Lugar agregado a la ruta', 'id_ruta_lugares': rl.id_ruta_lugares},
            status=status.HTTP_201_CREATED
        )

    @action(detail=False, methods=['delete'], url_path='eliminar_lugar')
    def eliminar_lugar(self, request):
        id_usuario = request.query_params.get('id_usuario')
        id_lugar   = request.query_params.get('id_lugar')
        try:
            ruta = Rutas.objects.get(id_usuario_id=id_usuario, tipo='personal')
            RutaLugares.objects.filter(id_rutas=ruta, id_lugar_id=id_lugar).delete()
            return Response({'mensaje': 'Lugar eliminado de la ruta'})
        except Rutas.DoesNotExist:
            return Response({'error': 'Ruta no encontrada'}, status=404)


class RutaLugaresViewSet(viewsets.ModelViewSet):
    queryset = RutaLugares.objects.all()
    serializer_class = RutaLugaresSerializer


class EventosViewSet(viewsets.ModelViewSet):
    queryset = Eventos.objects.all()
    serializer_class = EventosSerializer


class BitacoraViewSet(viewsets.ModelViewSet):
    queryset = Bitacora.objects.all()
    serializer_class = BitacoraSerializer