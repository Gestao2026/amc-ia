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

Leia o bloco `=== JSON ===` da saída. Se `"duplicado": true`, marque este edital como
duplicado e não o inclua no cadastro. Se `false`, é candidato a edital novo.

## Passo 6. Preparar o cadastro

Ainda não existe endpoint confirmado de criação de edital via API (`POST /v1/editais`).
Enquanto isso:

1. Salve todos os editais novos (não duplicados) em
   `editais-para-cadastrar/prontos-para-cadastro.json`, uma lista no formato de campos do
   CaptaHub (Passo 4), acrescentando `"origem_arquivo"` com o nome do arquivo de origem.
2. Mova os arquivos já processados (novos e duplicados) para
   `editais-para-cadastrar/processados/{AAAA-MM-DD}/`, preservando o nome original.
3. Se, num próximo passo, o endpoint de criação já estiver confirmado e implementado no
   conector, use-o aqui para cadastrar automaticamente em vez de só gerar o JSON.

## Passo 7. Relatório final

Informe em poucas linhas, sem detalhe técnico:

```
✅ Concluído: {N} arquivos lidos. {X} editais novos preparados para cadastro, {Y} já existiam (não duplicados).
Novos: {lista com título e órgão}
Já existentes (pulados): {lista com título e órgão}
Caminho dos novos prontos para cadastro: editais-para-cadastrar/prontos-para-cadastro.json
```

Se houver editais novos e o cadastro automático ainda não estiver disponível, oriente:
"cadastre estes {X} editais manualmente na tela do CaptaHub, ou aguarde a confirmação do
endpoint de criação para automatizar."

## Regras

- Nunca cadastre (ou marque como pronto) um edital já existente. Na dúvida entre duplicado
  e novo, trate como duplicado e avise para conferência manual.
- Nunca apague arquivo da pasta, só mova para `processados/`.
- Português correto, sem travessão.
- Sem token do CaptaHub configurado, a checagem de duplicidade funciona só com a base
  local; avise essa limitação no relatório final.
