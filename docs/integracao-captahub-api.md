# Integração com a API pública do CaptaHub

> Conector que liga a AMC IA à API REST do CaptaHub (já em produção). O CaptaHub
> é a fonte da verdade: editais (globais, leitura), pipeline de projetos e clientes (OSCs),
> ambos por usuário. O contrato completo do servidor está em `docs/prompt-api-captahub.md`.

## 1. Configuração (.env)

Tudo no `.env` (gitignorado, único lugar autorizado para segredos):

```
CAPTAHUB_API_URL=https://pkwwnajskprfutfavylq.supabase.co/functions/v1/api
CAPTAHUB_API_TOKEN=cpth_***   (token pessoal; nunca exibir sem máscara)
```

Toda chamada manda `Authorization: Bearer ${CAPTAHUB_API_TOKEN}`. O token é multi-tenant:
só enxerga e altera o pipeline e os clientes do próprio dono. Editais são globais.

## 2. O conector (`scripts/captahub-api.py`)

Módulo único, só biblioteca padrão (mesmo padrão dos outros scripts do projeto). Tem a
classe `CaptaHubClient` (injeta base URL + Bearer, faz GET/POST/PATCH, trata paginação e
normaliza erro) e uma linha de comando que os comandos e agentes invocam via Bash. A saída traz um
bloco legível para o chat e um bloco `=== JSON ===` para os agentes consumirem.

| Subcomando | O que faz | Endpoint |
|---|---|---|
| `testar` / `me` | testa a conexão, mostra dono e escopos | `GET /v1/me` |
| `editais [filtros]` | lista editais (globais) | `GET /v1/editais` |
| `edital --id` | um edital | `GET /v1/editais/{id}` |
| `estagios` | os 11 estágios do pipeline | `GET /v1/pipeline/estagios` |
| `projetos [filtros]` | lista a carteira do usuário | `GET /v1/projetos` |
| `projeto --id` | um projeto | `GET /v1/projetos/{id}` |
| `projeto-criar` | cria projeto (edital + cliente já conhecidos) | `POST /v1/projetos` |
| `controle-criar` | cria um Controle no pipeline para um edital novo, sem cliente nem edital ainda cadastrados (mesma rota do botão "Novo Controle") | `POST /v1/projetos` |
| `projeto-atualizar` | move estágio, grava nota, valores e (SOL-0007) faz backfill de `cliente_id`/`edital_id` | `PATCH /v1/projetos/{id}` |
| `clientes [filtros]` | lista as OSCs do usuário | `GET /v1/clientes` |
| `cliente --id` | uma OSC | `GET /v1/clientes/{id}` |
| `cliente-criar` | cria OSC | `POST /v1/clientes` |
| `cliente-atualizar` | edita OSC (parcial) | `PATCH /v1/clientes/{id}` |

Filtros de editais: `--scope` (Municipal/Estadual/Nacional/Internacional), `--category`,
`--q`, `--value-min`, `--value-max`, `--deadline-after`, `--deadline-before`,
`--is-continuous`, `--only-open`, `--limit` (máx 200, padrão 50), `--offset`, `--all`
(percorre todas as páginas). Listas respondem `{ data, total, limit, offset, has_next }`.

Exemplos:

```
python3 scripts/captahub-api.py testar
python3 scripts/captahub-api.py editais --scope Nacional --only-open --limit 20
python3 scripts/captahub-api.py projeto-atualizar --id <uuid> --status submetido --nota-tecnica 9 --data-submissao 2026-07-01
python3 scripts/captahub-api.py cliente-criar --nome "OSC Teste" --uf PE
```

## 3. Mapeamento de campos (API → modelos da AMC IA)

A AMC IA guarda os dados em arquivos markdown. O conector traduz entre os campos da
API e esses modelos. Datas sempre ISO (AAAA-MM-DD); valores monetários em reais (número),
não centavos; campo desconhecido vem `null` (nunca string vazia nem 0).

### 3.1 Edital → `base-editais/*.json` e `projetos/{slug}/edital.md`

| Campo da API | Modelo da AMC IA | Observação |
|---|---|---|
| `id` (uuid) | id do edital (referência ao CaptaHub) | usado em `edital_id` ao criar projeto |
| `title` | Título do edital | nunca nulo |
| `institution` | Órgão / financiador | |
| `category` | Categoria | |
| `scope` | Escopo (Municipal/Estadual/Nacional/Internacional) | nunca nulo |
| `value` | Valor | **`null` = "não informado"** (nunca 0) |
| `deadline` | Prazo de submissão | `null` = sem data; vencido é descartado por `only_open` |
| `is_continuous` | Fluxo contínuo | |
| `url` | Link do edital | |
| `description` | Descrição / objeto | base para `/edital-analisar` |
| `tags` | Palavras-chave | array ou null |
| `data_publicacao` | Data de publicação | timestamp ISO |

### 3.2 Cliente/OSC → `minhas-oscs/{slug}/perfil-osc.md`

| Campo da API | Seção/campo no `perfil-osc.md` |
|---|---|
| `nome` | Nome da organização |
| `sigla` | Sigla / nome fantasia |
| `cnpj` | CNPJ |
| `natureza_juridica` | Natureza jurídica |
| `fundacao` (AAAA-MM-DD) | Data de fundação / tempo de existência |
| `municipio`, `uf` | Município e UF (sede) |
| `territorios` (array) | Territórios de atuação |
| `areas_tematicas` (array) | Área(s) temática(s) |
| `missao` | Missão |
| `site` | Site e redes |
| `email`, `telefone` | Contato |
| `status_documental` (objeto de booleanos) | Situação documental (checklist do CaptaDoc) |
| `historico_aprovacoes` (array {financiador, valor, ano}) | Projetos já aprovados |

Chaves esperadas em `status_documental`: `cnpj_ativo`, `estatuto`, `cebas`,
`certidao_federal`, `certidao_estadual`, `certidao_municipal`, `fgts`, `cndt`,
`transferegov` (cada uma booleana). O checklist do `perfil-osc.md` (CNPJ ativo, Estatuto,
CEBAS, certidões federal/estadual/municipal, FGTS, CNDT, Transferegov) mapeia direto.

### 3.3 Projeto → estado do projeto e entregáveis dos 4 agentes

O projeto na API é o cartão da carteira no CaptaHub. A AMC IA elabora localmente
(`elegibilidade.md`, `proposta.md`, `orcamento.md`, `score.md`) e sincroniza o resultado
de volta para o cartão.

| Campo da API | Origem na AMC IA |
|---|---|
| `nome` | título do projeto/edital |
| `cliente_id` | id da OSC ativa no CaptaHub |
| `edital_id` | id do edital (do `/v1/editais`) |
| `descricao` | resumo do projeto |
| `status` | etapa da linha de montagem (um dos 11 estágios) |
| `nota_tecnica` (0..10) | nota do **CaptaScore** (`score.md`) |
| `chance_aprovacao` (string) | chance estimada pelo **CaptaScore** |
| `valor_solicitado` | total do **CaptaBudget** (`orcamento.md`) |
| `valor_aprovado` | valor contemplado (pós-resultado) |
| `data_submissao` (AAAA-MM-DD) | data de envio |

Estágios canônicos, em ordem: `selecionado`, `encontrar_cliente`, `checklist`, `contrato`,
`separar_documentos`, `elaborar_projeto`, `submetido`, `aprovado`, `reprovado`,
`pagamento_pendente`, `pagamento_recebido`.

## 3.4 Edital (leitura) × Controle (escrita) — distinção arquitetural obrigatória

> Confirmado por teste real em 30/07/2026. Ver `.claude/rules/decisoes-tecnicas.md`, SOL-0006.

A base de editais é administrada pelo próprio CaptaHub. **Não existe, e não deve ser tentado, nenhum `POST` na base de editais** (`POST /v1/editais` responde `404 Rota não encontrada`; nenhuma documentação, código ou material de treinamento do CaptaHub descreve um caminho alternativo de escrita, como `/v1/import`, `/v1/pipeline` de escrita ou similar).

Quando a AMC IA identifica um edital novo (fora do catálogo do CaptaHub, achado pela equipe numa pasta de entrada, PDF ou link), a operação certa **não é criar o edital**, é abrir um **Controle** no pipeline — o mesmo efeito do botão "Novo Controle" da tela do CaptaHub. Por baixo, chama a mesma rota `POST /v1/projetos` do `projeto-criar`, mas:

- **`cliente_id` e `edital_id` são opcionais** no servidor (confirmado ao vivo — o wrapper `criar_projeto` os trata como obrigatórios só por convenção do cliente, não porque o servidor exija). Um Controle pode nascer sem OSC e sem edital catalogado.
- O `status` inicial correto é `encontrar_cliente` (a etapa 2 do pipeline), nunca `selecionado`, para um edital sem cliente ainda vinculado.
- **O campo `edital` (dados extraídos: title, institution, category, scope, value, deadline, is_continuous, url, description, tags) é aceito no corpo sem erro, mas HOJE NÃO É PERSISTIDO.** O teste real voltou com `edital_id: null` e nenhum subcampo do `edital` enviado aparece de volta na resposta. Por isso, todo comando que usa `controle-criar` precisa gravar esses dados também localmente (ver `editais-para-cadastrar/controles-criados.json`), ou eles se perdem.

Uso:

```
python3 scripts/captahub-api.py controle-criar --nome "Programa X" --status encontrar_cliente --edital-json '{"title":"Programa X","scope":"Nacional","institution":"..."}'
```

## 3.5 Mecanismo central de dedup e pipeline (`controle-resolver.py`, SOL-0007)

> Ver `.claude/rules/decisoes-tecnicas.md`, SOL-0007 e SOL-0008.

`scripts/controle-resolver.py` é o único ponto de decisão de duplicidade de Controle,
compatibilidade com a carteira e etapa inicial do pipeline, reutilizado por
`/descricao-edital`, `/editais-pasta-processar` e `/edital-minerar`, para que as três
origens (CaptaHub, Web avulsa, Pasta Local e mineração) apliquem exatamente a mesma regra.
Só decide, nunca escreve no CaptaHub; quem cria ou atualiza é o comando chamador via
`captahub-api.py`.

Regra aplicada, em ordem:

1. **Dedup:** por `edital_id` exato (quando conhecido) ou por título normalizado contra
   o `nome` dos Controles existentes (`SequenceMatcher`, limiar 0,82). Se encontrar,
   `duplicado: true`, `acao: "atualizar"`, nenhuma criação.
2. **Compatibilidade** (só roda se `duplicado: false`): pontua a carteira de OSCs
   (`clientes --all`, ou um único cliente via `--cliente-id`, usado pelo `/edital-minerar`
   quando já se sabe a OSC) por categoria e território do edital. Bandas ALTA (score ≥ 6),
   MÉDIA (≥ 3), BAIXA. Só ALTA vincula automaticamente (`BANDA_MINIMA_PARA_VINCULO_AUTOMATICO`
   no script).
3. **Decisão de etapa:** ALTA -> `status_sugerido: "selecionado"`, `vincular_automaticamente: true`.
   Sem candidato ALTA -> `status_sugerido: "encontrar_cliente"`, sem vínculo.

Uso:

```
python3 scripts/controle-resolver.py --titulo "..." [--edital-id <uuid>] [--category "..."] [--scope "Estadual"] [--uf "MG"] [--description "..."] [--tags "tag1,tag2"] [--cliente-id <uuid>] [--sem-carteira]
```

Limite conhecido: o Controle (`GET /v1/projetos`) só expõe `nome`, não guarda instituição
nem link (esses só existem hoje na tabela interna `submissions`, fora da API pública, ver
seção sobre a tela "Editar Controle" ainda pendente de decisão), então o dedup por título
usa um sinal mais fraco que o do dedup de catálogo de edital (`editais-pasta-checar-duplicado.py`,
que compara título+órgão+URL).

## 4. Gotchas (cuidados que o conector já trata)

- **`value` de edital vem `null`** quando desconhecido (nunca 0). A exibição mostra "não informado".
- **`status_documental` no PATCH SUBSTITUI o objeto inteiro** (não faz merge). Para mudar um
  documento, envie o objeto completo. O conector deixa isso explícito.
- **Multi-tenant:** o token só vê os dados do próprio dono. `GET` de um id de outro usuário
  retorna 404 por design.
- **Erros normalizados:** `{ "error": { "code", "message" } }`, status 400/401/403/404/422/429/500,
  traduzidos para mensagem em português pela classe `CaptaHubAPIError`.
- **Paginação:** `--all` percorre todas as páginas usando `has_next`/`offset`.

## 5. Fronteira de posicionamento

O CaptaHub continua sendo a casa da carteira (pipeline e CRM). Este conector não traz gestão
de pipeline para dentro da AMC IA; ele permite **ler** editais e a carteira e
**sincronizar de volta** o resultado da elaboração (criar o projeto, gravar nota, valores e
status). É complementar, como manda o CLAUDE.md.
