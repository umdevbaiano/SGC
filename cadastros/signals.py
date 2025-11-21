from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import PagamentoMensalidade, Transacao

@receiver(post_save, sender=PagamentoMensalidade)
def criar_transacao_para_mensalidade(sender, instance, created, **kwargs):
    if created:
        Transacao.objects.create(
            descricao=f"Mensalidade: {instance.desbravador.nome_completo} - {instance.get_mes_display()}/{instance.ano}",
            tipo='E',
            valor=instance.valor_pago,
            data=instance.data_pagamento
        )