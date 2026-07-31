---
description: Gerar uma ficha descritiva avulsa de um edital, em .doc para download, sem vincular a nenhuma OSC. Cobre execução, prestação de contas e comunicação.
---

# /descricao-edital

Produz uma ficha descritiva completa de um edital específico, avulsa e sem vínculo com nenhuma OSC ativa, entregue como documento `.doc` pronto para baixar. Diferente do `/edital-analisar` (que alimenta os 4 agentes na pasta da OSC), este comando serve para consulta rápida e independente: por exemplo, quando o captador só quer entender as regras de um edital antes de decidir se vale a pena buscar uma OSC para ele, ou quando precisa checar rapidamente as regras de execução e prestação de contas.

## Passo 0. Sem contexto de OSC

Não leia `minhas-oscs/.ativa` nem nenhum `perfil-osc.md`. Este comando é intencionalmente desvinculado de qualquer organização.

## Passo 1. Obter o edital

Pergunte como o captador vai fornecer o edital:
1. Colar o texto.
2. Caminho de um PDF na máquina (leia o arquivo).
3. Link do edital (use a leitura de página; se indisponível, peça o texto ou o PDF).

## Passo 2. Anúncio

```
🔍 Próximo passo: montar a ficha descritiva do edital (15 pontos). Tempo estimado: 2 a 4 minutos.
```

## Passo 3. Extração

Consulte `.claude/skills/editais-fundamentos/SKILL.md`. Extraia e organize, sempre ancorado no texto do edital (marque "verificar no edital" quando algo for ambíguo):

1. **Identificação.** Órgão, número do edital, objeto do projeto (em destaque, com uma frase clara do que o edital financia), modalidade, categorias.
2. **Quem pode participar.** Natureza jurídica ou pessoal aceita, tempo de existência, território, área temática, quem está impedido.
3. **Quantas propostas por proponente e quantas serão selecionadas.** Responda com números precisos e a fonte exata no edital:
    - Quantas propostas a mesma organização (ou pessoa física/MEI) pode submeter nesta edição. O que acontece se enviar mais de uma (prevalece a última? é desclassificada?).
    - Se há limite de propostas simultâneas em execução ou aprovadas no mesmo período (somando outras fontes do mesmo órgão, quando o edital mencionar).
    - Quantas propostas serão selecionadas ao todo, e a distribuição por categoria, linha, eixo ou região, quando houver.
    Se o edital não trouxer algum desses números, registre como lacuna ("não informado no edital, verificar com o órgão"), não deixe em branco.
4. **Eixos principais e transversais para a elaboração do projeto.** Informação precisa, não genérica:
    - Eixos, linhas, categorias ou temas principais em que o edital se organiza, com a descrição literal de cada um (não parafraseie a ponto de perder a precisão).
    - Eixos ou critérios transversais que atravessam todas as categorias (ex: recorte de gênero, raça, território, ações afirmativas, sustentabilidade, acessibilidade) e que pesam na aprovação, mesmo sem serem o tema central.
    - Se o edital não usa a palavra "eixo" (ex: organiza por categoria, linha de ação ou modalidade), não invente o termo: identifique a estrutura equivalente que o edital de fato usa e diga isso explicitamente.
    - Feche esta seção com a frase: "o que será levado em consideração para a aprovação do projeto", listando de forma objetiva os pontos que a banca ou comissão avalia.
5. **Documentos exigidos** para inscrição e para habilitação.
6. **Valores.** Teto total, teto por item ou categoria, percentuais, contrapartida exigida, tributos.
7. **Despesas permitidas e vedadas.**
8. **Quadro de avaliação e pontuação dos critérios, sempre de forma discriminada.** Monte uma tabela (markdown, vira quadro no documento) com as colunas: Bloco | Critério | Faixa ou detalhe | Pontuação. **Discriminada significa: cada subcritério em sua própria linha, com sua própria pontuação.** Nunca agrupe subcritérios num único texto com parênteses (proibido escrever algo como "Conceito, conteúdo e relevância: 15 pts (conceito 5 + conteúdo 5 + relevância 5)"; o correto é uma linha para "Conceito" com 5 pts, outra para "Conteúdo" com 5 pts, outra para "Relevância" com 5 pts). O mesmo vale para faixas de uma mesma variável (ex: tempo de atuação, IDHM, faixa de população): cada faixa é sua própria linha, com o intervalo exato e a pontuação exata daquela faixa, nunca resumido em uma frase solta. Inclua todos os critérios com peso, a pontuação total possível, a nota de corte para aprovação (quando houver) e, em seguida, os critérios de desempate em ordem. Se o edital não detalhar pesos, registre isso como lacuna.
    - **Exigência operacional específica, obrigatória em todo edital: verificar se algum critério de pontuação ou elegibilidade depende de uma base de cálculo externa e variável** (IDHM do município, faixa de população do IBGE, renda per capita, outro índice social ou territorial, tabela de desconto de imposto). Esse tipo de critério muda de edital para edital, então não vale citar de forma genérica ("quanto menor, mais pontua"): é preciso extrair a tabela real, com as faixas e os valores exatos, e indicar qual documento ou fonte de dado prevalece para apurá-la (ex: o comprovante de endereço, não o campo apenas digitado no formulário). Se o edital não tiver nenhuma base de cálculo externa, registre isso explicitamente ("não há bases de cálculo externas variáveis neste edital").
9. **Prazos.** Submissão, resultado, recurso, habilitação, pagamento, execução, prestação de contas.
10. **Forma de submissão.** Plataforma, cadastros complementares exigidos, formato dos anexos.
11. **Execução e contratação.** O que pode e não pode ser pago com o recurso, limites de remanejamento, regras de readequação.
12. **Prestação de contas.** O que precisa ser apresentado, prazo, canal oficial, tempo de guarda dos documentos.
13. **Comunicação e divulgação.** Exigências de menção ao apoio recebido, uso de logomarca, prazos de aprovação de material, penalidade por descumprimento.
14. **Pontos de atenção e detalhes críticos.** Releia o edital procurando especificamente por regras que não saltam aos olhos numa leitura corrida, mas que custam pontos, desclassificam ou inabilitam. Procure em particular por:
    - Exigências de **comprovante de residência/domicílio/sede**: quantos documentos, janela de validade de cada um, de quem deve estar em nome, e se o município do comprovante prevalece sobre o que foi apenas declarado (risco de perda de pontos ou desclassificação por divergência).
    - Critérios de pontuação que funcionam ao **contrário do intuitivo** (ex: quanto menor o IDHM ou a população, mais pontos); a tabela real desse tipo de critério já deve ter sido extraída na seção 8, aqui só reforce o risco de leitura apressada.
    - Valores que precisam **fechar exatamente** (sem margem de arredondamento) em vez de "até o teto".
    - Limites de **quantidade de propostas simultâneas ou por ano** por proponente.
    - Itens cuja **ausência sozinha já desclassifica** (ex: contrapartida não indicada quando obrigatória).
    - Regras sobre **onde o recurso pode circular** (conta exclusiva, vedação de mistura de fontes).
    - Quando a inscrição é por **MEI, empresário individual ou CNPJ de fachada**, se os requisitos pessoais (idade, tempo de atuação, gênero, domicílio) recaem sobre o titular pessoa física ou sobre a empresa.
    - Situações cadastrais externas (SIAFI, Cadin, CAFIMP e similares) que travam a habilitação mesmo com documentação pessoal em ordem.
    Se não encontrar nenhum item desse tipo, registre isso explicitamente ("nenhum ponto de atenção adicional identificado além dos já cobertos nas seções anteriores") em vez de omitir a seção.
15. **Ponto indispensável fora do descritivo.** Releitura final, de fechamento: existe alguma exigência, regra ou condição indispensável para a aprovação do projeto que não se encaixou em nenhuma das 14 seções anteriores? Traga aqui, de forma explícita. Se a revisão não encontrar nada além do que já foi coberto, registre isso claramente ("revisão final feita; nenhum ponto indispensável adicional além do já coberto nas seções 1 a 14") em vez de omitir a seção.

## Passo 4. Geração do documento

1. Monte o conteúdo em markdown com as 15 seções acima.
2. Converta para `.doc` reaproveitando as funções `md_para_html` e `doc_word` de `scripts/exportar-projeto.py` (importe o módulo via `importlib`, não copie o código).
3. Garanta que a pasta `Descrição Editais/` exista na raiz do projeto (crie se não existir).
4. Salve o arquivo em `Descrição Editais/{edital-slug}.doc`.

## Passo 5. Criar ou atualizar o Controle no CaptaHub (nunca escrever na base de editais)

A ficha avulsa continua existindo e sendo salva localmente (Passo 4), isso não muda. **Regra de arquitetura, absoluta:** a base de editais é administrada pelo próprio CaptaHub; a AMC IA nunca escreve nela (não existe `POST /v1/editais` nem qualquer variante, e não deve ser tentado). O que a AMC IA faz é abrir (ou atualizar) um **Controle** no pipeline do CaptaHub para esse edital, seguindo a regra de negócio central do SOL-0007 (`.claude/rules/decisoes-tecnicas.md`), a mesma usada por `/editais-pasta-processar` e `/edital-minerar`.

```
🔍 Próximo passo: resolver duplicidade e abrir (ou atualizar) o Controle no CaptaHub (cerca de 30 segundos).
```

1. Monte os campos do edital no formato do CaptaHub (`title`, `institution`, `category`, `scope`, `value`, `deadline`, `is_continuous`, `url`, `description`, `tags`, ver `docs/integracao-captahub-api.md` seção 3.1) a partir do que já foi extraído nas seções 1 a 15.
2. **Rode o resolvedor central** (dedup + compatibilidade + decisão de etapa, num único lugar reutilizado pelas três origens):
   ```
   python3 scripts/controle-resolver.py --titulo "{title}" --category "{category}" --scope "{scope}" --uf "{uf, se o escopo for Municipal/Estadual e o edital tiver UF}" --description "{description}" --tags "{tags separadas por vírgula}"
   ```
   Leia o bloco `=== JSON ===` da saída.
3. **Se `duplicado: true`:** não crie um novo Controle. Use `controle_existente.id` na entrega. Se `sugerir_backfill_edital_id: true` e você já tiver um `edital_id` real do catálogo do CaptaHub para este edital, rode `python3 scripts/captahub-api.py projeto-atualizar --id {controle_existente.id} --edital-id {edital_id}` para completar o vínculo. Não tente enriquecer outros campos do Controle existente agora (Descrição, Prazo, Categoria etc. dependem da sincronização com a tela "Editar Controle", ainda pendente de decisão, ver SOL-0007).
4. **Se `duplicado: false`:** crie o Controle já na etapa e no vínculo sugeridos pelo resolvedor:
   ```
   python3 scripts/captahub-api.py controle-criar --nome "{title}" --status {status_sugerido} {--cliente-id {candidato_osc.id} se vincular_automaticamente=true} --edital-json '{json com os campos do passo 1}'
   ```
   Leia o bloco `=== JSON ===` da saída e guarde o `id` retornado.
5. **Guardar os dados extraídos localmente, sempre que um Controle novo foi criado.** O CaptaHub aceita o campo `edital` enviado, mas hoje não persiste nenhum subcampo dele (confirmado em teste real: `edital_id` volta `null`). Por isso, acrescente um registro em `editais-para-cadastrar/controles-criados.json` (leia o array existente e acrescente; crie o arquivo com `[]` se ainda não existir) com: `controle_id` (o id retornado), todos os campos do edital (passo 1), `osc_vinculada` (nome e id, se `vincular_automaticamente` foi true, ou `null`), `origem_arquivo` (caminho do `.doc` gerado no Passo 4), `criado_em` (data de hoje).
6. Se o CaptaHub não estiver conectado (sem token), pule este passo inteiro e avise que a ficha ficou só local, sem Controle criado ou atualizado.

## Passo 6. Entrega

Informe o caminho absoluto do `.doc` salvo. Depois, em uma linha, o resultado do Passo 5:
- se já existia um Controle (`duplicado: true`): "já existe um Controle para este edital no CaptaHub (id {id}), nenhum novo foi criado";
- se foi criado sem vínculo: "Controle criado no CaptaHub, na etapa Encontrar cliente (id {id})";
- se foi criado com vínculo automático (aderência ALTA): "Controle criado no CaptaHub, já vinculado a {nome da OSC} e na etapa Selecionado (id {id})";
- se não conectado: "CaptaHub não conectado, ficha gerada só localmente".

Não sugira `/projeto-elegibilidade` nem qualquer fluxo de OSC, a menos que o captador peça.

## Regras

- Não invente exigência que não esteja no edital.
- Português correto, sem travessão.
- Nunca leia nem grave nada dentro de `minhas-oscs/`. A busca de OSC compatível usa só a carteira via API do CaptaHub (`clientes`), nunca os perfis locais.
- **Nunca tente `POST /v1/editais` nem qualquer escrita na base de editais.** A única operação de escrita válida para um edital novo é `controle-criar` (que por baixo chama `POST /v1/projetos`, a mesma rota do botão "Novo Controle").
- Nunca diga que o edital "foi cadastrado no CaptaHub" — o que existe é um Controle (cartão de pipeline) aberto para ele, ainda sem OSC vinculada.