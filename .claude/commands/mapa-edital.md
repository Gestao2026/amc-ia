---
description: Mapa do Edital. Gerar o checklist completo de um edital para enviar ao cliente, em Word, com a identidade visual da Mobilizando.
---

# /mapa-edital

Produz o **Mapa do Edital**: o checklist completo de um edital, em documento Word com a marca da Mobilizando, escrito para o **cliente ler e conferir**. É o material que a captadora envia à organização para ela saber exatamente o que o edital exige.

Aciona também quando a captadora disser o nome, sem barra ("gera o Mapa do Edital do PNAB Ciclo 2", "faz um Mapa do Edital desse aqui").

> Este é o formato **para o cliente**. Existe um segundo formato, interno, para a própria captadora. Não misturar os dois: o do cliente não traz avaliação de carteira, nome de outras organizações, precificação nem estratégia comercial.

## Passo 0. Contexto

Não leia `minhas-oscs/.ativa` nem nenhum `perfil-osc.md`. O Mapa do Edital descreve o edital, não a organização. A elegibilidade de cada cliente é o passo seguinte (`/projeto-elegibilidade`).

## Passo 1. Obter o edital

Pergunte como o edital será fornecido:
1. Caminho da pasta com o edital e os anexos (preferido, porque as divergências entre edital e anexo só aparecem na leitura cruzada).
2. Caminho de um PDF.
3. Texto colado ou link.

Leia o edital **e todos os anexos disponíveis**. As seções 16 e 17 dependem dessa leitura cruzada.

## Passo 2. Anúncio

```
🔍 Próximo passo: montar o Mapa do Edital (18 seções). Tempo estimado: 4 a 7 minutos.
```

## Passo 3. Extração, as 18 seções obrigatórias

Consulte `.claude/skills/editais-fundamentos/SKILL.md`. Monte o conteúdo nesta ordem exata, sempre ancorado no texto do edital.

**Regra que vale para todas as seções:** em cada ponto, traga também a especificidade que existir ali dentro. Não basta a regra geral. Se o edital tem exceção, prazo próprio, exigência que só vale para uma modalidade, documento que só uma categoria pede ou condição que muda conforme o proponente, isso entra. Onde o edital for omisso, registre a lacuna de forma explícita, nunca deixe em branco.

Abertura, antes da seção 1: **LEIA PRIMEIRO. O QUE É URGENTE.** Quadro com o prazo final, quantos dias faltam contados de hoje, a plataforma e o cadastro prévio, os anexos que ainda precisam ser baixados, o prazo de habilitação e o limite de propostas por proponente.

1. **DADOS GERAIS DO EDITAL.** Órgão, número, fonte do recurso, objeto, valor total, vagas, período de inscrição, vigência, validade do resultado. Mais uma subseção com as especificidades que mudam a decisão (incidência de tributos, possibilidade de acúmulo com outras fontes, prorrogação).
2. **MODALIDADES.** Quadro comparativo, quando o edital tiver mais de uma. Duração, como se organiza, quem pode, tempo mínimo de existência, recurso, vagas, data do resultado. Se houver uma só modalidade, diga isso e descreva-a.
3. **QUEM PODE PARTICIPAR.** Sempre com subseção própria de **localidade** (domicílio ou sede, janela de validade do comprovante, dispensas previstas) e uma lista por modalidade ou categoria.
4. **QUEM NÃO PODE PARTICIPAR.** Impedimentos gerais, impedimentos exclusivos de alguma modalidade, e o que expressamente **não** impede (isso evita autoexclusão indevida).
5. **CATEGORIAS, LINHAS, VAGAS E VALORES.** Quadro por categoria com o que financia, vagas, teto por proposta e recurso da categoria. Mais as especificidades que costumam passar despercebidas (vedação de inscrição em mais de uma linha, distribuição de vagas definida só depois, teto por categoria).
6. **CRITÉRIOS DE ELEGIBILIDADE E HABILITAÇÃO.** Separar os dois momentos de forma explícita, porque confundi-los é erro caro. Listar a habilitação por tipo de proponente (pessoa física, pessoa jurídica, coletivo sem CNPJ).
7. **CRITÉRIOS DE PONTUAÇÃO E DESEMPATE.** Quadro discriminado, um critério por linha, com o que a banca avalia e a pontuação máxima. Total possível e nota de corte. Quadro de gradação, quando houver. Ordem de desempate. Hipóteses de desclassificação automática.
    - **Checagem obrigatória:** algum critério depende de base de cálculo externa e variável (IDHM, faixa de população, renda per capita, tempo de trajetória, número de edições)? Se sim, extrair a tabela real de faixas e valores. Se não, registrar que não há.
8. **COTAS E AÇÕES AFIRMATIVAS.** Percentuais, como concorrer, qual anexo preencher, se cotista concorre também à ampla, se pessoa jurídica e coletivo podem cotar e sob qual condição, o que acontece na desistência. Quadro de distribuição das vagas, quando o edital trouxer.
9. **CHECKLIST DOCUMENTAL DA INSCRIÇÃO.** Separado do de habilitação, com aviso explícito de que certidão não entra na inscrição (quando for o caso). Comum a todos, mais o específico de cada modalidade e de cada categoria.
10. **CRONOGRAMA.** Quadro com todas as etapas, inclusive prazos de recurso e de entrega de documentos. Quando houver cronogramas independentes por modalidade, uma coluna para cada.
11. **ITENS FINANCIÁVEIS E VEDADOS.** Estrutura da planilha orçamentária e regras financeiras. Se o edital não trouxer rol de vedações, dizer isso e listar as regras que funcionam como vedação na prática.
12. **CONTRAPARTIDA.** Se não houver exigência, dizer com todas as letras e explicar o que cumpre esse papel na leitura da banca.
13. **ACESSIBILIDADE E DEMOCRATIZAÇÃO DO ACESSO.** As dimensões exigidas (arquitetônica, comunicacional, atitudinal) e o detalhe que faz perder ponto (medida marcada e não descrita, medida descrita e não orçada).
14. **PRESTAÇÃO DE CONTAS.** O que apresentar, prazo, canal, tempo de guarda, desfechos possíveis e sanções. Separar por modalidade quando mudar.
15. **RISCOS DE INABILITAÇÃO E DE PERDA DE PONTO.** Quadro com três colunas: Risco, Por que acontece, Como resolver. Incluir sempre a pergunta de **capacidade real de execução**, conforme a orientação da captadora de trazer impedimentos e riscos com solução logo no início.
16. **DIVERGÊNCIAS ENTRE O EDITAL E OS ANEXOS.** Numeradas D1, D2, D3. Cada uma com o que o edital diz, o que o anexo diz e a orientação de qual leitura adotar enquanto não houver resposta oficial (sempre a mais exigente). Se a leitura cruzada não encontrar divergência, registrar isso explicitamente.
17. **ANEXOS E O QUE SERÁ NECESSÁRIO PARA ENVIO.** Quadro com todos os anexos listados no edital, o que cada um é e quando entra (consulta, envio obrigatório na inscrição, prestação de contas, contratação). Depois, o pacote final de envio, item a item, para reunir antes de abrir a plataforma.
18. **PERGUNTAS PARA O CANAL DE DÚVIDAS.** Lista numerada, cada pergunta remetendo à divergência que a originou, mais o canal e o prazo do canal.

## Passo 4. Escrever o markdown de origem

Salve em `editais-avulsos/mapa-edital-{edital-slug}.md`, com o bloco de metadados no topo:

```
---meta
titulo: Nome curto do edital
subtitulo: Identificação completa (número, programa, política)
orgao: Órgão responsável
prazo: DD/MM/AAAA, às HHh
plataforma: Onde se inscreve, com o cadastro prévio se houver
data: data de hoje
arquivo: MAPA DO EDITAL - {Nome curto}
---
```

Marcações aceitas pelo gerador: `## N. TÍTULO` (faixa verde numerada), `### Subtítulo`, `#### Sub-subtítulo`, tabela markdown, `- [ ] item` (quadradinho para marcar), `- item`, `1. item`, `> destaque` (caixa dourada), `!> alerta` (caixa roxa), `---` (fio dourado), `**negrito**` e `*itálico*`.

Use `- [ ]` em tudo que o cliente precisa conferir, e `-` só em desdobramento de um item já marcável. É o que transforma o documento em checklist de verdade.

## Passo 5. Gerar o Word

```
python scripts/mapa-edital.py "editais-avulsos/mapa-edital-{edital-slug}.md" --saida "C:/Users/rosep/Desktop/CONTROLE EDITAIS/2. ANALISE EDITAIS"
```

Esta pasta é o destino fixo de toda análise de edital, definido pela captadora em 14/08/2026.

## Passo 6. Entrega

Informe o caminho absoluto do `.docx`, o número de páginas e, em uma linha, o que ficou como lacuna do edital ou pendente de resposta do canal de dúvidas.

Não crie Controle no CaptaHub por este comando. Quem faz isso é o `/descricao-edital` (ficha interna) ou o `/editais-pasta-processar` (cadastro em lote).

## Regras

- Não invente exigência que não esteja no edital. Lacuna se registra como lacuna.
- Português correto, com acentuação, sem travessão.
- Documento voltado ao cliente: nunca cite outras organizações da carteira, valores de assessoria, estratégia comercial ou caminho de arquivo interno do sistema.
- A identidade visual (verde `#1D624D`, dourado `#D1B484`, roxo `#7F126F`, logo) vive em `scripts/mapa-edital.py` e em `painel/marca/`. Não redefinir cor dentro do conteúdo.
