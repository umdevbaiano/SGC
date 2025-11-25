Com certeza\! Um README bem feito é o "cartão de visitas" do seu projeto. Como você quer algo que misture o profissionalismo de um portfólio técnico com a sua personalidade e a jornada que tivemos, preparei um texto que conta a **história** da evolução do projeto (do monólito para a arquitetura distribuída).

Aqui está uma proposta. Você pode copiar, colar no seu `README.md` e ajustar os links/imagens.

-----

# ⚜️ SGC Pro - Sistema de Gerenciamento de Clube (V2)

> **"Não basta funcionar, tem que ser bonito, intuitivo e escalável."**

Seja bem-vindo ao repositório do **SGC Pro**. Este projeto é a evolução de um sistema de gestão para Clubes de Desbravadores. Surgiu de uma mera necessidade como requisito da especialidade de Informática Programável e transformou-se em uma solução moderna e distribuída, separando um Backend robusto (API Rest) de um Frontend fluido e nativo (Flutter).

-----

## 🚀 A Jornada Técnica

Este projeto não é apenas sobre gerenciar membros e finanças; é um laboratório prático de Engenharia de Software. Decidi migrar a arquitetura para **microsserviços** para garantir que o sistema possa rodar na Web, Desktop e Mobile com uma única base de código visual.

### O "Cérebro" (Backend) 🧠

Construído em **Django + Django REST Framework (DRF)**.

  - **Arquitetura:** Modular (Apps separados para Core, Financeiro, Secretaria).
  - **Segurança:** Autenticação via Token e controle de acesso (CORS).
  - **Documentação:** API totalmente documentada via **Swagger/OpenAPI**.
  - **Banco de Dados:** SQLite (Dev) preparado para PostgreSQL (Prod).

### A "Cara" (Frontend) 📱

Construído em **Flutter**.

  - **Design System:** Tema customizado seguindo a paleta oficial (Azul Marinho e Dourado).
  - **Arquitetura:** Padrão **Repository** (separação limpa entre UI e Dados).
  - **UX/UI:** Animações avançadas (Hero, Slide Transitions), feedback tátil e layouts responsivos.

-----

## ✨ Funcionalidades Implementadas (Até Agora)

### 🔐 Acesso e Segurança

  - [x] **Login Seguro:** Autenticação via API com persistência de Token (Shared Preferences).
  - [x] **Feedback Visual:** Tratamento de erros amigável (Snackbars de erro/sucesso).

### 📊 Dashboard Inteligente

  - [x] **Resumo em Tempo Real:** Cards com total de membros, saldo em caixa e estatísticas.
  - [x] **Animações:** Entrada fluida dos elementos (Fade + Slide).
  - [x] **Navegação:** Barra inferior (BottomNav) e navegação lateral customizada.

### 👥 Gestão de Membros

  - [x] **Listagem Infinita:** Visualização de todos os membros com busca em tempo real.
  - [x] **Avatares Inteligentes:** Geração automática de avatar com iniciais se não houver foto.
  - [x] **Cadastro Completo:** Formulário com seletores de data, dropdowns dinâmicos (buscando Unidades da API) e validação.
  - [x] **Perfil Detalhado:** Tela de detalhes com **Hero Animation**, abas de navegação (Geral, Saúde, Histórico) e layout limpo.

-----

## 🛠️ Próximos Passos (Roadmap)

O código não para\! Aqui está o que vem por aí:

  - [ ] **Módulo Financeiro:** Implementar telas de Fluxo de Caixa e Gráficos no Flutter.
  - [ ] **Módulo de Secretaria:** Gestão de Atas e Patrimônio via App.
  - [ ] **Ficha Médica:** Integrar a aba de saúde na tela de detalhes.
  - [ ] **Dockerização:** Criar containers para subir todo o ambiente com um comando.
  - [ ] **Deploy:** Colocar a API na nuvem e gerar o APK do Android.

-----

## 💻 Como Rodar o Projeto

Este é um **Monorepo**. Você precisará de dois terminais.

### 1\. Subindo a API (Backend)

```bash
cd backend
python -m venv venv
# Windows: venv\Scripts\activate | Linux/Mac: source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

> A API estará rodando em: `http://127.0.0.1:8000/api/`

### 2\. Subindo o App (Frontend)

Certifique-se de ter o [Flutter SDK](https://flutter.dev) instalado.

```bash
cd frontend
flutter pub get
flutter run
```

-----

## 🤝 Sobre o Desenvolvedor

Desenvolvido com muito café e código por **Samuel Miranda**.
O objetivo deste projeto é unir minha paixão pelo Clube de Desbravadores com minha carreira em desenvolvimento de software, criando algo útil, bonito e tecnicamente desafiador.

-----

*License: MIT*
