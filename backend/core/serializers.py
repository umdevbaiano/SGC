from rest_framework import serializers
from .models import (
    Unidade, Membro, Classe, Especialidade,
    PagamentoMensalidade, Transacao,
    Patrimonio, Ata, AutorizacaoSaida, FichaMedica
)

# --- BÁSICOS ---
class UnidadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Unidade
        fields = '__all__'

class ClasseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classe
        fields = '__all__'

class EspecialidadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Especialidade
        fields = '__all__'

# --- MEMBROS ---
class FichaMedicaSerializer(serializers.ModelSerializer):
    class Meta:
        model = FichaMedica
        fields = '__all__'

class MembroSerializer(serializers.ModelSerializer):
    unidade_nome = serializers.CharField(source='unidade.nome', read_only=True)
    cargo_display = serializers.CharField(source='get_cargo_display', read_only=True)
    idade = serializers.ReadOnlyField()

    class Meta:
        model = Membro
        fields = '__all__'

# --- FINANCEIRO ---
class TransacaoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transacao
        fields = '__all__'

class PagamentoMensalidadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PagamentoMensalidade
        fields = '__all__'

# --- SECRETARIA ---
class PatrimonioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patrimonio
        fields = '__all__'

class AtaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ata
        fields = '__all__'

class AutorizacaoSaidaSerializer(serializers.ModelSerializer):
    class Meta:
        model = AutorizacaoSaida
        fields = '__all__'