# Registro de Atividades. Sessão de 28/07/2026

> Documento de referência interna. Registra o que foi pedido, o que foi feito e o que mudou nesta sessão de trabalho, para consulta futura caso seja preciso entender uma decisão tomada ou retomar o que ficou pendente.

**Tema da sessão:** criação e aprofundamento da apostila de comandos da AMC IA.

---

## Resumo em uma linha

A apostila de comandos (`docs/apostila-comandos-amc-ia`) foi atualizada com os 2 comandos que faltavam e depois reescrita do zero num formato bem mais detalhado, com um capítulo completo por comando, nos três formatos (`.md`, `.html`, `.pdf`).

---

## Linha do tempo

### 1. Pedido inicial

O captador pediu uma apostila com todos os comandos do sistema e suas funções bem discriminadas, para saber tudo o que é possível fazer com a AMC IA.

### 2. Levantamento do que já existia

Antes de criar algo novo, foi conferido o que já existia no projeto:

- Em `.claude/commands/`, foram encontrados **24 comandos** cadastrados no sistema.
- Em `docs/`, já existia uma apostila de comandos (`apostila-comandos-amc-ia.md`, `.html` e `.pdf`), de uma sessão anterior, cobrindo **22 comandos**.
- Comparando a lista de comandos reais com o conteúdo da apostila, foram identificados **2 comandos que faltavam**: `/descricao-edital` e `/editais-pasta-processar`.

### 3. Primeira atualização (referência rápida)

A apostila existente foi atualizada, sem recriar do zero, para incluir os 2 comandos que faltavam:

- Adicionada uma linha para `/descricao-edital` e outra para `/editais-pasta-processar` na tabela da Área 2 (Editais).
- Atualizada a tabela de perguntas rápidas ("Quero fazer X, qual comando uso?") com as duas novas entradas.
- A mesma alteração foi replicada no `.html` (mantendo o mesmo estilo visual navy/verde já usado) e o `.pdf` foi regenerado a partir do HTML, usando o Google Chrome em modo headless (`chrome.exe --headless=new --print-to-pdf`).

Neste ponto, a apostila cobria os 24 comandos, mas ainda no formato de referência rápida (tabela com duas frases por comando: "para que serve" e "quando usar").

### 4. Confirmação do caminho salvo

O captador perguntou se o PDF havia sido salvo no lugar certo para imprimir e compartilhar. Foi confirmado o caminho absoluto do arquivo:

```
docs/apostila-comandos-amc-ia.pdf
```

### 5. Esclarecimento: atualização ou duplicação

O captador perguntou se a apostila anterior tinha sido substituída ou se uma nova havia sido criada ao lado. Foi esclarecido que:

- Os arquivos existentes (`.md`, `.html`, `.pdf`) foram **editados no mesmo lugar**, sem duplicar nada.
- Na pasta `docs/` existem outras apostilas, de temas diferentes, que não foram tocadas: `apostila-metodo-captar`, `apostila-treinamento-captahub` e `manual-captahub`.

### 6. Avaliação honesta do nível de detalhe

O captador perguntou se a apostila explicava bem cada comando, com detalhe. Foi respondido com honestidade que o formato de tabela (duas frases por comando) era bom como referência rápida, mas não descriminava:

- as perguntas da entrevista de cada comando (o passo a passo);
- o que exatamente cada agente entrega e em que formato;
- as dependências e travas entre comandos (ex: o Gate de Elegibilidade);
- o caminho exato de onde cada arquivo é salvo;

Foi oferecida a opção de reescrever a apostila com um capítulo completo por comando, com exemplo de como ficaria (preview), e o captador escolheu essa opção.

### 7. Levantamento completo do conteúdo de cada comando

Para poder descrever cada comando com precisão, os 24 arquivos de comando em `.claude/commands/` foram lidos por completo (não apenas o início, como na primeira passada), extraindo de cada um:

- o objetivo declarado no `description` do cabeçalho;
- o contexto que o comando lê antes de agir (arquivos, variáveis de ambiente);
- o passo a passo real da entrevista e da execução;
- o formato exato do entregável;
- o caminho onde o arquivo final é salvo;
- as regras e travas específicas daquele comando.

### 8. Reescrita completa da apostila

A apostila foi reescrita do zero nos três formatos, agora com um capítulo por comando (24 capítulos), organizados nas mesmas 7 áreas temáticas de antes (Organização, Editais, Projeto/4 agentes, CaptaHub, Marketing do captador, Venda e prestação do serviço, Apoio e sistema), seguidas das tabelas de referência (agentes especialistas, bases de conhecimento, fluxo completo do projeto e perguntas rápidas).

Cada capítulo de comando segue sempre a mesma estrutura fixa:

1. **Para que serve.** A função em uma frase.
2. **Quando usar.** O momento certo de digitar o comando.
3. **Contexto que ele lê.** O que o sistema consulta antes de começar.
4. **Passo a passo.** As perguntas e ações, na ordem real.
5. **O que entrega.** O conteúdo e a estrutura do entregável.
6. **Onde salva.** O caminho exato do arquivo.
7. **Travas e dependências.** O que precisa existir antes, e o que trava o comando.
8. **Próximo passo sugerido.** Para onde ir depois.

O arquivo `.html` foi reconstruído mantendo a mesma identidade visual da versão anterior (paleta navy/verde, tipografia, cabeçalho de área), adaptada para comportar o conteúdo mais longo por comando (blocos rotulados em vez de apenas linhas de tabela).

### 9. Geração do PDF e um problema técnico encontrado

Ao gerar o PDF pela segunda vez (a partir do HTML expandido), o arquivo resultante saiu suspeito: exatamente o mesmo tamanho em bytes da geração anterior (24.927 bytes), mesmo o conteúdo tendo crescido bastante. A investigação mostrou que:

- O caminho da pasta do projeto contém um espaço no nome (`OneDrive - Organizacao Multidisciplinar De Voluntariado E-missao`).
- O Google Chrome, em modo headless, ao receber essa URL `file://` com espaço, falhava silenciosamente (sem erro visível no terminal) e gerava um PDF de apenas **1 página**, quase vazio.
- O teste de diagnóstico foi copiar o mesmo HTML para uma pasta temporária sem espaço no caminho e gerar o PDF a partir de lá: o resultado saiu correto, com **8 páginas** e cerca de 500 KB.
- O PDF correto foi então copiado de volta para `docs/apostila-comandos-amc-ia.pdf`, substituindo o incompleto.

**Nota técnica para o futuro:** qualquer geração de PDF via Chrome headless neste projeto deve evitar passar o caminho da OneDrive diretamente na URL `file://`. O caminho seguro é gerar num diretório temporário sem espaços (ex: a pasta de scratchpad da sessão) e depois copiar o resultado para o destino final em `docs/` ou na pasta do projeto correspondente.

### 10. Conferência final

Foi confirmado, via `git status`, que apenas os três arquivos da apostila de comandos foram alterados nesta sessão:

```
M docs/apostila-comandos-amc-ia.html
M docs/apostila-comandos-amc-ia.md
M docs/apostila-comandos-amc-ia.pdf
```

Nenhuma alteração foi commitada (a sessão não incluiu nenhum pedido de commit).

---

## O que foi entregue

| Arquivo | Descrição | Situação |
|---|---|---|
| `docs/apostila-comandos-amc-ia.md` | Apostila completa, um capítulo por comando (24 comandos) | Atualizado |
| `docs/apostila-comandos-amc-ia.html` | Mesma apostila, formatada para abrir no navegador | Atualizado |
| `docs/apostila-comandos-amc-ia.pdf` | Mesma apostila, em PDF (8 páginas), pronta para imprimir ou compartilhar | Atualizado (corrigido o bug do PDF incompleto) |

---

## Comandos que passaram a constar na apostila (não estavam na versão anterior)

- `/descricao-edital`. Ficha descritiva avulsa de um edital, em `.doc`, sem vínculo com nenhuma OSC.
- `/editais-pasta-processar`. Leitura em lote da pasta `editais-para-cadastrar/`, checagem de duplicidade e preparação do cadastro no CaptaHub.

---

## Pendências ou próximos passos, se houver

Nenhuma pendência em aberto desta sessão. Se novos comandos forem criados no futuro em `.claude/commands/`, a apostila precisará ser atualizada manualmente (não há automação de sincronização entre os comandos do sistema e este documento).
