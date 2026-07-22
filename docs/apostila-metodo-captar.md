# Apostila do Negócio da Captação

> Apostila dividida em partes. Cobre o método de trabalho do captador, não a ferramenta (para a ferramenta, ver `docs/apostila-treinamento-captahub.md`).

---

## PARTE 1. O Método Captar

### 1.1 O que é o Método Captar

O Método Captar 2.0 é a metodologia do Portal do Captador (Johnatan e David) que organiza a captação de recursos do zero até a assessoria virar negócio recorrente. Ele está para a captação assim como uma metodologia de vendas está para o comercial: dá um passo a passo replicável, em vez de depender de "sorte" ou "jeito" de cada captador.

O método organiza o trabalho em **3 fases** e **10 pilares**, do encontrar o edital certo até renovar o contrato de assessoria com a OSC:

```
FASE 1. CAPTAR       -> dominar a técnica com IA (pilares 1 a 4)
FASE 2. POSICIONAR   -> marketing do captador como profissional (pilares 5 a 7)
FASE 3. ASSESSORAR   -> entregar, faturar e renovar (pilares 8 a 10)
```

Mantras do método, repetidos pela comunidade do Portal do Captador: "está no edital", "feito é melhor que perfeito", "confia no processo", "direção é mais importante que velocidade", "não seja o avestruz".

### 1.2 Fase 1. CAPTAR (dominar a técnica com IA)

É a fase técnica: transformar um edital em um projeto aprovado. Tem 4 pilares, e cada um resolve um dos quatro motivos mais comuns de reprovação.

**Pilar 1. Mineração.** Encontrar os editais certos para o perfil da OSC, filtrando por escopo (municipal, estadual, nacional, internacional), valor, prazo, área temática e natureza do proponente exigida. Elimina a garimpagem manual em Diário Oficial, sites de prefeitura ou grupos de WhatsApp.

**Pilar 2. Requisito.** Validar a elegibilidade da OSC antes de escrever qualquer proposta. Cruza os critérios do edital com o perfil da organização (natureza jurídica, tempo de existência, território, área de atuação, certidões e documentos obrigatórios). Veredito: APTO, APTO COM PENDÊNCIAS ou INAPTO. **Este é o Gate de Elegibilidade**, a regra de maior prioridade do método: nunca se escreve uma proposta antes de passar por aqui, porque o erro mais caro do captador é gastar semanas escrevendo um projeto para uma OSC que nunca poderia ganhar aquele edital.

**Pilar 3. Projeto.** Elaborar a proposta com estrutura técnica profissional, bloco a bloco, sempre ancorada nos critérios do edital, e montar o orçamento detalhado por rubrica, com memória de cálculo, dentro das regras financeiras do edital.

**Pilar 4. Submissão.** Antes de submeter, auditar a proposta cruzando com os critérios do edital, receber nota por item, estimativa de chance de aprovação por fase e a lista do que melhorar, e reescrever os campos mais críticos.

### 1.3 Fase 2. POSICIONAR (marketing como captador profissional)

É a fase de se tornar visível e vendável como assessor de captação. Tem 3 pilares:

**Pilar 5. Audiência.** Montar presença digital (site, redes sociais) e se posicionar como referência em captação, para atrair OSCs como clientes.

**Pilar 6. Assessoria.** Estruturar o serviço: definir escopo, precificar (faixa de R$ 3.000 a R$ 8.000 por proposta avulsa, ou contrato anual de R$ 20.000 a R$ 30.000), montar a proposta comercial.

**Pilar 7. Oferta.** Conduzir a reunião consultiva com a OSC prospectada, apresentar o serviço, responder objeções e fechar o contrato.

### 1.4 Fase 3. ASSESSORAR (entregar, faturar, renovar)

É a fase de operar a assessoria como negócio de verdade. Tem 3 pilares:

**Pilar 8. Prospecção.** Identificar e abordar sistematicamente organizações com perfil para contratar a assessoria, usando os canais construídos na Fase 2.

**Pilar 9. Pitch de vendas.** Apresentar a proposta de assessoria com script estruturado e objeções mapeadas, fechando contratos recorrentes.

**Pilar 10. Prestação do serviço.** Entregar a captação como assessor, usando o método completo, e documentar resultados para renovar o contrato. A gestão da carteira (pipeline, clientes, prazos) fica no CaptaHub, não é feita "na mão".

### 1.5 Os 4 agentes, a linha de montagem da Fase 1

A Fase 1 (CAPTAR) é executada por 4 agentes especialistas, cada um responsável por uma estação da linha de montagem do projeto, sempre nesta ordem:

```
CaptaDoc     -> elegibilidade + checklist documental (Pilar 2, Requisito)
     |
CaptaBuilder -> elabora a proposta completa, bloco a bloco (Pilar 3, Projeto)
     |
CaptaBudget  -> monta o orçamento técnico por rubrica (Pilar 3, Projeto)
     |
CaptaScore   -> nota por critério, chance de aprovação e o que melhorar (Pilar 4, Submissão)
```

Não é coincidência que sejam 4 agentes: cada um trata, em ordem, um dos quatro motivos recorrentes de reprovação do item 1.6 a seguir. É por isso que o método separa em 4 estações, em vez de pedir "uma proposta boa" de uma vez só.

### 1.6 Os 4 motivos de reprovação, e quem resolve cada um

Todo projeto reprova por um (ou mais) destes quatro motivos. O método trata cada um antes do envio:

| Motivo de reprovação | Quem resolve |
|---|---|
| Edital errado (perfil não alinhado) | Mineração (Pilar 1) |
| Elegibilidade falha (documento, natureza, prazo) | Requisito (Pilar 2), agente CaptaDoc |
| Texto fraco (não responde aos critérios) | Projeto (Pilar 3), agente CaptaBuilder, e Submissão (Pilar 4), agente CaptaScore |
| Orçamento furado (teto, item vedado, glosa) | Projeto (Pilar 3), agente CaptaBudget |

### 1.7 Antes de usar qualquer comando: a OSC ativa

Este sistema atende várias OSCs ao mesmo tempo, porque a assessoria trabalha com carteira de clientes. Antes de rodar qualquer comando da tabela do item 1.9, o sistema precisa saber para qual OSC você está trabalhando: a chamada **OSC ativa**.

- Ao abrir uma nova conversa, o sistema lê automaticamente qual é a OSC ativa e mostra o estágio dos projetos em aberto.
- Para trocar de OSC: `/osc-trocar`.
- Para cadastrar uma OSC nova, ainda fora da carteira: `/osc-nova`.
- Para importar uma OSC que já existe na carteira do CaptaHub, e ainda não tem pasta local: `/osc-importar`.

**Regra prática:** se um comando de projeto (elegibilidade, proposta, orçamento) parecer estar respondendo sobre a OSC errada, o primeiro passo é conferir a OSC ativa, não desconfiar do comando.

### 1.8 Como a AMC IA conversa com você: o fluxo padrão de 6 passos

Todo comando desta apostila segue os mesmos 6 passos, sempre nesta ordem:

1. **Contexto.** O sistema lê a OSC ativa e os arquivos já existentes daquele projeto.
2. **Entrevista.** De 3 a 5 perguntas, uma de cada vez, com opções numeradas quando houver escolha.
3. **Confirmação.** O sistema resume o que vai produzir e pede seu OK antes de gerar.
4. **Geração.** O entregável é produzido, aplicando o Método Captar e as regras daquele edital específico.
5. **Aprovação.** O sistema mostra o resultado e pergunta: "1. Aprovar e salvar" ou "2. Quero ajustar algo".
6. **Entrega.** O arquivo é salvo, o sistema informa o caminho completo, e sugere o próximo comando.

Saber esse padrão evita duas surpresas comuns em quem está começando: o sistema nunca gera um documento inteiro sem antes perguntar e confirmar, e o sistema sempre informa onde salvou o arquivo, não é preciso caçar.

### 1.9 Como fazer cada etapa (o comando certo para cada pilar)

Isso vale só para quem já está trabalhando dentro da AMC IA: cada pilar da Fase 1 tem um comando específico que executa aquela etapa, e um lugar fixo onde o resultado é salvo.

| Pilar | Comando | O que produz | Onde fica salvo |
|---|---|---|---|
| 1. Mineração | `/edital-minerar` | Lista de editais priorizados por aderência ao perfil da OSC ativa | Não gera arquivo, mostra a lista na própria conversa |
| 1. Mineração (edital específico) | `/edital-analisar` | Extração de critérios, prazos e exigências de um edital colado ou em PDF | `minhas-oscs/{osc}/projetos/{edital}/edital.md` |
| 2. Requisito | `/projeto-elegibilidade` | Parecer de elegibilidade (APTO, APTO COM PENDÊNCIAS, INAPTO) e checklist documental | `minhas-oscs/{osc}/projetos/{edital}/elegibilidade.md` |
| 3. Projeto (proposta) | `/projeto-escrever` | Proposta completa, bloco a bloco | `minhas-oscs/{osc}/projetos/{edital}/proposta.md` |
| 3. Projeto (orçamento) | `/projeto-orcamento` | Orçamento técnico por rubrica, com memória de cálculo | `minhas-oscs/{osc}/projetos/{edital}/orcamento.md` |
| 4. Submissão (avaliação) | `/projeto-avaliar` | Nota por critério, chance de aprovação, reescrita dos campos críticos | `minhas-oscs/{osc}/projetos/{edital}/score.md` |
| 4. Submissão (revisão final) | `/projeto-revisar` | Checklist final pré-submissão (completude, coerência, português) | Atualiza o `estado.md` do projeto, não gera arquivo novo |
| 4. Submissão (entrega) | `/projeto-exportar` | Arquivos finais em Word, PDF e planilha, prontos para submeter | `minhas-oscs/{osc}/projetos/{edital}/entrega-final/` |

**Plano B da mineração:** quando o CaptaHub não trouxer nenhum edital alinhado ao perfil da OSC, o `/edital-minerar` aciona automaticamente o agente `minerador-web`, que busca editais abertos direto na internet, confirma o prazo na fonte oficial, e devolve os candidatos marcados como "ainda fora do CaptaHub".

As Fases 2 e 3 (POSICIONAR e ASSESSORAR) têm seus próprios comandos (`/captador-perfil`, `/captador-conteudo`, `/captador-pagina`, `/captador-anuncio`, `/assessoria-estruturar`, `/assessoria-pitch`), fora do escopo desta apostila, que trata da Fase 1 (CAPTAR).

### 1.10 A fronteira entre a AMC IA e o CaptaHub

Fica mais fácil trabalhar aqui dentro entendendo uma regra de posicionamento: **a AMC IA não compete com o CaptaHub, são produtos complementares.**

- **CaptaHub** é a plataforma de descoberta e gestão: é onde vivem os editais (o banco de dados) e a carteira (o pipeline de projetos, clientes, prazos e status). É lá que o captador descobre e gerencia.
- **AMC IA** é o estúdio de elaboração: recebe um edital e uma OSC de cada vez, e produz o projeto passando pelos 4 agentes até a entrega final.

Por isso, de propósito, **não existe kanban nem CRM dentro da AMC IA.** Se alguém pedir "gestão de carteira", "quadro de prazos de vários projetos" ou "pipeline visual" aqui dentro, a resposta certa é orientar para o CaptaHub, não tentar construir isso na conversa.

Os dados também caminham nos dois sentidos, automaticamente: o CaptaHub fornece os editais e a carteira de clientes; a AMC IA sobe de volta o que produz aqui (cliente novo cadastrado, projeto criado, valor solicitado, nota técnica, mudança de estágio), sempre anunciando em uma linha o que foi sincronizado. A base local de editais (`base-editais/`) é só um cache do CaptaHub, usada como reserva se a conexão cair, nunca a fonte principal.

### 1.11 Ambientes externos que o captador precisa consultar

Além do CaptaHub (item 1.10), alguns pilares dependem de consultar sistemas de fora. Esta tabela deve ser completada com os links reais usados pela equipe, porque endereços mudam e variam por financiador.

| Ambiente | Para que serve | Link |
|---|---|---|
| Portal do Captador | Comunidade e curso de origem do Método Captar 2.0 | a preencher |
| Diário Oficial (municipal, estadual, federal) | Mineração manual quando o CaptaHub não traz edital alinhado ao perfil da OSC | a preencher, varia por município/estado |
| Transferegov (gov.br) | Cadastro obrigatório da OSC para captar recursos federais via termo de fomento ou colaboração (MROSC) | a preencher |
| SALIC (Sistema de Apoio às Leis de Incentivo à Cultura) | Editais e patrocínios de incentivo cultural (Lei Rouanet), acompanhamento de aprovação e comprovantes | a preencher |
| Sites e formulários próprios de cada financiador | Cada financiador (fundações, institutos, empresas) costuma ter seu próprio formulário de submissão fora do CaptaHub, como visto no caso da FSA e da CESE | um link por financiador, anotar no `edital.md` do projeto quando existir |
| Google Drive da OSC | Documentos institucionais, portfólio, comprovantes e histórico de ações já realizadas pela organização | um link por OSC, anotar no `perfil-osc.md` |

**Observação de escopo:** o CaptaHub é o único ambiente externo que faz parte do fluxo automático da AMC IA (editais puxados automaticamente por `/captahub-conectar` e `/edital-minerar`). Os demais são consultados manualmente pelo captador, quando o CaptaHub não cobre o que se precisa.

### 1.12 Checklist de aprendizado da Parte 1

- [ ] Sabe explicar, em uma frase, o que é o Método Captar e de onde ele vem.
- [ ] Consegue listar as 3 fases e nomear os 10 pilares, mesmo sem decorar a ordem exata dentro de cada fase.
- [ ] Sabe explicar o Gate de Elegibilidade e por que ele existe.
- [ ] Sabe nomear os 4 agentes, em ordem, e o que cada um produz.
- [ ] Consegue relacionar cada um dos 4 motivos de reprovação ao pilar e ao agente que o resolve.
- [ ] Sabe por que é preciso conferir a OSC ativa antes de rodar qualquer comando de projeto.
- [ ] Consegue descrever, em ordem, os 6 passos que todo comando segue.
- [ ] Sabe qual comando da AMC IA corresponde a cada pilar da Fase 1, e onde cada entrega é salva.
- [ ] Sabe explicar a fronteira entre a AMC IA e o CaptaHub, e por que não existe kanban aqui dentro.
- [ ] Sabe listar pelo menos 3 ambientes externos que pode precisar consultar, além do CaptaHub.

---

## PARTE 2. Tipos de Editais, Áreas e Análise de Requisitos

### 2.1 Tipos de editais

Nem todo edital funciona do mesmo jeito. Antes de mexer em qualquer proposta, é preciso identificar qual tipo de edital está na mesa, porque isso muda o instrumento jurídico, a forma de submissão e até a lógica de captação.

**Pelo instrumento jurídico:**

- **Chamamento público (MROSC, Lei 13.019/2014).** É o formato mais comum quando o financiador é poder público. Resulta em um dos três instrumentos:
  - **Termo de fomento.** O plano de trabalho é proposto pela própria OSC (iniciativa da organização).
  - **Termo de colaboração.** O plano de trabalho é proposto pela administração pública (iniciativa do órgão).
  - **Acordo de cooperação.** Parceria sem transferência de recursos financeiros.
- **Edital de fundação, instituto ou empresa privada.** Não segue o MROSC. Cada financiador cria suas próprias regras, formulário e sistema de submissão (foi o caso da Fundação Salvador Arena e da CESE, por exemplo).
- **Lei de incentivo fiscal.** Lógica diferente de edital direto: o projeto é aprovado num sistema oficial e a OSC capta recurso junto a patrocinadores que abatem o valor do imposto devido. Principais leis: Lei Rouanet (cultura, via sistema do Ministério da Cultura), Lei de Incentivo ao Esporte, Lei de Incentivo à Saúde (PRONAS/PRONON), Fundos da Infância e Adolescência (FIA) e do Idoso.

**Pela janela de inscrição:**

- **Fluxo contínuo.** Recebe propostas o ano todo, sem data de fechamento.
- **Janela fechada.** Tem data de abertura e de encerramento das inscrições, como qualquer edital tradicional.

**Pelo escopo geográfico:** municipal, estadual, nacional ou internacional. Isso decide, antes de qualquer outra análise, se a OSC sequer pode concorrer (muitos editais exigem sede ou atuação comprovada dentro do território do escopo).

### 2.2 Quais são as áreas temáticas

As áreas mais comuns encontradas nos editais que a AMC IA atende são: assistência social, educação, cultura, esporte, meio ambiente, direitos humanos, saúde e tecnologia/inclusão digital. Um mesmo edital pode declarar mais de uma área, e a categoria declarada no edital é o primeiro filtro da mineração, porque uma OSC de cultura não deve gastar tempo analisando um edital fechado para saúde, mesmo que o valor seja atrativo.

**Como isso aparece na prática (CaptaHub):** todo edital cadastrado traz o campo "Categoria", usado como filtro de mineração junto com escopo, valor e prazo (ver Apostila de Treinamento do CaptaHub, Módulo 3).

### 2.3 Como é feita a análise dos requisitos exigidos

A análise dos requisitos exigidos é a leitura estruturada do edital, sempre nesta ordem, porque cada item elimina candidatos antes do próximo:

1. **Objeto.** O que o edital quer financiar, especificamente.
2. **Quem pode participar.** Natureza jurídica, tempo de existência, território, área de atuação exigida.
3. **Habilitação.** A lista de documentos obrigatórios para comprovar o item anterior.
4. **Recursos.** Teto total, teto por item ou rubrica, percentuais máximos permitidos (por exemplo, limite de gasto com pessoal ou despesa administrativa), exigência de contrapartida.
5. **Despesas vedadas.** O que não pode, em hipótese alguma, ser pago com aquele recurso.
6. **Critérios de seleção.** Os itens que a banca vai pontuar, e os pesos, quando o edital os divulga.
7. **Prazos.** Data e hora exatas da submissão, vigência do projeto, e todo o cronograma do processo seletivo (pré-seleção, documentação, resultado, repasse).
8. **Forma de submissão.** Qual plataforma, quais anexos são aceitos, se existe formulário oficial próprio do financiador.

**Como fazer isso na AMC IA:** o comando `/edital-analisar` executa esse roteiro de extração sobre um edital colado, em PDF ou por link, e devolve os oito pontos organizados, junto com o que mais pontua e o que desclassifica automaticamente.

### 2.4 Como é feita a análise das organizações que podem participar

Depois de saber o que o edital pede (2.3), o próximo passo é cruzar isso com o perfil real da OSC. Essa é a checagem de elegibilidade, protegida pelo Gate de Elegibilidade (ver Parte 1, item 1.2): nunca se escreve proposta antes de fazer essa checagem.

**O que se cruza:**

- **Natureza jurídica.** Associação, fundação, OSCIP (que não é natureza jurídica, é uma qualificação concedida pelo Ministério da Justiça a quem cumpre a Lei 9.790/1999), organização religiosa ou cooperativa social, conforme o que o edital aceita.
- **Tempo de existência.** Muitos editais exigem um mínimo de 1, 2 ou 3 anos de CNPJ ativo.
- **Finalidade estatutária.** O estatuto da OSC precisa ser compatível com o objeto do edital, não basta a organização "fazer" aquele tipo de atividade na prática, se o estatuto não prevê.
- **Território de atuação.** Se o edital exige atuação comprovada dentro de um município, estado ou região.
- **Documentos de habilitação em dia.** CNPJ ativo, estatuto social registrado, ata de eleição da diretoria vigente, certidões negativas (federal, estadual, municipal), regularidade do FGTS (CRF), certidão trabalhista (CNDT), inscrição em conselho (CMAS, CMDCA) quando exigido, CEBAS quando aplicável, conta bancária específica, e cadastro no Transferegov para editais federais.

**O resultado dessa análise:** um veredito, sempre um destes três: **APTO** (segue direto para a elaboração), **APTO COM PENDÊNCIAS** (pode elaborar em paralelo, mas a submissão depende de regularizar o que falta) ou **INAPTO NO MOMENTO** (não avança, mostra o que precisa ser resolvido antes).

**Como fazer isso na AMC IA:** o comando `/projeto-elegibilidade` (agente CaptaDoc) executa essa análise, cruzando o `edital.md` com o `perfil-osc.md` da OSC ativa, e devolve o parecer com o veredito e o checklist documental.

### 2.5 Glossário complementar

| Termo | O que significa |
|---|---|
| Chamamento público | Processo de seleção formal usado pela administração pública para escolher OSCs parceiras, previsto no MROSC. |
| Habilitação / inabilitação | Fase eliminatória, puramente documental, dentro do processo seletivo. |
| Parecerista | Pessoa (ou banca) responsável por avaliar e pontuar o projeto. |
| Glosa | Despesa não aceita na prestação de contas, com exigência de devolução do valor. |
| Contrapartida | Aporte próprio da OSC, financeiro ou não financeiro, exigido ou valorizado pelo edital. |
| Rubrica | Categoria de despesa dentro do orçamento (por exemplo, pessoal, material de consumo, equipamento). Detalhada na Parte 3, item 3.5. |

### 2.6 Checklist de aprendizado da Parte 2

- [ ] Sabe diferenciar chamamento público (MROSC), edital de financiador privado e lei de incentivo fiscal.
- [ ] Sabe explicar a diferença entre termo de fomento, termo de colaboração e acordo de cooperação.
- [ ] Consegue citar pelo menos 5 áreas temáticas comuns nos editais atendidos pela AMC IA.
- [ ] Consegue listar, em ordem, os 8 pontos do roteiro de análise de requisitos de um edital.
- [ ] Sabe quais informações da OSC são cruzadas na análise de elegibilidade.
- [ ] Sabe os três vereditos possíveis da elegibilidade e o que cada um libera ou trava.
- [ ] Sabe quais comandos da AMC IA executam a análise do edital e a análise de elegibilidade.

---

## PARTE 3. Projetos: o que são e como construir

### 3.1 O que é um projeto

Dentro do trabalho de captação, "projeto" tem dois sentidos que precisam ficar claros, para não confundir:

- **No pipeline (CaptaHub):** projeto é o cartão que nasce quando uma OSC se candidata a um edital, acompanhado estágio a estágio até o resultado (ver Apostila de Treinamento do CaptaHub, Bloco 3).
- **Como documento (esta parte da apostila):** projeto é a proposta escrita que a OSC apresenta ao financiador, respondendo ponto a ponto ao que o edital pede. É o documento que o parecerista lê e pontua.

Esta Parte 3 trata do segundo sentido: como construir o documento do projeto.

**Definição prática:** um projeto é uma resposta estruturada e mensurável ao edital, que explica um problema real, propõe uma solução concreta, com metas verificáveis, dentro do prazo e do valor permitidos, e mostra que a OSC tem capacidade de executar o que promete.

### 3.2 Como construir um projeto (os princípios antes da estrutura)

Antes de olhar para o sumário, seis princípios guiam a escrita de qualquer seção:

1. **Tudo nasce do edital.** Cada seção do projeto responde a um critério do edital. Releia o edital e confira se cada seção tem cobertura.
2. **Coerência interna.** Objetivo geral, objetivos específicos, metas, metodologia, cronograma e orçamento contam a mesma história. Teste rápido: cada objetivo específico tem meta, atividade no cronograma e item no orçamento correspondentes?
3. **Mensurável sempre.** Troque "fortalecer", "promover" e "contribuir" por números e prazos.
4. **Dado, não adjetivo.** "Comunidade vulnerável" não pontua. "Bairro com IDH 0,5 e 38% de evasão escolar no ensino médio" pontua.
5. **Linguagem técnica e formal.** Sem travessão. Termos do próprio edital usados com precisão (termo de fomento, rubrica, contrapartida, meta, indicador).
6. **Maximize o que pontua.** Descubra os pesos no edital e invista mais texto e evidência nos critérios de maior peso.

### 3.3 O sumário completo do projeto, seção a seção

Esta é a estrutura padrão. Quando o edital fornecer um formulário oficial próprio (como visto nos casos da FSA e da CESE), adapte a esta estrutura, mas sem pular nenhum conteúdo, só reorganizando onde ele entra.

| Seção | O que deve conter |
|---|---|
| Título | Claro e específico, conecta problema e solução. Evite título genérico. Segue o formato do edital, quando ele define um. |
| Resumo executivo | Em um parágrafo: o que é, para quem, onde, por quanto tempo, qual resultado. É a primeira coisa que o parecerista lê. |
| Justificativa e problema central | O coração da nota. Problema apresentado com dado real do território e do público (estatística, diagnóstico, fonte), explicando por que o problema existe e por que esta OSC é a indicada para resolvê-lo, conectado ao objeto do edital. |
| Objetivo geral | Uma frase, verbo no infinitivo, o resultado maior que o projeto persegue, alinhado ao objeto do edital. |
| Objetivos específicos | De 3 a 5, cada um desdobrando o objetivo geral em frentes concretas. Cada um vai gerar meta, atividade e item de orçamento próprios. |
| Público-alvo | Quem, quantos, onde, com que critério de seleção. Direto e dimensionado, sem vaguidão. |
| Metas e indicadores | Toda meta mensurável: quantos, quando, onde, como será verificada. Cada meta com um indicador (o que mede) e um meio de verificação (lista de presença, relatório, registro). |
| Metodologia | Como o projeto será executado, passo a passo, coerente com objetivos e metas. Quem faz, como faz. |
| Cronograma | Distribuição das atividades por mês ou etapa, dentro da vigência permitida pelo edital. Cada atividade da metodologia aparece aqui. |
| Equipe e responsabilidades | Funções, qualificação e carga horária de cada pessoa envolvida. Mostra capacidade técnica, critério comum de pontuação. |
| Monitoramento e avaliação | Como o projeto acompanha os indicadores e corrige rota. Quem monitora, com que frequência, com que instrumento. |
| Resultados esperados | O que muda na vida do público ao fim do projeto. Conecta as metas ao impacto. |
| Sustentabilidade | Como a iniciativa continua depois do recurso acabar. Critério valorizado pela maioria dos editais. |
| Contrapartida | O que a OSC aporta, financeiro ou não financeiro, quando exigido ou valorizado pelo edital. |
| Diferenciais competitivos | Por que este projeto e esta OSC, frente aos concorrentes do edital. |
| Riscos e mitigação | Principais riscos de execução e o que será feito para reduzi-los. Mostra maturidade de planejamento. |

**Exemplo de meta bem escrita:** "Atender 120 adolescentes de 12 a 17 anos do bairro X em oficinas de música ao longo de 10 meses, com frequência média de 70%, verificada por lista de presença." Repare: quantos (120), quem (adolescentes de 12 a 17 anos), onde (bairro X), o quê (oficinas de música), quanto tempo (10 meses), como verifica (lista de presença, frequência de 70%).

### 3.4 Erros que derrubam nota

- Meta sem indicador.
- Atividade sem orçamento correspondente (ou item de orçamento sem atividade que o justifique).
- Justificativa sem dado real, só adjetivo.
- Metodologia genérica, que serviria para qualquer projeto, de qualquer OSC.
- Objetivos que não se conectam ao objeto do edital.
- Sustentabilidade ausente ou tratada como detalhe secundário.
- Texto que vende a OSC (institucional, autoelogioso) em vez de focar em resolver o problema do público-alvo.

### 3.5 Orçamento técnico, em profundidade (CaptaBudget)

O orçamento nasce do mesmo projeto: cada item existe porque uma atividade da metodologia precisa dele. É o motivo do segundo erro que derruba nota, "atividade sem orçamento correspondente" (item 3.4), e do motivo de reprovação "orçamento furado" (Parte 1, item 1.6).

**Rubricas comuns (categorias de despesa):**

| Rubrica | O que cobre |
|---|---|
| Pessoal e encargos | Equipe contratada para o projeto, com encargos. Muitos editais limitam o percentual de pessoal. |
| Serviços de terceiros (pessoa física) | Prestadores autônomos (oficineiros, consultores), com recolhimento devido. |
| Serviços de terceiros (pessoa jurídica) | Empresas contratadas (gráfica, transporte, contabilidade). |
| Material de consumo | Itens que se esgotam no uso (papel, material pedagógico, alimentação). |
| Material permanente e equipamento | Bens duráveis (computador, instrumento, mobiliário). Vários editais vedam ou limitam. |
| Diárias e passagens | Deslocamento da equipe, conforme tabela. |
| Despesas administrativas | Custos indiretos (água, luz, internet, taxa de administração). Quase sempre com teto percentual. |
| Contrapartida | Aporte da OSC, se exigido. |

**Memória de cálculo.** Toda linha do orçamento precisa explicar como o valor foi obtido, no formato: item, unidade, quantidade, valor unitário, valor total, memória de cálculo, justificativa.

Exemplo: "Oficineiro de música. 1 profissional x 8h/semana x 4 semanas x 10 meses x R$ 50,00/h = R$ 16.000,00. Justificativa: conduz as oficinas da Meta 1." Valor "no chute" é a porta de entrada da glosa. Use referências de preço estáveis: tabelas oficiais, cotações formais com CNPJ, mediana de 3 orçamentos. Evite marketplace, promoção e preço volátil.

**Regras a verificar no edital, sempre:**

1. **Teto total.** O orçamento não pode passar do valor máximo.
2. **Teto por categoria.** Percentual máximo de pessoal, de administrativo, de equipamento.
3. **Despesas vedadas.** O que o edital proíbe pagar (taxas bancárias, multas, obras, despesas anteriores à vigência, etc.).
4. **Exigência de 3 cotações.** Itens acima de certo valor precisam de três orçamentos anexados.
5. **Contrapartida.** Percentual e forma exigidos.
6. **Vigência.** Despesa só dentro do período de execução.

**Coerência projeto x orçamento, regra dura:** nenhuma atividade sem item de orçamento, nenhum item de orçamento sem atividade. Percorra as metas e atividades da proposta e confirme que cada uma tem custo previsto, e que cada custo serve a uma atividade. O CaptaScore e a banca cruzam isto.

**Cronograma de desembolso:** distribua os valores ao longo dos meses ou etapas, conforme a execução. Financiadores liberam por parcelas atreladas a metas.

**Glosa, o que evitar.** Glosa é a despesa rejeitada na prestação de contas, que vira devolução do valor. Causas comuns: item fora do aprovado, falta de 3 cotações, comprovante irregular, gasto fora da vigência, item vedado, valor acima do mercado.

**Padrão de valores:** sempre em reais, no formato R$ 1.234,56 (ponto de milhar, vírgula decimal).

### 3.6 Avaliação e chance de aprovação, em profundidade (CaptaScore)

Antes de submeter, o projeto passa por uma auditoria com visão de banca, não de quem escreveu. O objetivo é dizer a chance antes de enviar, e mostrar o que melhorar.

**As 3 fases de seleção, cada uma com uma lógica de chance diferente:**

| Fase | O que decide | Como a chance se comporta |
|---|---|---|
| Eliminatória (habilitação) | Documental e formal. Falta de documento, formato errado ou prazo perdido elimina antes do mérito. | Binária: habilitado ou não. |
| Técnica (mérito) | Nota por critério, dada pelos pareceristas. | É onde a qualidade da proposta decide. |
| Contemplação final | Concorrência por nota, frente ao recurso disponível do edital. | Mesmo com nota boa, pode não haver verba para todos; depende do número de vagas e do valor total do edital. |

**Critérios de pontuação.** Se o edital traz critérios e pesos próprios, o CaptaScore usa exatamente esses. Quando o edital não especifica, usa o conjunto padrão:

| Critério | O que avalia |
|---|---|
| Aderência ao edital | Quanto a proposta responde ao objeto e às exigências |
| Capacidade técnica | Experiência e qualificação da OSC e da equipe |
| Potencial de impacto | Relevância e alcance do resultado |
| Coerência metodológica | Metodologia consistente com objetivos e metas |
| Clareza de objetivos | Objetivos e metas claros e mensuráveis |
| Orçamento | Coerência, realismo e conformidade com o edital |
| Cronograma | Exequibilidade no prazo |
| Inovação | Diferencial frente ao convencional |
| Sustentabilidade | Continuidade após o recurso |

**Riscos de desclassificação, sempre checados:** documento de habilitação ausente ou vencido; orçamento acima do teto ou com item vedado; meta sem indicador ou sem meio de verificação; vigência ou cronograma incompatível com o edital; formulário oficial não preenchido conforme exigido; prazo de submissão.

**Inconsistências internas, sempre checadas:** objetivo específico sem meta; meta sem atividade; atividade sem orçamento; orçamento com item que não aparece na metodologia; valores do resumo diferentes do orçamento detalhado; público-alvo que muda de número entre seções.

**A reescrita "nota 9,5".** Para os 2 a 4 campos de menor nota e maior peso, o CaptaScore entrega uma versão reescrita pronta para colar, mostrando o antes e o depois. É aqui que mais agrega: não só aponta o problema, corrige.

**O veredito final,** sempre um destes três: **pronto para submeter**, **ajustar antes de submeter** (com a lista priorizada do que corrigir) ou **risco alto** (quando há um impedimento eliminatório ainda não resolvido).

### 3.7 Como fazer isso na AMC IA

| Etapa | Comando | Observação |
|---|---|---|
| Escrever o projeto completo (todas as seções do item 3.3, exceto orçamento) | `/projeto-escrever` | Agente CaptaBuilder. Só roda depois do Gate de Elegibilidade (Parte 1 e 2 desta apostila). Conduz a coleta bloco a bloco. |
| Montar o orçamento por rubrica | `/projeto-orcamento` | Agente CaptaBudget. Aplica os princípios do item 3.5. |
| Avaliar o projeto pronto, antes de submeter | `/projeto-avaliar` | Agente CaptaScore. Aplica os princípios do item 3.6. |

### 3.8 Checklist de aprendizado da Parte 3

- [ ] Sabe diferenciar os dois sentidos de "projeto" (cartão do pipeline x documento da proposta).
- [ ] Consegue recitar os 6 princípios de construção de um projeto, sem olhar a lista.
- [ ] Consegue listar, em ordem, as 16 seções do sumário completo de um projeto.
- [ ] Para cada seção, sabe dizer em uma frase o que ela precisa conter.
- [ ] Sabe montar uma meta mensurável (quantos, quem, onde, quando, como verifica), sem cair em promessa vaga.
- [ ] Consegue citar, de cabeça, pelo menos 4 dos 7 erros que derrubam nota.
- [ ] Sabe listar as 8 rubricas comuns de orçamento e o que cada uma cobre.
- [ ] Sabe montar uma linha de orçamento com memória de cálculo completa (item, unidade, quantidade, valor unitário, total, memória, justificativa).
- [ ] Consegue citar pelo menos 3 causas comuns de glosa.
- [ ] Sabe explicar as 3 fases de seleção e como a chance de aprovação se comporta em cada uma.
- [ ] Consegue listar os 9 critérios de pontuação padrão, usados quando o edital não traz os seus próprios.
- [ ] Sabe os três vereditos possíveis de uma avaliação (pronto para submeter, ajustar antes, risco alto).
- [ ] Sabe qual comando da AMC IA escreve o projeto, qual monta o orçamento e qual avalia o projeto pronto.

---

*Esta apostila cobre, de ponta a ponta, a Fase 1 do Método Captar (Mineração, Requisito, Projeto e Submissão), incluindo os 4 agentes, o sumário completo do projeto, o orçamento técnico e a avaliação de chance de aprovação. As Fases 2 e 3 (POSICIONAR e ASSESSORAR) têm seus próprios comandos, citados no item 1.9, e podem ganhar uma continuação desta apostila se for necessário no futuro.*
