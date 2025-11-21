from django import forms
from .models import Transacao, Membro, Classe, Especialidade
from django.core.exceptions import ValidationError

class CustoForm(forms.ModelForm):
    class Meta:
        model = Transacao
        fields = ['descricao', 'valor', 'data']
        widgets = {
            'descricao': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Ex: Compra de barracas'}),
            'valor': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Ex: 50.00'}),
            'data': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
        }

    def save(self, commit=True):
        instance = super().save(commit=False)
        instance.tipo = 'S'
        if commit:
            instance.save()
        return instance
    
class MembroForm(forms.ModelForm):
    class Meta:
        model = Membro
        # Em vez de '__all__', listamos apenas os campos que o usuário deve preencher
        fields = [
            'nome_completo', 'sexo', 'cargo', 'data_nascimento', 
            'nome_responsavel', 'telefone_responsavel', 'email_responsavel',
            'unidade', 'classe_atual', 'user', 'ativo'
        ]

    def clean(self):
        # ... (o método clean que já fizemos continua exatamente igual)
        cleaned_data = super().clean()
        
        unidade = cleaned_data.get("unidade")
        sexo_membro = cleaned_data.get("sexo")

        if unidade and sexo_membro:
            if unidade.sexo != sexo_membro:
                raise ValidationError(
                    f"Conflito de Gênero: Um membro do sexo '{Membro.SEXO_CHOICES[1 if sexo_membro == 'F' else 0][1]}' "
                    f"não pode ser associado a uma unidade '{unidade.get_sexo_display()}'."
                )
        
        return cleaned_data
    
class RelatorioClassesForm(forms.Form):
    classes = forms.ModelMultipleChoiceField(
        queryset=Classe.objects.all().order_by('nome'),
        widget=forms.CheckboxSelectMultiple,
        required=True,
        label="Selecione uma ou mais classes para o relatório"
    )

class RelatorioEspecialidadesForm(forms.Form):
    especialidades = forms.ModelMultipleChoiceField(
        queryset=Especialidade.objects.all().order_by('nome'),
        widget=forms.CheckboxSelectMultiple,
        required='True',
        label="Selecione uma ou mais especialidades para o relatório"
    )