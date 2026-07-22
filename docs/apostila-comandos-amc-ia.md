# Apostila de Comandos. AMC IA

> Guia de referência de todos os comandos, agentes e áreas de trabalho da AMC IA. Use para saber, na hora da dúvida, qual comando digitar para cada situação.

**Como usar esta apostila:**

Os comandos estão organizados pelas mesmas fases do Método Captar 2.0: primeiro **CAPTAR** (o dia a dia técnico com um edital e uma OSC), depois **POSICIONAR** (o marketing do captador como negócio) e **ASSESSORAR** (a venda e a prestação do serviço). No fim, uma área de **Apoio e Sistema** reúne o que dá suporte a tudo isso. Cada comando tem: para que serve, quando usar, o que ele pede e o que ele entrega.

---

## Antes de tudo. Como o sistema pensa

A AMC IA sempre trabalha em cima de duas coisas: **uma OSC ativa** e, dentro dela, **um projeto** (um edital sendo trabalhado). Quase todo comando começa lendo `minhas-oscs/.ativa` para saber qual organização está em foco.

```
CaptaHub (fonte da verdade: editais + carteira + pipeline)
        ↓ puxa
    AMC IA (estúdio de elaboração)
        ↓
  OSC ativa → Projeto (edital) → os 4 agentes → entrega pronta para submeter
```

O CaptaHub não compete com a AMC IA: ele é de onde vêm os editais e onde mora a carteira de clientes. A AMC IA é a bancada de trabalho onde um edital vira um projeto aprovado.

---

## Área 1. Organização (a OSC)

Cadastro e gestão da organização atendida. Todo o resto do sistema depende de existir uma OSC ativa.

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/osc-nova` | Cadastra uma OSC nova (dados cadastrais, natureza jurídica, área de atuação, território, documentos) e a define como ativa. | Primeira vez que vai trabalhar com aquela organização, e ela não está na carteira do CaptaHub. |
| `/osc-importar` | Traz uma OSC que já existe na carteira do CaptaHub para dentro da AMC IA, criando o perfil local. | A organização já está cadastrada no CaptaHub, só falta trazer para cá. |
| `/osc-trocar` | Mostra a carteira completa (CaptaHub + local) e troca qual OSC está ativa. | Vai atender outro cliente na mesma sessão. |
| `/osc-perfil` | Mostra e atualiza o perfil da OSC ativa: dados cadastrais, documentos, capacidade técnica. | Precisa checar ou corrigir um dado da organização, ou marcar documento obtido/vencido. |

---

## Área 2. Editais

Descoberta e leitura de oportunidades. Os editais sempre vêm do CaptaHub; a base local é só um cache de apoio.

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/edital-minerar` | Puxa os editais do CaptaHub e lista os mais aderentes ao perfil da OSC ativa (escopo, valor, prazo, área). | Está procurando qual edital vale a pena para a OSC ativa. |
| `/edital-analisar` | Lê um edital inteiro (PDF, link ou texto colado) e extrai critérios, prazos, exigências, o que pontua e o que derruba nota. | Já escolheu o edital e precisa entender a fundo antes de qualquer outra etapa. É a entrada de dados dos 4 agentes. |

---

## Área 3. Projeto. Os 4 agentes (o coração do sistema)

A linha de montagem que transforma um edital analisado em um projeto pronto para submeter. Segue sempre esta ordem, protegida pelo **Gate de Elegibilidade**: nunca se escreve proposta sem elegibilidade verificada primeiro.

```
CaptaDoc → CaptaBuilder → CaptaBudget → CaptaScore
```

| Comando | Agente | Para que serve | Quando usar |
|---|---|---|---|
| `/projeto-elegibilidade` | CaptaDoc | Cruza o edital com o perfil da OSC e dá o veredito: APTO, APTO COM PENDÊNCIAS ou INAPTO NO MOMENTO, com checklist documental. | Sempre o primeiro passo depois de `/edital-analisar`. Nenhuma proposta começa sem isso. |
| `/projeto-escrever` | CaptaBuilder | Conduz a entrevista por blocos (justificativa, objetivos, metas, metodologia, cronograma etc.) e escreve a proposta completa, ancorada nos critérios do edital. | Depois da elegibilidade confirmada (APTO ou APTO COM PENDÊNCIAS). |
| `/projeto-orcamento` | CaptaBudget | Monta o orçamento técnico por rubrica, com memória de cálculo, dentro do teto e das regras financeiras do edital. | Depois que a proposta existe: o orçamento nasce das atividades descritas nela. |
| `/projeto-avaliar` | CaptaScore | Dá nota de 0 a 10 por critério, estima a chance de aprovação por fase e reescreve os campos mais críticos. | Proposta e orçamento prontos, antes de revisar e submeter. É a auditoria com visão de banca. |
| `/projeto-revisar` | revisor-proposta | Checklist final: completude, coerência interna, conformidade com o formulário oficial e revisão de português. | Último passo antes de exportar e submeter. |
| `/projeto-exportar` | — | Gera a entrega final em Word, PDF e planilha, prontos para anexar na plataforma de submissão. | Projeto revisado e aprovado, hora de gerar os arquivos finais. |

---

## Área 4. CaptaHub (conexão e sincronização)

Comandos de integração entre a AMC IA e a plataforma que centraliza editais, carteira e pipeline.

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/captahub-conectar` | Conecta a AMC IA ao CaptaHub (token de API no `.env`) para puxar editais e carteira ao vivo. | Primeira configuração, ou se a conexão parou de funcionar. |
| `/captahub-sincronizar` | Reconcilia carteira e pipeline nos dois sentidos: puxa atualizações do CaptaHub e sobe o que existe só localmente (OSC nova, status de projeto). | Ao abrir a sessão, ao terminar uma etapa importante, ou quando quer garantir que tudo está espelhado. |

---

## Área 5. Marketing do captador (Fase 2. POSICIONAR)

> Diferente da Área 1 a 4: aqui o contexto não é uma OSC, é o próprio captador como negócio (`captador/perfil-captador.md`). O público é o gestor de OSC que pode contratar a assessoria.

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/captador-perfil` | Cadastra ou atualiza o perfil do captador e da marca da assessoria: quem é, especialidade, público, diferenciais. | Antes de qualquer outro comando desta área. Sem perfil, o conteúdo sai genérico. |
| `/captador-conteudo` | Gera conteúdo de autoridade (carrossel, post de texto ou roteiro de reel) para atrair OSCs nas redes. | Quer publicar algo esta semana para se posicionar como referência em captação. |
| `/captador-pagina` | Gera a página de captura de leads da assessoria: copy completa mais HTML de arquivo único. | Precisa de um link para direcionar tráfego (bio, anúncio, indicação). |
| `/captador-anuncio` | Gera anúncios (copy e direção de criativo) para levar gestores de OSC até a página ou o diagnóstico. | Vai investir em tráfego pago ou impulsionamento. |

---

## Área 6. Venda e prestação do serviço (Fase 2 e 3. OFERTA e ASSESSORAR)

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/assessoria-estruturar` | Estrutura o serviço de assessoria: escopo, pacotes, precificação, e gera a proposta comercial. | Antes de sair vendendo: precisa decidir o que está oferecendo e por quanto. |
| `/assessoria-pitch` | Gera o playbook de venda do contrato anual de assessoria para uma OSC específica, com script e objeções mapeadas. | Vai ter uma reunião de fechamento com uma organização prospectada. |

---

## Área 7. Apoio e sistema

| Comando | Para que serve | Quando usar |
|---|---|---|
| `/configurar` | Centraliza conexões e integrações: CaptaHub, atualização de editais, geração de imagens (opcional). | Configuração inicial do projeto ou ajuste de alguma integração. |
| `/sala-agentes` | Abre a Sala dos Agentes: um escritório visual em pixel art que mostra em tempo real qual agente está trabalhando e em que etapa. | Quer acompanhar visualmente o sistema em ação, ou mostrar para alguém como funciona. |

---

## Área 8. Agentes especialistas (por trás dos comandos)

Os comandos acima acionam agentes especializados. Normalmente você não invoca um agente diretamente, mas é útil saber quem faz o quê:

| Agente | Acionado por | O que faz |
|---|---|---|
| **CaptaDoc** (`captador-doc`) | `/projeto-elegibilidade` | Triagem documental e elegibilidade. Guardião do Gate de Elegibilidade. |
| **CaptaBuilder** (`captador-builder`) | `/projeto-escrever` | Elaboração estratégica da proposta, bloco a bloco. |
| **CaptaBudget** (`captador-budget`) | `/projeto-orcamento` | Orçamento técnico por rubrica, com memória de cálculo e pesquisa de preço quando o edital exige. |
| **CaptaScore** (`captador-score`) | `/projeto-avaliar` | Avaliação com visão de banca: nota, chance de aprovação, reescrita dos campos críticos. |
| **revisor-proposta** | `/projeto-revisar` | Revisão final de completude, coerência e português antes da submissão. |
| **minerador-editais** | `/edital-minerar` | Puxa e prioriza editais do CaptaHub conforme o perfil da OSC. |
| **minerador-web** | Fallback automático de `/edital-minerar` | Busca editais na web quando o CaptaHub não traz nada alinhado ao perfil. |
| **posicionador-captador** | `/captador-conteudo`, `/captador-pagina`, `/captador-anuncio` | Marketing e posicionamento do captador como negócio. |
| **orquestrador-captacao** | Uso interno | Diagnostica em que etapa da linha de montagem o captador está e direciona para o comando certo. |

---

## Área 9. Bases de conhecimento (skills consultadas pelos agentes)

Não são comandos, mas fundamentam as respostas dos agentes. Cite-as se quiser entender de onde vem um critério ou uma regra:

| Base de conhecimento | Consultada por | Conteúdo |
|---|---|---|
| `editais-fundamentos` | `/edital-analisar`, CaptaDoc | MROSC, tipos de parceria, naturezas jurídicas, plataformas de submissão, leis de incentivo. |
| `elaboracao-proposta` | CaptaBuilder | Estrutura de proposta seção a seção, como construir objetivos, metas, indicadores, metodologia e cronograma. |
| `orcamento-tecnico` | CaptaBudget | Rubricas, memória de cálculo, regras de teto e percentual, despesas vedadas, 3 cotações, glosa. |
| `avaliacao-projeto` | CaptaScore | Critérios de pontuação, fases de seleção, riscos de desclassificação, como estimar chance de aprovação. |
| `posicionamento-captador` | posicionador-captador | Público da assessoria, ângulos de conteúdo, precificação da oferta, Light Copy adaptada à captação. |

---

## Fluxo completo de um projeto, do zero à submissão

Para visualizar a jornada inteira, do primeiro contato com a OSC até o arquivo pronto para enviar:

```
1.  /osc-nova (ou /osc-importar)      → cadastra ou importa a organização
2.  /edital-minerar                   → encontra o edital certo
3.  /edital-analisar                  → entende o edital a fundo
4.  /projeto-elegibilidade            → CaptaDoc dá o veredito (Gate de Elegibilidade)
5.  /projeto-escrever                 → CaptaBuilder escreve a proposta
6.  /projeto-orcamento                → CaptaBudget monta o orçamento
7.  /projeto-avaliar                  → CaptaScore dá a nota e a chance de aprovação
8.  /projeto-revisar                  → checklist final pré-submissão
9.  /projeto-exportar                 → gera Word, PDF e planilha
10. (no CaptaHub) atualizar o status do projeto para "submetido"
```

Em paralelo, sempre que fizer sentido: `/captahub-sincronizar` para manter a carteira e o pipeline espelhados.

---

## Perguntas rápidas. "Quero fazer X, qual comando uso?"

| Eu quero... | Comando |
|---|---|
| Cadastrar uma organização nova | `/osc-nova` |
| Trazer uma OSC que já está no CaptaHub | `/osc-importar` |
| Trabalhar com outro cliente agora | `/osc-trocar` |
| Ver ou corrigir os dados da organização | `/osc-perfil` |
| Achar um edital bom para a OSC ativa | `/edital-minerar` |
| Entender um edital específico a fundo | `/edital-analisar` |
| Saber se a OSC pode concorrer a este edital | `/projeto-elegibilidade` |
| Escrever a proposta do projeto | `/projeto-escrever` |
| Montar o orçamento do projeto | `/projeto-orcamento` |
| Saber a chance de aprovação antes de enviar | `/projeto-avaliar` |
| Fazer a checagem final antes de submeter | `/projeto-revisar` |
| Gerar os arquivos finais (Word, PDF, planilha) | `/projeto-exportar` |
| Conectar ou reconectar ao CaptaHub | `/captahub-conectar` |
| Colocar tudo em dia com o CaptaHub | `/captahub-sincronizar` |
| Cadastrar meu perfil como captador | `/captador-perfil` |
| Criar um post ou carrossel para atrair clientes | `/captador-conteudo` |
| Gerar minha página de captação de leads | `/captador-pagina` |
| Criar um anúncio para tráfego pago | `/captador-anuncio` |
| Definir pacotes e preços da assessoria | `/assessoria-estruturar` |
| Preparar o discurso de venda para uma OSC | `/assessoria-pitch` |
| Configurar integrações do projeto | `/configurar` |
| Ver os agentes trabalhando visualmente | `/sala-agentes` |

---

## O que NÃO existe aqui (e onde procurar)

A AMC IA não tem pipeline, kanban nem CRM. Gestão de carteira, prazos de vários projetos e status de clientes ficam **sempre no CaptaHub**. Se a dúvida for "em que pé está cada projeto" ou "quais clientes tenho no total", a resposta está lá, não em um comando desta apostila.
