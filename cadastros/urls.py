# Arquivo: cadastros/urls.py

from django.urls import path
from . import views

urlpatterns = [
    # Rotas do App
    path('', views.lista_membros, name='lista_membros'),
    path('membro/<int:pk>/', views.detalhe_membro, name='detalhe_membro'),
    path('financeiro/caixa/', views.fluxo_de_caixa, name='fluxo_de_caixa'),
    path('financeiro/custos/', views.controle_de_custos, name='controle_de_custos'),
    path('patrimonio/', views.lista_patrimonio, name='lista_patrimonio'),
    path('atas/', views.lista_atas, name='lista_atas'),
    path('ata/<int:pk>/', views.detalhe_ata, name='detalhe_ata'),
    path('autorizacoes/', views.lista_autorizacoes, name='lista_autorizacoes'),
    path('relatorios/', views.pagina_relatorios, name='pagina_relatorios'),
    path('membro/novo/', views.membro_create, name='membro_create'),
    path('membro/<int:pk>/editar/', views.membro_update, name='membro_update'),
    

    # Rotas de Geração de PDF
    path('relatorios/membros/pdf/', views.gerar_pdf_membros, name='gerar_pdf_membros'),
    path('membro/<int:pk>/historico/pdf/', views.gerar_pdf_historico_membro, name='gerar_pdf_historico_membro'),
    path('relatorios/unidades/pdf/', views.gerar_pdf_unidades, name='gerar_pdf_unidades'),
    path('patrimonio/pdf/', views.gerar_pdf_patrimonio, name='gerar_pdf_patrimonio'),
    path('financeiro/caixa/pdf/', views.gerar_pdf_caixa, name='gerar_pdf_caixa'),
    path('atas/pdf/', views.gerar_pdf_atas, name='gerar_pdf_atas'),
    path('relatorios/classes/pdf/', views.gerar_pdf_classes, name='gerar_pdf_classes'),
    path('relatorios/especialidades/pdf/', views.gerar_pdf_especialidades, name='gerar_pdf_especialidades'),
    path('financeiro/mensalidades/pdf/', views.gerar_pdf_mensalidades, name='gerar_pdf_mensalidades'),
    path('autorizacoes/pdf/', views.gerar_pdf_autorizacoes, name='gerar_pdf_autorizacoes'),
]