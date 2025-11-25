# backend/core/models.py

from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
import datetime
from decimal import Decimal

# --- MODELOS BÁSICOS ---

class Unidade(models.Model):
    SEXO_CHOICES = (
        ('M', 'Masculina'),
        ('F', 'Feminina'),
    )
    nome = models.CharField(max_length=100)
    sexo = models.CharField(max_length=1, choices=SEXO_CHOICES, verbose_name="Sexo da Unidade")
    grito_de_guerra = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.nome} ({self.get_sexo_display()})"

class Especialidade(models.Model):
    AREAS = (
        ('AM', 'Artes e Habilidades Manuais'),
        ('AA', 'Atividades Agrícolas'),
        ('AR', 'Atividades Recreativas'),
        ('AP', 'Atividades Profissionais'),
        ('CS', 'Ciência e Saúde'),
        ('EN', 'Estudos da Natureza'),
        ('HD', 'Habilidades Domésticas'),
        ('ME', 'Mestrados'),
    )
    nome = models.CharField(max_length=100)
    area = models.CharField(max_length=2, choices=AREAS)
    # Opcional: upload de requisitos (mantivemos comentado no anterior, pode descomentar se quiser usar)
    # requisitos = models.FileField(upload_to='especialidades/', blank=True, null=True)

    def __str__(self):
        return f"{self.nome} ({self.get_area_display()})"

class Classe(models.Model):
    NIVEIS = (
        ('regular', 'Regular'),
        ('avancada', 'Avançada'),
        ('lideranca', 'Liderança'),
    )
    nome = models.CharField(max_length=100)
    nivel = models.CharField(max_length=10, choices=NIVEIS)

    def __str__(self):
        return f"{self.nome} ({self.get_nivel_display()})"

# --- MODELO PRINCIPAL: MEMBRO ---

class Membro(models.Model):
    CARGO_CHOICES = [
        ('DIR', 'Diretor'), ('ASCM', 'Diretor Associado'), ('ASCF', 'Diretora Associada'),
        ('SEC', 'Secretário(a)'), ('TES', 'Tesoureiro(a)'), ('CONS', 'Conselheiro(a)'),
        ('CSAS', 'Conselheiro(a) Associado(a)'), ('CAPC', 'Capelão(a) do Clube'),
        ('CAPU', 'Capitão(a) de Unidade'), ('SECU', 'Secretário(a) de Unidade'),
        ('TESU', 'Tesoureiro(a) de Unidade'), ('CAPUN', 'Capelão(a) de Unidade'),
        ('DBV', 'Desbravador(a)'),
    ] 

    SEXO_CHOICES = (('M', 'Masculino'), ('F', 'Feminino'),)

    user = models.OneToOneField(User, on_delete=models.SET_NULL, null=True, blank=True, verbose_name="Usuário de Login")
    nome_completo = models.CharField(max_length=255)
    sexo = models.CharField(max_length=1, choices=SEXO_CHOICES)
    cargo = models.CharField(max_length=5, choices=CARGO_CHOICES)
    data_nascimento = models.DateField()
    
    # Contato
    nome_responsavel = models.CharField(max_length=255, blank=True)
    telefone_responsavel = models.CharField(max_length=15, blank=True)
    email_responsavel = models.EmailField(blank=True, null=True)

    # Clube
    unidade = models.ForeignKey(Unidade, on_delete=models.SET_NULL, null=True, blank=True)
    classe_atual = models.ForeignKey(Classe, on_delete=models.SET_NULL, null=True, blank=True, related_name='desbravadores_na_classe')
    
    # Relacionamentos M2M com tabela intermediária (para guardar data de conclusão)
    especialidades_conquistadas = models.ManyToManyField(
        Especialidade, 
        through='MembroEspecialidadeConquistada', 
        blank=True
    )
    classes_conquistadas = models.ManyToManyField(
        Classe, 
        through='MembroClasseConquistada', 
        blank=True, 
        related_name='concluintes'
    )
    
    data_cadastro = models.DateTimeField(default=timezone.now)
    ativo = models.BooleanField(default=True)

    def __str__(self):
        return self.nome_completo
    
    @property
    def idade(self):
        if not self.data_nascimento:
            return None
        hoje = datetime.date.today()
        nascimento = self.data_nascimento
        return hoje.year - nascimento.year - ((hoje.month, hoje.day) < (nascimento.month, nascimento.day))

    def clean(self):
        # Validações de Regra de Negócio (Backend Safety Net)
        super().clean()
        cargos_juvenis = ['CAPU', 'SECU', 'TESU', 'CAPUN', 'DBV']
        
        # Regra de Idade
        if self.idade is not None and self.idade > 16 and self.cargo in cargos_juvenis:
            raise ValidationError(f"Membros com mais de 16 anos não podem ter o cargo de '{self.get_cargo_display()}'.")
        
        # Regra de Unidade/Sexo (Só valida se tiver unidade e sexo preenchidos)
        if self.unidade and self.sexo:
            if self.unidade.sexo != self.sexo:
                raise ValidationError(
                    f"Conflito de Gênero: Membro '{self.get_sexo_display()}' não pode estar na unidade '{self.unidade.nome}' ({self.unidade.get_sexo_display()})."
                )

# --- TABELAS INTERMEDIÁRIAS (CONQUISTAS) ---

class MembroClasseConquistada(models.Model):
    membro = models.ForeignKey('Membro', on_delete=models.CASCADE)
    classe = models.ForeignKey(Classe, on_delete=models.CASCADE)
    data_conclusao = models.DateField(default=datetime.date.today)

    class Meta:
        verbose_name = "Classe Conquistada"
        verbose_name_plural = "Classes Conquistadas"
        unique_together = ('membro', 'classe')

    def __str__(self):
        return f"{self.classe.nome} - {self.membro.nome_completo}"

class MembroEspecialidadeConquistada(models.Model):
    membro = models.ForeignKey('Membro', on_delete=models.CASCADE)
    especialidade = models.ForeignKey(Especialidade, on_delete=models.CASCADE)
    data_conclusao = models.DateField(default=datetime.date.today)

    class Meta:
        verbose_name = "Especialidade Conquistada"
        verbose_name_plural = "Especialidades Conquistadas"
        unique_together = ('membro', 'especialidade')

    def __str__(self):
        return f"{self.especialidade.nome} - {self.membro.nome_completo}"

# --- MÓDULO FINANCEIRO ---

class PagamentoMensalidade(models.Model):
    MESES_CHOICES = (
        (1, 'Janeiro'), (2, 'Fevereiro'), (3, 'Março'), (4, 'Abril'),
        (5, 'Maio'), (6, 'Junho'), (7, 'Julho'), (8, 'Agosto'),
        (9, 'Setembro'), (10, 'Outubro'), (11, 'Novembro'), (12, 'Dezembro'),
    )
    desbravador = models.ForeignKey(Membro, on_delete=models.CASCADE, related_name='mensalidades')
    ano = models.IntegerField()
    mes = models.IntegerField(choices=MESES_CHOICES)
    data_pagamento = models.DateField()
    valor_pago = models.DecimalField(max_digits=8, decimal_places=2)

    class Meta:
        unique_together = ('desbravador','ano', 'mes')
        ordering = ['-ano', '-mes']
    
    def __str__(self):
        return f"Pagamento de {self.desbravador.nome_completo} - {self.get_mes_display()}/{self.ano}"

class Transacao(models.Model):
    TIPO_CHOICES = (('E', 'Entrada'), ('S', 'Saída'),)
    descricao = models.CharField(max_length=255)
    tipo = models.CharField(max_length=1, choices=TIPO_CHOICES)
    valor = models.DecimalField(max_digits=10, decimal_places=2)
    data = models.DateField(default=datetime.date.today)

    class Meta:
        ordering = ['-data']
        verbose_name_plural = "Transações"

    def __str__(self):
        return f"{self.data} - {self.descricao} ({self.get_tipo_display()}) - R$ {self.valor}"

# --- MÓDULO SECRETARIA / ADM ---

class Patrimonio(models.Model):
    item = models.CharField(max_length=255, verbose_name="Item")
    quantidade = models.PositiveIntegerField(default=1)
    valor_estimado = models.DecimalField(max_digits=10, decimal_places=2, help_text="Valor estimado por unidade")
    data_aquisicao = models.DateField(default=datetime.date.today)
    responsavel = models.ForeignKey(Membro, on_delete=models.SET_NULL, null=True, blank=True, help_text="Membro responsável (opcional)")

    class Meta:
        ordering = ['item']
        verbose_name = "Item do Patrimônio"
        verbose_name_plural = "Itens do Patrimônio"

    def __str__(self):
        return self.item

class Ata(models.Model):
    TIPO_CHOICES = (('ATA', 'Ata de Reunião'), ('ATO', 'Ato Administrativo'),)
    titulo = models.CharField(max_length=255)
    tipo = models.CharField(max_length=3, choices=TIPO_CHOICES)
    data = models.DateField(default=datetime.date.today)
    responsavel = models.CharField(max_length=255, verbose_name="Secretário(a) ou Responsável")
    conteudo = models.TextField(verbose_name="Conteúdo")

    class Meta:
        ordering = ['-data']
        verbose_name = "Ata ou Ato"
        verbose_name_plural = "Atas ou Atos"

    def __str__(self):
        return f"{self.get_tipo_display()} - {self.titulo}"

class AutorizacaoSaida(models.Model):
    desbravador = models.ForeignKey(Membro, on_delete=models.CASCADE, related_name='autorizacoes')
    evento = models.CharField(max_length=255, verbose_name="Evento ou Atividade")
    documento = models.FileField(upload_to='autorizacoes/', verbose_name="Documento Assinado")
    data_upload = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-evento']
        verbose_name = "Autorização de Saída"
        verbose_name_plural = "Autorizações de Saída"

    def __str__(self):
        return f"Autorização de {self.desbravador.nome_completo} para {self.evento}"

class FichaMedica(models.Model):
    TIPOS_SANGUINEOS = [
        ('A+', 'A+'), ('A-', 'A-'), ('B+', 'B+'), ('B-', 'B-'),
        ('AB+', 'AB+'), ('AB-', 'AB-'), ('O+', 'O+'), ('O-', 'O-'),
        ('NI', 'Não Informado'),
    ]
    desbravador = models.OneToOneField(Membro, on_delete=models.CASCADE, primary_key=True, related_name='fichamedica')
    tipo_sanguineo = models.CharField(max_length=3, choices=TIPOS_SANGUINEOS, default='NI', verbose_name="Tipo Sanguíneo")
    alergias = models.TextField(blank=True, help_text="Liste todas as alergias conhecidas")
    medicamentos_uso_continuo = models.TextField(blank=True, verbose_name="Medicamentos de Uso Contínuo")
    plano_de_saude = models.CharField(max_length=100, blank=True, verbose_name="Plano de Saúde")
    contato_emergencia_nome = models.CharField(max_length=255, verbose_name="Nome do Contato de Emergência")
    contato_emergencia_telefone = models.CharField(max_length=20, verbose_name="Telefone do Contato de Emergência")
    observacoes = models.TextField(blank=True, verbose_name="Observações Médicas Adicionais")

    def __str__(self):
        return f"Ficha Médica de {self.desbravador.nome_completo}"