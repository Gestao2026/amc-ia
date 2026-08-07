# Fonte Única de Documentos dos Clientes

> Regra de processo que define onde a AMC IA busca documentos reais (certidões, contrato social, comprovantes, portfólios, CPF/RG de representante) de cada cliente. Consultar sempre que for preciso checar documentação de uma OSC/cliente para elegibilidade (CaptaDoc), checklist documental, análise de edital ou qualquer conferência de dado real, não descritivo. Ver `.claude/rules/checklist-triagem-captadoc.md` para o checklist que usa esta fonte.

## A regra

O único lugar autorizado para consultar documentos reais dos clientes é a pasta local:

`C:\Users\rosep\Desktop\_82 - Rosepaula Aparecida andrade Rodrigues\06 - Clientes\`

Dentro dela, cada cliente tem sua própria subpasta (ex: `13 - CaptaDrive - STK Produções`). Antes de declarar um documento como "faltando", "não localizado" ou "a confirmar" em qualquer parecer de elegibilidade, checklist documental ou análise de edital, é obrigatório abrir a subpasta do cliente correspondente dentro de `06 - Clientes` e checar o conteúdo real.

**Não são fonte válida de documentos:**
- Links do Google Drive (CaptaDrive) mencionados no `perfil-osc.md`, que podem estar desatualizados ou inacessíveis.
- O texto do `perfil-osc.md` sozinho, sem checar a pasta real. O perfil é a cópia de trabalho, não a fonte primária de documento.
- Suposições baseadas só no que já foi registrado em pareceres anteriores desta mesma OSC.

## Como aplicar

1. Identificar o cliente ativo (slug em `minhas-oscs/.ativa`).
2. Localizar a subpasta correspondente dentro de `06 - Clientes` (o nome da subpasta pode não ser idêntico ao slug da OSC; procurar pelo nome da organização ou do cliente).
3. Antes de qualquer veredito de elegibilidade (CaptaDoc) ou checklist documental, abrir e conferir os arquivos reais dessa subpasta.
4. Se um documento citado no perfil como "não encontrado" aparecer de fato na pasta, atualizar `perfil-osc.md` e o(s) parecer(es) afetados imediatamente, sem esperar o cliente reenviar.
5. Se a subpasta do cliente ainda não existir ou estiver vazia, registrar isso como lacuna real (não simular, presumir ou inventar documento).

## Por que esta regra existe

Em 07/08/2026, uma triagem de elegibilidade da STK Produções (4 editais novos, CaptaDoc) listou certidões e outros documentos como "faltando" com base só no `perfil-osc.md`, quando parte deles já estava disponível na pasta local do cliente (CNH-e do representante legal, comprovante oficial do PRONAC no SALIC, que resolveu inclusive uma pendência territorial crítica de outro edital, Energisa Cultural). O captador identificou a falha e determinou que esta pasta local é a única fonte de verdade documental dos clientes, substituindo qualquer consulta baseada só em descrição ou link de Drive.
