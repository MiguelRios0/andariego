from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    UsuariosViewSet, LugaresViewSet, LugarImagenViewSet,
    TipoTurismoViewSet, HobbiesViewSet, HobbiesUsuarioViewSet,
    CaracterizacionViewSet, HorariosPreferidosViewSet,
    PresupuestosViewSet, FavoritosViewSet, ComentariosViewSet,
    RutasViewSet, RutaLugaresViewSet, EventosViewSet, BitacoraViewSet
)

router = DefaultRouter()
router.register(r'usuarios',            UsuariosViewSet,            basename='usuarios')
router.register(r'lugares',             LugaresViewSet,             basename='lugares')
router.register(r'lugar-imagenes',      LugarImagenViewSet,         basename='lugar-imagenes')
router.register(r'tipo-turismo',        TipoTurismoViewSet,         basename='tipo-turismo')
router.register(r'hobbies',             HobbiesViewSet,             basename='hobbies')
router.register(r'hobbies-usuario',     HobbiesUsuarioViewSet,      basename='hobbies-usuario')
router.register(r'caracterizacion',     CaracterizacionViewSet,     basename='caracterizacion')
router.register(r'horarios-preferidos', HorariosPreferidosViewSet,  basename='horarios-preferidos')
router.register(r'presupuestos',        PresupuestosViewSet,        basename='presupuestos')
router.register(r'favoritos',           FavoritosViewSet,           basename='favoritos')
router.register(r'comentarios',         ComentariosViewSet,         basename='comentarios')
router.register(r'rutas',               RutasViewSet,               basename='rutas')
router.register(r'ruta-lugares',        RutaLugaresViewSet,         basename='ruta-lugares')
router.register(r'eventos',             EventosViewSet,             basename='eventos')
router.register(r'bitacora',            BitacoraViewSet,            basename='bitacora')

urlpatterns = [
    path('', include(router.urls)),
]