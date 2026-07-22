# Pasta de trabalho. Editais para cadastrar no CaptaHub

Salve aqui os editais que você encontrar e que ainda não estão no CaptaHub. Toda
segunda-feira (ou quando você rodar `/editais-pasta-processar`), o sistema lê tudo
que estiver nesta pasta, extrai os dados de cada edital, confere se já existe no
CaptaHub (ou na base local) para não duplicar, e prepara os que são novos.

## Formatos aceitos

- PDF do edital
- Link (arquivo `.txt` ou `.md` com a URL, uma por arquivo)
- Word (`.docx`)
- Excel (`.xlsx`)
- Imagem (`.png`, `.jpg`, `.jpeg`), por exemplo print de tela do edital

## Como usar

1. Solte os arquivos nesta pasta, um edital por arquivo (ou uma URL por arquivo de texto).
2. Rode `/editais-pasta-processar` (ou aguarde a rotina de segunda-feira, quando estiver configurada).
3. O sistema mostra quantos são novos e quantos já existiam (duplicados, não cadastrados de novo).
4. Os arquivos já processados vão para `processados/{data}/`, para não reprocessar por engano.
5. Os editais novos ficam prontos em `prontos-para-cadastro.json`, no formato de campos do CaptaHub,
   aguardando a confirmação do endpoint de criação (`POST /v1/editais`) junto ao time do CaptaHub.
   Enquanto isso não existir, veja `prontos-para-cadastro.json` para cadastrar manualmente na tela do CaptaHub.

## Observação

Esta pasta é só uma esteira de entrada. A base de editais que os agentes realmente usam
(mineração, elegibilidade, etc.) continua sendo puxada do CaptaHub (`base-editais/`, cache).
