---
description: Checklist Mobilizando. Gerar o checklist interno de um edital, em Word, para a captadora trabalhar. Traz a informação completa em cada linha, mais a aplicação à carteira.
---

# /checklist-mobilizando

Produz o **Checklist Mobilizando**: o documento interno de trabalho da captadora sobre um edital. É o par do Mapa do Edital, e nunca vai para o cliente.

Aciona também pelo nome falado ("faz o Checklist Mobilizando desse edital", "quero o checklist interno do X").

| | Mapa do Edital | Checklist Mobilizando |
|---|---|---|
| Para quem | a organização cliente | a captadora, uso interno |
| Tom | explicativo, ensina o cliente a conferir | operacional, decide onde investir tempo |
| Abre por | prazo e urgência | impeditivos e riscos, com a solução de cada um |
| Traz carteira | nunca | sim, seção própria de aplicação à carteira |
| Traz item do edital | não, atrapalha a leitura | sim, em coluna "Onde está", em toda linha |
| Comando | `/mapa-edital` | `/checklist-mobilizando` |

## REGRA DE OURO DESTE COMANDO

> Definida pela captadora em 14/08/2026, e é o motivo de o documento existir.

**Nunca mande a captadora abrir o edital.** Toda linha traz a **informação completa**, escrita ali, mais a localização (item e página) como conferência extra, nunca como substituto.

Isso significa, na prática:
- Errado: "Análise de admissibilidade conforme a IN MinC nº 29/2026 (item 14.1)".
- Certo: "Análise de admissibilidade conforme a IN MinC nº 29/2026. Só as aprovadas viram projeto e recebem número de Pronac (item 14.1 e 14.1.1)".
- Quando o edital remete a outro documento que não está na pasta (uma Instrução Normativa, uma lei estadual), **diga isso explicitamente e liste o que ficou de fora**, em vez de apontar um número que ela não tem como abrir. Isso vira lacuna registrada na seção de divergências.
- Se a numeração de subitem do PDF não for confiável (comum quando o número fica em coluna lateral e sai fora de ordem na extração), use o bloco numerado mais a página, que são precisos, e avise isso na abertura do documento.

## Passo 0. Contexto

Leia `.claude/rules/naturezas-juridicas-carteira.md` e o arquivo de dados `minhas-oscs/_carteira/naturezas-juridicas.md`, necessários para a seção de aplicação à carteira. Não é preciso definir OSC ativa: este documento olha a carteira inteira.

## Passo 1. Obter o edital

Pergunte como o edital será fornecido: pasta com edital e anexos (preferido), PDF, texto colado ou link. Leia o edital **e todos os anexos disponíveis**.

Se já existir o Mapa do Edital daquele edital em `editais-avulsos/mapa-edital-{slug}.md`, reaproveite a extração em vez de reler do zero. O Checklist Mobilizando é o Mapa do Edital mais as camadas internas.

## Passo 2. Anúncio

```
🔍 Próximo passo: montar o Checklist Mobilizando (22 seções). Tempo estimado: 6 a 10 minutos.
```

## Passo 3. As 22 seções obrigatórias

Abertura, antes da seção 1: **LEIA ANTES DE QUALQUER COISA**, com o filtro (ou os filtros) que eliminam de saída, antes de qualquer análise de mérito, mais uma nota curta de como ler o documento.

1. **Impeditivos e riscos, com a solução de cada um.** Quadro de 4 colunas: marcar, Risco ou impeditivo, O que o edital exige, Solução ou verificação. Ordem deliberada, o que derruba vem antes do que encanta. Prefixe cada risco com a família: `ELIMINA`, `CAIXA`, `EXECUÇÃO` ou `RISCO`. Incluir sempre a pergunta de capacidade real de execução.
2. **Dados gerais do edital.** Quadro Item / Conteúdo, com valor, vagas, prazos, canais e o direito do promotor de alterar o edital.
3. **Modalidades e caminhos do recurso**, mais o que o edital NÃO define e vem de outro documento.
4. **Quem pode participar**, com localidade, natureza jurídica e o que o edital não exige (a ausência de exigência é informação de triagem).
5. **Quem não pode participar.**
6. **Categorias, vagas e valores.**
7. **Elegibilidade e habilitação**, separadas de forma explícita.
8. **Critérios de avaliação e seleção**, com as etapas de análise, o quadro discriminado de critérios e as hipóteses de desclassificação.
9. **Resultado, classificação, desempate e recursos.** Se não couber recurso, dizer com todas as letras.
10. **Cotas e ações afirmativas.**
11. **Cronograma completo.**
12. **Checklist da inscrição na plataforma.**
13. **Checklist documental**, separando o que vai na inscrição do que vem depois.
14. **Regras financeiras e do orçamento.**
15. **Contrapartidas.**
16. **Acessibilidade e democratização do acesso.**
17. **Após a seleção: execução e prestação de contas.**
18. **Anexos e o que é necessário para envio.**
19. **Divergências e lacunas do edital**, numeradas D1, D2, D3, com a orientação de qual leitura adotar.
20. **Perguntas para o canal de dúvidas**, cada uma remetendo à divergência que a originou.
21. **Aplicação à carteira.** Cruzar os filtros de entrada com os perfis da carteira, em duas tabelas (passam / não passam), com a coluna "Situação frente aos filtros". Fechar com as observações que valem dinheiro: cliente com pendência documental, organizações irmãs, cliente mais aderente. **Deixar explícito quando passar no filtro não significa estar apto**, apontando qual é o filtro decisivo.
22. **Sequência recomendada de trabalho.** Quadro Quando / Ação, do "agora" até depois da submissão.

Seção que não se aplica àquele edital não é omitida: é registrada como lacuna, dizendo por que não se aplica e o que vale no lugar.

## Passo 4. Escrever o markdown de origem

!> **Este documento cita clientes reais.** Salve em `minhas-oscs/_carteira/checklists/checklist-mobilizando-{edital-slug}.md`, que está fora do controle de versão. **Nunca** salve em `editais-avulsos/`, que é versionado num repositório público.

Bloco de metadados no topo:

```
---meta
documento: CHECKLIST MOBILIZANDO
chamada: Documento interno de trabalho. Não enviar ao cliente
nota_capa: (frase do rodapé da capa)
titulo: Nome curto do edital (até 34 caracteres aparecem no cabeçalho)
subtitulo: Identificação completa
rotulo_orgao: Órgão responsável, ou Promotor, se for edital privado
orgao: ...
patrocinador: (opcional)
base_legal: (opcional)
prazo: ...
plataforma: ...
data: data de hoje
fecho: (nota final do documento, com a origem da leitura)
arquivo: CHECKLIST MOBILIZANDO - {Nome curto}
---
```

Marcações do gerador: `## N. TÍTULO`, `### Subtítulo`, `#### Sub-subtítulo`, tabela markdown, `- [ ]`, `-`, `1.`, `> destaque`, `!> alerta`, `---`, `**negrito**`, `*itálico*`.

Em tabela, a coluna de marcar tem o cabeçalho `☐` e a célula `☐`. O gerador reconhece esse cabeçalho e fixa a coluna estreita.

## Passo 5. Gerar o Word

```
python scripts/mapa-edital.py "minhas-oscs/_carteira/checklists/checklist-mobilizando-{slug}.md" --saida "C:/Users/rosep/Desktop/CONTROLE EDITAIS/2. ANALISE EDITAIS/2. CHECKLIST (interno Mobilizando)"
```

O mesmo gerador serve aos dois documentos. O que muda é o campo `documento:` do bloco meta e o conteúdo.

## Passo 6. Entrega

Informe o caminho absoluto do `.docx`, o número de páginas, quais clientes passam no filtro de entrada e o que ficou como lacuna a levantar.

## Regras

- Não invente exigência que não esteja no edital. Lacuna se registra como lacuna.
- Português correto, com acentuação, sem travessão.
- Nunca enviar este documento ao cliente. Para o cliente é o `/mapa-edital`.
- Nome de cliente, CNPJ e dado de carteira nunca entram em arquivo versionado.
