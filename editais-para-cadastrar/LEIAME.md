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
5. Os editais novos ganham um **Controle** aberto direto no CaptaHub (pipeline, etapa "Encontrar
   cliente"), a mesma operação do botão "Novo Controle" da tela. A base de editais em si não é
   escrita pela AMC IA (não existe, e não deve ser tentado, nenhum `POST /v1/editais`; é o próprio
   CaptaHub que administra o catálogo). Os dados extraídos de cada edital também ficam guardados em
   `controles-criados.json`, porque o CaptaHub hoje não persiste esses campos junto ao Controle.

## Observação

Esta pasta é só uma esteira de entrada. A base de editais que os agentes realmente usam
(mineração, elegibilidade, etc.) continua sendo puxada do CaptaHub (`base-editais/`, cache).
