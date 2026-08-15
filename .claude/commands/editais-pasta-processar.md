---
description: Ler os editais salvos em editais-para-cadastrar/, conferir duplicidade e preparar o cadastro no CaptaHub.
---

# /editais-pasta-processar

Lê tudo que estiver em `editais-para-cadastrar/`, extrai os dados de cada edital, confere
se já existe (na base local ou no CaptaHub ao vivo) para nunca duplicar, e prepara os
editais novos para cadastro. Pensado para rodar toda segunda-feira, mas pode ser chamado
a qualquer momento.

## Passo 0. Contexto

Confira se `python3 scripts/captahub-api.py testar` responde (CaptaHub conectado). Se não
responder, avise que a checagem de duplicidade vai usar só a base local (`base-editais/`),
sem conferir ao vivo, e prossiga mesmo assim.

**Origem padrão dos editais.** Quando o captador pedir para cadastrar editais sem indicar
outro caminho, a origem é a pasta matriz externa:

```
C:\Users\rosep\Desktop\_82 - Rosepaula Aparecida Andrade Rodrigues\04 - Controle de Submissão_\01 - Mineração de Editais\02 - Editais Abertos
```

Essa pasta tem uma subpasta por instituição/programa, cada uma podendo conter o edital
principal e anexos (cronograma, orçamento, modelos). Antes do Passo 2, copie para
`editais-para-cadastrar/` apenas as subpastas/arquivos que ainda não foram processados
(confira contra `origem_arquivo` em `editais-para-cadastrar/controles-criados.json` e
contra `editais-para-cadastrar/processados/`, para não reprocessar o que já tem Controle
criado). Dentro de cada subpasta copiada, trate como fonte principal o arquivo cujo nome
remeta ao edital em si (ex: contém "edital", "regulamento", "política de patrocínio"); os
demais (anexo de cronograma, orçamento, modelo) servem só de contexto complementar, não
precisam virar um edital separado. Se o captador indicar outro caminho na conversa, use o
caminho indicado em vez da pasta matriz.

## Passo 1. Anúncio

```
🔍 Próximo passo: ler os editais da pasta de trabalho e conferir duplicidade ({N} arquivos). Tempo estimado: 2 a 4 minutos.
```

## Passo 2. Listar arquivos

Liste os arquivos em `editais-para-cadastrar/`, ignorando `LEIAME.md`, a subpasta
`processados/` e `prontos-para-cadastro.json`. Se não houver nenhum arquivo, informe e pare
aqui.

## Passo 3. Extrair o texto de cada arquivo

Para cada arquivo, conforme a extensão:

- `.pdf`, `.png`, `.jpg`, `.jpeg`: leia o arquivo diretamente.
- `.txt`, `.md`: leia o arquivo; se o conteúdo for um link, busque a página para extrair
  os dados do edital.
- `.docx`, `.xlsx`: rode `python3 scripts/editais-pasta-extrair-texto.py "{caminho}"` e leia
  o texto extraído.
- Outro formato: avise que não é suportado e pule o arquivo (não apague).

## Passo 4. Extrair os campos do edital

Para cada arquivo lido, monte os campos no formato do CaptaHub (ver
`docs/integracao-captahub-api.md`, seção 3.1):

`title`, `institution`, `category`, `scope` (Municipal/Estadual/Nacional/Internacional),
`value` (número ou null se não informado, nunca 0), `deadline` (AAAA-MM-DD ou null),
`is_continuous`, `url`, `description`, `tags`.

Não invente dado que não está no arquivo. Campo não encontrado fica `null`.

## Passo 4.1. Verificar prazo de inscrição (obrigatório, sempre)

Para cada edital extraído com `is_continuous: false` e `deadline` preenchido, compare a
`deadline` com a data de hoje.

- Se `deadline` já passou, o edital **não é processado**: não roda duplicidade (Passo 5),
  não roda o resolvedor de Controle (Passo 6). Em vez de mover para `processados/`, mova
  o(s) arquivo(s) de origem para a pasta externa de histórico (ver "Destino dos editais
  vencidos" abaixo). Guarde `title`, `institution` e `deadline` numa lista à parte
  ("vencidos") para o relatório final.
- Se `is_continuous: true` ou `deadline` é `null` (programa contínuo ou prazo não
  informado no arquivo), não há vencimento a checar; segue o fluxo normal.
- Se `deadline` está dentro do prazo, segue o fluxo normal.

Esta checagem é parte fixa do processo de cadastro em lote e roda em toda execução deste
comando, não é opcional.

**Destino dos editais vencidos (regra fixa).** Mova o(s) arquivo(s) de origem do edital
vencido para a pasta externa de histórico do captador (fora do amc-ia, não é
`editais-para-cadastrar/processados/`):

```
C:\Users\rosep\Desktop\_82 - Rosepaula Aparecida Andrade Rodrigues\04 - Controle de Submissão_\01 - Mineração de Editais\06 - Histórico de Editais _ Não Submetidos
```

Essa pasta já tem uma subpasta por instituição/edital (ex: "03 - Edital Cemig FIA", "01 -
Petrobrás"). Antes de mover, confira se já existe uma subpasta para aquela
instituição/edital (pelo nome); se existir, acrescente o arquivo a ela. Se não existir,
crie uma subpasta nova, numerada em sequência ao que já está lá (ex: "05 - Edital {nome}").
Nunca apague o arquivo, só mova.

## Passo 5. Checar duplicidade

Para cada edital que passou pela checagem de prazo (Passo 4.1), rode:

```
python3 scripts/editais-pasta-checar-duplicado.py --titulo "{title}" --orgao "{institution}" --url "{url}"
```

(Some `--sem-captahub` se o Passo 0 indicou que o CaptaHub não respondeu.)

Leia o bloco `=== JSON ===` da saída. Se `"duplicado": true`, guarde o `correspondente.id`
retornado (é um `edital_id` real do catálogo do CaptaHub, útil no Passo 6). Se `false`, é
candidato a edital novo, sem `edital_id` no CaptaHub.

## Passo 6. Abrir ou atualizar o Controle no CaptaHub (nunca escrever na base de editais)

**Regra de arquitetura, absoluta:** a base de editais é administrada pelo próprio CaptaHub;
a AMC IA nunca escreve nela (não existe `POST /v1/editais` nem qualquer variante — não
tente). O que este comando faz para cada edital do lote é abrir (ou atualizar) um
**Controle** no pipeline, seguindo a regra de negócio central do SOL-0007
(`.claude/rules/decisoes-tecnicas.md`), a mesma usada por `/descricao-edital` e
`/edital-minerar` (não confundir com a duplicidade de **edital no catálogo**, já resolvida
no Passo 5).

1. **Para cada edital do lote, rode o resolvedor central:**
   ```
   python3 scripts/controle-resolver.py --titulo "{title}" --edital-id "{correspondente.id, se o Passo 5 achou}" --category "{category}" --scope "{scope}" --uf "{uf, se houver}" --description "{description}" --tags "{tags separadas por vírgula}"
   ```
   Leia o bloco `=== JSON ===` da saída.
2. **Se `duplicado: true`:** não crie outro Controle. Guarde `controle_existente.id` como o
   Controle deste edital, trate como já processado. Se `sugerir_backfill_edital_id: true` e o
   Passo 5 trouxe `correspondente.id`, rode
   `python3 scripts/captahub-api.py projeto-atualizar --id {controle_existente.id} --edital-id {correspondente.id}`
   para completar o vínculo. Não enriqueça outros campos agora (ver SOL-0007, sincronização
   de campo a campo ainda pendente).
3. **Se `duplicado: false`:** crie o Controle já na etapa e no vínculo sugeridos:
   ```
   python3 scripts/captahub-api.py controle-criar --nome "{title}" --status {status_sugerido} {--cliente-id {candidato_osc.id} se vincular_automaticamente=true} {--edital-id {correspondente.id} se o Passo 5 achou, senão --edital-json '{json com os campos do Passo 4}'}
   ```
   Leia o bloco `=== JSON ===` e guarde o `id` do Controle criado.
4. **Guardar os dados extraídos localmente, sempre que um Controle novo foi criado com
   `--edital-json`.** O CaptaHub aceita esse campo mas hoje não o persiste (confirmado em
   teste real, `edital_id` volta `null`). Acrescente um registro em
   `editais-para-cadastrar/controles-criados.json` (leia o array existente e acrescente; crie
   com `[]` se não existir) com: `controle_id`, os campos do edital (Passo 4), `osc_vinculada`
   (nome e id, se `vincular_automaticamente` foi true, ou `null`), `origem_arquivo`,
   `criado_em` (data de hoje).
5. Mova os arquivos já processados (novos e duplicados) para
   `editais-para-cadastrar/processados/{AAAA-MM-DD}/`, preservando o nome original.
6. Sem token do CaptaHub configurado (Passo 0), pule este passo inteiro: não há como criar
   nem atualizar Controle. Avise isso no relatório final.

## Passo 6.1. Preparar o preenchimento manual da tela "Editar Controle"

**Confirmado ao vivo (teste real, `PATCH /v1/projetos/{id}`, resposta `HTTP 422 Nenhum campo
válido para atualizar`): a API pública do CaptaHub não aceita `prazo`/`deadline`,
`is_continuous`, `categoria`/`category`, `abrangência`/`scope`, `valor_captador` nem
`link_edital`/`url` no Controle.** Só é possível escrever via API: `nome`, `descricao`,
`status`, `nota_tecnica`, `chance_aprovacao`, `valor_solicitado`, `valor_aprovado`,
`data_submissao`, `cliente_id`, `edital_id`. O upload de PDF com preenchimento automático por
IA existe só na tela do CaptaHub, sem endpoint equivalente conhecido na API pública.

Por isso, para cada Controle **novo** criado no Passo 6, monte um bloco pronto para o
captador colar na tela "Editar Controle" daquele card, com os dados já extraídos no Passo 4:

```
Controle: {title}
Anexar PDF: {caminho do arquivo de origem}
Nome do Edital: {title}
Prazo do Edital: {deadline, formato dd/mm/aaaa} (ou marcar "Fluxo Contínuo" se is_continuous=true)
Valor do Projeto: {value, formatado em R$, ou "não informado no edital" se null}
Valor do Captador: definir com o captador (não vem do edital)
Categoria: {category}
Abrangência: {scope}{, UF, se houver}
Descrição: {description}
Link do Edital: {url, ou "não informado" se null}
```

Campo sem dado extraído do arquivo (`null`) entra como "não informado no edital", nunca
inventado. Este passo não faz nenhuma chamada de escrita, só organiza o que já foi extraído
para colagem manual; roda para todo Controle novo do lote, é parte fixa do processo.

## Passo 7. Relatório final

Informe em poucas linhas, sem detalhe técnico. Os editais que não viraram Controle **novo**,
seja por prazo vencido (Passo 4.1) ou por já existir (catálogo, Passo 5, ou Controle no
pipeline, Passo 6), entram juntos numa única lista, cada um com seu status:

```
✅ Concluído: {N} arquivos lidos.
Controles novos criados no CaptaHub: {X} ({X''} vinculados a OSC compatível e já em Selecionado, {X'''} em Encontrar cliente)
Novos: {lista com título e órgão}

⚠️ Não viraram Controle novo no CaptaHub:
- {título} ({órgão}) — vencido, prazo encerrado em {deadline}
- {título} ({órgão}) — duplicado, já existe no catálogo do CaptaHub
- {título} ({órgão}) — duplicado, já existe Controle no pipeline{, edital_id vinculado agora, se o backfill do Passo 6 item 2 rodou}

Dados extraídos guardados também em: editais-para-cadastrar/controles-criados.json
```

Logo em seguida, para cada Controle novo, apresente o bloco de preenchimento manual montado
no Passo 6.1, um por edital, para o captador colar direto na tela "Editar Controle" (prazo,
categoria, abrangência, valor do captador, link e o PDF a anexar não têm hoje escrita via
API, ver Passo 6.1).

Se não houve nenhum item vencido nem duplicado, omita a seção "Não viraram Controle novo".

O arquivo dos editais vencidos (Passo 4.1) é movido para a pasta externa de histórico
("04 - Histórico de Editais _ Não Submetidos", ver Passo 4.1), não fica em
`editais-para-cadastrar/` nem vai para `processados/`. Os duplicados (catálogo ou
Controle) são movidos normalmente para `processados/` (Passo 6 item 5), por já estarem
tratados.

Se o CaptaHub não estava conectado, avise: "CaptaHub não conectado, nenhum Controle foi
aberto nem atualizado; edite `.env` e rode `/captahub-conectar` para ativar essa parte do
fluxo."

## Regras

- Nunca cadastre (ou marque como pronto) um edital já existente. Na dúvida entre duplicado
  e novo, trate como duplicado e avise para conferência manual.
- **Nunca tente `POST /v1/editais` nem qualquer escrita na base de editais.** A única
  operação de escrita válida para um edital novo é `controle-criar`; para um Controle já
  existente, a única escrita válida hoje é o backfill de `edital_id`/`cliente_id` via
  `projeto-atualizar` (ver Passo 6, SOL-0007).
- **Regra de ouro (SOL-0007): um edital nunca gera dois Controles.** A checagem do Passo 6
  (via `controle-resolver.py`) é obrigatória para todo edital do lote, mesmo os que já
  passaram pelo dedup de catálogo do Passo 5.
- Nunca apague arquivo da pasta, só mova para `processados/`.
- Português correto, sem travessão.
- Sem token do CaptaHub configurado, a checagem de duplicidade de edital funciona só com a
  base local, e o Passo 6 (Controle) é pulado inteiro; avise essa limitação no relatório final.
