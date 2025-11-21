# cadastros/views.py

from django.shortcuts import render, get_object_or_404, redirect
from django.db.models import Sum
from django.utils import timezone
from .models import (
    Membro, PagamentoMensalidade, Transacao, Patrimonio, Ata, Unidade,
    MembroClasseConquistada, MembroEspecialidadeConquistada
) 
import datetime
from decimal import Decimal
from .forms import CustoForm, MembroForm, RelatorioClassesForm, RelatorioEspecialidadesForm
from django.http import HttpResponse
from django.template.loader import render_to_string
from weasyprint import HTML
from django.contrib.auth.decorators import login_required, permission_required

@login_required
#@permission_required('cadastros.change_membro', raise_exception=True)
def membro_update(request, pk):
    # Busca o objeto existente que queremos editar
    membro = get_object_or_404(Membro, pk=pk)
    
    # Se o formulário está sendo enviado (via POST)
    if request.method == 'POST':
        # Passamos 'instance=membro' para que o formulário saiba que está editando
        form = MembroForm(request.POST, instance=membro)
        if form.is_valid():
            form.save()
            # Redireciona de volta para a página de detalhes
            return redirect('detalhe_membro', pk=membro.pk)
    # Se for o primeiro acesso (via GET)
    else:
        # Passamos 'instance=membro' para que o formulário já venha preenchido
        form = MembroForm(instance=membro)
    
    contexto = {
        'form': form,
        'form_title': f'Editando: {membro.nome_completo}' # Um título dinâmico
    }
    # REAPROVEITAMOS O MESMO TEMPLATE DE ADICIONAR!
    return render(request, 'cadastros/membro_form.html', contexto)

@login_required
#@permission_required('cadastros.add_membro', raise_exception=True)
def membro_create(request):
    # Se o formulário for enviado (método POST)
    if request.method == 'POST':
        print("--- DENTRO DO POST ---") # ESPİÃO 1
        form = MembroForm(request.POST)
        
        # Vamos verificar se o formulário é válido e imprimir o resultado
        if form.is_valid():
            print("--- FORMULÁRIO É VÁLIDO ---") # ESPİÃO 2
            novo_membro = form.save()
            print(f"--- MEMBRO '{novo_membro.nome_completo}' SALVO COM SUCESSO ---") # ESPİÃO 3
            return redirect('detalhe_membro', pk=novo_membro.pk)
        else:
            # Se o formulário NÃO for válido, vamos imprimir os erros no terminal
            print("--- FORMULÁRIO É INVÁLIDO ---") # ESPİÃO 4
            print("Erros do formulário:", form.errors.as_json()) # ESPİÃO 5
    # Se for um acesso normal (método GET)
    else:
        form = MembroForm()
    
    contexto = {
        'form': form,
        'form_title': 'Adicionar Novo Membro'
    }
    return render(request, 'cadastros/membro_form.html', contexto)

#-----PÁGINA DE LISTAGEM DE MEMBROS-----#
@login_required
def lista_membros(request):
    membros_ativos = Membro.objects.filter(ativo=True)
    total_membros = membros_ativos.count()
    transacoes = Transacao.objects.all()
    total_entradas = transacoes.filter(tipo='E').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    total_saidas = transacoes.filter(tipo='S').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    saldo_caixa = total_entradas - total_saidas
    membros_menores = [m for m in membros_ativos if m.idade < 18]
    autorizacoes_pendentes = sum(1 for m in membros_menores if not m.autorizacoes.exists())
    hoje = timezone.now().date()
    limite_aniversario = hoje + datetime.timedelta(days=30)
    aniversariantes = []
    for membro in membros_ativos:
        niver_este_ano = membro.data_nascimento.replace(year=hoje.year)
        if niver_este_ano < hoje:
            niver_este_ano = niver_este_ano.replace(year=hoje.year + 1)
        if hoje <= niver_este_ano <= limite_aniversario:
            aniversariantes.append(membro)
    aniversariantes.sort(key=lambda x: x.data_nascimento.replace(year=hoje.year))
    contexto = {
        'total_membros': total_membros,
        'saldo_caixa': saldo_caixa,
        'autorizacoes_pendentes': autorizacoes_pendentes,
        'aniversariantes': aniversariantes,
        'membros': membros_ativos.order_by('nome_completo'),
    }
    return render(request, 'cadastros/lista_membros.html', contexto)

#-----PÁGINA DE DETALHAMENTO DO MEMBRO-----#
@login_required
def detalhe_membro(request, pk):
    membro = get_object_or_404(Membro, pk=pk)
    ano_atual = datetime.date.today().year
    pagamentos_do_ano = PagamentoMensalidade.objects.filter(desbravador=membro, ano=ano_atual)
    meses_pagos = {p.mes for p in pagamentos_do_ano}
    meses_do_ano = []
    for mes_num in range(1, 13):
        meses_do_ano.append({
            'numero': mes_num,
            'nome': PagamentoMensalidade.MESES_CHOICES[mes_num-1][1],
            'pago': mes_num in meses_pagos
        })
    contexto = {
        'membro': membro,
        'status_mensalidades': meses_do_ano, 
        'ano_referencia': ano_atual,
    }
    return render(request, 'cadastros/detalhe_membro.html', contexto)

#-----PÁGINAS FINANCEIRAS-----#
@login_required
def fluxo_de_caixa(request):
    transacoes = Transacao.objects.all()
    total_entradas = transacoes.filter(tipo='E').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    total_saidas = transacoes.filter(tipo='S').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    saldo = total_entradas - total_saidas
    contexto = {
        'transacoes': transacoes,
        'total_entradas': total_entradas,
        'total_saidas': total_saidas,
        'saldo': saldo
    }
    return render(request, 'cadastros/fluxo_de_caixa.html', contexto)

@login_required
def controle_de_custos(request):
    if request.method == 'POST':
        form = CustoForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('controle_de_custos')
    else:
        form = CustoForm()
    custos = Transacao.objects.filter(tipo='S')
    contexto = {
        'form': form,
        'custos': custos
    }
    return render(request, 'cadastros/controle_de_custos.html', contexto)

#----PÁGINA DO PATRIMÔNIO-----#
@login_required
def lista_patrimonio(request):
    itens = Patrimonio.objects.all()
    contexto = {
        'itens_patrimonio': itens
    }
    return render(request, 'cadastros/lista_patrimonio.html', contexto)

#-----PÁGINA DE ATAS E ATOS-----#
@login_required
def lista_atas(request):
    atas = Ata.objects.all()
    contexto = {
        'atas': atas
    }
    return render(request, 'cadastros/lista_atas.html', contexto)

@login_required
def detalhe_ata(request, pk):
    ata = get_object_or_404(Ata, pk=pk)
    contexto = {
        'ata': ata
    }
    return render(request, 'cadastros/detalhe_ata.html', contexto)

#-----PÁGINA DE AUTORIZAÇÕES-----#
@login_required
def lista_autorizacoes(request):
    membros = Membro.objects.filter(ativo=True).order_by('nome_completo')
    contexto = {
        'membros': membros,
    }
    return render(request, 'cadastros/lista_autorizacoes.html', contexto)

#-----PÁGINA DE RELATÓRIOS-----#
@login_required
def pagina_relatorios(request):
    form_classes = RelatorioClassesForm()
    form_especialidades = RelatorioEspecialidadesForm()
    contexto = {
        'form_classes': form_classes,
        'form_especialidades': form_especialidades,
    }
    return render(request, 'cadastros/pagina_relatorios.html', contexto)

#-----GERAR RELATÓRIOS EM PDF-----#
@login_required
def gerar_pdf_membros(request):
    membros = Membro.objects.filter(ativo=True).order_by('nome_completo')
    data_hoje = datetime.date.today()
    contexto = {
        'membros': membros,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/membros_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_membros.pdf"'
    return response

@login_required
def gerar_pdf_patrimonio(request):
    itens = Patrimonio.objects.all()
    data_hoje = datetime.date.today()
    contexto = {
        'itens_patrimonio': itens,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/patrimonio_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_patrimonio.pdf"'
    return response

@login_required
def gerar_pdf_caixa(request):
    transacoes = Transacao.objects.all()
    total_entradas = transacoes.filter(tipo='E').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    total_saidas = transacoes.filter(tipo='S').aggregate(total=Sum('valor'))['total'] or Decimal('0.00')
    saldo = total_entradas - total_saidas
    data_hoje = datetime.date.today()
    contexto = {
        'transacoes': transacoes,
        'total_entradas': total_entradas,
        'total_saidas': total_saidas,
        'saldo': saldo,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/fluxo_de_caixa_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_fluxo_de_caixa.pdf"'
    return response

@login_required
def gerar_pdf_atas(request):
    atas = Ata.objects.all()
    data_hoje = datetime.date.today()
    contexto = {
        'atas': atas,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/lista_atas_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_atas_e_atos.pdf"'
    return response

@login_required
def gerar_pdf_mensalidades(request):
    ano_atual = datetime.date.today().year
    membros = Membro.objects.filter(ativo=True).order_by('nome_completo')
    pagamentos = PagamentoMensalidade.objects.filter(ano=ano_atual)
    pagamentos_por_membro = {}
    for pgto in pagamentos:
        if pgto.desbravador_id not in pagamentos_por_membro:
            pagamentos_por_membro[pgto.desbravador_id] = set()
        pagamentos_por_membro[pgto.desbravador_id].add(pgto.mes)
    relatorio_data = []
    for membro in membros:
        meses_pagos_do_membro = pagamentos_por_membro.get(membro.id, set())
        status_meses = []
        for mes_num in range(1, 13):
            status_meses.append(mes_num in meses_pagos_do_membro)
        relatorio_data.append({
            'nome': membro.nome_completo,
            'status_meses': status_meses
        })
    contexto = {
        'relatorio_data': relatorio_data,
        'meses_header': [mes[1] for mes in PagamentoMensalidade.MESES_CHOICES],
        'ano_referencia': ano_atual,
        'data_hoje': datetime.date.today()
    }
    html_string = render_to_string('cadastros/mensalidades_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_mensalidades.pdf"'
    return response

@login_required
def gerar_pdf_autorizacoes(request):
    membros = Membro.objects.filter(ativo=True).order_by('nome_completo')
    data_hoje = datetime.date.today()
    contexto = {
        'membros': membros,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/autorizacoes_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_autorizacoes.pdf"'
    return response

@login_required
def gerar_pdf_unidades(request):
    unidades = Unidade.objects.all().order_by('sexo', 'nome')
    data_hoje = datetime.date.today()
    contexto = {
        'unidades': unidades,
        'data_hoje': data_hoje
    }
    html_string = render_to_string('cadastros/unidades_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_unidades.pdf"'
    return response

@login_required
def gerar_pdf_classes(request):
    classes_selecionadas_ids = request.GET.getlist('classes')
    if not classes_selecionadas_ids:
        return HttpResponse("Nenhuma classe foi selecionada.", status=400)
    conquistas = MembroClasseConquistada.objects.filter(
        classe_id__in=classes_selecionadas_ids
    ).select_related('membro', 'classe').order_by('classe__nome', 'membro__nome_completo')
    relatorio_por_classe = {}
    for conquista in conquistas:
        nome_classe = conquista.classe.nome
        if nome_classe not in relatorio_por_classe:
            relatorio_por_classe[nome_classe] = []
        relatorio_por_classe[nome_classe].append({
            'membro': conquista.membro.nome_completo,
            'data': conquista.data_conclusao
        })
    contexto = {
        'relatorio_por_classe': relatorio_por_classe,
        'data_hoje': datetime.date.today()
    }
    html_string = render_to_string('cadastros/classes_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_por_classe.pdf"'
    return response

@login_required
def gerar_pdf_especialidades(request):
    especialidades_selecionadas_ids = request.GET.getlist('especialidades')
    if not especialidades_selecionadas_ids:
        return HttpResponse("Nenhuma especialidade foi selecionada.", status=400)
    conquistas = MembroEspecialidadeConquistada.objects.filter(
        especialidade_id__in=especialidades_selecionadas_ids
    ).select_related('membro', 'especialidade').order_by('especialidade__nome', 'membro__nome_completo')
    relatorio_por_especialidade = {}
    for conquista in conquistas:
        nome_especialidade = conquista.especialidade.nome
        if nome_especialidade not in relatorio_por_especialidade:
            relatorio_por_especialidade[nome_especialidade] = []
        relatorio_por_especialidade[nome_especialidade].append({
            'membro': conquista.membro.nome_completo,
            'data': conquista.data_conclusao
        })
    contexto = {
        'relatorio_por_especialidade': relatorio_por_especialidade,
        'data_hoje': datetime.date.today()
    }
    html_string = render_to_string('cadastros/especialidades_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="relatorio_especialidade.pdf"'
    return response

@login_required
def gerar_pdf_historico_membro(request, pk):
    membro = get_object_or_404(Membro, pk=pk)
    classes_concluidas = MembroClasseConquistada.objects.filter(membro=membro).order_by('data_conclusao')
    especialidades_concluidas = MembroEspecialidadeConquistada.objects.filter(membro=membro).order_by('data_conclusao')
    contexto = {
        'membro': membro,
        'classes_concluidas': classes_concluidas,
        'especialidades_concluidas': especialidades_concluidas,
        'data_hoje': datetime.date.today()
    }
    html_string = render_to_string('cadastros/historico_membro_pdf.html', contexto)
    pdf = HTML(string=html_string).write_pdf()
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="historico_{membro.nome_completo}.pdf"'
    return response