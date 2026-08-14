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
3. **A ordenação é do menor prazo para o maior**, entre os editais ainda abertos. Quem vence antes fica em cima, e quem vence hoje fica no topo.
4. **Os contínuos ficam separados, em bloco próprio, depois dos abertos.** Não têm data limite, então não entram na contagem regressiva e não podem ser misturados com quem tem prazo. Na GERAL são três blocos separados por linha em branco: contínuos gerais, BIP Prosas e o bloco `DIVULGAR`.
5. **O que já venceu desce para o rodapé**, depois dos contínuos, do vencimento mais recente para o mais antigo. Decidido pela captadora em 11/08/2026: o que ainda dá para enviar tem que aparecer primeiro, e o vencido vira histórico. Quem não tem data limite nenhuma fica por último, para ela preencher.
6. **A coluna ORDEM (I) é a auxiliar que traduz prazo em posição:**
   `=SE(H3="";"";SE(ÉTEXTO(H3);5000;SE(H3>=0;H3;6000+ABS(H3))))`
   Aberto entra pelos dias que faltam (0 a 4999), contínuo vira 5000 e vencido vira 6000 mais os dias de atraso. Assim a coluna oculta sempre concorda com a ordem que está na tela.
7. **O prazo da próxima etapa (coluna N, `=M-HOJE()`) não entra nesta atividade.** Ele mede o andamento interno do trabalho, não o vencimento do edital. Nunca usar essa coluna para ordenar.

## Reposicionamento imediato (regra permanente)

> Definida pela captadora em 11/08/2026.

Sempre que ela lançar um edital novo na planilha e a data limite ficar fora da ordem de dias restantes, **reposicionar a linha na hora, sem perguntar**. Não deixar a correção para uma passada de arrumação depois: a lista precisa estar sempre lida de cima para baixo como fila de urgência.

Como aplicar:
1. Ao mexer na planilha por qualquer motivo, conferir o bloco com data (hoje, linhas 5 em diante) e ver se os prazos sobem sem quebra.
2. Achou uma linha fora de ordem, mover o registro inteiro (colunas A a P, incluindo o link do edital com o hiperlink) para a posição correta, empurrando as demais.
3. Não arrastar as colunas H, I e N junto: elas são fórmulas presas à própria linha e se refazem sozinhas na posição nova.
4. Edital sem data (`Contínuo`) nunca entra nesse bloco; vai para o bloco de contínuos, no rodapé.
5. Avisar em uma linha o que foi movido e para onde.

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

## Correções aplicadas em 11/08/2026

Backup em `1 - Controle de Submissão_ (backup antes das correcoes 11-08-2026).xlsx`, na mesma pasta.

- **Essencis Minas voltou para a posição certa.** Estava na linha 5 com prazo de 31 dias, acima de três editais com 2 dias. Foi para a linha 15, entre o FSA/BRDE (24 dias) e o MINAS LIGA (50 dias). O bloco inteiro, da linha 5 à 25, ficou em ordem crescente.
- **A fórmula de ORDEM foi restaurada nas linhas 3 a 300.** Antes só 21 linhas tinham fórmula; as células `I11` e `I43` traziam uma fórmula errada apontando para a coluna G, que devolvia `#VALOR!`. O nome "Ponto Cultural", que estava digitado dentro da `I36`, foi movido para a `J36` (CLIENTE), que é o lugar dele.
- **As 9 regras de cor mortas da coluna F foram removidas.** Eram fórmulas salvas como texto entre aspas ou apontando para `#REF!`, que nunca disparavam. As 32 regras vivas (prazo e status) continuam intactas.
- **As fórmulas de PRAZO (H) e do prazo da próxima etapa (N) passaram a testar se a data está vazia antes de calcular.** Linha em branco agora fica em branco, no lugar do número negativo gigante que aparecia em quase mil linhas.

Fórmulas em vigor depois da correção:

```
H   =SE(F5="";"";SE(OU(F5="Continuo";F5="Contínuo";F5="CONTINUO";F5="CONTÍNUO";F5="Contìnuo");"Contínuo";F5-HOJE()))
I   =SE(H5="";"";SE(ÉTEXTO(H5);5000;SE(H5>=0;H5;6000+ABS(H5))))
N   =SE(M5="";"";M5-HOJE())
```

A fórmula de ORDEM acima substituiu, em 11/08/2026, a versão anterior (`...SE(H5<0;ABS(H5);1000+H5)`), que mandava todo edital vencido para cima de qualquer edital aberto. Na GERAL o defeito nunca apareceu, porque lá não fica edital vencido; nas planilhas dos clientes, que são histórico, ele colocava o vencido há três meses na frente do que fecha amanhã.

A coluna I (ORDEM) é oculta na planilha. Ela funciona como motor da ordenação, não como informação de tela.

## As planilhas dos clientes (aplicado em 11/08/2026)

A mesma configuração vale para a planilha `1 - Controle de Submissão.xlsx` de cada cliente, dentro de `06 - Clientes\{NN} - CaptaDrive - {cliente}\`, na aba **SUBMISSÕES**. São 18. Backup de todas em `06 - Clientes\_Backup planilhas 11-08-2026\`.

Diferenças em relação à GERAL, que precisam ser respeitadas por qualquer script futuro:

- **Não existe a coluna DOCUMENTAÇÃO.** Depois de PRÓXIMA ETAPA vem o prazo dela e OBS, e acabou.
- **A coluna A é NÚMERO**, mas não é posição: em alguns clientes tem furo na sequência (o Ponto Cultural vai 1, 2, 3, 6, 5, 6...). É identificador do registro, então **anda junto com a linha** quando reordena. Nunca renumerar.
- **A STK Produções tem uma coluna vazia a mais no meio**, então o prazo da próxima etapa fica em O, não em N. Localizar as colunas pelo texto do cabeçalho, nunca pela letra fixa.
- **A lista de status tem 27 opções**, os 25 da GERAL mais `Selecionado` e `Recurso`, que só aparecem nas planilhas de cliente. Cada arquivo ganhou a sua aba `Status` e o intervalo nomeado `Lista_Status`.
- **Linhas vazias com status preenchido.** Cerca de 900 linhas sem edital nenhum trazem `Selecionado` de um preenchimento antigo. Foram mantidas, a pedido da captadora de não apagar nada.
- **As posições das linhas foram preservadas.** A reordenação trocou os registros entre as linhas que já ocupavam, sem compactar. No Ponto Cultural, que tem registros espalhados, sobraram dois contínuos lá nas linhas 99 e 100.

Cuidado que gerou perda e não pode se repetir: duas linhas da Almira Lopes tinham uma **data digitada dentro da coluna de cálculo PRAZO**, com PRÓXIMA ETAPA vazia. Ao instalar a fórmula, a data foi sobrescrita. Foi recuperada do backup e devolvida para PRÓXIMA ETAPA. **Antes de escrever fórmula por cima de qualquer coluna calculada, varrer a coluna atrás de valor que não seja derivável** (data, texto, número digitado à mão) e decidir o destino de cada um. Vale a mesma lição do formato: a célula que recebe a fórmula precisa voltar para o formato Geral, senão herda o formato de data do valor antigo e mostra 1900-05-10 no lugar de 131 dias.

## Pendências que ficaram

- As abas **REPROVADOS** e **EXCLUIDOS** têm as mesmas regras de cor mortas na coluna F e a mesma fórmula de prazo sem proteção contra linha vazia. Como são arquivo morto, ficaram sem mexer. Corrigir se um dia essas abas voltarem a ser consultadas.

## Armadilha de acento ao comparar em Python

`"ontinu" in texto.lower()` **não** encontra `Contínuo`, porque o `í` acentuado não é o `i` do padrão. Esse erro classificou contínuos acentuados como "sem data limite" e os jogou para o fim da planilha, num primeiro passe da configuração dos clientes. Na base convivem quatro grafias reais: `Contínuo`, `Continuo`, `CONTÍNUO` e `Contìnuo` (esta com crase, provável erro de digitação).

Qualquer comparação de texto em português neste projeto deve tirar o acento antes de comparar:

```python
import unicodedata
def sem_acento(s):
    return "".join(c for c in unicodedata.normalize("NFD", s)
                   if unicodedata.category(c) != "Mn").lower()
```

A fórmula do Excel não tem esse problema porque lista as grafias uma a uma, mas ela também quebra se aparecer uma quinta grafia. Ao encontrar grafia nova, acrescentar à fórmula.

## Links do edital (coluna G). Conferência obrigatória ao reordenar

> Corrigido em 14/08/2026. Registro técnico completo em `.claude/rules/decisoes-tecnicas.md`, SOL-0024.

No Excel, o endereço escrito na célula e o destino do clique são guardados em lugares separados: o destino fica preso ao endereço da célula (`G43`), não ao conteúdo. Mover, inserir ou apagar linha faz o texto andar e o link ficar parado, e o clique passa a abrir o endereço da linha vizinha.

Regra: **o clique tem que abrir exatamente o endereço escrito na célula.** Sempre que reordenar a planilha, conferir esse par nas colunas que guardam link (G principalmente, mas também J, K, O e P, que já tiveram link).

Ao mover linha, usar recortar e "Inserir células recortadas", que leva o link junto. Copiar e colar o conteúdo deixa o link para trás, e é a origem do problema.

Onde o texto da célula é um título de página e não um endereço (Floresta Viva, Consulado do Japão, Ambipar, Sispro do Ibama, Brasilidades & Futuros), o link é deliberado e não deve ser reescrito automaticamente: conferir um a um.
