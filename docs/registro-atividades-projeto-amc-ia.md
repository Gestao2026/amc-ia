# Registro de Atividades. Projeto AMC IA

> Documento de referência interna. Reconstrói, a partir do histórico do git, tudo o que foi feito no projeto AMC IA desde o início, para consulta futura caso seja preciso entender de onde veio uma decisão, uma automação ou um arquivo. Para o detalhe minuto a minuto de uma sessão específica, veja os registros de sessão (ex: `registro-atividades-2026-07-28.md`, sobre a apostila de comandos).

---

## Visão geral

O AMC IA é um assistente de captação de recursos para o terceiro setor, construído sobre o Método Captar 2.0, com 4 agentes especialistas (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore) que transformam um edital e uma OSC num projeto pronto para submissão.

Este repositório (`Gestao2026/amc-ia`) é um **fork** do projeto original de Diego Almeida (`DiegoAlmeidaDev/amc-ia`), que continua recebendo atualizações do autor original (chamado aqui de "upstream"). O trabalho feito neste fork combina duas frentes:

1. **Receber e manter as atualizações do upstream**, via um workflow automático de sincronização.
2. **Customizações e conteúdo próprios**, específicos deste fork: automações extras, base de editais atualizada, manuais e apostilas de apoio, e editais cadastrados manualmente pela equipe.

---

## Linha do tempo por marco

### Marco 1. Sistema inicial (30/06/2026)

**Commit:** `aea1f6b` — "AMC IA. Assistente de captacao de recursos para o terceiro setor"

O projeto nasceu já com o sistema completo: 92 arquivos, quase 30 mil linhas. Este commit único trouxe toda a espinha dorsal que existe até hoje:

- **4 agentes especialistas** (`captador-doc`, `captador-builder`, `captador-budget`, `captador-score`) e mais 5 agentes de apoio (`minerador-editais`, `minerador-web`, `orquestrador-captacao`, `posicionador-captador`, `revisor-proposta`).
- **Os comandos** em `.claude/commands/` que dão acesso a esses agentes (a base do que hoje é documentado na apostila de comandos).
- **As bases de conhecimento** (skills) que fundamentam cada agente: `editais-fundamentos`, `elaboracao-proposta`, `orcamento-tecnico`, `avaliacao-projeto`, `posicionamento-captador`.
- **As regras do projeto**: o Método Captar 2.0 completo (`.claude/rules/metodo-captar.md`), o Gate de Elegibilidade, a regra de acentuação obrigatória, os tempos estimados de cada operação.
- **Os hooks de automação**: `agentes-status.py` (alimenta a Sala dos Agentes) e `sem-travessao.py` (barra o uso de travessão nos textos gerados, por regra de estilo).
- **Os scripts Python** que dão suporte aos comandos: `captahub-editais.py` (sincronização de editais), `minerar-editais.py` (ranking de aderência), `exportar-projeto.py` (geração de Word, PDF e planilha), `verificar-acentuacao.py` (auditoria de português).
- **A estrutura de pastas**: `minhas-oscs/` (carteira de organizações), `captador/` (perfil e marketing do captador), `base-editais/` (cache local de editais), `painel/` e `docs/`.

Este commit foi coautorado pelo Claude Opus 4.8, no repositório original de Diego Almeida, antes de o fork existir.

### Marco 2. Sala dos Agentes ganha atalho fora do editor (04/07/2026)

**Commits:** `139e116`, `03d1e4d` (fix complementar em 12/07/2026)

A Sala dos Agentes (`/sala-agentes`) é a página visual em pixel art que mostra os agentes trabalhando em tempo real. Problema identificado: clicar no arquivo `.html` de dentro do VS Code só mostra o código-fonte, nunca a página renderizada. Solução: criado o atalho `abrir-sala-dos-agentes.bat`, e o comando `/sala-agentes` passou a rodá-lo direto por terminal (sem depender de clique manual do captador), abrindo explicitamente no Chrome ou Edge para evitar que o Windows tentasse abrir a página como texto.

### Marco 3. Base de editais e arquivos de consolidação (04/07/2026)

**Commit:** `aca0f02`

Inicialização da base de editais (`base-editais/editais-abertos.json` e `editais-index.json`) com o primeiro grande lote de editais, mais os arquivos de consolidação da carteira (`mineracao-consolidada-carteira.md`) e o registro da primeira OSC ativa (`minhas-oscs/.ativa`).

### Marco 4. Sincronização automática com o projeto original (09 a 12/07/2026)

**Commits:** `c6b9012`, `bc9bd99`, `3e9a00e`, `6a4f0ad`, `72f06f0`, `95efc05`

Esta foi a frente de trabalho mais longa e iterativa da fase inicial: um workflow do GitHub Actions (`.github/workflows/sync-upstream.yml`) para manter o fork atualizado com o projeto original de Diego Almeida, sem perder as customizações locais. Evoluiu em 6 passos:

1. **Criação do workflow** de sincronização diária automática (merge direto na `main`).
2. **Notificação de falha** via Telegram, para o caso de o merge automático dar conflito.
3. **Correção de um risco real**: o merge padrão do git podia apagar silenciosamente, do fork, qualquer arquivo que o upstream tivesse removido e que o fork nunca tivesse alterado (um caso "sem conflito" do ponto de vista do git, mas destrutivo do ponto de vista do captador). O workflow passou a detectar e restaurar esses arquivos antes de enviar.
4. **Troca do merge automático direto por Pull Request semanal** (toda sexta-feira às 18h, horário de Brasília), exigindo aprovação manual antes de entrar na `main`. Ficou mais seguro: nada do upstream entra sem revisão.
5. **Ajuste de nomenclatura** dos jobs e etapas do workflow, mantendo a proteção contra apagar arquivo e o tratamento de conflito real.
6. **Simplificação**: a notificação por Telegram foi removida, substituída pelo aviso nativo do GitHub por e-mail (Watch > Custom > Pull requests).

O estado final: todo sábado (ou quando houver novidade), uma PR é aberta automaticamente trazendo as atualizações do Diego Almeida, e só entra na `main` deste fork com aprovação manual.

### Marco 5. Primeira atualização de base e primeiro manual (12 e 13/07/2026)

**Commits:** `f6384a3`, `0bc6ad8`

- Atualização da base local de editais, de 533 para 536 editais (remoção de vencidos, inclusão dos novos captados).
- Criação do **Manual do CaptaHub** (`docs/manual-captahub.md`, `.html`, `.pdf`), o primeiro material de apoio da pasta `docs/`, explicando a integração entre a AMC IA e a plataforma CaptaHub.

### Marco 6. Sincronizações automáticas periódicas (22 e 23/07/2026)

**Commits:** `cb8cbbd`, `8bd80f8`

Duas rodadas do workflow de sincronização automática trouxeram, do upstream, atualizações relevantes que passaram a fazer parte deste fork:

- O comando `/editais-pasta-processar` (leitura em lote da pasta de editais para cadastrar, com checagem de duplicidade).
- A **primeira versão da apostila de comandos** (`docs/apostila-comandos-amc-ia.md`, `.html`, `.pdf`), com 196 linhas cobrindo os comandos existentes até então.
- A **apostila do Método Captar** (`docs/apostila-metodo-captar.md`, `.html`, `.pdf`).
- Uma leva de editais de exemplo (Havan, Ana Ter, ArcelorMittal, Catalisar, Lei Rouanet, Santander), usados como material de referência para modelos de proposta e orçamento.

### Marco 7. Editais cadastrados manualmente e novo comando (27/07/2026)

**Commit:** `1cc0fa2`

- Adição manual de mais editais à base de trabalho (FAOP/FEC, entre outros).
- Chegada do comando `/descricao-edital` (ficha descritiva avulsa de um edital, em `.doc`, sem vínculo com nenhuma OSC).

### Marco 8. Apostila de comandos aprofundada (28/07/2026, sessão de hoje)

Sem commit ainda (mudanças pendentes de commit no momento deste registro).

A apostila de comandos, que já cobria 22 comandos num formato de referência rápida, foi:

1. Atualizada para cobrir os **24 comandos** que existem hoje no sistema (faltavam `/descricao-edital` e `/editais-pasta-processar`).
2. Reescrita do zero num formato **muito mais detalhado**: um capítulo completo por comando, com para que serve, quando usar, contexto que lê, passo a passo da entrevista, o que entrega, onde salva e as travas e dependências de cada um.
3. No processo, foi identificado e corrigido um problema técnico na geração do PDF pelo Google Chrome headless: o espaço no nome da pasta do projeto (`OneDrive - Organizacao Multidisciplinar De Voluntariado E-missao`) quebrava a URL `file://` e produzia um PDF incompleto (1 página) sem erro visível. A solução foi gerar o PDF num caminho sem espaço e copiar o resultado para o destino final.

Detalhe completo desta sessão em `docs/registro-atividades-2026-07-28.md`.

---

## Estado atual do sistema (resumo)

| Item | Quantidade / conteúdo |
|---|---|
| Comandos (`.claude/commands/`) | 24 |
| Agentes especialistas (`.claude/agents/`) | 9 (4 principais + 5 de apoio) |
| Bases de conhecimento (`.claude/skills/`) | 5, mais as skills de apoio a cada comando |
| Regras globais (`.claude/rules/`) | Método Captar 2.0, tempos estimados |
| Scripts de automação (`scripts/`) | 4 scripts Python (editais, mineração, exportação, acentuação), mais os scripts de integração com o CaptaHub adicionados depois |
| Materiais de apoio (`docs/`) | Manual do CaptaHub, apostila do Método Captar, apostila de treinamento do CaptaHub, apostila de comandos da AMC IA |
| Base de editais (`base-editais/`) | Atualizada periodicamente pela sincronização automática e por cadastro manual |
| Workflow de sincronização (`.github/workflows/`) | PR semanal automática trazendo atualizações do projeto original (upstream), com aprovação manual antes de entrar na main |

---

## Onde encontrar mais detalhe

- **Sessão de hoje (apostila de comandos):** `docs/registro-atividades-2026-07-28.md`.
- **Histórico completo, commit a commit:** `git log --stat` na raiz do projeto.
- **O que cada comando faz, em detalhe:** `docs/apostila-comandos-amc-ia.md` (ou `.html` / `.pdf`).
- **A metodologia por trás do sistema:** `docs/apostila-metodo-captar.md` e `.claude/rules/metodo-captar.md`.
- **A integração com o CaptaHub:** `docs/manual-captahub.md` e `docs/integracao-captahub-api.md`.

---

## Nota sobre manutenção deste registro

Este documento foi montado manualmente a partir do histórico do git em 28/07/2026. Ele não se atualiza sozinho: para mantê-lo fiel, é preciso acrescentar um novo marco aqui sempre que uma mudança relevante for commitada no projeto (não é necessário registrar cada commit pequeno, apenas os marcos que mudam o que o sistema faz ou como ele funciona).
