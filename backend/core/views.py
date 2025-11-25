from rest_framework import viewsets
from .models import (
    Unidade, Membro, Classe, Especialidade,
    PagamentoMensalidade, Transacao,
    Patrimonio, Ata, AutorizacaoSaida, FichaMedica
)
from .serializers import (
    UnidadeSerializer, MembroSerializer, ClasseSerializer, EspecialidadeSerializer,
    PagamentoMensalidadeSerializer, TransacaoSerializer,
    PatrimonioSerializer, AtaSerializer, AutorizacaoSaidaSerializer, FichaMedicaSerializer
)

class UnidadeViewSet(viewsets.ModelViewSet):
    queryset = Unidade.objects.all()
    serializer_class = UnidadeSerializer

class MembroViewSet(viewsets.ModelViewSet):
    queryset = Membro.objects.all().order_by('nome_completo')
    serializer_class = MembroSerializer
    filterset_fields = ['unidade', 'ativo'] # Permite filtrar na URL (ex: ?ativo=true)

class FichaMedicaViewSet(viewsets.ModelViewSet):
    queryset = FichaMedica.objects.all()
    serializer_class = FichaMedicaSerializer

class ClasseViewSet(viewsets.ModelViewSet):
    queryset = Classe.objects.all()
    serializer_class = ClasseSerializer

class EspecialidadeViewSet(viewsets.ModelViewSet):
    queryset = Especialidade.objects.all()
    serializer_class = EspecialidadeSerializer

class TransacaoViewSet(viewsets.ModelViewSet):
    queryset = Transacao.objects.all().order_by('-data')
    serializer_class = TransacaoSerializer

class PagamentoMensalidadeViewSet(viewsets.ModelViewSet):
    queryset = PagamentoMensalidade.objects.all().order_by('-data_pagamento')
    serializer_class = PagamentoMensalidadeSerializer

class PatrimonioViewSet(viewsets.ModelViewSet):
    queryset = Patrimonio.objects.all()
    serializer_class = PatrimonioSerializer

class AtaViewSet(viewsets.ModelViewSet):
    queryset = Ata.objects.all().order_by('-data')
    serializer_class = AtaSerializer

class AutorizacaoSaidaViewSet(viewsets.ModelViewSet):
    queryset = AutorizacaoSaida.objects.all()
    serializer_class = AutorizacaoSaidaSerializer