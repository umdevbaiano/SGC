from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from core import views
from rest_framework.authtoken.views import obtain_auth_token

# Criando o Roteador da API
router = DefaultRouter()

# Cadastros Principais
router.register(r'unidades', views.UnidadeViewSet)
router.register(r'membros', views.MembroViewSet)
router.register(r'fichas-medicas', views.FichaMedicaViewSet)
router.register(r'classes', views.ClasseViewSet)
router.register(r'especialidades', views.EspecialidadeViewSet)

# Financeiro
router.register(r'transacoes', views.TransacaoViewSet)
router.register(r'mensalidades', views.PagamentoMensalidadeViewSet)

# Secretaria
router.register(r'patrimonio', views.PatrimonioViewSet)
router.register(r'atas', views.AtaViewSet)
router.register(r'autorizacoes', views.AutorizacaoSaidaViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),

    path('api/login/', obtain_auth_token, name='api_token_auth'),

    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

]

# Servir arquivos de mídia (fotos, pdfs) no desenvolvimento
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)