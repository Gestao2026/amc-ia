# Especificação. Endpoint de criação de edital (`POST /v1/editais`)

> ⚠️ **SUPERADO em 30/07/2026 (SOL-0006, `.claude/rules/decisoes-tecnicas.md`).** Este documento partia da premissa de que a AMC IA um dia deveria escrever diretamente na base de editais do CaptaHub. Confirmado por teste real que isso não é o caminho certo: a base de editais é administrada pelo próprio CaptaHub e não deve ser escrita pela API. O fluxo correto para um edital novo é abrir um **Controle** no pipeline (`controle-criar`, ver `docs/integracao-captahub-api.md` seção 3.4), não criar um edital. Mantido aqui só como registro histórico do porquê essa hipótese foi descartada; não usar como guia de implementação.

> Este documento não é implementado pela AMC IA. O backend do CaptaHub é um produto externo a este repositório (não há código de Supabase Edge Functions, schema de banco ou pasta de backend aqui). Este arquivo era a especificação cogitada para levar a quem mantém a API do CaptaHub, para que um endpoint de criação de edital passasse a existir — hipótese descartada, ver aviso acima.

## Por que este documento existe

A API pública do CaptaHub (`scripts/captahub-api.py`) hoje só lê editais (`GET /v1/editais`, `GET /v1/editais/{id}`). Não existe `POST /v1/editais`. Isso já limitava o `/editais-pasta-processar` e agora também limita o `/descricao-edital` (ver `.claude/rules/decisoes-tecnicas.md`, SOL-0003): os dois comandos identificam editais novos, mas não têm como cadastrá-los de fato no CaptaHub, só prepará-los para cadastro manual.

## 1. Contrato do endpoint

```
POST /v1/editais
Authorization: Bearer {token}
Content-Type: application/json
```

Corpo, espelhando a convenção já usada por `criar_cliente`/`criar_projeto` em `scripts/captahub-api.py` (só o obrigatório sempre presente; os demais entram no corpo apenas se informados, nunca como chave vazia):

| Campo | Obrigatório | Observação |
|---|---|---|
| `title` | sim | nunca nulo (mesma regra da leitura, seção 3.1 de `docs/integracao-captahub-api.md`) |
| `scope` | sim | `Municipal` / `Estadual` / `Nacional` / `Internacional`, nunca nulo |
| `institution` | não | órgão / financiador |
| `category` | não | categoria livre |
| `value` | não | número; ausente ou `null` = "não informado" (nunca `0`) |
| `currency` | não | ex: `BRL`; default `BRL` se omitido |
| `value_brl` | não | valor convertido, quando `currency` for diferente de `BRL` |
| `deadline` | não | `AAAA-MM-DD`; ausente = sem data conhecida |
| `is_continuous` | não | booleano; default `false` |
| `url` | não | link oficial do edital; usado como chave de deduplicação (ver seção 3) |
| `description` | não | descrição/objeto |
| `tags` | não | array de strings |
| `uf`, `municipio` | não | quando o escopo for Municipal/Estadual e o edital tiver sede definida |

Esses são exatamente os campos que já aparecem numa leitura real de edital hoje (confirmado com `python3 scripts/captahub-api.py editais --limit 1`), então a criação deve aceitar o mesmo conjunto que a leitura devolve, sem campo novo inventado.

**Resposta esperada:** `201 Created`, corpo = o objeto criado, no mesmo formato de `GET /v1/editais/{id}` (incluindo o `id` uuid gerado pelo servidor).

## 2. Decisão que precisa ser tomada antes de implementar: editais são dados globais

`clientes` e `projetos` são dados **por usuário** (a própria doc da API diz que cada token "só enxerga e altera os do próprio dono"). Editais são dados **globais**, compartilhados por todos os captadores da plataforma (`# ----- editais (globais, leitura) -----` no código do conector). Isso muda o risco de abrir escrita: se qualquer token pessoal puder criar edital, qualquer captador pode poluir (ou até vandalizar, por engano ou não) o catálogo que todos os outros usam.

Duas alternativas, uma decisão obrigatória de quem for implementar:

- **Escopo elevado.** O endpoint exige um escopo que o token pessoal hoje não tem (ex: `editais:escrever`), e permanece fechado para o uso comum do captador. Precisa de um fluxo separado de concessão desse escopo.
- **Fila de moderação.** Qualquer token pode enviar um edital novo, mas ele entra em uma fila de revisão e só aparece no catálogo geral (`GET /v1/editais`) depois de aprovado por um moderador. O endpoint devolveria, por exemplo, `status: "pendente_revisao"` no corpo de resposta.

Sem essa decisão, não dá para saber se um dia o token pessoal atual (`CAPTAHUB_API_TOKEN` no `.env`) vai simplesmente funcionar com este endpoint ou vai receber `403` (token sem escopo, ver seção 4).

## 3. Deduplicação no servidor

A AMC IA já faz uma checagem de duplicidade do lado do cliente (`scripts/editais-pasta-checar-duplicado.py`): compara por URL exata ou por similaridade de título+órgão normalizados (limiar 0,82). É uma checagem aproximada. O endpoint deveria ter sua própria deduplicação, para não depender só disso:

- Se `url` for enviada e já existir um edital com a mesma URL: responder `409 Conflict` com o registro já existente no corpo (padrão idempotente: quem chama duas vezes com a mesma URL recebe o mesmo edital, não duas linhas).
- Sem `url` (ou URL nova): aceitar a criação; duplicidade por título/órgão parecido fica por conta da checagem client-side, como já é hoje.

## 4. Erros

Reaproveitar exatamente o envelope e os códigos que a API já usa hoje (`scripts/captahub-api.py`, classe `CaptaHubAPIError`):

```json
{"error": {"code": "algum_codigo", "message": "mensagem legível"}}
```

| Status | Significado já normalizado no conector |
|---|---|
| 400 | requisição malformada |
| 401 | token inválido ou ausente |
| 403 | token sem o escopo necessário para esta ação (ver seção 2) |
| 404 | não encontrado |
| 422 | dados inválidos (falha de validação, ex: `title` ausente) |
| 429 | limite de chamadas excedido |
| 500 | erro interno |
| 409 | duplicado (novo, específico deste endpoint, ver seção 3) |

## 5. Trabalho de acompanhamento na AMC IA, só depois de o endpoint existir

Nenhuma destas mudanças deve ser feita agora, ficam registradas aqui para quando o endpoint estiver confirmado:

1. Adicionar `criar_edital(title, scope, **campos)` em `scripts/captahub-api.py`, no mesmo molde de `criar_cliente`: `body = {"title": title, "scope": scope}` seguido de `body.update({k: v for k, v in campos.items() if v is not None})`, chamando `self.post("/v1/editais", body)`. Adicionar o subcomando `edital-criar` no parser de CLI, junto de `cmd_edital_criar`.
2. Atualizar `.claude/commands/descricao-edital.md` (Passo 5, item 5) para chamar `edital-criar` de verdade em vez de só acrescentar em `editais-para-cadastrar/prontos-para-cadastro.json`.
3. Atualizar `.claude/commands/editais-pasta-processar.md` (Passo 6) da mesma forma.
4. Se a decisão da seção 2 for "fila de moderação", os dois comandos acima devem informar ao captador que o edital "foi enviado para revisão do CaptaHub", nunca "já está disponível no catálogo".
