from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from core import views

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
    # A raiz da API será em /api/
    path('api/', include(router.urls)),
]

# Servir arquivos de mídia (fotos, pdfs) no desenvolvimento
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)