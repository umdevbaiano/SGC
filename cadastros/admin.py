from django.contrib import admin
from .models import (
    Unidade, Especialidade, Classe, Membro, PagamentoMensalidade, 
    Transacao, Patrimonio, Ata, AutorizacaoSaida, FichaMedica,
    MembroClasseConquistada, MembroEspecialidadeConquistada
)
from .forms import MembroForm 

class FichaMedicaInline(admin.StackedInline):
    model = FichaMedica
    can_delete = False
    verbose_name_plural = 'Ficha Médica'

class AutorizacaoSaidaInline(admin.TabularInline):
    model = AutorizacaoSaida
    extra = 1

class MembroClasseConquistadaInline(admin.TabularInline):
    model = MembroClasseConquistada
    extra = 1
    autocomplete_fields = ['classe']

class MembroEspecialidadeConquistadaInline(admin.TabularInline):
    model = MembroEspecialidadeConquistada
    extra = 1
    autocomplete_fields = ['especialidade']

try:
    admin.site.unregister(Membro)
except admin.sites.NotRegistered:
    pass

@admin.register(Membro)
class MembroAdmin(admin.ModelAdmin):
    form = MembroForm
    list_display = ('nome_completo', 'cargo', 'unidade', 'ativo')
    search_fields = ('nome_completo',)
    list_filter = ('ativo', 'unidade', 'sexo', 'cargo')
    
    inlines = [
        FichaMedicaInline, 
        AutorizacaoSaidaInline,
        MembroClasseConquistadaInline,
        MembroEspecialidadeConquistadaInline
    ]

@admin.register(Unidade)
class UnidadeAdmin(admin.ModelAdmin):
    list_display = ('nome', 'sexo')
    search_fields = ('nome',)
    list_filter = ('sexo',)

@admin.register(Especialidade)
class EspecialidadeAdmin(admin.ModelAdmin):
    list_display = ('nome', 'area')
    search_fields = ('nome',)
    list_filter = ('area',)

@admin.register(Classe)
class ClasseAdmin(admin.ModelAdmin):
    list_display = ('nome', 'nivel',)
    search_fields = ('nome',)
    list_filter = ('nivel',)