---
description: Analisar um edital nos mesmos 8 pontos do /edital-analisar, mas sem OSC vinculada, salvando em editais-avulsos/. Para quando ainda não há organização definida para aquele edital.
---

# /edital-analisar-avulso

Faz a mesma extração técnica do `/edital-analisar` (os 8 pontos que alimentam os 4 agentes), mas fora do contexto de qualquer OSC. Use quando o edital ainda não tem organização definida, ou quando a OSC ativa não é elegível para ele (ex: exige natureza de OSC e a organização é uma empresa; ou não atende a território, área ou tempo de existência exigido) e você quer manter a análise disponível para oferecer a um cliente futuro da carteira, em vez de descartá-la.

Diferente do `/descricao-edital` (ficha de consulta em `.doc`, 15 pontos, para leitura humana), este comando produz o mesmo `.md` de 8 pontos que o `/edital-analisar` grava dentro da pasta de uma OSC, só que numa pasta compartilhada. Ver `editais-avulsos/LEIAME.md` para a comparação completa dos três lugares onde um edital pode existir no sistema.

## Passo 0. Sem contexto de OSC

Não leia `minhas-oscs/.ativa` nem nenhum `perfil-osc.md`. Este comando é intencionalmente desvinculado de qualquer organização.

## Passo 1. Obter o edital

Pergunte como o captador vai fornecer o edital:
1. Colar o texto.
2. Caminho de um PDF na máquina (leia o arquivo).
3. Link do edital (use a leitura de página; se indisponível, peça o texto ou o PDF).

## Passo 2. Anúncio

```
🔍 Próximo passo: analisar o edital e extrair critérios, prazos e exigências (8 pontos). Tempo estimado: 2 a 4 minutos.
```

## Passo 3. Extração

Consulte `.claude/skills/editais-fundamentos/SKILL.md`. Extraia e organize, exatamente os mesmos 8 pontos do `/edital-analisar`:

1. **Identificação.** Órgão, número do edital, objeto, modalidade (termo de fomento, colaboração, chamamento, lei de incentivo).
2. **Quem pode participar.** Natureza jurídica aceita, tempo de existência, território, área temática.
3. **Documentos exigidos** para habilitação.
4. **Valores.** Teto total, teto por item ou categoria, percentuais máximos (pessoal, administrativo), contrapartida exigida.
5. **Despesas permitidas e vedadas.**
6. **Critérios de pontuação** e seus pesos. O que mais pontua e o que derruba nota.
7. **Prazos.** Data e hora de submissão, vigência do projeto, cronograma do edital.
8. **Forma de submissão.** Plataforma (Transferegov, sistema próprio), formato dos anexos, formulário oficial.

Não invente exigência que não esteja no edital; onde algo for ambíguo, marque "verificar no edital".

## Passo 4. Salvamento

1. Garanta que a pasta `editais-avulsos/` exista (crie com o `LEIAME.md` de `editais-avulsos/LEIAME.md` como referência, se ainda não existir).
2. Salve o arquivo em `editais-avulsos/{edital-slug}.md`, com a extração dos 8 pontos.
3. No topo do arquivo, antes do título, inclua um bloco de citação com: se veio de uma OSC descartada por inelegibilidade (explique o motivo em uma frase), e uma linha "Controle no CaptaHub: a preencher pelo Passo 5" (substituída depois de rodar o Passo 5).
4. Informe o caminho.

## Passo 5. Criar ou atualizar o Controle no CaptaHub (nunca escrever na base de editais)

Mesma regra central usada por `/descricao-edital`, `/editais-pasta-processar` e `/edital-minerar` (SOL-0007, `.claude/rules/decisoes-tecnicas.md`). A base de editais é do CaptaHub, a AMC IA nunca escreve nela; a operação de escrita válida é abrir ou atualizar um **Controle** no pipeline.

```
🔍 Próximo passo: resolver duplicidade e abrir (ou atualizar) o Controle no CaptaHub (cerca de 30 segundos).
```

1. Monte os campos do edital no formato do CaptaHub (`title`, `institution`, `category`, `scope`, `value`, `deadline`, `is_continuous`, `url`, `description`, `tags`, ver `docs/integracao-captahub-api.md` seção 3.1) a partir do que já foi extraído nos 8 pontos.
2. Rode o resolvedor central:
   ```
   python3 scripts/controle-resolver.py --titulo "{title}" --category "{category}" --scope "{scope}" --uf "{uf, se o escopo for Municipal/Estadual e o edital tiver UF}" --description "{description}" --tags "{tags separadas por vírgula}"
   ```
   Leia o bloco `=== JSON ===` da saída.
3. **Se `duplicado: true`:** não crie um novo Controle. Use `controle_existente.id` na entrega. Se `sugerir_backfill_edital_id: true` e você já tiver um `edital_id` real do catálogo do CaptaHub, rode `python3 scripts/captahub-api.py projeto-atualizar --id {controle_existente.id} --edital-id {edital_id}`.
4. **Se `duplicado: false`:** crie o Controle na etapa e no vínculo sugeridos pelo resolvedor:
   ```
   python3 scripts/captahub-api.py controle-criar --nome "{title}" --status {status_sugerido} {--cliente-id {candidato_osc.id} se vincular_automaticamente=true} --edital-json '{json com os campos do passo 1}'
   ```
   Leia o bloco `=== JSON ===` e guarde o `id` retornado.
5. **Sempre que um Controle novo foi criado**, acrescente um registro em `editais-para-cadastrar/controles-criados.json` (leia o array existente e acrescente; crie com `[]` se não existir) com: `controle_id`, os campos do edital, `osc_vinculada` (nome e id, ou `null`), `origem_arquivo` (caminho do `.md` salvo no Passo 4), `criado_em` (data de hoje).
6. Atualize a linha "Controle no CaptaHub" no topo do arquivo salvo no Passo 4 com o `id` retornado (ou com "já existia, id {id}", ou "CaptaHub não conectado, ficha só local").
7. Se o CaptaHub não estiver conectado (sem token), pule este passo inteiro e avise que a ficha ficou só local.

## Passo 6. Entrega

Informe o caminho absoluto do `.md` salvo. Depois, em uma linha, o resultado do Passo 5, no mesmo padrão do `/descricao-edital`:
- se já existia um Controle: "já existe um Controle para este edital no CaptaHub (id {id}), nenhum novo foi criado";
- se foi criado sem vínculo: "Controle criado no CaptaHub, na etapa Encontrar cliente (id {id})";
- se foi criado com vínculo automático (aderência ALTA): "Controle criado no CaptaHub, já vinculado a {nome da OSC} e na etapa Selecionado (id {id})";
- se não conectado: "CaptaHub não conectado, ficha gerada só localmente".

Lembre que, quando o captador escolher uma OSC compatível para este edital, o arquivo deve ser copiado para `minhas-oscs/{osc}/projetos/{edital-slug}/edital.md` e o fluxo normal retomado a partir de `/projeto-elegibilidade` (Gate de Elegibilidade, sempre antes de qualquer proposta).

## Regras

- Não invente exigência que não esteja no edital.
- Português correto, sem travessão.
- Nunca leia nem grave nada dentro de `minhas-oscs/` a partir deste comando. A busca de OSC compatível no resolvedor usa só a carteira via API do CaptaHub, nunca os perfis locais.
- Nunca tente `POST /v1/editais` nem qualquer escrita na base de editais. A única operação de escrita válida para um edital novo é `controle-criar`.
- Nunca diga que o edital "foi cadastrado no CaptaHub". O que existe é um Controle (cartão de pipeline) aberto para ele, ainda sem OSC vinculada (a menos que a aderência automática tenha vinculado uma).
