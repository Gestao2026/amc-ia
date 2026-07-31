# Registro de Atividades. Sessão de 31/07/2026

> Documento de referência interna. Registra o encerramento da Sprint de persona compartilhada do Captador: arquitetura consolidada, regras de negócio, componentes alterados, limitações, testes, pendências e próximos passos. Consultar antes de retomar este tema ou iniciar a Etapa 2 (SOL-0005 em `.claude/rules/decisoes-tecnicas.md`).

**Tema da sessão:** relatório final da Sprint "persona compartilhada Captador na CaptaSuite".

---

## 1. Arquitetura atual

O sistema é composto por um assistente principal (governado por [CLAUDE.md](../CLAUDE.md)) e uma suíte de 6 agentes especializados, cada um definido em `.claude/agents/`, acionados por comandos (`.claude/commands/`) ou diretamente pela thread principal:

- **CaptaDoc** ([captador-doc.md](../.claude/agents/captador-doc.md)). Triagem documental e elegibilidade. Guardião do Gate de Elegibilidade.
- **CaptaBuilder** ([captador-builder.md](../.claude/agents/captador-builder.md)). Elaboração da proposta, bloco a bloco.
- **CaptaBudget** ([captador-budget.md](../.claude/agents/captador-budget.md)). Orçamento técnico por rubrica, com pesquisa de preço via `WebSearch`/`WebFetch`.
- **CaptaScore** ([captador-score.md](../.claude/agents/captador-score.md)). Avaliação com visão de banca.
- **orquestrador-captacao** ([orquestrador-captacao.md](../.claude/agents/orquestrador-captacao.md)). Diagnóstico do estado do projeto e recomendação do próximo comando. Não executa os demais agentes.
- **posicionador-captador** ([posicionador-captador.md](../.claude/agents/posicionador-captador.md)). Marketing e posicionamento do próprio captador (Fase 2 do Método Captar).

Nenhum desses 6 agentes possui a ferramenta `Agent`: quem aciona cada um é sempre a thread principal, disparada por um comando (`/projeto-elegibilidade`, `/projeto-escrever` etc.) digitado pelo captador. Isso significa que a linha de montagem (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore) é hoje sequencial, mas conduzida por um humano entre cada etapa, nunca encadeada automaticamente por um agente.

Desde esta Sprint, todos os 6 agentes compartilham uma identidade comum, carregada no "Passo 0" de cada um a partir de [.claude/rules/persona-captador.md](../.claude/rules/persona-captador.md): o Captador, consultor com 25 ou mais anos de mercado em captação de recursos para o terceiro setor, com domínio do arcabouço legal do setor como postura, não como citação de lei. `CLAUDE.md` referencia o mesmo arquivo para manter o assistente principal alinhado.

O sistema tem fronteira clara com o CaptaHub: editais e carteira de OSCs vêm de lá (fonte da verdade), a AMC IA é o estúdio de elaboração. Não existe pipeline, kanban nem CRM neste projeto.

## 2. Regras de negócio implementadas

- **Gate de Elegibilidade.** Nenhuma proposta é escrita sem `elegibilidade.md` com veredito APTO ou APTO COM PENDÊNCIAS.
- **Checklist de 13 dimensões do CaptaDoc** ([checklist-triagem-captadoc.md](../.claude/rules/checklist-triagem-captadoc.md)), incluindo a checagem obrigatória de base de cálculo externa e variável (IDHM, população, renda per capita), registrada como SOL-0002.
- **Persona compartilhada do Captador** (SOL-0004, desta Sprint). Identidade única em todos os agentes; legislação específica fica exclusivamente nas Skills (`editais-fundamentos`) e no edital em análise, nunca hardcoded na persona, por falta de responsável designado para manter isso atualizado.
- **Sincronização bidirecional com o CaptaHub** para carteira de OSCs e pipeline de projetos, com identidade sempre por id, nunca por URL ou título de edital.
- **`/descricao-edital` não cria edital na base do CaptaHub** (SOL-0003, revista pela SOL-0006).
- **Acentuação obrigatória em pt_BR** e verificação automática via `scripts/verificar-acentuacao.py`.
- **Tokens só no `.env`**, nunca hardcoded.

## 3. Componentes alterados nesta Sprint

Commit `4e8fa03` ("feat: adiciona persona compartilhada Captador na CaptaSuite"), 9 arquivos, 155 inserções, 12 remoções:

| Arquivo | Alteração |
|---|---|
| `.claude/rules/persona-captador.md` | Criado. Identidade do Captador, tom, mapeamento por agente, nota de desenho para a Etapa 2, regra de manutenção sobre legislação. |
| `.claude/agents/captador-doc.md` | Passo 0 passa a ler `persona-captador.md`; abertura reescrita para vestir a persona. |
| `.claude/agents/captador-builder.md` | Idem. |
| `.claude/agents/captador-budget.md` | Idem. |
| `.claude/agents/captador-score.md` | Idem. |
| `.claude/agents/orquestrador-captacao.md` | Idem (sem nenhuma alteração de ferramentas). |
| `.claude/agents/posicionador-captador.md` | Idem. |
| `CLAUDE.md` | Seção "Quem Você É" ganha referência à persona compartilhada. |
| `.claude/rules/decisoes-tecnicas.md` | Registradas SOL-0004 (persona compartilhada) e SOL-0005 (roadmap do Agente Mestre). |

Nenhuma ferramenta (`tools:` no frontmatter) foi alterada em nenhum agente. Nenhuma lógica de execução, comando ou fluxo de aprovação humana foi tocada.

## 4. Limitações conhecidas

- **orquestrador-captacao não executa, só recomenda.** Não há hoje nenhum agente que efetivamente controle o fluxo entre CaptaDoc, CaptaBuilder, CaptaBudget e CaptaScore. É intencional nesta Sprint (ver SOL-0005).
- **Legislação não é citada com precisão de artigo em nenhum agente.** Limitação deliberada, não uma lacuna a corrigir sem antes resolver quem seria o dono da manutenção desse conteúdo.
- **CaptaHub não expõe criação de edital via API** (`POST /v1/editais` retorna 404, confirmado em teste real). O caminho correto passou a ser abrir um Controle no pipeline (`POST /v1/projetos` sem `cliente_id`/`edital_id`), registrado em SOL-0006, fora do escopo desta Sprint mas presente no repositório.
- **O campo `edital` enviado ao criar um Controle não é persistido pelo CaptaHub** (retorna `edital_id: null`), por isso os dados extraídos do edital continuam sendo guardados localmente em `editais-para-cadastrar/`.

## 5. Testes executados

Este projeto não tem suíte de testes automatizados de código (é um conjunto de agentes e regras em linguagem natural, não uma aplicação com lógica executável tradicional). A verificação realizada nesta Sprint foi:

- **Verificação de acentuação** (`scripts/verificar-acentuacao.py`) rodada sobre os 9 arquivos alterados. Nenhum erro real encontrado; os 5 avisos em `persona-captador.md` foram checados manualmente e confirmados como falso positivo do script (pronome demonstrativo "esta/desta", não a forma verbal "está").
- **Releitura manual** dos 6 agentes após edição, para confirmar que só o Passo 0 e o parágrafo de abertura foram alterados, sem tocar Saída, Regras, Proteção ou Encerramento.
- **Conferência do escopo do commit** (`git show --stat`) para garantir que exatamente os 9 arquivos pretendidos entraram no histórico, depois de um primeiro commit ter varrido acidentalmente cerca de 50 arquivos pendentes de outra frente de trabalho (corrigido com `git reset --soft`, seguido de `git reset` e `git add` explícito só dos 9 arquivos).

Não houve teste funcional do comportamento dos agentes em uma conversa real (rodar `/projeto-elegibilidade` de ponta a ponta, por exemplo) dentro desta Sprint.

## 6. Pendências

- **Cerca de 50 arquivos permanecem pendentes de commit no repositório**, sem relação com esta Sprint: exclusões de documentos fonte em `editais-para-cadastrar/` (Havan, Santander, ANATER, Acellor Mittal, CATALISAR, Floresta Viva, Prefeitura de BH, BB Socioculturais), novas fichas em `Descrição Editais/`, `scripts/captahub-api.py` e `scripts/editais-pasta-checar-duplicado.py` modificados, `scripts/controle-resolver.py` novo, e os documentos de SOL-0006 (`docs/especificacao-endpoint-criacao-edital.md`, `docs/pergunta-captahub-endpoint-criacao-edital.md`). Precisam de uma decisão e um commit à parte.
- **Branch local está 2 commits à frente de `origin/main`**, nenhum deles enviado (`git push` pendente).
- **Nenhum teste funcional dos 6 agentes com a nova persona** foi rodado em conversa real.
- **Etapa 2 (Agente Mestre)** segue como roadmap não iniciado, SOL-0005.

## 7. Próximos passos recomendados

1. Decidir separadamente o que fazer com os cerca de 50 arquivos pendentes de `editais-para-cadastrar/` e afins (não fazem parte desta Sprint, mas seguem em aberto no repositório).
2. Validar em uma conversa real que a persona aparece corretamente ao rodar `/projeto-elegibilidade` ou outro comando da suíte.
3. Decidir sobre o `git push` dos 2 commits locais.
4. Quando o roadmap SOL-0005 for priorizado, abrir uma sessão de planejamento própria para a evolução do `orquestrador-captacao` em Agente Mestre, sem misturar com outras frentes.

Sprint encerrada sem nenhuma implementação nova além do já registrado no commit `4e8fa03`.
