# Atividade. Ordenação da Planilha de Controle de Submissão

> Atividade recorrente da captadora, definida por ela em 11/08/2026. Descreve como a planilha `1 - Controle de Submissão_.xlsx` é organizada e o que deve ser conferido sempre que ela for atualizada. Consultar antes de mexer nessa planilha, e sempre que for pedido "reordenar por prazo".

## Onde fica

`_82 - {captadora}\04 - Controle de Submissão_\01 - Mineração de Editais\01 - Planejamento de Submissões\1 - Controle de Submissão_.xlsx`

O caminho completo, com o nome da pasta pessoal, está na memória do projeto (ver `reference_pasta_matriz_editais`). A pasta é irmã da pasta matriz de editais e é sincronizada para o Google Drive pela automação de mão única (SOL-0013 e SOL-0018).

## A regra da atividade

A aba **GERAL** é ordenada pelo tempo que falta, do menor para o maior.

1. **DATA LIMITE (coluna F) manda.** É o último dia em que o edital pode ser enviado. É o único campo digitado à mão nessa lógica.
2. **PRAZO (coluna H) é o sinalizador, calculado, nunca digitado.** É quantos dias faltam até a data limite:
   `=SE(OU(F5="Continuo";F5="Contínuo");"Contínuo";F5-HOJE())`
   Como usa `HOJE()`, recalcula sozinho a cada abertura da planilha.
3. **A ordenação é do menor prazo para o maior.** Quem vence antes fica em cima.
4. **Os contínuos ficam separados, em bloco próprio no rodapé.** Não têm data limite, então não entram na contagem regressiva e não podem ser misturados com quem tem prazo. Hoje são três blocos, separados por linha em branco: contínuos gerais, BIP Prosas e o bloco `DIVULGAR`.
5. **A coluna ORDEM (I) é a auxiliar que traduz prazo em posição:**
   `=SE(ÉTEXTO(H3);9999;SE(H3=0;9998;SE(H3<0;ABS(H3);1000+H3)))`
   Contínuo vai para 9999 (fim da fila), vence hoje vai para 9998, vencido entra pelo valor absoluto (o mais antigo primeiro) e o que ainda está no prazo entra como 1000 mais os dias.
6. **O prazo da próxima etapa (coluna N, `=M-HOJE()`) não entra nesta atividade.** Ele mede o andamento interno do trabalho, não o vencimento do edital. Nunca usar essa coluna para ordenar.

## Estrutura da aba GERAL (para não quebrar nada)

Título mesclado em `A1`, cabeçalho na linha 2, dados a partir da linha 3, filtro em `A2:O112`.

| Coluna | Conteúdo |
|---|---|
| A | numeração dentro do bloco (ou o marcador `DIVULGAR`) |
| B a E | nome, descrição, recurso disponível, recurso por projeto |
| F | DATA LIMITE (data ou o texto `Contínuo`) |
| G | link do edital |
| H | PRAZO (calculado a partir de F) |
| I | ORDEM (calculado a partir de H) |
| J, K | cliente e CaptaDrive do cliente |
| L | STATUS (lista suspensa `Lista_Status`, alimentada pela aba `Status`) |
| M, N | próxima etapa e o prazo dela |
| O, P | documentação e observações |

Outras abas: `REPROVADOS` e `EXCLUIDOS` (mesmo layout, arquivo morto), `TABELA DE PROJETOS` (vazia hoje) e `Status` (fonte dos 26 status e das cores).

## Cores (formatação condicional)

- **Coluna H, prazo:** menos de 25 dias, entre 25 e 30, mais de 30 e vence hoje têm cores próprias; `Contínuo` aparece em verde.
- **Coluna L, status:** 26 regras, uma por status, em famílias. Verde para aprovado e derivados, vermelho para reprovado, inelegível e desistência, amarelo e laranja para pendências, azul para andamento (mapeado, pronto, submetido, contrato), roxo para em execução e cinza para encerrado.

## O que conferir a cada reordenação

1. Nenhuma linha com data limite está fora da sequência crescente de prazo.
2. Nenhum contínuo subiu para o bloco dos que têm data, e vice-versa.
3. A fórmula de PRAZO continua na coluna H de toda linha nova (não digitar o número na mão).
4. A fórmula de ORDEM continua na coluna I, sem valor digitado por cima.
5. Fazer backup antes de reordenar, no padrão já usado na pasta: `1 - Controle de Submissão_ (backup antes da {ação} DD-MM-AAAA).xlsx`.

## Pendências conhecidas (11/08/2026)

Levantadas na leitura da planilha e ainda não corrigidas, aguardando decisão da captadora:

- **Essencis Minas está na linha 5**, com prazo de 31 dias, acima de três editais com 2 dias. É a única quebra da ordenação no bloco com data.
- **A coluna ORDEM está pela metade.** Só 21 linhas têm a fórmula. As células `I11` e `I43` receberam por engano uma fórmula que aponta para a coluna G e devolve texto, gerando `#VALOR!`, e a `I36` tem o nome de um cliente digitado dentro dela. Na prática a ordenação está sendo feita manualmente.
- **A formatação condicional da coluna F não funciona.** Três regras foram salvas como texto entre aspas e outras apontam para `#REF!`. Nunca disparam.
- **Linhas vazias mostram um número negativo enorme na coluna H**, porque célula vazia menos `HOJE()` dá isso, e a regra de cor as trata como muito atrasadas. É ruído visual em cerca de mil linhas; some se a fórmula testar se F está vazia antes de calcular.
