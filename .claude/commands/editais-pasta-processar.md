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

## Passo 5. Checar duplicidade

Para cada edital extraído, rode:

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

## Passo 7. Relatório final

Informe em poucas linhas, sem detalhe técnico:

```
✅ Concluído: {N} arquivos lidos. {X} editais novos, {Y} já existiam (não duplicados no catálogo).
Controles criados no CaptaHub: {X'} ({X''} vinculados a OSC compatível e já em Selecionado, {X'''} em Encontrar cliente)
Controles já existentes, não duplicados: {Z} (backfill de edital_id feito em {Z'})
Novos: {lista com título e órgão}
Já existentes (pulados): {lista com título e órgão}
Dados extraídos guardados também em: editais-para-cadastrar/controles-criados.json
```

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
